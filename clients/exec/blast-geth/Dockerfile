#1
ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250123.1

FROM ${BASE_IMAGE} as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV BLASTGETH_VERSION=v1.1.0

# Clone and checkout in a separate layer
WORKDIR /root
RUN git clone --depth 1 --branch $BLASTGETH_VERSION https://github.com/blast-io/blast.git

# Build blast-geth with Go caching
WORKDIR /root/blast/blast-geth
RUN mkdir -p build/bin
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    make geth && \
    cp build/bin/geth /root/bin/blast-geth

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/blast-geth /root/bin/
