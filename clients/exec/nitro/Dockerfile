ARG BASE_IMAGE=ghcr.io/blockjoy/debian-bookworm:v20250213.4
ARG NITRO_IMAGE=offchainlabs/nitro-node:v3.3.2-9d70997

FROM ${NITRO_IMAGE} AS nitro_node

# Create minimal final image
FROM ${BASE_IMAGE}
RUN apt-get update && \
    apt-get install sysstat -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc/* /var/cache/ldconfig/aux-cache /usr/lib/python3.9/__pycache__/ /usr/lib/python3.9/*/__pycache__/ /var/log/*
COPY --from=nitro_node /usr/local/bin/nitro /root/bin/nitro
COPY --from=nitro_node /home/user/target/machines /root/bin/machines/
