# Blockvisor Protocols

This repository contains Docker configurations for blockchain protocol nodes and their associated clients. It includes protocol implementations and client software configurations for use with the BlockJoy platform.

## Overview

Blockvisor Protocols is a comprehensive collection of containerized blockchain node implementations designed to run on the BlockJoy platform. This repository provides standardized, production-ready Docker configurations for deploying and managing a wide variety of blockchain protocols.

Key features:
- Containerized blockchain node implementations for 20+ protocols
- Standardized configuration and deployment patterns
- Resource-optimized variants (full, archive, etc.)
- Integrated with BlockJoy platform services

## Repository Structure

```
.
├── base-images/              # Base images with common utilities
│   ├── debian-bookworm/      # Debian Bookworm base image
│   └── ...                   # Other base images
├── clients/                  # Client-specific Dockerfiles and configurations
│   ├── consensus/            # Consensus client implementations
│   │   ├── lighthouse/       # Lighthouse client
│   │   ├── heimdall/         # Heimdall client
│   │   └── ...               # Other consensus clients
│   └── exec/                 # Execution client implementations
│       ├── erigon/           # Erigon client
│       ├── reth/             # Reth client
│       ├── geth/             # Go-Ethereum client
│       └── ...               # Other execution clients
├── docs/                     # Documentation
│   ├── HOWTO.md              # Protocol development guide
│   └── example/              # Example implementation
├── protocols/                # Protocol configurations
│   ├── ethereum/             # Ethereum protocol configurations
│   │   ├── ethereum-erigon/  # Erigon-based Ethereum node
│   │   └── ethereum-reth/    # Reth-based Ethereum node
│   ├── avalanche/            # Avalanche protocol configurations
│   ├── cosmos/               # Cosmos protocol configurations
│   └── ...                   # Other protocol configurations
```

## Supported Protocols

This repository includes implementations for numerous blockchain protocols, including:

- Ethereum and EVM-compatible chains (Optimism, Arbitrum, Base, etc.)
- Layer 1 blockchains (Avalanche, Near, Sui, etc.)
- Layer 2 solutions (Arbitrum, Optimism, Polygon, etc.)
- Specialized protocols (Tellor, SQD, etc.)

Each protocol implementation follows a standardized structure and includes:
- Container image definitions
- Protocol configuration metadata (`babel.yaml`)
- Configuration templates and runtime scripts

## Getting Started

### Creating a New Protocol Implementation

To create a new protocol implementation:

1. Ensure clients are available in the `clients/` directory
2. Create a new directory in `protocols/<protocol-name>/<protocol-name>-<client>/`
3. Create required files:
   - `babel.yaml` - Protocol metadata and configuration
   - `main.rhai` - Main protocol interface
   - `aux.rhai` - Auxiliary functions
   - `Dockerfile` - Container configuration
   - `templates/` - Configuration templates

See the [Protocol Development Guide](docs/HOWTO.md) and example in `docs/example/` for a detailed walkthrough.

## Runtime Architecture

Protocol images use a standardized runtime interface based on:
- Metadata configuration (`babel.yaml`)
- Runtime interface (`main.rhai` and other Rhai scripts)
- Container configuration (`Dockerfile`)

The BlockJoy platform uses this interface to:
- Plan and allocate resources for node deployments
- Configure networking and firewall rules
- Initialize and manage protocol services
- Monitor node health and status

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.
