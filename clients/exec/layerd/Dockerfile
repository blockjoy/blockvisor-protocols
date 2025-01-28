ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM golang:1.23-bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV PROTOCOL_VERSION=v2.0.1-fix

# Install build dependencies
RUN apt-get update && \
    apt-get install -y build-essential git make gcc g++ pkg-config llvm-dev libclang-dev clang --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/bin

# Build Layerd
WORKDIR /root
RUN git clone --depth 1 --branch $PROTOCOL_VERSION https://github.com/tellor-io/layer

WORKDIR /root/layer
RUN go build ./cmd/layerd && \
    cp ./layerd /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}

# Copy binary to user's directory
COPY --from=builder /root/bin/layerd /root/bin/