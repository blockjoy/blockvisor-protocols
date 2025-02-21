#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.6

FROM ${BASE_IMAGE}

ENV HEIMDALL_VERSION=v1.0.10

# Create non-root user first
RUN useradd -r -u 1000 -m -s /bin/bash heimdall && \
    mkdir -p /home/heimdall/bin && \
    chown -R heimdall:heimdall /home/heimdall

# Build heimdall
WORKDIR /var/lib/heimdall
RUN apt-get update -y && \
    apt-get install -y build-essential git --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    git clone --depth 1 --branch ${HEIMDALL_VERSION} https://github.com/maticnetwork/heimdall.git . && \
    make build && \
    cp build/heimdalld /home/heimdall/bin/ && \
    cp build/heimdallcli /home/heimdall/bin/ && \
    chown -R heimdall:heimdall /home/heimdall/bin

# Set PATH for the binaries
ENV PATH="/home/heimdall/bin:${PATH}"

# Switch to non-root user
USER heimdall
WORKDIR /home/heimdall
