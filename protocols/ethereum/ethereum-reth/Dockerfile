#1
ARG RETH_IMAGE=ghcr.io/blockjoy/reth:v20250414.1
ARG LIGHTHOUSE_IMAGE=ghcr.io/blockjoy/lighthouse:v20250414.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250408.1

FROM ${RETH_IMAGE} AS reth

FROM ${LIGHTHOUSE_IMAGE} AS lighthouse-build

FROM ${BASE_IMAGE}

RUN mkdir -p /root/bin
COPY --from=reth /root/bin/reth /root/bin/
COPY --from=lighthouse-build /root/bin/lighthouse /root/bin/

COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
COPY templates/Caddyfile.template /var/lib/babel/templates/
