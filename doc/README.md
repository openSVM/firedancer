# Firedancer Developer and Operator Toolkit

This directory contains comprehensive documentation and tools for developing and operating Firedancer, the high-performance Solana validator.

## 📋 Quick Reference

### 🚀 Getting Started
- **[Quick Start Guide](QUICK_START.md)** - One-liner setup and minimum requirements
- **[DevContainer Setup](.devcontainer/)** - GitHub Codespaces development environment
- **[Implementation Comparison](IMPLEMENTATION_COMPARISON.md)** - How Firedancer compares to other Solana implementations

### 📊 Operations & Monitoring  
- **[Validator Monitoring](VALIDATOR_MONITORING.md)** - Comprehensive metrics and alerting guide
- **[Operational Guide](OPERATIONAL_GUIDE.md)** - Production deployment, security, and troubleshooting

### 📚 Comprehensive Documentation
- **[Project Overview](comprehensive-review/PROJECT_OVERVIEW.md)** - Complete project context and architecture
- **[Development Plan](comprehensive-review/development-plan.md)** - Technical implementation roadmap
- **[Community Engagement Plan](comprehensive-review/community-engagement-plan.md)** - Community building strategy

## 🎯 Quick Actions

### Start Development Environment
```bash
# Using GitHub Codespaces - click "Code" → "Codespaces" → "Create codespace"
# Or locally with the .devcontainer configuration

# Manual setup
git clone --recurse-submodules https://github.com/firedancer-io/firedancer.git
cd firedancer
./deps.sh +dev
make -j$(nproc) fdctl solana
```

### Deploy Testnet Validator
```bash
# One-liner testnet setup
curl -sSL https://raw.githubusercontent.com/firedancer-io/firedancer/main/scripts/quick-start.sh | bash -s -- --network testnet
```

### Monitor Validator Performance
```bash
# Check validator health
curl -s http://localhost:7999/metrics | grep -E "(slot_height|vote_distance|balance)"

# Live monitoring
fdctl monitor --config config.toml

# System diagnosis
./doc/troubleshooting.sh diagnose
```

## 📈 Performance Expectations

| Metric | Firedancer | Traditional Validators |
|--------|------------|----------------------|
| **Peak TPS** | 1,000,000+ | 65,000 |
| **Latency (p50)** | <400ms | 1-2s |
| **Memory Usage** | 32-64GB | 128-256GB |
| **CPU Efficiency** | 95% | 60% |
| **Network Bandwidth** | 10-20Gbps | 1-5Gbps |

## 🎛️ System Requirements

### Minimum (Testnet)
- **CPU**: 8-Core @ 2.5GHz (AVX2)
- **RAM**: 32GB DDR4
- **Storage**: 256GB NVMe SSD
- **Network**: 100 Mbps
- **OS**: Linux kernel 4.18+ (Ubuntu 20.04+)

### Recommended (Mainnet)
- **CPU**: 32-Core @ 3.0GHz (AVX512)
- **RAM**: 128GB DDR4 ECC
- **Storage**: 2TB NVMe Gen4 SSD
- **Network**: 10 Gbps dedicated
- **Additional**: Intel X710/E810 NIC for optimal AF_XDP performance

## 🔧 Essential Tools

### Development Tools
```bash
# Build and test
make -j$(nproc) fdctl solana
make test

# Development validator
fddev dev

# Performance monitoring
fdctl monitor --config config.toml
```

### Operations Tools
```bash
# System optimization
./doc/performance-optimization.sh

# Security hardening  
./doc/security-hardening.sh

# Monitoring setup
./doc/monitoring-setup.sh

# Backup and recovery
./doc/backup-recovery.sh backup
```

## 📊 Key Metrics to Monitor

### Critical Validator Metrics
- `fd_validator_slot_height` - Current processed slot
- `fd_validator_vote_distance` - Distance from latest vote (should be <5)
- `fd_validator_skip_rate` - Block production skip rate (should be <5%)
- `fd_validator_balance_lamports` - Validator balance (maintain >1 SOL)

