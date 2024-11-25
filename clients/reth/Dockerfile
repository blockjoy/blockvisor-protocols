FROM ghcr.io/blockjoy/node-base:abc123

# Add build arguments for Cloudflare and Grafana push credentials
ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV DEBIAN_FRONTEND=noninteractive
ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

ENV RETH_VERSION=v0.1.0-alpha.11
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Install Rust and required dependencies
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup default stable && \
    rustup target add x86_64-unknown-linux-gnu

WORKDIR /root
RUN git clone https://github.com/paradigmxyz/reth.git && \
    cd reth && \
    git checkout $RETH_VERSION

# Build reth with performance features
WORKDIR /root/reth
RUN . "$HOME/.cargo/env" && \
    mkdir /root/bin && \
    cargo build --profile maxperf && \
    cp target/maxperf/reth /root/bin/ && \
    rm -rf /root/reth

COPY Caddyfile.template /var/lib/babel/templates/Caddyfile.template
COPY config-alloy.template /var/lib/babel/templates/config-alloy.template
COPY reth.rhai /var/lib/babel/plugin/reth.rhai
