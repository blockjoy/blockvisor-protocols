#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.4

FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV BOR_VERSION=v1.5.4
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

# Install build dependencies
RUN apt-get update && \
    apt-get install -y build-essential git make gcc g++ pkg-config llvm-dev libclang-dev clang --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/bin

# Build Bor
WORKDIR /root
RUN git clone --depth 1 --branch $BOR_VERSION https://github.com/maticnetwork/bor.git

WORKDIR /root/bor
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make bor && \
    cp build/bin/bor /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}

# Create non-root user
RUN useradd -r -u 1000 -m -s /bin/bash bor && \
    mkdir -p /home/bor/bin && \
    chown -R bor:bor /home/bor

# Copy binary to user's directory
COPY --from=builder --chown=bor:bor /root/bin/bor /home/bor/bin/

# Set PATH for the binary
ENV PATH="/home/bor/bin:${PATH}"

# Switch to non-root user
USER bor
WORKDIR /home/bor
