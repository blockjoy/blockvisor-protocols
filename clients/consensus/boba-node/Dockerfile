#7
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250304.5
FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV CLIENT_VERSION=v1.6.15
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Build Op Node
WORKDIR /root
RUN . "$HOME/.cargo/env" && \
    git clone https://github.com/bobanetwork/boba.git && \
    cd boba && \
    git checkout ${CLIENT_VERSION} && \
    make op-node && \
    mkdir -p /root/bin 
RUN mv boba/op-node/bin/op-node /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/op-node /root/bin/