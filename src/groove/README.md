# groove - High-Performance Database Layer

The `groove` directory implements a high-performance, thread-safe database layer optimized for Firedancer's specific access patterns and performance requirements.

## Purpose

Groove provides:
- **High-performance storage**: Optimized for blockchain validator access patterns
- **Thread-safe operations**: Safe concurrent access across multiple tiles
- **Memory-efficient**: Custom memory management for optimal performance
- **Atomic operations**: ACID compliance with minimal overhead

## Architecture

Groove is built around several key abstractions:

### Core Components
- **fd_groove_base**: Foundation types, error codes, and base functionality
- **fd_groove_meta**: Metadata management and indexing
- **fd_groove_volume**: Volume and space management
- **fd_groove_data**: Main data storage and retrieval API

### Key Features
- **NUMA-aware**: Optimized for multi-socket systems
- **Lock-free where possible**: Minimizes contention between tiles
- **Memory-mapped I/O**: Efficient disk access patterns
- **Configurable consistency**: Tunable consistency vs performance trade-offs

## API Overview

The groove API provides:
- **Key-value storage**: Binary keys with arbitrary value data
- **Atomic operations**: Compare-and-swap, atomic updates
- **Range queries**: Efficient iteration over key ranges
- **Snapshot isolation**: Consistent read views

## Relationship to funk

While `funk` provides the main database implementation for Solana ledger and accounts, `groove` serves as a complementary high-performance storage layer for:
- **Hot data**: Frequently accessed account data
- **Caching layer**: Performance optimization for common queries
- **Specialized storage**: Use cases requiring specific performance characteristics

## Performance Characteristics

Groove is optimized for:
- **High read throughput**: Millions of reads per second
- **Low latency access**: Microsecond-level access times
- **Concurrent access**: Efficient multi-threaded operation
- **Cache efficiency**: Optimized memory access patterns

## Configuration

Groove behavior can be tuned through various parameters:
- **Memory allocation**: Page sizes and allocation strategies
- **Concurrency**: Thread synchronization methods
- **Persistence**: Durability vs performance trade-offs
- **Caching**: Cache sizes and eviction policies

## Usage in Firedancer

Groove is used by tiles that require high-performance data access:
- **Bank tiles**: Account state caching
- **Verification tiles**: Signature verification caches
- **Consensus tiles**: Vote and stake information

## Error Handling

Groove uses a consistent error code system:
- **FD_GROOVE_SUCCESS**: Operation completed successfully
- **FD_GROOVE_ERR_INVAL**: Invalid parameters
- **FD_GROOVE_ERR_AGAIN**: Operation should be retried
- **FD_GROOVE_ERR_CORRUPT**: Data corruption detected
- **FD_GROOVE_ERR_EMPTY**: No data available
- **FD_GROOVE_ERR_FULL**: Storage capacity exceeded

## Thread Safety

Groove is designed for safe concurrent use with:
- **Atomic operations**: Lock-free primitives where possible
- **Reader-writer locks**: For operations requiring coordination
- **Memory barriers**: Proper ordering guarantees
- **Hazard pointers**: Safe memory reclamation

See individual header files for detailed API documentation.