#!/bin/bash

set -euo pipefail

# Build node-base
echo "Building node-base..."
docker buildx build \
    --platform "linux/amd64" \
    -t node-base:latest .
