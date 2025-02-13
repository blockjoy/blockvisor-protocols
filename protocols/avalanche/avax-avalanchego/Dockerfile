ARG AVALANCHEGO_IMAGE=ghcr.io/blockjoy/avalanchego:v20250212.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250212.3

FROM ${AVALANCHEGO_IMAGE} AS avalanchego

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /root/avalanche /var/lib/babel/templates

# Copy avalanchego binary and templates
COPY --from=avalanchego /root/bin/avalanchego /root/bin/
COPY configs /root/avalanche/configs
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/