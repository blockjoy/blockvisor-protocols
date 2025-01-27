ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV AXELARD_VERSION=v1.1.3

# Install build dependencies
RUN apt-get update && \
    apt-get install -y build-essential git make gcc g++ pkg-config llvm-dev libclang-dev clang --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/bin

# Build Axelard
WORKDIR /root
RUN git clone --depth 1 --branch $AXELARD_VERSION https://github.com/axelarnetwork/axelar-core.git

WORKDIR /root/axelar-core
RUN make build && \
    cp bin/axelard /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}

# Copy binary to user's directory
COPY --from=builder /root/bin/axelard /root/bin/
