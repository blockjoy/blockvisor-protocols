ARG AXELARD_IMAGE=ghcr.io/blockjoy/axelard:v20250221.1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250220.1

FROM ${AXELARD_IMAGE} AS axelard

FROM ${BASE_IMAGE}

# Create necessary directories
RUN mkdir -p /root/bin /var/lib/babel/templates /root/configs

# Copy binaries from builds
COPY --from=axelard /root/bin/axelard /root/bin/

# Copy templates and protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/addrbook-json.template /var/lib/babel/templates/
COPY templates/app-toml.template /var/lib/babel/templates/
COPY templates/config-toml.template /var/lib/babel/templates/
COPY templates/genesis-json.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
