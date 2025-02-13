ARG HEIMDALL_IMAGE=ghcr.io/blockjoy/heimdall:v20250212.1
ARG BOR_IMAGE=ghcr.io/blockjoy/bor:v20250212.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250212.4

FROM ${HEIMDALL_IMAGE} AS heimdall

FROM ${BOR_IMAGE} AS bor

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /root/lib /var/lib/babel/templates

# Copy binaries from builds
COPY --from=heimdall /home/heimdall/bin/heimdalld /root/bin/
COPY --from=heimdall /home/heimdall/bin/heimdallcli /root/bin/
COPY --from=bor /home/bor/bin/bor /root/bin/

COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
