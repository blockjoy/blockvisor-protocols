ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250304.5

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV MANTLE_GETH_VERSION=v1.1.0

# Install Go 1.20 for compatibility
ENV GOLANG_VERSION=1.20.14
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    make \
    gcc \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/local/go && \
    curl -fsSL "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local

RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $MANTLE_GETH_VERSION https://github.com/mantlenetworkio/op-geth.git

# Build mantle-op-geth with Go caching
WORKDIR /root/op-geth
RUN mkdir -p build/bin
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make geth && \
    cp build/bin/geth /root/bin/mantle-geth
