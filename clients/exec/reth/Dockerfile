ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:57f9ec4
ARG RETH_VERSION=v1.1.4
ARG LIGHTHOUSE_VERSION=v5.3.0

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Install system dependencies including libclang
RUN apt-get update && \
    apt-get install -y \
    clang \
    libclang-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust and required dependencies
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup default stable && \
    rustup target add x86_64-unknown-linux-gnu

WORKDIR /root
RUN git clone https://github.com/paradigmxyz/reth.git && \
    cd reth && \
    git checkout $RETH_VERSION

# Build reth with performance features
WORKDIR /root/reth
RUN . "$HOME/.cargo/env" && cargo build --profile maxperf && \
    mkdir -p /root/bin && \
    cp /root/reth/target/maxperf/reth /root/bin/reth
