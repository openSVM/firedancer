# Firedancer Validator & RPC Monitoring Guide

This guide provides comprehensive monitoring metrics and alerting recommendations for running Firedancer as a validator or RPC node.

## 🎯 Critical Metrics Overview

### Validator Performance Metrics

| Metric | Description | Threshold | Alert Level |
|--------|-------------|-----------|-------------|
| `validator_slot_height` | Current processed slot | Lagging >10 slots | Critical |
| `validator_vote_distance` | Distance from latest vote | >5 slots | Warning |
| `validator_skip_rate` | Block production skip rate | >5% | Critical |
| `validator_stake_percent` | Validator stake percentage | <0.01% | Warning |
| `validator_balance_sol` | Validator balance in SOL | <1 SOL | Critical |

### Network & Consensus Metrics

| Metric | Description | Threshold | Alert Level |
|--------|-------------|-----------|-------------|
| `gossip_peer_count` | Active gossip peers | <50 peers | Warning |
| `gossip_messages_per_sec` | Gossip message rate | <100/sec | Warning |
| `tower_vote_credits` | Accumulated vote credits | Decreasing | Warning |
| `fork_choice_active_forks` | Number of active forks | >3 forks | Warning |
| `transaction_pool_size` | Pending transactions | >10000 | Warning |

### System Performance Metrics

| Metric | Description | Threshold | Alert Level |
|--------|-------------|-----------|-------------|
| `cpu_usage_percent` | CPU utilization | >90% | Critical |
| `memory_usage_percent` | Memory utilization | >85% | Critical |
| `disk_usage_percent` | Disk utilization | >90% | Critical |
| `network_bandwidth_mbps` | Network throughput | >800 Mbps | Warning |
| `tile_backpressure_percent` | Tile backpressure | >10% | Warning |

## 📊 Prometheus Metrics Collection

### Basic Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'firedancer-validator'
    static_configs:
      - targets: ['localhost:7999']
    scrape_interval: 5s
    metrics_path: /metrics

  - job_name: 'firedancer-system'
    static_configs:
      - targets: ['localhost:9100']
    scrape_interval: 10s

rule_files:
  - "firedancer_alerts.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### Key Firedancer Metrics

#### Validator Health Metrics
```prometheus
# Slot progression rate
fd_validator_slot_height

# Vote performance
fd_validator_vote_distance
fd_validator_vote_credits_total

# Block production
fd_validator_blocks_produced_total
fd_validator_blocks_skipped_total
fd_validator_leader_slots_total

# Stake and economics
fd_validator_stake_lamports
fd_validator_balance_lamports
fd_validator_commission_percent
```

#### Network Performance Metrics
```prometheus
# Gossip network
fd_gossip_peers_active
fd_gossip_messages_received_total
fd_gossip_messages_sent_total
fd_gossip_pull_requests_total

# Transaction processing
fd_transactions_processed_total
fd_transactions_failed_total
fd_transaction_pool_size

# Network I/O
fd_network_packets_received_total
fd_network_packets_sent_total
fd_network_bytes_received_total
fd_network_bytes_sent_total
```

#### Tile Performance Metrics
```prometheus
# Individual tile performance
fd_tile_heartbeat_timestamp{tile="net"}
fd_tile_heartbeat_timestamp{tile="quic"}
fd_tile_heartbeat_timestamp{tile="verify"}
fd_tile_heartbeat_timestamp{tile="dedup"}
fd_tile_heartbeat_timestamp{tile="pack"}
fd_tile_heartbeat_timestamp{tile="bank"}

# Tile utilization
fd_tile_cpu_percent{tile="*"}
fd_tile_backpressure_percent{tile="*"}
fd_tile_overrun_percent{tile="*"}

# Inter-tile communication
fd_tile_message_backlog{from="*",to="*"}
fd_tile_message_rate{from="*",to="*"}
```

