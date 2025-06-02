# Firedancer Quick Start Guide

## 🚀 One-Liner Validator Setup

```bash
# Clone, build, and start Firedancer validator in one command
curl -sSL https://raw.githubusercontent.com/firedancer-io/firedancer/main/scripts/quick-start.sh | bash -s -- --network testnet --auto-configure
```

### Alternative Step-by-Step One-Liner

```bash
git clone --recurse-submodules https://github.com/firedancer-io/firedancer.git && cd firedancer && ./deps.sh +dev && make -j$(nproc) fdctl solana && sudo ./build/native/gcc/bin/fdctl configure init all --config <(echo -e "user = \"$USER\"\n[gossip]\n    entrypoints = [\"entrypoint.testnet.solana.com:8001\"]\n[consensus]\n    identity_path = \"./validator-keypair.json\"\n    vote_account_path = \"./vote-keypair.json\"") && ./build/native/gcc/bin/solana-keygen new --no-bip39-passphrase -o validator-keypair.json && ./build/native/gcc/bin/solana-keygen new --no-bip39-passphrase -o vote-keypair.json && sudo ./build/native/gcc/bin/fdctl run --config <(echo -e "user = \"$USER\"\n[gossip]\n    entrypoints = [\"entrypoint.testnet.solana.com:8001\"]\n[consensus]\n    identity_path = \"./validator-keypair.json\"\n    vote_account_path = \"./vote-keypair.json\"")
```

## 📋 Minimum System Requirements

### Testnet Validator (Minimum)
- **CPU**: 8-Core Intel/AMD @ 2.5GHz (AVX2 support required)
- **RAM**: 32GB DDR4
- **Storage**: 256GB NVMe SSD
- **Network**: 100 Mbps dedicated bandwidth
- **OS**: Ubuntu 20.04+ / Fedora 29+ / RHEL 8+ (Linux kernel 4.18+)

### Mainnet Validator (Minimum)
- **CPU**: 24-Core Intel/AMD @ 2.5GHz (AVX512 recommended)
- **RAM**: 64GB DDR4 (ECC recommended)
- **Storage**: 512GB NVMe SSD
- **Network**: 1 Gbps dedicated bandwidth
- **OS**: Ubuntu 20.04+ / Fedora 29+ / RHEL 8+ (Linux kernel 4.18+)

### RPC Node (Minimum)
- **CPU**: 16-Core Intel/AMD @ 3.0GHz
- **RAM**: 128GB DDR4
- **Storage**: 1TB NVMe SSD (separate disk for OS)
- **Network**: 1 Gbps dedicated bandwidth
- **OS**: Ubuntu 20.04+ / Fedora 29+ / RHEL 8+ (Linux kernel 4.18+)

## 🏆 Recommended Production Specifications

### High-Performance Validator
- **CPU**: 32-Core Intel Xeon or AMD EPYC @ 3.0GHz+ with AVX512
- **RAM**: 128GB DDR4 ECC @ 3200MHz+
- **Storage**: 2TB NVMe Gen4 SSD (enterprise grade)
- **Network**: 10 Gbps dedicated bandwidth
- **Additional**: Dedicated network card (Intel X710 or similar)

### Enterprise RPC Node
- **CPU**: 64-Core Intel Xeon or AMD EPYC @ 3.0GHz+
- **RAM**: 256GB DDR4 ECC @ 3200MHz+
- **Storage**: 4TB NVMe Gen4 SSD RAID setup
- **Network**: 10 Gbps dedicated bandwidth with redundancy
- **Additional**: Load balancer and clustering setup

## ⚡ Performance Optimization

### CPU Requirements
```bash
# Check CPU features
lscpu | grep -E "(avx|avx2|avx512)"

# Recommended CPU models:
# Intel: Xeon Gold 6300+ series, Core i9-12900K+
# AMD: EPYC 7003+ series, Ryzen 9 5900X+
```

