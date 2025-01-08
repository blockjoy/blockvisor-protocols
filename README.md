# blockjoy-protocols

This repository contains Docker configurations for blockchain protocol nodes and their associated clients. It includes automated build processes and version management for both protocol implementations and client software.

## Repository Structure

```
.
├── clients/                # Client-specific Dockerfiles and configurations
│   ├── consensus/         # Consensus client implementations
│   │   └── lighthouse/    # Lighthouse client
│   └── exec/             # Execution client implementations
│       ├── erigon/       # Erigon client
│       └── reth/         # Reth client
├── protocols/            # Protocol-specific implementations
│   └── ethereum/         # Ethereum protocol configurations
└── node-base/           # Base image with common utilities and monitoring
```

## Automation Features

### GitHub Actions Workflow

The repository uses a GitHub Actions workflow (`docker-build.yml`) that handles:

1. **Change Detection**: Automatically detects changes in client and protocol directories
2. **Version Management**: 
   - Generates versioned tags in format `vYYYYMMDD.N` (e.g., `v20250108.1`)
   - Includes git SHA in image tags for traceability
3. **Build Matrix**: Dynamically builds affected images based on changes
4. **Image Publishing**: Publishes images to GitHub Container Registry (ghcr.io)

### Renovate Bot Integration

Renovate bot manages dependency updates with the following features:

1. **Version Control**:
   - Prevents major version updates for clients by default
   - Allows excluding specific problematic versions using regex patterns
2. **Docker Updates**:
   - Monitors and updates base images
   - Updates client versions in Dockerfiles
3. **Automated PRs**: Creates pull requests for version updates that pass the configured rules

## Creating New Images

### Adding a New Client

1. Create a new directory under `clients/`:
```bash
clients/
└── [consensus|exec]/
    └── your-client/
        ├── Dockerfile
        └── ... (additional files)
```

2. Dockerfile requirements:
```dockerfile
# 1. Use the base image
ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v176
FROM ${BASE_IMAGE}

# 2. Set client version (required for automation)
ENV YOUR_CLIENT_VERSION=v1.2.3

# 3. Add your build steps
RUN ...
```

### Adding a New Protocol

1. Create a new directory under the protocol type:
```bash
protocols/
└── your-protocol/
    └── your-implementation/
        ├── Dockerfile
        └── ... (additional files)
```

2. Dockerfile requirements:
```dockerfile
# 1. Reference client images using ARG
ARG CLIENT_IMAGE=ghcr.io/blockjoy/your-client:latest
FROM ${CLIENT_IMAGE}

# 2. Add protocol-specific configurations
COPY . .
```

## Build Process

1. **Local Testing**:
```bash
# Build node-base image
docker build \
  -t localhost:5000/blockjoy/node-base:latest \
  node-base/

# Build client image using local node-base
docker build \
  --build-arg BASE_IMAGE=localhost:5000/blockjoy/node-base:latest \
  -t localhost:5000/blockjoy/your-client:latest \
  clients/[consensus|exec]/your-client/

# Build protocol image using local client
docker build \
  --build-arg CLIENT_IMAGE=localhost:5000/blockjoy/your-client:latest \
  -t localhost:5000/blockjoy/your-protocol:latest \
  protocols/your-protocol/your-implementation/

# Push images to local registry (if needed)
docker push localhost:5000/blockjoy/node-base:latest
docker push localhost:5000/blockjoy/your-client:latest
docker push localhost:5000/blockjoy/your-protocol:latest
```

2. **Automated Builds**:
- Push changes to a branch
- Create a pull request
- GitHub Actions will:
  - Build affected images
  - Tag with version and SHA
  - Push to ghcr.io

## Version Management

- Client versions are managed in their respective Dockerfiles using `*_VERSION` environment variables
- To exclude problematic versions, add regex patterns to `renovate.json`:
```json
{
  "packageRules": [
    {
      "matchPaths": ["clients/your-client/**"],
      "matchPackagePatterns": ["YOUR_CLIENT_VERSION"],
      "ignoreVersions": ["/^1\\.2\\.3-.*/" ]
    }
  ]
}
```

## Notes

- All images are built from the `node-base` image which provides common utilities and monitoring capabilities
- Version tags are generated daily with an incremental counter (e.g., `v20250108.1`, `v20250108.2`)
- Each image also includes the git SHA for traceability
- Protocol images are named using their protocol directory name (e.g., `ethereum-erigon`)