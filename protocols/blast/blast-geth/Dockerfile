#1
ARG BLAST_OP_NODE_IMAGE=ghcr.io/blockjoy/blast-node:v20250414.1
ARG BLAST_OP_GETH_IMAGE=ghcr.io/blockjoy/blast-geth:v20250414.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250408.1

FROM ${BLAST_OP_NODE_IMAGE} AS blast-op-node

FROM ${BLAST_OP_GETH_IMAGE} AS blast-op-geth

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /root/config/mainnet /root/config/sepolia /var/lib/babel/templates

# Copy binaries from builds
COPY --from=blast-op-node /root/bin/blast-node /root/bin/
COPY --from=blast-op-geth /root/bin/blast-geth /root/bin/

# Copy templates and protocol files
COPY config/mainnet/genesis.json /root/config/mainnet
COPY config/mainnet/rollup.json /root/config/mainnet
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
