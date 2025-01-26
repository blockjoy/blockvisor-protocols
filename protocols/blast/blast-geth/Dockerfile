ARG BLAST_OP_NODE_IMAGE=ghcr.io/blockjoy/blast-node:v20250125.1
ARG BLAST_OP_GETH_IMAGE=ghcr.io/blockjoy/blast-geth:v20250126.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${BLAST_OP_NODE_IMAGE} AS blast-op-node

FROM ${BLAST_OP_GETH_IMAGE} AS blast-op-geth

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

# Create necessary directories
RUN mkdir -p /root/bin /root/config/{mainnet,sepolia} /var/lib/babel/templates

# Copy binaries from builds
COPY --from=blast-op-node /root/bin/blast-node /root/bin/
COPY --from=blast-op-geth /root/bin/blast-geth /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY templates/genesis-json.template /var/lib/babel/templates/
COPY templates/rollup-json.template /var/lib/babel/templates/
COPY blast-geth.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
