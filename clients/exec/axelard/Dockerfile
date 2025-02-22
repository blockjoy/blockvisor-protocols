ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250221.1

FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV AXELARD_VERSION=v1.1.3
ENV WASM_VERSION=v1.3.1
ENV CGO_LDFLAGS=-lm

# Install build dependencies
RUN apt-get update && \
    apt-get install -y build-essential git make gcc g++ pkg-config libc6-dev musl-dev llvm-dev libclang-dev clang --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/bin

# Build Axelard
WORKDIR /root
RUN wget https://github.com/CosmWasm/wasmvm/releases/download/${WASM_VERSION}/libwasmvm_muslc.x86_64.a \
-O /lib/libwasmvm_muslc.a
RUN git clone --depth 1 --branch $AXELARD_VERSION https://github.com/axelarnetwork/axelar-core.git

WORKDIR /root/axelar-core
RUN make ARCH="x86_64" MUSLC="true" WASM="true" IBC_WASM_HOOKS="false" build && \
    cp bin/axelard /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}

# Copy binary to user's directory
COPY --from=builder /root/bin/axelard /root/bin/

