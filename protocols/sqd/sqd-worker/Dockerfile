ARG WORKER_IMAGE=ghcr.io/blockjoy/worker-rs:v20250312.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250304.4

FROM ${WORKER_IMAGE} AS worker

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /root/lib /var/lib/babel/templates

# Copy binaries from builds
COPY --from=worker /root/bin/worker /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/mainnet-env.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
