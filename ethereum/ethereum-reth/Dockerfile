FROM reth:latest AS reth-build

FROM lighthouse:latest AS lighthouse-build

FROM node-base:latest

ARG CLOUDFLARE_API_KEY
ARG GRAFANA_LOKI_BASICAUTH
ARG GRAFANA_PROM_BASICAUTH

ENV CLOUDFLARE_API_KEY=${CLOUDFLARE_API_KEY}
ENV GRAFANA_LOKI_BASICAUTH=${GRAFANA_LOKI_BASICAUTH}
ENV GRAFANA_PROM_BASICAUTH=${GRAFANA_PROM_BASICAUTH}

RUN mkdir -p /root/bin
COPY --from=reth-build /root/bin/reth /root/bin/
COPY --from=lighthouse-build /root/bin/lighthouse /root/bin/

COPY Caddyfile.template /var/lib/babel/templates/
COPY reth.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
COPY config-alloy.template /var/lib/babel/templates/config-alloy.template