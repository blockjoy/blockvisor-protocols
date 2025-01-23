ARG ARB_NODE_IMAGE=ghcr.io/blockjoy/arb-node:v20250120.1
ARG NITRO_IMAGE=ghcr.io/blockjoy/nitro:v20250120.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250120.1

FROM ${ARB_NODE_IMAGE} AS arb-node

FROM ${NITRO_IMAGE} AS nitro

FROM ${BASE_IMAGE}

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

# Create necessary directories
RUN mkdir -p /root/bin /var/lib/babel/templates

# Copy libs and binaries from builds
COPY --from=arb_node /usr/lib/librocksdb.so.6.20 /root/lib
COPY --from=arb_node /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /root/lib
COPY --from=arb_node /usr/lib/x86_64-linux-gnu/libtcmalloc.so.4 /root/lib
COPY --from=arb-node /root/bin/arb-node /root/bin/
COPY --from=nitro /root/bin/nitro /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY nitro.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
