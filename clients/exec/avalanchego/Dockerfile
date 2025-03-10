#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250304.5

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV AVALANCHEGO_VERSION=v1.12.1
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $AVALANCHEGO_VERSION https://github.com/ava-labs/avalanchego.git

# Build avalanchego with Go caching
WORKDIR /root/avalanchego
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    ./scripts/build.sh && \
    cp build/avalanchego /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/avalanchego /root/bin/
