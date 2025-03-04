FROM ghcr.io/blockjoy/debian-bookworm:v20250304.4

ENV DEBIAN_FRONTEND=noninteractive

ENV GO_VERSION=1.23.1
ENV RUST_VERSION=1.83.0
ENV NVM_VERSION=0.40.1
ENV NODE_VERSION=21.6.2

RUN apt-get update --allow-insecure-repositories \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO - 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null && \
    echo "deb [arch=all,$(dpkg --print-architecture) signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs)" | tee /etc/apt/sources.list.d/prebuilt-mpr.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    just \
    procps \
    sysstat \
    clang \
    libclang-dev \
    cmake \
    libpq-dev \
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
    rustup default ${RUST_VERSION} && \
    rustup target add x86_64-unknown-linux-gnu

RUN . "$HOME/.cargo/env" && cargo install --git https://github.com/foundry-rs/foundry --profile release --locked forge cast chisel anvil

ENV NVM_DIR=/root/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash 

RUN . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION}

RUN . "$NVM_DIR/nvm.sh" && \
    npm install -g pnpm
