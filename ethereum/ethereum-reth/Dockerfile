# 5
ARG RETH_IMAGE=ghcr.io/blockjoy/reth:v20250110.2
ARG LIGHTHOUSE_IMAGE=ghcr.io/blockjoy/lighthouse:v20250110.2
ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v20250109.3

FROM ${RETH_IMAGE} AS reth

FROM ${LIGHTHOUSE_IMAGE} AS lighthouse-build

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

RUN mkdir -p /root/bin
COPY --from=reth /root/bin/reth /root/bin/
COPY --from=lighthouse-build /root/bin/lighthouse /root/bin/

COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY reth.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
