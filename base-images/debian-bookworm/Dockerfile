FROM golang:1.23.1 as go-builder

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    cd / && \
    xcaddy build --with github.com/caddy-dns/cloudflare --with github.com/blockjoy/request-decompressor

FROM debian:bookworm-slim@sha256:f70dc8d6a8b6a06824c92471a1a258030836b26b043881358b967bf73de7c5ab

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --allow-insecure-repositories \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    procps \
    sysstat \
    wget \
    curl \
    software-properties-common \
    vim \
    psmisc \
    net-tools \
    nano \
    git \
    libc6 \
    libfontconfig1 \
    apt-utils \
    iproute2 \
    iputils-ping \
    netcat-traditional \
    dnsutils \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings/ && \
    wget --inet4-only --no-check-certificate -qO - http://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] http://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list

RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-xcaddy-archive-keyring.gpg && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/debian.deb.txt' > /etc/apt/sources.list.d/caddy-xcaddy.list

RUN apt-get update && apt-get install -y --no-install-recommends alloy grafana

RUN wget https://packages.cloud.google.com/apt/doc/apt-key.gpg -qO /usr/share/keyrings/prometheus-archive-keyring.gpg && \
    curl -fsSL https://ftp-master.debian.org/keys/archive-key-11.asc | gpg --batch --yes --dearmor -o /usr/share/keyrings/debian-archive-keyring-11.gpg && \
    curl -fsSL https://ftp-master.debian.org/keys/archive-key-12.asc | gpg --batch --yes --dearmor -o /usr/share/keyrings/debian-archive-keyring-12.gpg && \
    curl -fsSL https://ftp-master.debian.org/keys/archive-key-12-security.asc | gpg --dearmor -o /usr/share/keyrings/debian-archive-keyring-12-security.gpg

COPY --from=go-builder /caddy /usr/bin/caddy
RUN chmod +x /usr/bin/caddy && mkdir -p /etc/caddy

RUN mkdir -p /var/lib/babel/templates && \
    mkdir -p /var/lib/babel/plugin

RUN mkdir -p /etc/grafana /var/lib/grafana /usr/share/grafana/conf/provisioning/datasources \
    /usr/share/grafana/conf/provisioning/dashboards /var/lib/grafana/dashboards

COPY config/grafana-dashboard.yml /usr/share/grafana/conf/provisioning/dashboards/dashboard.yml

RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY base.rhai /var/lib/babel/plugin/base.rhai
COPY templates/caddy-dashboard.template /var/lib/babel/templates/
COPY templates/grafana-datasource.template /var/lib/babel/templates/
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/