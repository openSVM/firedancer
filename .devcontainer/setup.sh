#!/bin/bash
set -e

echo "🔥 Setting up Firedancer development environment..."

# Update package manager
apt-get update

# Install required system packages for Firedancer
apt-get install -y \
    build-essential \
    clang \
    git \
    make \
    wget \
    curl \
    pkg-config \
    libssl-dev \
    libudev-dev \
    zlib1g-dev \
    llvm \
    libclang-dev \
    protobuf-compiler \
    gcc-11 \
    g++-11 \
    libnuma-dev \
    liburing-dev \
    python3 \
    python3-pip \
    net-tools \
    iproute2 \
    ethtool \
    nodejs \
    npm \
    yarn

# Set GCC 11 as default
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11

# Install rustup and setup Rust toolchain
if ! command -v rustup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
    source "$HOME/.cargo/env"
fi

# Install Solana CLI tools
echo "📦 Installing Solana CLI..."
if ! command -v solana &> /dev/null; then
    sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
    export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
fi

# Initialize git submodules
echo "🔧 Initializing git submodules..."
git submodule update --init --recursive

# Run the Firedancer dependency installation script
echo "📦 Installing Firedancer dependencies..."
if [ -f "./deps.sh" ]; then
    ./deps.sh +dev
else
    echo "⚠️  deps.sh not found, dependencies may need to be installed manually"
fi

# Install SVM/Solana development tools
echo "🛠️  Installing SVM/Solana development tools..."

# Source configuration
source .devcontainer/svm-tools.conf

# Source Rust environment
source "$HOME/.cargo/env"

# Install Rust-based tools
echo "📦 Installing Rust-based SVM tools..."
for tool in "${RUST_TOOLS[@]}"; do
    echo "Installing $tool..."
    if eval "cargo install $tool"; then
        echo "✅ $tool installed successfully"
    else
        echo "⚠️  $tool installation failed, continuing..."
    fi
done

# Install Node.js tools
echo "📦 Installing Node.js SVM tools..."
for tool in "${NODE_TOOLS[@]}"; do
    echo "Installing $tool..."
    if npm install -g "$tool"; then
        echo "✅ $tool installed successfully"
    else
        echo "⚠️  $tool installation failed, continuing..."
    fi
done

# Install Python packages
echo "📦 Installing Python SVM tools..."
for tool in "${PYTHON_TOOLS[@]}"; do
    echo "Installing $tool..."
    if pip3 install "$tool"; then
        echo "✅ $tool installed successfully"
    else
        echo "⚠️  $tool installation failed, continuing..."
    fi
done

# Clone additional repositories for reference
echo "📚 Cloning additional SVM reference repositories..."
mkdir -p /tmp/svm-repos
cd /tmp/svm-repos
for repo in "${ADDITIONAL_REPOS[@]}"; do
    repo_name=$(basename "$repo" .git)
    if [ ! -d "$repo_name" ]; then
        echo "Cloning $repo_name..."
        git clone "$repo" "$repo_name" || echo "Failed to clone $repo_name"
    fi
done
cd /workspace/firedancer

# Build Firedancer for development
echo "🔨 Building Firedancer..."
make -j$(nproc) fdctl solana

# Create development user
echo "👤 Creating firedancer user for development..."
if ! id "firedancer" &>/dev/null; then
    useradd -m -s /bin/bash firedancer
    mkdir -p /home/firedancer/.firedancer
    chown -R firedancer:firedancer /home/firedancer
fi

# Set up basic configuration for development
echo "⚙️  Setting up basic development configuration..."
cat > /workspace/firedancer/dev-config.toml << 'EOF'
user = "firedancer"

[gossip]
    entrypoints = [
      "entrypoint.testnet.solana.com:8001",
      "entrypoint2.testnet.solana.com:8001",
      "entrypoint3.testnet.solana.com:8001",
    ]

[development]
    sandbox = false
    no_configure = true

[rpc]
    port = 8899
    full_api = true
    private = true

[metrics]
    prometheus_listen_port = 7999

[reporting]
    solana_metrics_config = "host=https://metrics.solana.com:8086,db=tds,u=testnet_write,p=c4fa841aa918bf8274e3e2a44d77568d9861b3ea"

[log]
    path = "/tmp/firedancer.log"
    colorize = "auto"
    level_stderr = "NOTICE"
    level_flush = "WARNING"
EOF

echo "✅ Firedancer development environment setup complete!"
echo ""
echo "🚀 Quick start commands:"
echo "  Build:          make -j\$(nproc) fdctl solana"
echo "  Test build:     make test"
echo "  Dev validator:  fddev dev"
echo "  Configuration:  ./build/native/gcc/bin/fdctl configure init all --config dev-config.toml"
echo "  Run validator:  ./build/native/gcc/bin/fdctl run --config dev-config.toml"
echo ""
echo "🛠️  SVM/Solana development tools installed:"
echo "  Solana CLI:     solana --version"
echo "  Anchor:         anchor --version"
echo "  Metaboss:       metaboss --version"
echo "  SPL Token CLI:  spl-token --version"
echo "  Create dApp:    npx create-solana-dapp my-app"
echo "  Amman:          amman --help"
echo ""
echo "📚 Documentation:"
echo "  Firedancer:     https://docs.firedancer.io/"
echo "  SVM Tools:      cat doc/SVM_DEVELOPMENT_TOOLS.md"
echo "  GitHub:         https://github.com/firedancer-io/firedancer"