#### RPC Performance Metrics
```prometheus
# RPC request metrics
fd_rpc_requests_total{method="*"}
fd_rpc_request_duration_seconds{method="*"}
fd_rpc_requests_failed_total{method="*"}

# RPC connection metrics
fd_rpc_connections_active
fd_rpc_connections_total
fd_rpc_bytes_sent_total
fd_rpc_bytes_received_total

# Specific RPC methods
fd_rpc_getAccountInfo_total
fd_rpc_getBalance_total
fd_rpc_getBlockHeight_total
fd_rpc_getSlot_total
fd_rpc_sendTransaction_total
```

## 🚨 Critical Alerting Rules

### Validator Health Alerts

```yaml
# firedancer_alerts.yml
groups:
  - name: firedancer_validator
    rules:
    - alert: ValidatorBehindSlots
      expr: fd_validator_slot_distance > 10
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Validator is {{ $value }} slots behind"
        description: "Validator has fallen behind the network consensus"

    - alert: ValidatorSkipRateHigh
      expr: rate(fd_validator_blocks_skipped_total[5m]) / rate(fd_validator_leader_slots_total[5m]) > 0.05
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Block skip rate is {{ $value | humanizePercentage }}"
        description: "Validator is skipping too many blocks during leadership"

    - alert: ValidatorBalanceLow
      expr: fd_validator_balance_lamports / 1000000000 < 1
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Validator balance is {{ $value }} SOL"
        description: "Validator balance is critically low"

    - alert: ValidatorNotVoting
      expr: increase(fd_validator_vote_credits_total[10m]) == 0
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: "Validator has not voted in 10 minutes"
        description: "Validator appears to have stopped voting"
```

### System Performance Alerts

```yaml
  - name: firedancer_system
    rules:
    - alert: HighCPUUsage
      expr: fd_system_cpu_percent > 90
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "CPU usage is {{ $value }}%"
        description: "System CPU usage is critically high"

    - alert: HighMemoryUsage
      expr: fd_system_memory_percent > 85
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Memory usage is {{ $value }}%"
        description: "System memory usage is high"

    - alert: TileBackpressure
      expr: fd_tile_backpressure_percent > 10
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "Tile {{ $labels.tile }} backpressure is {{ $value }}%"
        description: "High backpressure detected in processing tile"
```

### Network Health Alerts

```yaml
  - name: firedancer_network
    rules:
    - alert: LowGossipPeers
      expr: fd_gossip_peers_active < 50
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Only {{ $value }} gossip peers connected"
        description: "Gossip peer count is low, potential network isolation"

    - alert: RPCHighErrorRate
      expr: rate(fd_rpc_requests_failed_total[5m]) / rate(fd_rpc_requests_total[5m]) > 0.1
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "RPC error rate is {{ $value | humanizePercentage }}"
        description: "High error rate detected in RPC requests"
```

## 📈 Grafana Dashboard Recommendations

### Essential Dashboard Panels

1. **Validator Overview**
   - Current slot height vs network
   - Vote distance trend
   - Block production performance
   - Stake and balance monitoring

2. **Network Performance**
   - Gossip peer connections
   - Transaction throughput
   - Network bandwidth utilization
   - Latency distributions

3. **System Resources**
   - CPU, memory, disk utilization
   - Network interface statistics
   - Process count and status
   - File descriptor usage

4. **Tile Performance**
   - Individual tile CPU usage
   - Inter-tile message flows
   - Backpressure monitoring
   - Tile restart frequency

### Grafana Panel Queries

```promql
# Validator slot lag
fd_validator_slot_height - on() fd_network_slot_height

# Block production success rate
rate(fd_validator_blocks_produced_total[5m]) / rate(fd_validator_leader_slots_total[5m])

# Transaction processing rate
rate(fd_transactions_processed_total[1m])

# Tile CPU usage heatmap
fd_tile_cpu_percent

# Network throughput
rate(fd_network_bytes_received_total[1m]) * 8 / 1000000
```

## 🔧 Monitoring Commands

### Quick Health Checks

