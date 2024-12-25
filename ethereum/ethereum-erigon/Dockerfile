# 4
ARG ERIGON_IMAGE=ghcr.io/blockjoy/erigon:v176
ARG LIGHTHOUSE_IMAGE=ghcr.io/blockjoy/lighthouse:v176
ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v176

FROM ${ERIGON_IMAGE} as erigon-build

FROM ${LIGHTHOUSE_IMAGE} AS lighthouse-build

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

RUN mkdir -p /root/bin
COPY --from=erigon-build /root/bin/erigon /root/bin/
COPY --from=lighthouse-build /root/bin/lighthouse /root/bin/

COPY Caddyfile.template /var/lib/babel/templates/Caddyfile.template
COPY erigon.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
COPY config-alloy.template /var/lib/babel/templates/config-alloy.template
