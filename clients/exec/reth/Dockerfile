FROM node-base:latest

ENV DEBIAN_FRONTEND=noninteractive

ENV RETH_VERSION=v1.1.4
ENV LIGHTHOUSE_VERSION=v5.3.0
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
RUN . "$HOME/.cargo/env" && cargo build --profile maxperf
