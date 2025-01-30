FROM debian:bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    jq \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Install Caddy
RUN curl -o /usr/bin/caddy -L "https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_linux_amd64" \
    && chmod +x /usr/bin/caddy

# Install other dependencies as required
   
# Create necessary directories
RUN mkdir -p /var/lib/babel/plugin /var/lib/babel/templates

# Copy base configuration
COPY base.rhai /var/lib/babel/plugin/base.rhai