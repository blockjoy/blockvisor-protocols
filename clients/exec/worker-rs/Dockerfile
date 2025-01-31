ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250203.1
ARG WORKER_VERSION=v2.0.3
# added to trigger build

# Build the worker from subsquid/worker-rs repository
FROM ${BASE_IMAGE} AS builder

WORKDIR /build
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    pkg-config \
    libssl-dev \
    protobuf-compiler \
    libprotobuf-dev \
    libsqlite3-dev \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

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
