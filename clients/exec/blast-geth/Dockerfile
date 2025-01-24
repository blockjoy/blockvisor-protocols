#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV BLASTGETH_VERSION=v1.1.0
ENV GO111MODULE=on
ENV CGO_ENABLED=1

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
