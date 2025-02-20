#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.3

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV ERIGON_VERSION=v2.60.9
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin /root/lib

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $ERIGON_VERSION https://github.com/erigontech/erigon.git

# Build erigon with Go caching
WORKDIR /root/erigon
RUN mkdir -p distro
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make erigon && make DIST=distro install

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/erigon/distro/erigon /root/bin/
COPY --from=builder /root/erigon/distro/libsilkworm_capi.so /root/lib/
