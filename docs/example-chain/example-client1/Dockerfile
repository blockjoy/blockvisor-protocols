# Build stage for the example client
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache make gcc musl-dev linux-headers git

# Clone and build example client (replace with actual repository)
RUN git clone https://github.com/example/example-client.git /src
WORKDIR /src
RUN make build

# Final stage
FROM ghcr.io/blockjoy/node-base:latest

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Copy the example client binary from builder
COPY --from=builder /src/build/example-node /usr/bin/
RUN chmod +x /usr/bin/example-node

# Create necessary directories
RUN mkdir -p /var/lib/babel/templates

# Copy protocol files
COPY . /var/lib/babel/
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
