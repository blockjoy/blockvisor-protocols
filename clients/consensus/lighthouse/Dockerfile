ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v1
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

ENV LIGHTHOUSE_VERSION=v5.3.0
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Install system dependencies including libclang
RUN apt-get update && \
    apt-get install -y \
    clang \
    libclang-dev \
    cmake \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust and required dependencies
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup default stable && \
    rustup target add x86_64-unknown-linux-gnu

# Build Lighthouse
WORKDIR /root
RUN git clone https://github.com/sigp/lighthouse.git && \
    cd lighthouse && \
    git checkout $LIGHTHOUSE_VERSION

WORKDIR /root/lighthouse
RUN . "$HOME/.cargo/env" && cargo build --release --features portable && \
    mkdir -p /root/bin && \
    cp  /root/lighthouse/target/release/lighthouse /root/bin/lighthouse
