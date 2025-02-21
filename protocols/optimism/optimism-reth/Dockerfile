#1
ARG OP_NODE_IMAGE=ghcr.io/blockjoy/op-node:v20250220.6
ARG OP_RETH_IMAGE=ghcr.io/blockjoy/op-reth:v20250220.2
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250220.1

FROM ${OP_NODE_IMAGE} AS op-node

FROM ${OP_RETH_IMAGE} AS op-reth

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /root/lib /var/lib/babel/templates

# Copy binaries from builds
COPY --from=op-node /root/bin/op-node /root/bin/
COPY --from=op-reth /root/bin/op-reth /root/bin/

# Copy templates and protocol files
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
