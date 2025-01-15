#4
ARG OP_RETH_IMAGE=ghcr.io/blockjoy/op-reth:v20250115.1
ARG OP_NODE_IMAGE=ghcr.io/blockjoy/op-node:v20250114.2
ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v20250109.3

FROM ${OP_RETH_IMAGE} AS op_reth
FROM ${OP_NODE_IMAGE} AS op_node

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

RUN mkdir -p /root/bin
COPY --from=op_reth /root/bin/op-reth /root/bin/
COPY --from=op_node /root/bin/op-node /root/bin/

COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY base-op-reth.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
