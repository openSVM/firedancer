#!/bin/bash
# Quick SVM Development Testing Script
# Tests all installed SVM tools and provides debugging information

set -e

echo "🧪 Testing SVM Development Environment"
echo "======================================"

# Function to test command and report status
test_command() {
    local cmd="$1"
    local name="$2"

    echo -n "Testing $name... "
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ Available"
        return 0
    else
        echo "❌ Not found"
        return 1
    fi
}

# Function to test and show version
test_version() {
    local cmd="$1"
    local name="$2"

    echo -n "Testing $name... "
    if command -v "$cmd" >/dev/null 2>&1; then
        version=$($cmd --version 2>/dev/null | head -1 || echo "unknown")
        echo "✅ $version"
        return 0
    else
        echo "❌ Not found"
        return 1
    fi
}

echo ""
echo "🔧 Core Solana Tools:"
test_version "solana" "Solana CLI"
test_version "solana-keygen" "Solana Keygen"
test_version "spl-token" "SPL Token CLI"

echo ""
echo "⚓ Anchor Framework:"
test_version "anchor" "Anchor CLI"
test_command "avm" "AVM (Anchor Version Manager)"

echo ""
echo "🛠️  Development Tools:"
test_version "metaboss" "Metaboss"
test_command "solana-verify" "Solana Verify"

echo ""
echo "📦 Node.js Tools:"
test_command "node" "Node.js"
test_command "npm" "npm"
test_command "yarn" "Yarn"

echo ""
echo "🐍 Python Tools:"
test_command "python3" "Python 3"
test_command "pip3" "pip3"

# Test Python packages
echo -n "Testing Python Solana packages... "
if python3 -c "import solathon, anchorpy, solders" 2>/dev/null; then
    echo "✅ Available"
else
    echo "❌ Some packages missing"
fi

echo ""
echo "🦀 Rust Environment:"
test_version "rustc" "Rust Compiler"
test_version "cargo" "Cargo"

echo ""
echo "🌐 Network Connectivity Tests:"

# Test RPC endpoints
test_rpc() {
    local url="$1"
    local name="$2"

    echo -n "Testing $name... "
    if curl -s -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","id":1,"method":"getHealth"}' \
        "$url" | grep -q "ok" 2>/dev/null; then
        echo "✅ Connected"
    else
        echo "❌ Failed"
    fi
}

test_rpc "https://api.devnet.solana.com" "Devnet RPC"
test_rpc "https://api.testnet.solana.com" "Testnet RPC"
test_rpc "https://api.mainnet-beta.solana.com" "Mainnet RPC"

echo ""
echo "⚙️  Solana Configuration:"
if command -v solana >/dev/null 2>&1; then
    echo "Current config:"
    solana config get 2>/dev/null || echo "❌ Could not get Solana config"

    echo ""
    echo "Wallet info:"
    if solana address >/dev/null 2>&1; then
        ADDRESS=$(solana address)
        echo "Address: $ADDRESS"

        # Check balance
        BALANCE=$(solana balance 2>/dev/null || echo "0")
        echo "Balance: $BALANCE"
    else
        echo "❌ No wallet configured"
    fi
else
    echo "❌ Solana CLI not available"
fi

echo ""
echo "📂 Development Environment:"

# Check for example projects
echo -n "Example projects... "
if [ -d "$HOME/solana-projects" ]; then
    count=$(ls -1 "$HOME/solana-projects" 2>/dev/null | wc -l)
    echo "✅ $count projects in ~/solana-projects"
else
    echo "❌ No project directory found"
fi

# Check for quick start script
echo -n "Quick start script... "
if [ -f "$HOME/solana-projects/quick-start.sh" ]; then
    echo "✅ Available at ~/solana-projects/quick-start.sh"
else
    echo "❌ Not found"
fi

echo ""
echo "🔥 Firedancer Integration:"

# Test Firedancer build
echo -n "Firedancer build status... "
if [ -f "./build/native/gcc/bin/fdctl" ]; then
    echo "✅ Built and ready"
else
    echo "❌ Not built (run 'make -j$(nproc) fdctl')"
fi

# Check for Firedancer config
echo -n "Development config... "
if [ -f "./dev-config.toml" ]; then
    echo "✅ Available"
else
    echo "❌ Missing dev-config.toml"
fi

echo ""
echo "🚀 Quick Test Commands:"
echo ""

if command -v solana >/dev/null 2>&1; then
    echo "# Get devnet SOL for testing:"
    echo "solana airdrop 2"
    echo ""
fi

if command -v anchor >/dev/null 2>&1; then
    echo "# Create new Anchor program:"
    echo "anchor init my-test-program"
    echo "cd my-test-program && anchor build"
    echo ""
fi

echo "# Create new Solana dApp:"
echo "npx create-solana-dapp my-test-dapp"
echo ""

echo "# Run Firedancer validator:"
echo "make -j\$(nproc) fdctl && ./build/native/gcc/bin/fdctl run --config dev-config.toml"
echo ""

echo "✅ SVM Development Environment Test Complete!"
echo ""
echo "💡 If any tests failed, run './scripts/svm/setup-svm-dev.sh' to reinstall tools"
echo "📚 Full documentation: cat doc/SVM_DEVELOPMENT_TOOLS.md"