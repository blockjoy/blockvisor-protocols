# blockjoy-protocols

This repository contains Docker configurations for blockchain protocol nodes and their associated clients. It includes protocol implementations and client software configurations for use with the BlockJoy platform.

## Repository Structure

```
.
├── clients/                  # Client-specific Dockerfiles and configurations
│   ├── consensus/            # Consensus client implementations
│   │   └── lighthouse/       # Lighthouse client
│   └── exec/                 # Execution client implementations
│       ├── erigon/           # Erigon client
│       └── reth/             # Reth client
├── docs/                     # Documentation
│   ├── HOWTO.md              # Protocol development guide
│   └── example-chain/        # Example protocol implementation
│       └── example-client1/  # Example client implementation
├── protocols/                # Protocol configurations
│   └── ethereum/             # Ethereum protocol configurations
│       ├── ethereum-erigon/  # Erigon-based Ethereum node
│       └── ethereum-reth/    # Reth-based Ethereum node
└── base-images/              # Base images with common utilities
```

## Documentation

- [Protocol Development Guide](docs/HOWTO.md) - Learn how to create and maintain protocol implementations
- Example implementation in `example-chain` directory
