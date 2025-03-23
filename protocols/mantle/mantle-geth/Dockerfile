ARG MANTLE_NODE_IMAGE=ghcr.io/blockjoy/mantle-node:v20250322.1
ARG MANTLE_GETH_IMAGE=ghcr.io/blockjoy/mantle-geth:v20250322.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250304.4

FROM ${MANTLE_NODE_IMAGE} AS mantle-node

FROM ${MANTLE_GETH_IMAGE} AS mantle-geth

FROM ${BASE_IMAGE}

RUN mkdir -p /root/bin /root/config /var/lib/babel/templates

COPY --from=mantle-node /root/bin/mantle-node /root/bin/
COPY --from=mantle-geth /root/bin/mantle-geth /root/bin/

COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
COPY config /root/config