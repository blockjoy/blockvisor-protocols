#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.3

FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV CLIENT_VERSION=v1.2.11
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin /root/lib

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $CLIENT_VERSION https://github.com/bobanetwork/op-erigon.git

# Build erigon with Go caching
WORKDIR /root/op-erigon
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make erigon

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/op-erigon/build/bin/erigon /root/bin/
COPY --from=builder /root/go/pkg/mod/github.com/erigontech/silkworm-go@v0.18.0/lib/linux_x64/libsilkworm_capi.so /root/bin/
