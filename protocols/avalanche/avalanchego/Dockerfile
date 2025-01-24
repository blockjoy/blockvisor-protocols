ARG AVALANCHEGO_IMAGE=ghcr.io/blockjoy/avalanchego:v20250124.5
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${AVALANCHEGO_IMAGE} AS avalanchego

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

# Create necessary directories
RUN mkdir -p /root/bin /root/avalanche /var/lib/babel/templates

# Copy avalanchego binary and templates
COPY --from=avalanchego /root/bin/avalanchego /root/bin/
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY configs /root/avalanche/configs

# Copy protocol files
COPY avalanche.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/