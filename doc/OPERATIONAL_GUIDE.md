# Firedancer Operational Knowledge Base

## 🎯 Production Operations Guide

### Pre-Deployment Checklist

#### Hardware Verification
```bash
#!/bin/bash
# hardware-check.sh - Verify system meets Firedancer requirements

echo "🔍 Firedancer Hardware Verification"
echo "=================================="

# Check CPU features
echo "CPU Features:"
CPU_INFO=$(lscpu)
echo "$CPU_INFO" | grep -E "Model name|Architecture|CPU\(s\)|Thread|MHz|Cache"

# Verify required CPU features
REQUIRED_FEATURES="avx2 sse4_1 sse4_2"
MISSING_FEATURES=""

for feature in $REQUIRED_FEATURES; do
    if ! grep -q $feature /proc/cpuinfo; then
        MISSING_FEATURES="$MISSING_FEATURES $feature"
    fi
done

if [ -n "$MISSING_FEATURES" ]; then
    echo "❌ Missing required CPU features:$MISSING_FEATURES"
    echo "   Firedancer requires modern CPU with AVX2 support"
else
    echo "✅ CPU features: All required features present"
fi

# Check AVX512 (recommended)
if grep -q avx512 /proc/cpuinfo; then
    echo "✅ AVX512: Available (recommended for optimal performance)"
else
    echo "⚠️  AVX512: Not available (performance may be reduced)"
fi

# Memory check
echo -e "\nMemory Configuration:"
TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
echo "Total memory: ${TOTAL_MEM}GB"

if [ $TOTAL_MEM -lt 32 ]; then
    echo "❌ Memory: Insufficient ($TOTAL_MEM GB < 32GB minimum)"
elif [ $TOTAL_MEM -lt 64 ]; then
    echo "⚠️  Memory: Minimal ($TOTAL_MEM GB, 64GB+ recommended)"
else
    echo "✅ Memory: Adequate ($TOTAL_MEM GB)"
fi

# Check memory speed and ECC
dmidecode -t memory 2>/dev/null | grep -E "Speed|ECC" | head -5

# Storage performance test
echo -e "\nStorage Performance:"
LEDGER_PATH=${1:-$HOME/.firedancer/fd1/ledger}
if command -v fio >/dev/null; then
    echo "Testing storage performance..."
    fio --name=test --ioengine=posixaio --rw=randwrite --bs=4k --size=1g \
        --numjobs=1 --iodepth=32 --runtime=30 --time_based \
        --directory=${LEDGER_PATH%/*} --output-format=json | \
        jq -r '.jobs[0].write | "IOPS: \(.iops | round), Latency: \(.lat_ns.mean/1000000 | round)ms"'
else
    echo "⚠️  fio not installed, install with: sudo apt install fio"
fi

# Network interface check
echo -e "\nNetwork Interfaces:"
for iface in $(ip link show | grep -E "^[0-9]:" | grep -v lo | cut -d: -f2 | tr -d ' '); do
    DRIVER=$(ethtool -i $iface 2>/dev/null | grep driver | cut -d: -f2 | tr -d ' ')
    SPEED=$(ethtool $iface 2>/dev/null | grep Speed | cut -d: -f2 | tr -d ' ')
    echo "Interface: $iface, Driver: $DRIVER, Speed: $SPEED"

    # Check for recommended drivers
    case $DRIVER in
        ixgbe|i40e|ice|mlx5_core)
            echo "✅ $iface: Recommended driver ($DRIVER)"
            ;;
        *)
            echo "⚠️  $iface: Driver $DRIVER may have limited AF_XDP support"
            ;;
    esac
done

# Kernel version check
echo -e "\nKernel Version:"
KERNEL_VERSION=$(uname -r | cut -d. -f1-2)
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)
KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d. -f2)

if [ $KERNEL_MAJOR -gt 4 ] || ([ $KERNEL_MAJOR -eq 4 ] && [ $KERNEL_MINOR -ge 18 ]); then
    echo "✅ Kernel: $KERNEL_VERSION (>= 4.18 required)"
else
    echo "❌ Kernel: $KERNEL_VERSION (< 4.18, upgrade required)"
fi

# Check for XDP support
if [ -f /proc/config.gz ]; then
    if zcat /proc/config.gz | grep -q "CONFIG_XDP_SOCKETS=y"; then
        echo "✅ XDP: Kernel support enabled"
    else
        echo "❌ XDP: Kernel support missing"
    fi
elif [ -f /boot/config-$(uname -r) ]; then
    if grep -q "CONFIG_XDP_SOCKETS=y" /boot/config-$(uname -r); then
        echo "✅ XDP: Kernel support enabled"
    else
        echo "❌ XDP: Kernel support missing"
    fi
else
    echo "⚠️  XDP: Cannot verify kernel config"
fi

echo -e "\n🏁 Hardware verification complete"
```

