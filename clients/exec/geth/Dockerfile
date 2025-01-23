#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV GETH_VERSION=v1.14.12
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $GETH_VERSION https://github.com/ethereum/go-ethereum.git

# Build geth with Go caching
WORKDIR /root/go-ethereum
RUN mkdir -p build/bin
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make geth && \
    cp build/bin/geth /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/geth /root/bin/
