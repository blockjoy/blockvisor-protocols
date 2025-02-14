#7
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250213.4
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV OP_NODE_VERSION=op-node/v1.11.0
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Install additional system dependencies
RUN apt-get update && \
    apt-get install -y \
    clang \
    libclang-dev \
    cmake \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install node
# Download and install nvm:
ENV NVM_DIR=/root/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash 

RUN . "$NVM_DIR/nvm.sh" && \
    nvm install 22

# Install pnpm
RUN . "$NVM_DIR/nvm.sh" && \
    npm install -g pnpm

# Install Rust and required dependencies
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup default stable && \
    rustup target add x86_64-unknown-linux-gnu

# Install Just
RUN . "$HOME/.cargo/env" && cargo install just

# Install Foundry
RUN . "$HOME/.cargo/env" && cargo install --git https://github.com/foundry-rs/foundry --profile release --locked forge cast chisel anvil

# Build Op Node
WORKDIR /root
RUN . "$HOME/.cargo/env" && git clone https://github.com/ethereum-optimism/optimism.git && \
    cd optimism && \
    git checkout ${OP_NODE_VERSION} && \
    make op-node && \
    mkdir -p /root/bin && \
    mv op-node/bin/op-node /root/bin/
