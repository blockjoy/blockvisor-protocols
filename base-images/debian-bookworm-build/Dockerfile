FROM ghcr.io/blockjoy/debian-bookworm:v20250213.4

ENV DEBIAN_FRONTEND=noninteractive

ENV GO_VERSION=1.23.1
ENV RUST_VERSION=1.75.0

RUN apt-get update --allow-insecure-repositories \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    procps \
    sysstat \
    wget \
    curl \
    software-properties-common \
    git \
    build-essential \
    libc6 \
    libfontconfig1 \
    apt-utils \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION} && \
    . "$HOME/.cargo/env" && \
    rustup target add x86_64-unknown-linux-gnu