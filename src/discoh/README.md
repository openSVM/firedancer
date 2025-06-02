# discoh - Disco Hybrid/Helper Components

The `discoh` directory contains hybrid and helper implementations for specific disco tile use cases. These components serve as bridges or specialized implementations for particular deployment scenarios.

## Purpose

`discoh` provides:
- **Hybrid implementations**: Components that bridge between Firedancer and Agave
- **Helper utilities**: Specialized components for specific use cases
- **Transition components**: Tools to facilitate migration between different validator implementations

## Components

### Banking Components
- **bank**: Hybrid banking implementation for transition scenarios
- **poh**: Proof of History helper implementations

### Storage and Resolution
- **store**: Storage abstraction and helper implementations
- **resolv**: Name resolution and service discovery helpers

## Relationship to Other Disco Directories

- **disco**: Base framework and Frankendancer implementations
- **discof**: Full Firedancer implementations (production target)
- **discoh**: Hybrid/helper implementations (this directory)

## Use Cases

The `discoh` components are typically used for:
1. **Development and testing**: Specialized implementations for development workflows
2. **Migration scenarios**: Helper components when transitioning between validator versions
3. **Specialized deployments**: Custom implementations for specific operational requirements
4. **Integration testing**: Bridge components for testing interactions between different systems

## Status

These are specialized implementations that support specific use cases rather than primary production components. Most production deployments will use either the hybrid Frankendancer (disco) or full Firedancer (discof) implementations.