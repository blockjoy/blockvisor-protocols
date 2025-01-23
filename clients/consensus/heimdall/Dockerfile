#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250120.1

FROM golang:latest AS builder

ENV HEIMDALL_VERSION=v1.0.10
WORKDIR /var/lib/heimdall

RUN apt-get update -y && \
    apt-get install -y build-essential git --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    git clone --depth 1 --branch $HEIMDALL_VERSION https://github.com/maticnetwork/heimdall.git . && \
    make build && \
    mkdir -p /root/bin && \
    cp build/heimdalld /root/bin/ && \
    cp build/heimdallcli /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}

# Create non-root user
RUN useradd -r -u 1000 -m -s /bin/bash heimdall && \
    mkdir -p /home/heimdall/bin && \
    chown -R heimdall:heimdall /home/heimdall

# Copy binaries to user's directory
COPY --from=builder --chown=heimdall:heimdall /root/bin/heimdalld /home/heimdall/bin/
COPY --from=builder --chown=heimdall:heimdall /root/bin/heimdallcli /home/heimdall/bin/

# Set PATH for the binaries
ENV PATH="/home/heimdall/bin:${PATH}"

# Switch to non-root user
USER heimdall
WORKDIR /home/heimdall
