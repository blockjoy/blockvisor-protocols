ARG AVALANCHEGO_IMAGE=ghcr.io/blockjoy/avalanchego:v20250121.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250120.1

FROM ${AVALANCHEGO_IMAGE} AS avalanchego

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

# Create necessary directories
RUN mkdir -p /usr/local/bin /var/lib/avalanchego /var/lib/babel/templates

# Copy avalanchego binary and templates
COPY --from=avalanchego /usr/local/bin/avalanchego /usr/local/bin/
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/

# Copy protocol files
COPY avalanche.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/