#### Security Hardening
```bash
#!/bin/bash
# security-hardening.sh - Harden system for Firedancer production

echo "🔒 Firedancer Security Hardening"
echo "==============================="

# Create firedancer user with minimal privileges
if ! id "firedancer" &>/dev/null; then
    useradd -r -s /bin/false -d /home/firedancer -m firedancer
    echo "✅ Created firedancer user"
else
    echo "✅ Firedancer user exists"
fi

# Set up directory permissions
mkdir -p /home/firedancer/.firedancer/fd1/{ledger,snapshots,accounts}
chown -R firedancer:firedancer /home/firedancer
chmod 750 /home/firedancer
chmod -R 750 /home/firedancer/.firedancer

# Configure firewall
ufw --force enable
ufw default deny incoming
ufw default allow outgoing

# Allow essential ports
ufw allow 22/tcp comment "SSH"
ufw allow 8000:8020/tcp comment "Gossip range"
ufw allow 8001/udp comment "Gossip"
ufw allow 8003/udp comment "TVU"
ufw allow 8004/udp comment "TVU forwards"
ufw allow 8899/tcp comment "RPC (restrict to specific IPs in production)"
ufw allow 7999/tcp comment "Metrics (restrict to monitoring network)"

echo "✅ Firewall configured"

# Disable unnecessary services
systemctl disable --now cups-browsed 2>/dev/null || true
systemctl disable --now avahi-daemon 2>/dev/null || true
systemctl disable --now bluetooth 2>/dev/null || true

# Kernel security parameters
cat > /etc/sysctl.d/99-firedancer-security.conf << 'EOF'
# Network security
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Memory protection
kernel.randomize_va_space = 2
kernel.exec-shield = 1
kernel.core_uses_pid = 1

# Performance optimizations
vm.swappiness = 1
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF

sysctl -p /etc/sysctl.d/99-firedancer-security.conf
echo "✅ Security kernel parameters configured"

# Set up log rotation
cat > /etc/logrotate.d/firedancer << 'EOF'
/var/log/firedancer/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    postrotate
        systemctl reload firedancer || true
    endscript
}
EOF

echo "✅ Log rotation configured"

# SSH hardening
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl reload sshd

echo "✅ SSH hardened (root login disabled, password auth disabled)"
echo "⚠️  Ensure you have SSH key access before logging out!"

# Fail2ban for SSH protection
if command -v fail2ban-client >/dev/null; then
    systemctl enable --now fail2ban
    echo "✅ Fail2ban enabled"
else
    echo "⚠️  Consider installing fail2ban: apt install fail2ban"
fi

echo -e "\n🔒 Security hardening complete"
echo "Next steps:"
echo "1. Configure SSH keys for secure access"
echo "2. Set up monitoring and alerting"
echo "3. Regular security updates: unattended-upgrades"
echo "4. Consider additional monitoring tools"
```

### Performance Optimization

