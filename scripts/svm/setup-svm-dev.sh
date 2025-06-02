#!/bin/bash
set -e

# SVM Development Environment Setup Script
# Quickly sets up a complete SVM development environment

echo "🛠️  Setting up SVM development environment..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install with error handling
safe_install() {
    local cmd="$1"
    local name="$2"
    echo "Installing $name..."
    if eval "$cmd"; then
        echo "✅ $name installed successfully"
    else
        echo "⚠️  $name installation failed, continuing..."
    fi
}

# Ensure we're in the right directory
cd "$(dirname "$0")/../.."

# Source Rust environment if available
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Add Solana to PATH if installed
if [ -d "$HOME/.local/share/solana/install/active_release/bin" ]; then
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
fi

echo "📦 Installing core SVM development tools..."

# Install Solana CLI if not present
if ! command_exists solana; then
    echo "Installing Solana CLI..."
    sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
fi

# Install Anchor
if ! command_exists anchor; then
    safe_install "cargo install --git https://github.com/coral-xyz/anchor anchor-cli --locked" "Anchor CLI"
fi

# Install AVM (Anchor Version Manager)
safe_install "cargo install --git https://github.com/coral-xyz/anchor avm --locked" "AVM"

# Install SPL Token CLI
if ! command_exists spl-token; then
    safe_install "cargo install spl-token-cli" "SPL Token CLI"
fi

# Install Metaboss
if ! command_exists metaboss; then
    safe_install "cargo install metaboss" "Metaboss"
fi

# Install Solana Verify CLI
safe_install "cargo install solana-verify" "Solana Verify"

echo "📚 Installing JavaScript/TypeScript tools..."

# Install Node.js tools
safe_install "npm install -g @solana/web3.js" "Solana Web3.js"
safe_install "npm install -g @solana/wallet-adapter-react" "Wallet Adapter"
safe_install "npm install -g create-solana-dapp" "Create Solana dApp"
safe_install "npm install -g @metaplex-foundation/amman" "Amman"
safe_install "npm install -g ts-node" "TypeScript Node"

echo "🐍 Installing Python tools..."

# Install Python packages
safe_install "pip3 install solathon" "Solathon"
safe_install "pip3 install anchorpy" "AnchorPy"
safe_install "pip3 install seahorse-lang" "Seahorse"
safe_install "pip3 install solders" "Solders"

echo "🔧 Setting up development environment..."

# Create development directories
mkdir -p ~/solana-projects
mkdir -p ~/.config/solana

# Set Solana config to devnet by default
solana config set --url devnet || echo "Could not set Solana config"

# Generate a development keypair if none exists
if [ ! -f ~/.config/solana/id.json ]; then
    echo "Generating development keypair..."
    solana-keygen new --outfile ~/.config/solana/id.json --no-bip39-passphrase || echo "Could not generate keypair"
fi

echo "📝 Creating quick start script..."

# Create a quick start script
cat > ~/solana-projects/quick-start.sh << 'EOF'
#!/bin/bash
# Solana Development Quick Start

echo "🚀 Solana Development Quick Start"
echo "=================================="
echo ""
echo "Current configuration:"
solana config get || echo "Solana CLI not configured"
echo ""
echo "Your wallet address:"
solana address || echo "No wallet configured"
echo ""
echo "Available commands:"
echo "  solana config set --url [devnet|testnet|mainnet]  # Switch network"
echo "  solana balance                                    # Check balance"
echo "  solana airdrop 1                                 # Get 1 SOL (devnet/testnet)"
echo "  anchor init my-program                           # Create new Anchor program"
echo "  npx create-solana-dapp my-dapp                   # Create new dApp"
echo ""
echo "💡 Tip: Run 'solana airdrop 2' to get SOL for development on devnet"
EOF

chmod +x ~/solana-projects/quick-start.sh

echo "🎯 Creating example projects..."

# Create example Anchor project
if command_exists anchor; then
    cd ~/solana-projects
    if [ ! -d "example-anchor-program" ]; then
        anchor init example-anchor-program --no-git || echo "Could not create example project"
    fi
fi

# Create example dApp
if command_exists npx; then
    cd ~/solana-projects
    if [ ! -d "example-solana-dapp" ]; then
        npx create-solana-dapp example-solana-dapp --template nextjs --no-install || echo "Could not create example dApp"
    fi
fi

echo "✅ SVM development environment setup complete!"
echo ""
echo "🎉 What's installed:"
echo "  ✓ Solana CLI"
echo "  ✓ Anchor Framework"
echo "  ✓ SPL Token CLI"
echo "  ✓ Metaboss (NFT tools)"
echo "  ✓ JavaScript/TypeScript libraries"
echo "  ✓ Python Solana libraries"
echo ""
echo "📂 Example projects created in ~/solana-projects/"
echo ""
echo "🚀 Next steps:"
echo "  1. cd ~/solana-projects"
echo "  2. ./quick-start.sh"
echo "  3. solana airdrop 2  # Get SOL for development"
echo "  4. cd example-anchor-program && anchor build"
echo ""
echo "📚 Documentation: cat doc/SVM_DEVELOPMENT_TOOLS.md"