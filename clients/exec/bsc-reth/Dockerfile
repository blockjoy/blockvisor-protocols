ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250412.4

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV BSCRETH_VERSION=v1.1.1

RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $BSCRETH_VERSION https://github.com/bnb-chain/reth.git

# Build bsc-reth with Cargo caching
WORKDIR /root/reth
RUN --mount=type=cache,target=/root/.cargo/git \
    --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/reth/target \
    . "$HOME/.cargo/env" && \
    make build-bsc && \
    cp target/release/bsc-reth /root/bin/bsc-reth

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/bsc-reth /root/bin/