#### CPU and Memory Optimization
```bash
#!/bin/bash
# performance-optimization.sh - Optimize system for Firedancer

echo "⚡ Firedancer Performance Optimization"
echo "====================================="

# CPU governor and frequency scaling
echo "Configuring CPU performance..."
cpupower frequency-set -g performance 2>/dev/null || {
    echo "performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
}

# Disable CPU idle states for consistent latency
echo 1 > /sys/devices/system/cpu/cpu*/cpuidle/state*/disable 2>/dev/null || true

# IRQ affinity optimization
echo "Optimizing interrupt handling..."
for irq in $(grep -E "(eth|ens|enp)" /proc/interrupts | cut -d: -f1 | tr -d ' '); do
    if [ -f /proc/irq/$irq/smp_affinity ]; then
        # Bind network IRQs to first few CPUs
        echo 0f > /proc/irq/$irq/smp_affinity 2>/dev/null
    fi
done

# Huge pages configuration
echo "Configuring huge pages..."
HUGEPAGES_COUNT=2048
echo $HUGEPAGES_COUNT > /proc/sys/vm/nr_hugepages

# Add to grub for persistence
if ! grep -q "hugepages=$HUGEPAGES_COUNT" /proc/cmdline; then
    echo "⚠️  Add 'hugepages=$HUGEPAGES_COUNT' to GRUB_CMDLINE_LINUX in /etc/default/grub"
    echo "   Then run: update-grub && reboot"
fi

# Memory optimization
cat > /etc/sysctl.d/99-firedancer-performance.conf << 'EOF'
# Memory management
vm.nr_hugepages = 2048
vm.swappiness = 1
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50

# Network performance
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr

# XDP optimization
net.core.bpf_jit_enable = 1
net.core.bpf_jit_harden = 0
EOF

sysctl -p /etc/sysctl.d/99-firedancer-performance.conf

# NUMA optimization (if applicable)
if command -v numactl >/dev/null && [ $(numactl --hardware | grep "available:" | awk '{print $2}') -gt 1 ]; then
    echo "✅ NUMA system detected"
    echo "   Configure NUMA affinity in firedancer config:"
    echo "   [development]"
    echo "     affinity_tile_cpu = \"0-15\""
    echo "     affinity_net_cpu = \"16-31\""
fi

# Storage optimization
echo "Optimizing storage..."
for disk in $(lsblk -dpno NAME | grep -E "sd|nvme"); do
    # Set I/O scheduler for SSDs
    if grep -q 0 /sys/block/$(basename $disk)/queue/rotational 2>/dev/null; then
        echo none > /sys/block/$(basename $disk)/queue/scheduler 2>/dev/null ||
        echo mq-deadline > /sys/block/$(basename $disk)/queue/scheduler 2>/dev/null
        echo "✅ Set scheduler for SSD: $disk"
    fi
done

echo "✅ Performance optimization complete"
```

