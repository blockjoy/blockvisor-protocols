ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm-build:v20250220.1
ARG NEAR_IMAGE=nearprotocol/nearcore:2.5.0


FROM ${NEAR_IMAGE} AS near_node

# Create minimal final image
FROM ${BASE_IMAGE}
RUN apt-get update && \
    apt-get install sysstat -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc/* /var/cache/ldconfig/aux-cache /usr/lib/python3.9/__pycache__/ /usr/lib/python3.9/*/__pycache__/ /var/log/*
COPY --from=near_node /usr/local/bin/neard /root/bin/
