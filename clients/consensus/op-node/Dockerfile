#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250321.2
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV OP_NODE_VERSION=op-node/v1.12.2
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Build Op Node
WORKDIR /root
RUN . "$HOME/.cargo/env" && git clone https://github.com/ethereum-optimism/optimism.git && \
    cd optimism && \
    git checkout ${OP_NODE_VERSION} && \
    cd op-node && \
    just op-node && \
    mkdir -p /root/bin && \
    mv bin/op-node /root/bin/