#### Network Optimization
```bash
#!/bin/bash
# network-optimization.sh - Optimize networking for Firedancer

echo "🌐 Network Optimization for Firedancer"
echo "======================================"

# Detect primary network interface
PRIMARY_IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "Primary interface: $PRIMARY_IFACE"

# Configure network interface for optimal performance
ethtool -G $PRIMARY_IFACE rx 4096 tx 4096 2>/dev/null || echo "⚠️  Could not set ring buffer sizes"
ethtool -K $PRIMARY_IFACE gro off gso off tso off 2>/dev/null || echo "⚠️  Could not disable offloading"
ethtool -C $PRIMARY_IFACE rx-usecs 1 rx-frames 1 2>/dev/null || echo "⚠️  Could not set interrupt coalescing"

# XDP configuration
echo "Configuring XDP support..."
if ! command -v bpftool >/dev/null; then
    echo "⚠️  Installing bpf tools..."
    apt update && apt install -y linux-tools-$(uname -r) linux-tools-generic
fi

# Verify XDP capabilities
if ethtool -i $PRIMARY_IFACE | grep -q "driver: i40e\|driver: ixgbe\|driver: ice"; then
    echo "✅ Network driver supports native XDP"
else
    echo "⚠️  Network driver may have limited XDP support"
    echo "   Consider upgrading to Intel X710/X722 (i40e) or similar"
fi

# Network tuning parameters
cat > /etc/sysctl.d/99-firedancer-network.conf << 'EOF'
# High-performance networking
net.core.rmem_default = 268435456
net.core.rmem_max = 268435456
net.core.wmem_default = 268435456
net.core.wmem_max = 268435456
net.core.netdev_max_backlog = 30000
net.core.netdev_budget = 600

# TCP optimization
net.ipv4.tcp_rmem = 4096 87380 268435456
net.ipv4.tcp_wmem = 4096 65536 268435456
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1

# UDP optimization
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192

# Buffer overflow protection
net.core.netdev_max_backlog = 30000
net.netfilter.nf_conntrack_max = 1000000

# XDP/eBPF
net.core.bpf_jit_enable = 1
net.core.bpf_jit_kallsyms = 1
EOF

sysctl -p /etc/sysctl.d/99-firedancer-network.conf
echo "✅ Network parameters optimized"

# Set up network monitoring
cat > /usr/local/bin/network-monitor.sh << 'EOF'
#!/bin/bash
# Network monitoring for Firedancer

INTERFACE=${1:-$(ip route | grep default | awk '{print $5}' | head -1)}

echo "Monitoring interface: $INTERFACE"
echo "Press Ctrl+C to stop"

while true; do
    RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    TX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    RX_PACKETS=$(cat /sys/class/net/$INTERFACE/statistics/rx_packets)
    TX_PACKETS=$(cat /sys/class/net/$INTERFACE/statistics/tx_packets)
    RX_DROPPED=$(cat /sys/class/net/$INTERFACE/statistics/rx_dropped)
    TX_DROPPED=$(cat /sys/class/net/$INTERFACE/statistics/tx_dropped)

    sleep 1

    RX_BYTES_NEW=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    TX_BYTES_NEW=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    RX_PACKETS_NEW=$(cat /sys/class/net/$INTERFACE/statistics/rx_packets)
    TX_PACKETS_NEW=$(cat /sys/class/net/$INTERFACE/statistics/tx_packets)

    RX_RATE=$(( ($RX_BYTES_NEW - $RX_BYTES) * 8 / 1000000 ))
    TX_RATE=$(( ($TX_BYTES_NEW - $TX_BYTES) * 8 / 1000000 ))
    RX_PPS=$(( $RX_PACKETS_NEW - $RX_PACKETS ))
    TX_PPS=$(( $TX_PACKETS_NEW - $TX_PACKETS ))

    printf "\r%s: RX: %4d Mbps (%6d pps) TX: %4d Mbps (%6d pps) Dropped: %d/%d" \
           "$(date +'%H:%M:%S')" $RX_RATE $RX_PPS $TX_RATE $TX_PPS $RX_DROPPED $TX_DROPPED
done
EOF

chmod +x /usr/local/bin/network-monitor.sh
echo "✅ Network monitoring script installed"
echo "   Run: /usr/local/bin/network-monitor.sh"
```

### Monitoring and Alerting

