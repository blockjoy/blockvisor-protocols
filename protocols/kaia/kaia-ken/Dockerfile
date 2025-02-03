ARG KAIA_KEN_IMAGE=ghcr.io/blockjoy/ken:v20250123.2
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250203.1

FROM ${KAIA_KEN_IMAGE} AS kaia_ken

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

RUN mkdir -p /root/bin
COPY --from=kaia_ken /root/bin/ken /root/bin/

COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
