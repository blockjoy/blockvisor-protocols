ARG HEIMDALL_IMAGE=ghcr.io/blockjoy/heimdall:v20250126.3
ARG ERIGON_IMAGE=ghcr.io/blockjoy/erigon:v20250123.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250203.1

FROM ${HEIMDALL_IMAGE} AS heimdall

FROM ${ERIGON_IMAGE} AS erigon

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
COPY --from=erigon /root/bin/erigon /root/bin/
COPY --from=erigon /root/lib/libsilkworm_capi.so /root/lib/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
