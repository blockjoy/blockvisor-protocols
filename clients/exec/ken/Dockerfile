ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.3

FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV KEN_VERSION=1.0.3

WORKDIR /root
RUN wget https://packages.kaia.io/kaia/v${KEN_VERSION}/ken-v${KEN_VERSION}-0-linux-amd64.tar.gz && \
    tar xfz ken-v${KEN_VERSION}-0-linux-amd64.tar.gz && \
    rm ken-v${KEN_VERSION}-0-linux-amd64.tar.gz

FROM ${BASE_IMAGE}
RUN mkdir -p /root/bin/
COPY --from=builder /root/ken-linux-amd64/bin/ken /root/bin/