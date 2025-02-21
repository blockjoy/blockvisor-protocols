#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.6

FROM ${BASE_IMAGE} AS builder

ENV CELO_GETH_VERSION=v1.8.4

# Remove any existing Go installation
RUN rm -rf /usr/local/go

ENV GOLANG_VERSION=1.21.2
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local

WORKDIR /go-ethereum
RUN git clone --depth 1 --branch $CELO_GETH_VERSION https://github.com/celo-org/celo-blockchain.git .

RUN apt update && \
    platform="$(dpkg --print-architecture)" && \
    apt install -y build-essential git linux-headers-$platform && make geth && \
    mkdir -p /root/bin && \
    cp build/bin/geth /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/geth /root/bin/