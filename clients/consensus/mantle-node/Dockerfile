ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250203.1
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

# Install Go
ENV GOLANG_VERSION=1.21.2
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

RUN curl -fsSL "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local

# Clone and build mantle-node
RUN git clone https://github.com/mantlenetworkio/mantle-v2.git /mantle && \
    cd /mantle && \
    git checkout ${MANTLE_VERSION} && \
    cd op-node && \
    make op-node && \
    mkdir -p /root/bin && \
    mv ./bin/op-node /root/bin/
