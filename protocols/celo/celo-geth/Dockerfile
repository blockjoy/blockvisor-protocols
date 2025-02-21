ARG CELO_GETH_IMAGE=ghcr.io/blockjoy/celo-geth:v20250220.2
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250220.1

FROM ${CELO_GETH_IMAGE} AS celo-geth

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /var/lib/babel/templates

# Copy binaries from builds
COPY --from=celo-geth /root/bin/geth /root/bin/

# Copy templates and protocol files
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
