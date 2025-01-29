ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM golang:1.22-bookworm AS builder
ENV OPERA_VERSION="release/txtracing/1.1.3-rc.5"

WORKDIR /go-opera
RUN git clone --depth 1 --branch $OPERA_VERSION https://github.com/Fantom-foundation/go-opera.git .

RUN apt update && \
    platform="$(dpkg --print-architecture)" && \
    apt install -y build-essential git linux-headers-$platform && make opera && \
    mkdir -p /root/bin && \
    cp build/opera /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/opera /root/bin/