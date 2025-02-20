ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.1

FROM ${BASE_IMAGE} AS builder

# Remove any existing Go installation
RUN rm -rf /usr/local/go

ENV GOLANG_VERSION=1.21.2
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local

ENV OPERA_VERSION="release/txtracing/1.1.3-rc.5"

WORKDIR /go-opera
RUN git clone --depth 1 --branch $OPERA_VERSION https://github.com/Fantom-foundation/go-opera.git .

RUN apt update && \
    platform="$(dpkg --print-architecture)" && \
    apt install -y build-essential git linux-headers-$platform && make opera && \
    mkdir -p /root/bin && \
    cp build/opera /root/bin/

# Create minimal final image
FROM ${BASE_IMAGE}
COPY --from=builder /root/bin/opera /root/bin/