#### Production Monitoring Setup
```bash
#!/bin/bash
# monitoring-setup.sh - Set up comprehensive monitoring

echo "📊 Setting up Firedancer Monitoring"
echo "==================================="

# Install monitoring tools
apt update
apt install -y prometheus node-exporter grafana-server

# Configure Prometheus
cat > /etc/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "firedancer_alerts.yml"

scrape_configs:
  - job_name: 'firedancer'
    static_configs:
      - targets: ['localhost:7999']
    scrape_interval: 5s

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
    scrape_interval: 10s

  - job_name: 'firedancer-custom'
    static_configs:
      - targets: ['localhost:8000']
    scrape_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093
EOF

# Firedancer-specific alert rules
cat > /etc/prometheus/firedancer_alerts.yml << 'EOF'
groups:
  - name: firedancer_critical
    rules:
    - alert: ValidatorDown
      expr: up{job="firedancer"} == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Firedancer validator is down"
        description: "Firedancer validator has been down for more than 1 minute"

    - alert: SlotLag
      expr: fd_validator_slot_distance > 10
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Validator {{ $value }} slots behind"
        description: "Validator is significantly behind network consensus"

    - alert: HighSkipRate
      expr: rate(fd_validator_blocks_skipped_total[5m]) / rate(fd_validator_leader_slots_total[5m]) > 0.05
      for: 3m
      labels:
        severity: critical
      annotations:
        summary: "Block skip rate {{ $value | humanizePercentage }}"
        description: "Validator is skipping too many blocks"

    - alert: LowBalance
      expr: fd_validator_balance_lamports / 1000000000 < 1
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Validator balance {{ $value }} SOL"
        description: "Validator balance is critically low"

  - name: firedancer_performance
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage {{ $value }}%"
        description: "CPU usage has been above 90% for 5 minutes"

    - alert: HighMemoryUsage
      expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage {{ $value }}%"
        description: "Memory usage has been above 85% for 5 minutes"

    - alert: TileBackpressure
      expr: fd_tile_backpressure_percent > 10
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "Tile {{ $labels.tile }} backpressure {{ $value }}%"
        description: "High backpressure detected in processing tile"
EOF

# Start monitoring services
systemctl enable --now prometheus
systemctl enable --now node-exporter
systemctl enable --now grafana-server

echo "✅ Basic monitoring configured"
echo "   Prometheus: http://localhost:9090"
echo "   Grafana: http://localhost:3000 (admin/admin)"
```

### Disaster Recovery

#### Backup and Recovery Procedures
```bash
#!/bin/bash
# backup-recovery.sh - Firedancer backup and recovery procedures

BACKUP_DIR="/backup/firedancer"
DATA_DIR="/home/firedancer/.firedancer/fd1"
CONFIG_FILE="/etc/firedancer/config.toml"

backup_validator() {
    echo "🔄 Starting Firedancer backup..."

    mkdir -p $BACKUP_DIR/$(date +%Y%m%d_%H%M%S)
    CURRENT_BACKUP=$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)

    # Stop validator for consistent backup
    systemctl stop firedancer

    # Backup critical files
    echo "Backing up configuration..."
    cp $CONFIG_FILE $CURRENT_BACKUP/

    echo "Backing up keypairs..."
    cp -r /home/firedancer/.ssh $CURRENT_BACKUP/ 2>/dev/null || true
    find /home/firedancer -name "*.json" -exec cp {} $CURRENT_BACKUP/ \;

    echo "Backing up ledger snapshot..."
    rsync -av --progress $DATA_DIR/snapshots/ $CURRENT_BACKUP/snapshots/

    echo "Backing up accounts database..."
    rsync -av --progress $DATA_DIR/accounts/ $CURRENT_BACKUP/accounts/

    # Create backup manifest
    cat > $CURRENT_BACKUP/manifest.txt << EOF
Backup Date: $(date)
Hostname: $(hostname)
Firedancer Version: $(./build/native/gcc/bin/fdctl --version)
Ledger Size: $(du -sh $DATA_DIR/ledger | cut -f1)
Snapshot Count: $(ls $DATA_DIR/snapshots/*.tar.* 2>/dev/null | wc -l)
EOF

    # Compress backup
    tar -czf $BACKUP_DIR/firedancer_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C $BACKUP_DIR $(basename $CURRENT_BACKUP)
    rm -rf $CURRENT_BACKUP

    # Restart validator
    systemctl start firedancer

    echo "✅ Backup completed: $BACKUP_DIR/firedancer_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
}

restore_validator() {
    BACKUP_FILE=$1

    if [ -z "$BACKUP_FILE" ]; then
        echo "Usage: restore_validator <backup_file.tar.gz>"
        return 1
    fi

    echo "🔄 Restoring Firedancer from backup..."
    echo "⚠️  This will overwrite current configuration and data!"
    read -p "Continue? (y/N): " confirm

    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Restore cancelled"
        return 1
    fi

    # Stop validator
    systemctl stop firedancer

    # Extract backup
    RESTORE_DIR="/tmp/firedancer_restore_$$"
    mkdir -p $RESTORE_DIR
    tar -xzf $BACKUP_FILE -C $RESTORE_DIR

    # Restore files
    BACKUP_CONTENTS=$(ls $RESTORE_DIR)
    echo "Restoring configuration..."
    cp $RESTORE_DIR/$BACKUP_CONTENTS/config.toml $CONFIG_FILE

    echo "Restoring keypairs..."
    cp $RESTORE_DIR/$BACKUP_CONTENTS/*.json /home/firedancer/

    echo "Restoring snapshots..."
    rsync -av $RESTORE_DIR/$BACKUP_CONTENTS/snapshots/ $DATA_DIR/snapshots/

    echo "Restoring accounts..."
    rsync -av $RESTORE_DIR/$BACKUP_CONTENTS/accounts/ $DATA_DIR/accounts/

    # Fix permissions
    chown -R firedancer:firedancer /home/firedancer

    # Cleanup
    rm -rf $RESTORE_DIR

    echo "✅ Restore completed"
    echo "Start validator: systemctl start firedancer"
}

# Automated backup scheduling
setup_backup_cron() {
    cat > /etc/cron.d/firedancer-backup << 'EOF'
# Firedancer automated backups
0 2 * * * root /usr/local/bin/firedancer-backup.sh backup >/var/log/firedancer-backup.log 2>&1
0 6 * * 0 root find /backup/firedancer -name "*.tar.gz" -mtime +30 -delete
EOF

    echo "✅ Automated backup scheduled (daily at 2 AM)"
}

case "$1" in
    backup)
        backup_validator
        ;;
    restore)
        restore_validator "$2"
        ;;
    setup-cron)
        setup_backup_cron
        ;;
    *)
        echo "Usage: $0 {backup|restore <file>|setup-cron}"
        ;;
esac
```

