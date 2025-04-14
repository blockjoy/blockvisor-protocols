#7
ARG OP_RETH_IMAGE=ghcr.io/blockjoy/op-reth:v20250412.2
ARG OP_NODE_IMAGE=ghcr.io/blockjoy/op-node:v20250414.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250408.1

FROM ${OP_RETH_IMAGE} AS op_reth
FROM ${OP_NODE_IMAGE} AS op_node

FROM ${BASE_IMAGE}

RUN mkdir -p /root/bin
COPY --from=op_reth /root/bin/op-reth /root/bin/
COPY --from=op_node /root/bin/op-node /root/bin/

COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
