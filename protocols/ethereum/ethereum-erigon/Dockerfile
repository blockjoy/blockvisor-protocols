ARG ERIGON_IMAGE=ghcr.io/blockjoy/erigon:v20250414.2
ARG LIGHTHOUSE_IMAGE=ghcr.io/blockjoy/lighthouse:v20250414.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250408.1

FROM ${ERIGON_IMAGE} AS erigon

FROM ${LIGHTHOUSE_IMAGE} AS lighthouse-build

FROM ${BASE_IMAGE}

RUN mkdir -p /root/bin /root/lib
COPY --from=erigon /root/bin/erigon /root/bin/
COPY --from=erigon /root/lib/libsilkworm_capi.so /root/lib/
COPY --from=lighthouse-build /root/bin/lighthouse /root/bin/

COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