### Memory Optimization
```bash
# Check current memory
free -h

# Enable huge pages for better performance
echo 'vm.nr_hugepages = 2048' >> /etc/sysctl.conf
sysctl -p
```

### Storage Performance
```bash
# Test storage performance
sudo fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --size=4g --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1

# Recommended: >10,000 IOPS, <1ms latency
```

### Network Configuration
```bash
# Check network interface
ip link show

# Recommended network cards:
# - Intel X710/X722 (i40e driver)
# - Intel E810 (ice driver)
# - Intel X540/X550 (ixgbe driver)
```

## 🔧 Quick Setup Scripts

### Development Environment Setup
```bash
#!/bin/bash
# dev-setup.sh - Quick development environment

set -e

echo "🔥 Setting up Firedancer development environment..."

# Install system dependencies
if command -v apt-get >/dev/null; then
    sudo apt-get update
    sudo apt-get install -y build-essential clang git make wget curl pkg-config \
        libssl-dev libudev-dev zlib1g-dev llvm libclang-dev protobuf-compiler \
        gcc-11 g++-11 libnuma-dev liburing-dev python3 python3-pip
elif command -v yum >/dev/null; then
    sudo yum groupinstall -y "Development Tools"
    sudo yum install -y clang git make wget curl pkgconfig openssl-devel \
        libudev-devel zlib-devel llvm clang-devel protobuf-compiler \
        gcc11 gcc11-c++ numactl-devel liburing-devel python3 python3-pip
fi

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

# Clone and build Firedancer
git clone --recurse-submodules https://github.com/firedancer-io/firedancer.git
cd firedancer
./deps.sh +dev
make -j$(nproc) fdctl solana

echo "✅ Development environment ready!"
echo "Run: cd firedancer && fddev dev"
```

### Testnet Validator Setup
```bash
#!/bin/bash
# testnet-validator.sh - Quick testnet validator setup

set -e

IDENTITY_KEYPAIR="${1:-./validator-keypair.json}"
VOTE_KEYPAIR="${2:-./vote-keypair.json}"

echo "🚀 Setting up Firedancer testnet validator..."

# Generate keypairs if they don't exist
if [ ! -f "$IDENTITY_KEYPAIR" ]; then
    ./build/native/gcc/bin/solana-keygen new --no-bip39-passphrase -o "$IDENTITY_KEYPAIR"
fi

if [ ! -f "$VOTE_KEYPAIR" ]; then
    ./build/native/gcc/bin/solana-keygen new --no-bip39-passphrase -o "$VOTE_KEYPAIR"
fi

# Create configuration
cat > testnet-config.toml << EOF
user = "$(whoami)"

[gossip]
    entrypoints = [
        "entrypoint.testnet.solana.com:8001",
        "entrypoint2.testnet.solana.com:8001",
        "entrypoint3.testnet.solana.com:8001",
    ]

[consensus]
    identity_path = "$IDENTITY_KEYPAIR"
    vote_account_path = "$VOTE_KEYPAIR"
    known_validators = [
        "5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on",
        "dDzy5SR3AXdYWVqbDEkVFdvSPCtS9ihF5kJkHCtXoFs",
        "Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN",
        "eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ",
        "9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv",
    ]

[rpc]
    port = 8899
    full_api = true
    private = true

[metrics]
    prometheus_listen_port = 7999

[reporting]
    solana_metrics_config = "host=https://metrics.solana.com:8086,db=tds,u=testnet_write,p=c4fa841aa918bf8274e3e2a44d77568d9861b3ea"

[log]
    path = "./firedancer.log"
    colorize = "auto"
    level_stderr = "NOTICE"
    level_flush = "WARNING"
EOF

# Configure system
echo "⚙️  Configuring system..."
sudo ./build/native/gcc/bin/fdctl configure init all --config testnet-config.toml

# Start validator
echo "🚀 Starting validator..."
sudo ./build/native/gcc/bin/fdctl run --config testnet-config.toml

echo "✅ Testnet validator started!"
echo "Monitor: ./build/native/gcc/bin/fdctl monitor --config testnet-config.toml"
echo "Logs: tail -f firedancer.log"
```

