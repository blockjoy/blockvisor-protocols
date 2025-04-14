# 8
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250412.4
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

ENV LIGHTHOUSE_VERSION=v6.0.1
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Build Lighthouse
WORKDIR /root
RUN git clone https://github.com/sigp/lighthouse.git && \
    cd lighthouse && \
    git checkout $LIGHTHOUSE_VERSION

WORKDIR /root/lighthouse
RUN . "$HOME/.cargo/env" && cargo build --release --features portable,gnosis && \
    mkdir -p /root/bin && \
    cp  /root/lighthouse/target/release/lighthouse /root/bin/lighthouse
