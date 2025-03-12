ARG EXEC_IMAGE=ghcr.io/blockjoy/boba-erigon:v20250310.1
ARG CONSENSUS_IMAGE=ghcr.io/blockjoy/boba-node:v20250310.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250304.4

FROM ${EXEC_IMAGE} AS exec

FROM ${CONSENSUS_IMAGE} AS consensus

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /var/lib/babel/templates

# Copy binaries from builds
COPY --from=exec /root/bin/erigon /root/bin/
COPY --from=exec /root/bin/libsilkworm_capi.so /root/bin/
COPY --from=consensus /root/bin/op-node /root/bin/

# Copy templates and protocol files
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
