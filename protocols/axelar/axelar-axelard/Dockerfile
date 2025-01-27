ARG AXELAR_AXELARD_IMAGE=ghcr.io/blockjoy/axelard:v20250126.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${AXELAR_AXELARD_IMAGE} AS axelar-axelard

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
COPY --from=axelar-axelard /root/bin/axelard /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY templates/addrbook-json.template /var/lib/babel/templates/
COPY templates/app-toml.template /var/lib/babel/templates/
COPY templates/config-toml.template /var/lib/babel/templates/
COPY templates/genesis-json.template /var/lib/babel/templates/
COPY axelar-axelard.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
