ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v20250120.1
ARG WORKER_VERSION=v2.0.3

# Build the worker from subsquid/worker-rs repository
FROM rust:1.81-slim-bookworm AS builder
WORKDIR /build
RUN apt-get update && \
    apt-get install -y \
    git \
    protobuf-compiler \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone and build the worker
RUN git clone https://github.com/subsquid/worker-rs.git . && \
    if [ "$WORKER_VERSION" != "latest" ]; then \
        git checkout $WORKER_VERSION; \
    fi && \
    cargo build --release

# Create minimal final image
FROM ${BASE_IMAGE}
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sysstat \
    libsqlite3-dev \
    net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc/* /var/cache/ldconfig/aux-cache /usr/lib/python3.9/__pycache__/ /usr/lib/python3.9/*/__pycache__/ /var/log/*

COPY --from=builder /build/target/release/worker /root/bin/worker

ENV LISTEN_PORT="12345"
