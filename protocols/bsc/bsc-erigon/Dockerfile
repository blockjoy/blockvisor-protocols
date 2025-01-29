ARG BSC_ERIGON_IMAGE=ghcr.io/blockjoy/bsc-erigon:v20250128.5
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${BSC_ERIGON_IMAGE} AS erigon

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

RUN mkdir -p /root/bin /root/lib
COPY --from=erigon /root/bin/erigon /root/bin/
COPY --from=erigon /root/lib/libsilkworm_capi.so /root/lib/

COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
