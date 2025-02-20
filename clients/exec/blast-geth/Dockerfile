ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.1

FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV BLASTGETH_VERSION=v1.1.0
ENV GO111MODULE=on
ENV CGO_ENABLED=1
ENV GO_VERSION=1.21.5

# Remove existing Go installation and install Go 1.21.5
RUN rm -rf /usr/local/go && \
    wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Create directories
RUN mkdir -p /root/bin

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $BLASTGETH_VERSION https://github.com/blast-io/blast.git

# Build blast-geth with Go caching
WORKDIR /root/blast/blast-geth
RUN mkdir -p build/bin
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    go mod download && \
    go build -v -o /root/bin/blast-geth ./cmd/geth

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/blast-geth /root/bin/
