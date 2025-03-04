ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250304.4

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV PROTOCOL_VERSION=v3.0.3

RUN mkdir -p /root/bin

# Build Layerd
WORKDIR /root
RUN git clone --depth 1 --branch $PROTOCOL_VERSION https://github.com/tellor-io/layer

WORKDIR /root/layer
RUN go build ./cmd/layerd && \
    cp ./layerd /root/bin/
