#1
ARG NITRO_IMAGE=ghcr.io/blockjoy/nitro:v20250414.2
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250408.1

FROM ${NITRO_IMAGE} AS nitro

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /var/lib/babel/templates

# Copy libs and binaries from builds
COPY --from=nitro /root/bin/nitro /root/bin/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
