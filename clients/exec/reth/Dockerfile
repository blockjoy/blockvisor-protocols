# 5
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.1

FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV RETH_VERSION=v1.2.0
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Install system dependencies in a separate layer
RUN apt-get update && \
    apt-get install -y \
    clang \
    libclang-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust in a separate layer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup default stable && \
    rustup target add x86_64-unknown-linux-gnu

# Clone and checkout in a separate layer
WORKDIR /root
RUN --mount=type=cache,target=/root/.cargo/git \
    --mount=type=cache,target=/root/.cargo/registry \
    git clone --depth 1 --branch $RETH_VERSION https://github.com/paradigmxyz/reth.git

# Build reth with cargo caching
WORKDIR /root/reth
RUN --mount=type=cache,target=/root/.cargo/git \
    --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/reth/target \
    . "$HOME/.cargo/env" && \
    cargo build --profile maxperf && \
    mkdir -p /root/bin && \
    cp target/maxperf/reth /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/reth /root/bin/reth
