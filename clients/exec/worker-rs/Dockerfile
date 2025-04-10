ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250321.2
ARG WORKER_VERSION=v2.2.0

FROM ${BASE_IMAGE} AS builder

WORKDIR /build
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    pkg-config \
    libssl-dev \
    protobuf-compiler \
    libprotobuf-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone and build the worker
RUN git clone https://github.com/subsquid/worker-rs.git . && \
    if [ "$WORKER_VERSION" != "latest" ]; then \
        git checkout $WORKER_VERSION; \
    fi && \
    . "$HOME/.cargo/env" && \
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
