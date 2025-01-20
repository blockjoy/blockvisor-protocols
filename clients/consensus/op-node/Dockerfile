#7
ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v20250120.1
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

ENV OP_NODE_VERSION=op-node/v1.10.2
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENV GO_VERSION=1.23.4

# Install system dependencies including libclang
RUN apt-get update && \
    apt-get install -y \
    clang \
    libclang-dev \
    cmake \
    make \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install go
RUN curl -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz 

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

ENV PATH=$PATH:/usr/local/go/bin:/usr/local/bin
ENV GOROOT="/usr/local/go"

# Build Op Node
WORKDIR /root
RUN . "$HOME/.cargo/env" &&git clone https://github.com/ethereum-optimism/optimism.git && \
    cd optimism && \
    git checkout ${OP_NODE_VERSION} && \
    make op-node && \
    mkdir -p /root/bin && \
    mv op-node/bin/op-node /root/bin/
