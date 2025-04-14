#1
ARG PROTOCOL_IMAGE=ghcr.io/blockjoy/layerd:v20250414.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250408.1

FROM ${PROTOCOL_IMAGE} AS layerd

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /var/lib/babel/templates /root/configs

# Copy binaries from builds
COPY --from=layerd /root/bin/layerd /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/client-toml.template /var/lib/babel/templates/
COPY templates/app-toml.template /var/lib/babel/templates/
COPY templates/config-toml.template /var/lib/babel/templates/
COPY templates/genesis-json.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
