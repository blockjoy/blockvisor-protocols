FROM node-base:0.0.1

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    clang \
    libclang-dev \
    llvm-dev \
    && rm -rf /var/lib/apt/lists/*

ENV RETH_VERSION=v1.1.2
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

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
RUN . "$HOME/.cargo/env" && \
    mkdir /root/bin && \
    cargo build --profile maxperf && \
    cp target/maxperf/reth /root/bin/ && \
    rm -rf /root/reth

COPY Caddyfile.template /var/lib/babel/templates/Caddyfile.template
COPY config-alloy.template /var/lib/babel/templates/config-alloy.template
COPY reth.rhai /var/lib/babel/plugin/reth.rhai
