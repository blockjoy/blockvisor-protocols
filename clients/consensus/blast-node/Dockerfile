#7
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250321.2
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV BLASTOP_VERSION=v1.1.0
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENV GO_VERSION=1.21.5

# Remove existing Go installation and install Go 1.21.5
RUN rm -rf /usr/local/go && \
    wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Build Blast Node
WORKDIR /root
RUN . "$HOME/.cargo/env" && git clone https://github.com/blast-io/blast.git && \
    cd blast && \
    git checkout ${BLASTOP_VERSION} && \
    cd blast-optimism && \
    make op-node && \
    mkdir -p /root/bin && \
    mv op-node/bin/op-node /root/bin/blast-node
