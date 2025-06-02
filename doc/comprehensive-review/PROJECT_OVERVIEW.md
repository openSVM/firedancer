# Firedancer Project Overview

## Project Context

**Project Name**: Firedancer
**Project Goals**: High-performance, secure, and independent Solana validator client
**Target Audience**: Solana validators, developers, network operators
**Key Technologies**: C, GNU Make, custom IPC (tango), networking (waltz), hardware acceleration
**Current State**: Active development with production-ready Frankendancer and full Firedancer in development

## What is Firedancer?

Firedancer is a ground-up reimplementation of a Solana validator client, designed with three core principles:

### 🚀 Fast
- Designed from the ground up to be *fast*
- Concurrency model draws from experience in low latency trading
- Novel high-performance reimplementations of core Solana primitives
- Tile-based architecture for optimal CPU utilization

### 🔒 Secure
- Highly restrictive sandbox with minimal system calls
- Memory safety through custom management
- Independent implementation reduces supply chain attack surface
- Security-conscious coding practices throughout

### 🏗️ Independent
- Written from scratch for client diversity
- Brings resilience to the Solana network
- No dependency on existing validator implementations
- Custom implementations of all critical components

## Two Validator Implementations

Firedancer produces two distinct validators:

### Frankendancer (Production Ready)
- **Hybrid validator** using parts of Firedancer and parts of Agave
- Uses Firedancer networking stack and block production components
- Execution and consensus use Agave validator code
- **Available now** on testnet and mainnet-beta
- Better performance while leader due to Firedancer networking

### Firedancer (Full Implementation)
- **Complete from-scratch implementation** with no Agave code
- Currently under development
- **Not ready** for test or production use
- Future target for full independence and maximum performance

## Architecture Overview

```
┌─────────────────┬─────────────────┬─────────────────┐
│   Applications  │   Applications  │   Applications  │
│                 │                 │                 │
│     fdctl       │     fddev       │   firedancer    │
│ (Frankendancer) │ (Development)   │ (Full Version)  │
└─────────────────┴─────────────────┴─────────────────┘
                          │
           ┌──────────────────────────────────┐
           │         Core Components          │
           │                                  │
           │  ┌─────────┐ ┌─────────┐ ┌──────┐│
           │  │ waltz   │ │ disco   │ │choreo││
           │  │(Network)│ │(Tiles)  │ │(Cons)││
           │  └─────────┘ └─────────┘ └──────┘│
           │                                  │
           │  ┌─────────┐ ┌─────────┐ ┌──────┐│
           │  │flamenco │ │  funk   │ │ util ││
           │  │(Runtime)│ │(Database)│ │(Core)││
           │  └─────────┘ └─────────┘ └──────┘│
           └──────────────────────────────────┘
                          │
           ┌──────────────────────────────────┐
           │        Foundation Layer          │
           │                                  │
           │  ┌─────────┐ ┌─────────┐ ┌──────┐│
           │  │ tango   │ │ ballet  │ │groove││
           │  │  (IPC)  │ │(Crypto) │ │ (DB) ││
           │  └─────────┘ └─────────┘ └──────┘│
           └──────────────────────────────────┘
```

## Key Components

### Network Layer (waltz)
- Zero-copy networking with kernel bypass
- Custom QUIC implementation for transaction ingestion
- DoS mitigation and traffic shaping
- Support for multiple high-performance NICs

### Processing Layer (disco)
Tile-based processing architecture:
- **net**: Network packet handling
- **quic**: QUIC protocol and transaction reception
- **verify**: Cryptographic signature verification
- **dedup**: Transaction deduplication
- **pack**: Transaction scheduling and bundling
- **bank**: Transaction execution
- **poh**: Proof of History generation
- **shred**: Data shredding for distribution

### Consensus Layer (choreo)
- Tower BFT consensus implementation
- Fork choice and voting logic
- Leader scheduling
- Equivocation detection

### Runtime Layer (flamenco)
- Solana runtime environment
- Account management
- Program execution
- State transitions

### Storage Layer (funk + groove)
- **funk**: Main database for ledger and accounts
- **groove**: High-performance caching layer
- Optimized for validator access patterns
- NUMA-aware memory management

### Cryptographic Layer (ballet)
- Custom implementations of cryptographic primitives
- ED25519 signatures, SHA-256/512 hashing
- Optimized for performance and security
- Multiple implementation variants (reference, AVX-512)

