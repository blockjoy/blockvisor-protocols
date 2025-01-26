ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV BSC_ERIGON_VERSION=v1.2.16
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin /root/lib

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $BSC_ERIGON_VERSION https://github.com/node-real/bsc-erigon.git

# Build bsc-erigon with Go caching
WORKDIR /root/bsc-erigon
RUN mkdir -p distro /root/bin /root/lib
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make bsc-erigon && make DIST=distro install

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bsc-erigon/distro/bsc-erigon /root/bin/
COPY --from=builder /root/bsc-erigon/distro/libsilkworm_capi.so /root/lib/
COPY --from=builder /root/bsc-erigon/distro/bsc-rpcdaemon /root/bin/
