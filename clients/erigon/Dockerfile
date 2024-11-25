FROM ghcr.io/blockjoy/node-base:abc123

# Add build arguments for Grafana credentials
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV DEBIAN_FRONTEND=noninteractive
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

ENV ERIGON_VERSION v2.60.9

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN mkdir -p /root/bin

WORKDIR /root
RUN git clone https://github.com/erigontech/erigon.git && \
    cd erigon && \
    git checkout $ERIGON_VERSION

WORKDIR /root/erigon
RUN make erigon

RUN cp /root/erigon/build/bin/erigon /root/bin/erigon && \
    rm -rf /root/erigon

COPY Caddyfile.template /var/lib/babel/templates/Caddyfile.template
COPY config-alloy.template /var/lib/babel/templates/config-alloy.template
COPY erigon.rhai /var/lib/babel/plugin/erigon.rhai
