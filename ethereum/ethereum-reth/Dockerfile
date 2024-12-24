# 5
ARG RETH_IMAGE=ghcr.io/blockjoy/reth:v163
ARG LIGHTHOUSE_IMAGE=ghcr.io/blockjoy/lighthouse:v163
ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v154

FROM ${RETH_IMAGE} AS reth-build

FROM ${LIGHTHOUSE_IMAGE} AS lighthouse-build

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

RUN mkdir -p /root/bin
COPY --from=reth-build /root/bin/reth /root/bin/
COPY --from=lighthouse-build /root/bin/lighthouse /root/bin/

COPY Caddyfile.template /var/lib/babel/templates/
COPY reth.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
COPY config-alloy.template /var/lib/babel/templates/config-alloy.template
