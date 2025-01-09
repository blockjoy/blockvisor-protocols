# 6
ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v20250109.1

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV ERIGON_VERSION=v2.60.9
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $ERIGON_VERSION https://github.com/erigontech/erigon.git

# Build erigon with Go caching
WORKDIR /root/erigon
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make erigon && \
    cp build/bin/erigon /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/erigon /root/bin/erigon
