ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.4

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV OPL2GETH_VERSION=develop
ENV GO_VERSION=1.19.13
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

# Install Go
RUN curl -O https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $OPL2GETH_VERSION https://github.com/ethereum-optimism/optimism-legacy.git

# Build op-l2geth with Go caching
WORKDIR /root/optimism-legacy/l2geth
RUN mkdir -p build/bin
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make geth && \
    cp build/bin/geth /root/bin/op-l2geth

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/op-l2geth /root/bin/
