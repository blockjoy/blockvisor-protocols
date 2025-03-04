#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250304.4

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV OPGETH_VERSION=v1.101500.0
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $OPGETH_VERSION https://github.com/ethereum-optimism/op-geth.git

# Build op-geth with Go caching
WORKDIR /root/op-geth
RUN mkdir -p build/bin
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make geth && \
    cp build/bin/geth /root/bin/op-geth

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/op-geth /root/bin/
