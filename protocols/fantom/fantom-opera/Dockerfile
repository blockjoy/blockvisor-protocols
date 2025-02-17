ARG FANTOM_OPERA_IMAGE=ghcr.io/blockjoy/opera:v20250214.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250213.4

FROM ${FANTOM_OPERA_IMAGE} AS fantom-opera

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /var/lib/babel/templates

# Copy binaries from builds
COPY --from=fantom-opera /root/bin/opera /root/bin/

# Copy templates and protocol files
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
