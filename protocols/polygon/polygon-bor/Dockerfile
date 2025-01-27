ARG HEIMDALL_IMAGE=ghcr.io/blockjoy/heimdall:v20250126.1
ARG BOR_IMAGE=ghcr.io/blockjoy/bor:v20250126.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${HEIMDALL_IMAGE} AS heimdall

FROM ${BOR_IMAGE} AS bor

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

# Create necessary directories
RUN mkdir -p /root/bin /root/lib /var/lib/babel/templates

# Copy binaries from builds
COPY --from=heimdall /home/heimdall/bin/heimdalld /root/bin/
COPY --from=heimdall /home/heimdall/bin/heimdallcli /root/bin/
COPY --from=bor /home/bor/bin/bor /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY polygon-bor.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
