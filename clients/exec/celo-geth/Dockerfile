#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250203.1

FROM golang:1.19-bookworm AS builder
ENV CELO_GETH_VERSION=v1.8.4

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