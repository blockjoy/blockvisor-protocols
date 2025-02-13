ARG EXEC_IMAGE=ghcr.io/blockjoy/boba-erigon:v20250213.1
ARG CONSENSUS_IMAGE=ghcr.io/blockjoy/boba-node:v20250212.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250203.1

FROM ${EXEC_IMAGE} AS exec

FROM ${CONSENSUS_IMAGE} AS consensus

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
COPY --from=exec /root/bin/erigon /root/bin/
COPY --from=exec /root/bin/libsilkworm_capi.so /root/bin/
COPY --from=consensus /root/bin/op-node /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
