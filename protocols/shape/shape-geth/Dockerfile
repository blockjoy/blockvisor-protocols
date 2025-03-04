ARG OP_NODE_IMAGE=ghcr.io/blockjoy/op-node:v20250222.1
ARG OP_GETH_IMAGE=ghcr.io/blockjoy/op-geth:v20250222.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250303.2

FROM ${OP_NODE_IMAGE} AS op-node

FROM ${OP_GETH_IMAGE} AS op-geth

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /root/config/{mainnet,sepolia} /var/lib/babel/templates

# Copy binaries from builds
COPY --from=op-node /root/bin/op-node /root/bin/
COPY --from=op-geth /root/bin/op-geth /root/bin/

# Copy templates and protocol files
COPY templates/mainnet-rollup-json.template /root/config/mainnet/rollup.json
COPY templates/mainnet-genesis-json.template /root/config/mainnet/genesis.json
COPY templates/sepolia-rollup-json.template /root/config/sepolia/rollup.json
COPY templates/sepolia-genesis-json.template /root/config/sepolia/genesis.json
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
