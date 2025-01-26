ARG OP_NODE_IMAGE=ghcr.io/blockjoy/op-node:v20250125.1
ARG OP_RETH_IMAGE=ghcr.io/blockjoy/op-reth:v20250123.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${OP_NODE_IMAGE} AS op-node

FROM ${OP_RETH_IMAGE} AS op-reth

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

# Create necessary directories
RUN mkdir -p /root/bin /root/lib /var/lib/babel/templates

# Copy binaries from builds
COPY --from=op-node /root/bin/op-node /root/bin/
COPY --from=op-reth /root/bin/op-reth /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY op-reth.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
