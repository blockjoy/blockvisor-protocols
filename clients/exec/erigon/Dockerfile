ARG BASE_IMAGE=node-base:latest
FROM ghcr.io/blockjoy/${BASE_IMAGE}

# Add build arguments for Cloudflare and Grafana push credentials
ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV DEBIAN_FRONTEND=noninteractive
ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

ENV ERIGON_VERSION=v2.60.9

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin

WORKDIR /root
RUN git clone https://github.com/erigontech/erigon.git && \
    cd erigon && \
    git checkout $ERIGON_VERSION

WORKDIR /root/erigon
RUN make erigon

RUN cp /root/erigon/build/bin/erigon /root/bin/erigon
