ARG KAIA_KEN_IMAGE=ghcr.io/blockjoy/ken:v20250220.2
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250220.1

FROM ${KAIA_KEN_IMAGE} AS kaia_ken

FROM ${BASE_IMAGE}

RUN mkdir -p /root/bin
COPY --from=kaia_ken /root/bin/ken /root/bin/

COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