### Mainnet Validator Setup
```bash
#!/bin/bash
# mainnet-validator.sh - Production mainnet validator setup

set -e

echo "🏦 Setting up Firedancer mainnet validator..."
echo "⚠️  WARNING: This is for production use. Ensure you have:"
echo "   - Sufficient SOL for voting (0.02 SOL per vote)"
echo "   - Backup of your keypairs"
echo "   - Monitoring and alerting configured"
echo "   - Firewall and security measures in place"
echo

read -p "Continue? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    exit 1
fi

IDENTITY_KEYPAIR="${1:-./mainnet-validator-keypair.json}"
VOTE_KEYPAIR="${2:-./mainnet-vote-keypair.json}"

# Create production configuration
cat > mainnet-config.toml << EOF
user = "firedancer"

[gossip]
    entrypoints = [
        "entrypoint.mainnet-beta.solana.com:8001",
        "entrypoint2.mainnet-beta.solana.com:8001",
        "entrypoint3.mainnet-beta.solana.com:8001",
    ]

[consensus]
    identity_path = "$IDENTITY_KEYPAIR"
    vote_account_path = "$VOTE_KEYPAIR"
    known_validators = [
        "7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2",
        "GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ",
        "DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBkPx6u9qHY",
        "CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S",
    ]
    expected_bank_hash = "11111111111111111111111111111111"
    wait_for_supermajority = true

[rpc]
    port = 8899
    full_api = false
    private = true

[metrics]
    prometheus_listen_port = 7999

[reporting]
    solana_metrics_config = "host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password"

[log]
    path = "/var/log/firedancer/firedancer.log"
    colorize = "auto"
    level_stderr = "WARNING"
    level_flush = "ERROR"

[development]
    sandbox = true
    no_configure = false
EOF

# Create firedancer user
sudo useradd -m -s /bin/bash firedancer || true
sudo mkdir -p /var/log/firedancer
sudo chown firedancer:firedancer /var/log/firedancer

# Configure system for production
sudo ./build/native/gcc/bin/fdctl configure init all --config mainnet-config.toml

echo "✅ Mainnet validator configured!"
echo "🚀 Start with: sudo ./build/native/gcc/bin/fdctl run --config mainnet-config.toml"
echo "📊 Monitor: ./build/native/gcc/bin/fdctl monitor --config mainnet-config.toml"
```

## 🔍 Health Check Commands

### Validator Status Check
```bash
# Check if validator is running and healthy
curl -s http://localhost:7999/metrics | grep -E "(slot_height|vote_distance|balance)"

# Check gossip status
./build/native/gcc/bin/solana -ut gossip

# Verify voting
./build/native/gcc/bin/solana -ut validators --output json | jq '.[] | select(.identityPubkey=="YOUR_IDENTITY_KEY")'
```

### Performance Monitoring
```bash
# Monitor tile performance
./build/native/gcc/bin/fdctl monitor --config config.toml

# Check system resources
htop -p $(pgrep -d',' -f fdctl)

# Network monitoring
ss -tuln | grep -E "(8001|8899|7999)"
```

## 🚨 Common Issues and Solutions

### Insufficient Permissions
```bash
# If getting permission errors
sudo setcap cap_sys_admin,cap_net_raw,cap_net_admin+ep ./build/native/gcc/bin/fdctl
```

### Memory Issues
```bash
# If running out of memory during build
make -j$(($(nproc)/2)) fdctl solana  # Use half the cores
```

### Network Interface Problems
```bash
# Check available interfaces
ip link show
# Update config.toml with correct interface name
```

### Disk Space Issues
```bash
# Monitor disk usage
df -h
# Clean old ledger data if needed
rm -rf ~/.firedancer/fd1/ledger/rocksdb
```

This quick start guide provides everything needed to get Firedancer running efficiently with minimal setup time while ensuring proper configuration for different use cases.