# discof - Firedancer Disco Tiles

The `discof` directory contains the complete Firedancer tile implementations. This is the "Full Firedancer" version of disco tiles that implement all functionality from scratch without relying on Agave components.

## Relationship to disco

- **disco**: Base tile framework and Frankendancer hybrid implementations
- **discof**: Full Firedancer implementations of all tiles (this directory)
- **discoh**: Hybrid/helper implementations for specific use cases

## Tile Implementations

### Banking and Execution
- **bank**: Full Solana runtime implementation for transaction execution
- **exec**: Advanced execution engine components
- **execor**: Execution orchestration and coordination

### Block Processing
- **batch**: Transaction batching and processing
- **poh**: Proof of History implementation from scratch
- **writer**: Block and state writing to storage

### Consensus
- **consensus**: Full consensus mechanism implementation
- **replay**: Block replay and validation logic
- **eqvoc**: Equivocation detection and slashing

### Communication
- **gossip**: Cluster communication and peer discovery
- **repair**: Block repair and synchronization protocols
- **sender**: Network packet transmission
- **rpcserver**: JSON-RPC server implementation

### Management
- **restart**: Validator restart and recovery logic
- **resolv**: Name resolution and service discovery
- **forest**: Fork choice and tree management

## Key Differences from Hybrid Version

The `discof` implementations are:
- **Independent**: No dependency on Agave code
- **Optimized**: Designed specifically for Firedancer's architecture
- **Secure**: Implement Firedancer's security model from the ground up
- **High-performance**: Optimized for the tile-based architecture

## Status

These implementations represent the future of Firedancer as a fully independent validator. While Frankendancer (hybrid) is production-ready, the full Firedancer validator using these implementations is under active development.

## Usage

These tiles are used when running the full `firedancer` binary rather than the hybrid `fdctl` (Frankendancer) implementation.