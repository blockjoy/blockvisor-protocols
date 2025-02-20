ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.1
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV MANTLE_VERSION=v1.1.0

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    make \
    gcc \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.20 for compatibility with quic-go
ENV GOLANG_VERSION=1.20.14
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p /root/bin

RUN rm -rf /usr/local/go && \
    curl -fsSL "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local

# Clone and build mantle-node
RUN git clone --recursive https://github.com/mantlenetworkio/mantle-v2.git /mantle && \
    cd /mantle && \
    git checkout ${MANTLE_VERSION} && \
    cd op-node && \
    go build -o bin/op-node ./cmd && \
    cp bin/op-node /root/bin/mantle-node
