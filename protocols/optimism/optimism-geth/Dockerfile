ARG OP_NODE_IMAGE=ghcr.io/blockjoy/op-node:v20250203.1
ARG OP_GETH_IMAGE=ghcr.io/blockjoy/op-geth:v20250203.1
ARG OP_L2GETH_IMAGE=ghcr.io/blockjoy/op-l2geth:v20250203.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250203.1

FROM ${OP_NODE_IMAGE} AS op-node

FROM ${OP_GETH_IMAGE} AS op-geth

FROM ${OP_L2GETH_IMAGE} AS op-l2geth

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

# Create necessary directories
RUN mkdir -p /root/bin /var/lib/babel/templates

# Copy binaries from builds
COPY --from=op-node /root/bin/op-node /root/bin/
COPY --from=op-geth /root/bin/op-geth /root/bin/
COPY --from=op-l2geth /root/bin/op-l2geth /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
