ARG OP_NODE_IMAGE=ghcr.io/blockjoy/op-node:v20250219.1
ARG OP_GETH_IMAGE=ghcr.io/blockjoy/op-geth:v20250214.2
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250213.4

FROM ${OP_NODE_IMAGE} AS op-node

FROM ${OP_GETH_IMAGE} AS op-geth

FROM ${BASE_IMAGE}

RUN mkdir -p /root/bin /var/lib/babel/templates

COPY --from=op-node /root/bin/op-node /root/bin/
COPY --from=op-geth /root/bin/op-geth /root/bin/

COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
