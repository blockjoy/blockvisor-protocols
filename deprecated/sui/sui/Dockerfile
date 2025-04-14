ARG PROTOCOL_IMAGE=ghcr.io/blockjoy/sui:v20250414.2
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250408.1

FROM ${PROTOCOL_IMAGE} AS protocol

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /root/lib /var/lib/babel/templates

# Copy binaries from builds
COPY --from=protocol /root/bin/sui-node /root/bin/

# Copy templates and protocol files
COPY templates/fullnode-yaml.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
