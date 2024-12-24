# 1
FROM debian:bookworm-slim@sha256:1537a6a1cbc4b4fd401da800ee9480207e7dc1f23560c21259f681db56768f63

ARG GRAFANA_LOKI_API_KEY
ARG GRAFANA_PROM_API_KEY

ENV DEBIAN_FRONTEND=noninteractive
ENV GRAFANA_LOKI_API_KEY=${GRAFANA_LOKI_API_KEY}
ENV GRAFANA_PROM_API_KEY=${GRAFANA_PROM_API_KEY}

ENV GO_VERSION=1.23.1
ENV CADVISOR_VERSION=0.49.1

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    software-properties-common \
    vim \
    psmisc \
    net-tools \
    nano \
    git \
    build-essential \
    ca-certificates \
    libc6 \
    libfontconfig1 \
    apt-utils

RUN mkdir -p /etc/apt/keyrings/ && \
    wget --inet4-only --no-check-certificate -qO - http://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] http://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list

RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-xcaddy-archive-keyring.gpg && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/debian.deb.txt' > /etc/apt/sources.list.d/caddy-xcaddy.list

RUN apt-get update && apt-get install -y xcaddy alloy grafana

RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

RUN wget https://packages.cloud.google.com/apt/doc/apt-key.gpg -qO /usr/share/keyrings/prometheus-archive-keyring.gpg && \
    curl -fsSL https://ftp-master.debian.org/keys/archive-key-11.asc | gpg --batch --yes --dearmor -o /usr/share/keyrings/debian-archive-keyring-11.gpg && \
    curl -fsSL https://ftp-master.debian.org/keys/archive-key-12.asc | gpg --batch --yes --dearmor -o /usr/share/keyrings/debian-archive-keyring-12.gpg && \
    curl -fsSL https://ftp-master.debian.org/keys/archive-key-12-security.asc | gpg --dearmor -o /usr/share/keyrings/debian-archive-keyring-12-security.gpg

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

RUN cd / && \
    xcaddy build --with github.com/caddy-dns/cloudflare && \
    mv ./caddy /usr/bin/ && chmod +x /usr/bin/caddy && \
    mkdir -p /etc/caddy

RUN wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && \
    sh /tmp/netdata-kickstart.sh --stable-channel --disable-telemetry --non-interactive --dont-start-it --native-only --disable-cloud

RUN mkdir -p /var/lib/babel/templates && \
    mkdir -p /var/lib/babel/plugins

RUN mkdir -p /etc/grafana /var/lib/grafana /usr/share/grafana/conf/provisioning/datasources \
    /usr/share/grafana/conf/provisioning/dashboards /var/lib/grafana/dashboards

COPY config/grafana-datasource.yml /usr/share/grafana/conf/provisioning/datasources/datasource.yml
COPY config/grafana-dashboard.yml /usr/share/grafana/conf/provisioning/dashboards/dashboard.yml

#COPY config/caddy-dashboard.json /var/lib/grafana/dashboards

RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY base.rhai /var/lib/babel/plugin/base.rhai
COPY templates/netdata-conf.template /var/lib/babel/templates/netdata-conf.template
COPY templates/netdata-stream-conf.template /var/lib/babel/templates/netdata-stream-conf.template
COPY templates/caddy-dashboard.template /var/lib/babel/templates/caddy-dashboard.template
