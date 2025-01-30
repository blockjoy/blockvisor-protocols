# Build stage
FROM base-image AS base

# Install build dependencies
RUN apk add --no-cache make gcc musl-dev linux-headers git

# Clone and build example client (replace with actual repository)
RUN git clone https://github.com/example/example-client.git /src
WORKDIR /src
RUN make build

# Final stage
FROM base

# Install additional runtime dependencies if needed
RUN apt-get update && apt-get install -y \
    libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the example client binary from builder
COPY --from=builder /src/build/example-node /root/bin/