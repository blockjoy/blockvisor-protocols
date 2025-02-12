ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250212.4

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV BSCRETH_VERSION=v1.1.1
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH

# Install build dependencies
RUN apt-get update && \
    apt-get install -y libclang-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    rustup target add x86_64-unknown-linux-gnu

RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $BSCRETH_VERSION https://github.com/bnb-chain/reth.git

# Build bsc-reth with Cargo caching
WORKDIR /root/reth
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/root/reth/target \
    make build-bsc && \
    cp target/release/bsc-reth /root/bin/bsc-reth

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/bsc-reth /root/bin/
