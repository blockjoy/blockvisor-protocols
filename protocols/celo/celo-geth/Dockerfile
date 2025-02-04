ARG CELO_GETH_IMAGE=ghcr.io/blockjoy/celo-geth:v20250203.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250203.1

FROM ${CELO_GETH_IMAGE} AS celo-geth

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
COPY --from=celo-geth /root/bin/geth /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
