ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV CELO_GETH_VERSION=v1.8.4
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $CELO_GETH_VERSION https://github.com/celo-org/celo-blockchain.git

# Build geth with Go caching
WORKDIR /root/celo-blockchain
RUN mkdir -p build/bin
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make geth && \
    cp build/bin/geth /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/geth /root/bin/