### Communication Layer (tango)
- High-performance IPC between tiles
- Lock-free message passing
- Flow control and backpressure handling
- Shared memory optimization

### Core Utilities (util)
- C language environment and runtime
- Memory management and data structures
- Logging, metrics, and monitoring
- Cross-platform compatibility layer

### Hardware Acceleration (wiredancer)
- FPGA-based acceleration for intensive operations
- Currently focuses on ED25519 signature verification
- AWS F1 support with 1M+ signatures/second throughput
- Extensible framework for other acceleration needs

## Performance Characteristics

### Tile Scaling Guidelines
| Tile Type | Recommended Count | Throughput per Tile | Notes |
|-----------|------------------|-------------------|--------|
| QUIC | 1 | >1M TPS | Single tile sufficient for current mainnet |
| Verify | 4+ | 20-40k TPS | Primary bottleneck, scale as needed |
| Bank | 2 | 20-40k TPS | Diminishing returns beyond 2 |
| Shred | 1 | >1M TPS | Dependent on cluster size |
| Others | 1 | Varies | Generally sufficient for current conditions |

### Hardware Requirements
- **Minimum**: Modern x86-64 CPU with Linux kernel v4.18+
- **Recommended**: High core count with multiple NUMA nodes
- **Memory**: Large memory capacity with huge page support
- **Network**: High-performance NICs with kernel bypass support
- **Storage**: High IOPS storage for database operations

## Development Workflow

### Quick Start
```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/firedancer-io/firedancer.git
cd firedancer

# Install dependencies
./deps.sh +dev

# Build and run development cluster
make -j run
```

### Build System
- GNU Make-based build system
- Machine-specific configuration in `config/machine/`
- Support for cross-compilation and optimization flags
- Integrated dependency management

### Testing Framework
- Unit tests adjacent to source code (`test_*.c`)
- Integration tests for full validator scenarios
- Fuzz testing with sanitizer support
- Continuous integration via GitHub Actions

## Documentation Structure

```
doc/
├── comprehensive-review/    # This comprehensive analysis
│   ├── phase1-codebase-analysis.md
│   ├── phase2-missing-components.md
│   ├── phase3-comprehensive-documentation.md
│   └── phase4-strategic-roadmap.md
├── build-system.md        # Build system documentation
├── testing.md             # Testing procedures and guidelines
└── organization.txt       # Source tree organization

book/                      # User-facing documentation
├── guide/                 # User guides and tutorials
│   ├── getting-started.md
│   ├── configuring.md
│   ├── tuning.md
│   └── monitoring.md
└── api/                   # API reference documentation
```

## Contributing

Firedancer is open source and welcomes contributions. Key areas for contribution include:

### High Priority
- Documentation improvements and clarifications
- Testing framework enhancements
- Performance optimization and tuning
- Security audit and hardening

### Medium Priority
- Developer experience improvements
- Integration with external tools
- Platform support expansion
- Community tooling development

### Getting Started
1. Read `CONTRIBUTING.md` for code style and guidelines
2. Set up development environment following quick start guide
3. Look for issues labeled `good-first-issue`
4. Join community discussions and ask questions

## Roadmap

The project follows a phased development approach:

### Phase 1: Foundation (Current)
- Complete documentation and architectural clarity
- Robust testing framework
- Production monitoring and observability
- Security hardening

### Phase 2: Enhancement
- Advanced monitoring and analytics
- Enhanced developer experience
- Operational tooling and automation
- Community contribution framework

### Phase 3: Advanced Features
- Elastic scaling capabilities
- Multi-region deployment support
- Advanced security features
- Research and innovation initiatives

See `doc/comprehensive-review/phase4-strategic-roadmap.md` for detailed roadmap and timeline.

## Community and Support

- **GitHub**: [firedancer-io/firedancer](https://github.com/firedancer-io/firedancer)
- **Documentation**: [docs.firedancer.io](https://docs.firedancer.io)
- **License**: Apache 2.0
- **Maintainer**: Jump Trading Group with community stewardship transition planned

## Security

Security is a core principle of Firedancer. The project includes:
- Custom implementations to reduce attack surface
- Minimal system call usage
- Memory safety practices
- Regular security audits

Report security vulnerabilities according to `SECURITY.md`.

---

*This overview provides a comprehensive introduction to the Firedancer project. For detailed technical information, see the specific documentation in the `doc/` and `book/` directories.*