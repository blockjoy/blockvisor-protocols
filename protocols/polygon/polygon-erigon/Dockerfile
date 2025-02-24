ARG HEIMDALL_IMAGE=ghcr.io/blockjoy/heimdall:v20250224.1
ARG ERIGON_IMAGE=ghcr.io/blockjoy/erigon:v20250222.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250220.1

FROM ${HEIMDALL_IMAGE} AS heimdall

FROM ${ERIGON_IMAGE} AS erigon

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /root/lib /var/lib/babel/templates

# Copy binaries from builds
COPY --from=heimdall /home/heimdall/bin/heimdalld /root/bin/
COPY --from=erigon /root/bin/erigon /root/bin/
COPY --from=erigon /root/lib/libsilkworm_capi.so /root/lib/

# Copy templates and protocol files
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
