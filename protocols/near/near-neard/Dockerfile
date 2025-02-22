ARG CLIENT_IMAGE=ghcr.io/blockjoy/neard:v20250221.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250220.1

FROM ${CLIENT_IMAGE} AS client

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /root/lib /var/lib/babel/templates

# Copy binaries from builds
COPY --from=client /root/bin/neard /root/bin/

# Copy templates and protocol files
COPY templates/config-json.template /var/lib/babel/templates/
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
