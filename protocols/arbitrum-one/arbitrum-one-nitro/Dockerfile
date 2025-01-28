ARG ARB_NODE_IMAGE=ghcr.io/blockjoy/arb-node:v20250123.6
ARG NITRO_IMAGE=ghcr.io/blockjoy/nitro:v20250123.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

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
RUN mkdir -p /root/bin /root/lib /var/lib/babel/templates

# Copy libs and binaries from builds
COPY --from=arb-node /usr/lib/librocksdb.so.6.20 /usr/lib/
COPY --from=arb-node /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /usr/lib/x86_64-linux-gnu/
COPY --from=arb-node /usr/lib/x86_64-linux-gnu/libtcmalloc.so.4 /usr/lib/x86_64-linux-gnu/
COPY --from=arb-node /usr/lib/x86_64-linux-gnu/libsnappy.so.1 /usr/lib/x86_64-linux-gnu/
COPY --from=arb-node /usr/lib/x86_64-linux-gnu/libgflags.so.2.2 /usr/lib/x86_64-linux-gnu/
COPY --from=arb-node /usr/lib/x86_64-linux-gnu/libzstd.so.1 /usr/lib/x86_64-linux-gnu/
COPY --from=arb-node /usr/lib/x86_64-linux-gnu/libunwind.so.8 /usr/lib/x86_64-linux-gnu/
COPY --from=arb-node /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/
COPY --from=arb-node /usr/lib/x86_64-linux-gnu/libatomic.so.1 /usr/lib/x86_64-linux-gnu/
COPY --from=arb-node /root/bin/arb-node /root/bin/
COPY --from=nitro /root/bin/nitro /root/bin/
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