### Performance Metrics
- `fd_tile_cpu_percent` - Individual tile CPU usage
- `fd_tile_backpressure_percent` - Tile backpressure (should be <10%)
- `fd_network_packets_*` - Network throughput statistics
- `fd_gossip_peers_active` - Active gossip connections (should be >50)

### System Metrics
- CPU usage (should be <90%)
- Memory usage (should be <85%)
- Disk I/O performance (>10,000 IOPS)
- Network bandwidth utilization

## 🚨 Alert Thresholds

### Critical Alerts
- Validator down (immediate)
- Slot lag >10 slots (2 minutes)
- Skip rate >5% (3 minutes)
- Balance <1 SOL (5 minutes)

### Warning Alerts
- CPU >90% (5 minutes)
- Memory >85% (5 minutes)
- Tile backpressure >10% (2 minutes)
- Gossip peers <50 (5 minutes)

## 🔒 Security Best Practices

### System Hardening
- Run Firedancer as non-root user (`firedancer`)
- Use tile-based sandboxing for process isolation
- Configure firewall to allow only necessary ports
- Disable unnecessary system services
- Enable SSH key authentication only

### Network Security
- Restrict RPC access to trusted networks
- Use VPN for administrative access
- Monitor for unusual network patterns
- Implement DDoS protection

### Operational Security
- Regular security updates
- Backup keypairs securely offline
- Monitor for unauthorized access
- Use hardware security modules for key storage

## 🛠️ Troubleshooting

### Common Issues

1. **High CPU Usage**
   ```bash
   # Check tile distribution
   fdctl monitor --config config.toml
   
   # Optimize CPU affinity
   # Add to config.toml:
   [development]
     affinity_tile_cpu = "0-15"
   ```

2. **Network Connectivity Issues**
   ```bash
   # Check XDP driver support
   ethtool -i eth0 | grep driver
   
   # Verify ports are accessible
   ss -tuln | grep -E "(8001|8899|7999)"
   ```

3. **Memory Issues**
   ```bash
   # Enable huge pages
   echo 2048 > /proc/sys/vm/nr_hugepages
   
   # Check memory usage
   free -h && cat /proc/meminfo | grep HugePages
   ```

4. **Slot Lag**
   ```bash
   # Check network latency to gossip peers
   for peer in entrypoint.testnet.solana.com entrypoint2.testnet.solana.com; do
     ping -c 3 $peer
   done
   
   # Verify system clock synchronization
   timedatectl status
   ```

### Debug Information Collection
```bash
# Automated debug collection
./doc/troubleshooting.sh debug

# Manual collection
journalctl -u firedancer --since "1 hour ago" > /tmp/firedancer.log
curl -s http://localhost:7999/metrics > /tmp/metrics.txt
dmesg | tail -100 > /tmp/kernel.log
```

## 📞 Support and Community

### Getting Help
- **Documentation**: [docs.firedancer.io](https://docs.firedancer.io/)
- **GitHub Issues**: [github.com/firedancer-io/firedancer/issues](https://github.com/firedancer-io/firedancer/issues)
- **Discord**: [Solana Discord #firedancer](https://discord.gg/solana)
- **Twitter**: [@firedancer_io](https://twitter.com/firedancer_io)

### Contributing
- Review the [Development Plan](comprehensive-review/development-plan.md)
- Check the [Community Engagement Plan](comprehensive-review/community-engagement-plan.md)
- Submit PRs following the contribution guidelines
- Join community discussions and code reviews

## 📝 Release Information

### Current Status
- **Frankendancer**: Production ready on testnet and mainnet
- **Full Firedancer**: In active development, testnet compatible
- **Target**: Full production release in 2024

### Version Information
```bash
# Check current version
./build/native/gcc/bin/fdctl --version

# Latest releases
git tag --sort=-version:refname | head -5
```

---

This toolkit provides everything needed to successfully develop, deploy, and operate Firedancer at scale. For specific questions or advanced use cases, consult the individual documentation files or reach out to the community.