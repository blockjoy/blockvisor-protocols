ARG BSC_ERIGON_IMAGE=ghcr.io/blockjoy/bsc-erigon:v20250414.2
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250408.1

FROM ${BSC_ERIGON_IMAGE} AS erigon

FROM ${BASE_IMAGE}

RUN mkdir -p /root/bin /root/lib
COPY --from=erigon /root/bin/erigon /root/bin/
COPY --from=erigon /root/lib/libsilkworm_capi.so /root/lib/

COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