### Troubleshooting Guide

#### Common Issues and Solutions

```bash
#!/bin/bash
# troubleshooting.sh - Firedancer troubleshooting utilities

diagnose_system() {
    echo "🔍 Firedancer System Diagnosis"
    echo "============================="

    # Check if Firedancer is running
    if pgrep -f "fdctl run" >/dev/null; then
        echo "✅ Firedancer process is running"
        PID=$(pgrep -f "fdctl run")
        echo "   Main PID: $PID"
        echo "   Child processes: $(pgrep -P $PID | wc -l)"
    else
        echo "❌ Firedancer is not running"
        echo "   Check logs: journalctl -u firedancer -f"
        return 1
    fi

    # Check network connectivity
    echo -e "\nNetwork Connectivity:"
    for endpoint in entrypoint.testnet.solana.com entrypoint.mainnet-beta.solana.com; do
        if timeout 5 nc -z $endpoint 8001 2>/dev/null; then
            echo "✅ $endpoint:8001 reachable"
        else
            echo "❌ $endpoint:8001 unreachable"
        fi
    done

    # Check local ports
    echo -e "\nLocal Ports:"
    for port in 8001 8899 7999; do
        if ss -tuln | grep -q ":$port "; then
            echo "✅ Port $port is listening"
        else
            echo "❌ Port $port is not listening"
        fi
    done

    # Check system resources
    echo -e "\nSystem Resources:"
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
    CPU_COUNT=$(nproc)
    LOAD_PERCENT=$(echo "scale=1; $LOAD / $CPU_COUNT * 100" | bc)
    echo "CPU Load: $LOAD ($LOAD_PERCENT% of $CPU_COUNT cores)"

    MEM_USED=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    echo "Memory Usage: $MEM_USED%"

    DISK_USED=$(df /home/firedancer | tail -1 | awk '{print $5}')
    echo "Disk Usage: $DISK_USED"

    # Check for common issues
    echo -e "\nCommon Issues Check:"

    # Check for slot lag
    if command -v curl >/dev/null; then
        SLOT_HEIGHT=$(curl -s http://localhost:7999/metrics 2>/dev/null | grep "fd_validator_slot_height" | awk '{print $2}')
        if [ -n "$SLOT_HEIGHT" ]; then
            echo "✅ Metrics accessible, current slot: $SLOT_HEIGHT"
        else
            echo "❌ Cannot access metrics endpoint"
        fi
    fi

    # Check for file descriptor limits
    FD_SOFT=$(ulimit -Sn)
    FD_HARD=$(ulimit -Hn)
    if [ $FD_SOFT -lt 65536 ]; then
        echo "⚠️  File descriptor limit too low: $FD_SOFT (recommended: 65536+)"
    else
        echo "✅ File descriptor limit adequate: $FD_SOFT"
    fi

    # Check for huge pages
    HUGEPAGES=$(cat /proc/meminfo | grep HugePages_Total | awk '{print $2}')
    if [ $HUGEPAGES -lt 1024 ]; then
        echo "⚠️  Huge pages not configured: $HUGEPAGES (recommended: 2048+)"
    else
        echo "✅ Huge pages configured: $HUGEPAGES"
    fi
}

fix_common_issues() {
    echo "🔧 Applying Common Fixes"
    echo "======================="

    echo "1. Increasing file descriptor limits..."
    cat > /etc/security/limits.d/99-firedancer.conf << 'EOF'
firedancer soft nofile 65536
firedancer hard nofile 65536
root soft nofile 65536
root hard nofile 65536
EOF

    echo "2. Configuring huge pages..."
    echo 2048 > /proc/sys/vm/nr_hugepages

    echo "3. Setting CPU governor to performance..."
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null

    echo "4. Disabling swap..."
    swapoff -a

    echo "5. Optimizing network settings..."
    echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
    echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
    sysctl -p

    echo "✅ Common fixes applied. Restart Firedancer to take effect."
}

collect_debug_info() {
    DEBUG_DIR="/tmp/firedancer-debug-$(date +%Y%m%d_%H%M%S)"
    mkdir -p $DEBUG_DIR

    echo "📋 Collecting Debug Information"
    echo "=============================="

    # System information
    uname -a > $DEBUG_DIR/system_info.txt
    lscpu > $DEBUG_DIR/cpu_info.txt
    free -h > $DEBUG_DIR/memory_info.txt
    df -h > $DEBUG_DIR/disk_info.txt
    ip addr show > $DEBUG_DIR/network_info.txt

    # Firedancer specific
    pstree -p $(pgrep -f "fdctl run" | head -1) > $DEBUG_DIR/process_tree.txt 2>/dev/null
    ss -tuln > $DEBUG_DIR/listening_ports.txt

    # Logs
    journalctl -u firedancer --since "1 hour ago" > $DEBUG_DIR/service_logs.txt 2>/dev/null
    dmesg | tail -100 > $DEBUG_DIR/kernel_logs.txt

    # Configuration
    cp /etc/firedancer/config.toml $DEBUG_DIR/ 2>/dev/null

    # Metrics snapshot
    curl -s http://localhost:7999/metrics > $DEBUG_DIR/metrics.txt 2>/dev/null

    # Performance data
    top -bn1 | head -20 > $DEBUG_DIR/top_output.txt
    iostat -x 1 3 > $DEBUG_DIR/iostat_output.txt 2>/dev/null

    # Create archive
    tar -czf $DEBUG_DIR.tar.gz -C /tmp $(basename $DEBUG_DIR)
    rm -rf $DEBUG_DIR

    echo "✅ Debug information collected: $DEBUG_DIR.tar.gz"
    echo "   Share this file with support for troubleshooting"
}

case "$1" in
    diagnose)
        diagnose_system
        ;;
    fix)
        fix_common_issues
        ;;
    debug)
        collect_debug_info
        ;;
    *)
        echo "Usage: $0 {diagnose|fix|debug}"
        echo "  diagnose - Run system diagnosis"
        echo "  fix      - Apply common fixes"
        echo "  debug    - Collect debug information"
        ;;
esac
```

This operational knowledge base provides comprehensive guidance for running Firedancer in production environments, covering security, performance optimization, monitoring, disaster recovery, and troubleshooting.