```bash
# Check validator status
curl -s http://localhost:7999/metrics | grep fd_validator_slot_height

# Monitor tile performance
fdctl monitor --config config.toml

# Check RPC health
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"getHealth"}' \
  http://localhost:8899

# Verify gossip connectivity
solana gossip --url http://localhost:8899

# Check vote account status
solana vote-account --url http://localhost:8899 VOTE_ACCOUNT_ADDRESS
```

### Performance Monitoring Scripts

```bash
#!/bin/bash
# firedancer-health-check.sh

echo "=== Firedancer Health Check ==="
echo "Timestamp: $(date)"
echo

# Check if validator is running
if ! pgrep -f "fdctl run" > /dev/null; then
    echo "❌ Firedancer is not running!"
    exit 1
fi

# Check slot height
SLOT=$(curl -s http://localhost:7999/metrics | grep "fd_validator_slot_height" | awk '{print $2}')
echo "Current slot: $SLOT"

# Check voting status
VOTE_DISTANCE=$(curl -s http://localhost:7999/metrics | grep "fd_validator_vote_distance" | awk '{print $2}')
echo "Vote distance: $VOTE_DISTANCE"

# Check balance
BALANCE=$(curl -s http://localhost:7999/metrics | grep "fd_validator_balance_lamports" | awk '{print $2}')
BALANCE_SOL=$(echo "scale=2; $BALANCE / 1000000000" | bc)
echo "Balance: $BALANCE_SOL SOL"

# Check system resources
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEM=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
echo "CPU: ${CPU}%, Memory: ${MEM}%"

echo "✅ Health check complete"
```

## 🎛️ Advanced Monitoring Setup

### Log Aggregation with ELK Stack

```yaml
# filebeat.yml
filebeat.inputs:
- type: log
  paths:
    - /home/firedancer/.firedancer/fd1/log/*.log
  fields:
    service: firedancer
    environment: production

output.elasticsearch:
  hosts: ["localhost:9200"]
  index: "firedancer-logs-%{+yyyy.MM.dd}"

processors:
  - timestamp:
      field: timestamp
      layouts:
        - '2006-01-02T15:04:05.000Z'
```

### Custom Metric Collection

```python
#!/usr/bin/env python3
# firedancer-custom-metrics.py

import time
import json
import requests
from prometheus_client import Gauge, Counter, start_http_server

# Define custom metrics
slot_height_gauge = Gauge('fd_custom_slot_height', 'Current validator slot height')
vote_lag_gauge = Gauge('fd_custom_vote_lag', 'Validator vote lag in seconds')
network_health_gauge = Gauge('fd_custom_network_health_score', 'Overall network health score')

def collect_metrics():
    """Collect and export custom Firedancer metrics"""
    try:
        # Get metrics from Firedancer
        response = requests.get('http://localhost:7999/metrics', timeout=5)
        metrics = response.text

        # Parse and export slot height
        for line in metrics.split('\n'):
            if 'fd_validator_slot_height' in line and not line.startswith('#'):
                slot_height = float(line.split()[-1])
                slot_height_gauge.set(slot_height)
                break

        # Calculate vote lag
        rpc_response = requests.post('http://localhost:8899',
            json={"jsonrpc":"2.0","id":1,"method":"getSlot"}, timeout=5)
        network_slot = rpc_response.json()['result']
        vote_lag = max(0, network_slot - slot_height)
        vote_lag_gauge.set(vote_lag)

        # Calculate network health score (0-100)
        health_score = max(0, 100 - (vote_lag * 10))
        network_health_gauge.set(health_score)

    except Exception as e:
        print(f"Error collecting metrics: {e}")

if __name__ == '__main__':
    start_http_server(8000)
    print("Custom metrics server started on port 8000")

    while True:
        collect_metrics()
        time.sleep(15)
```

This comprehensive monitoring setup provides complete visibility into Firedancer validator and RPC performance, enabling proactive issue detection and optimal performance maintenance.