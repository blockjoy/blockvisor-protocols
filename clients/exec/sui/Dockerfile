ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v20250109.3
ARG SUI_IMAGE=mysten/sui-node:mainnet-v1.19.1

FROM ${SUI_IMAGE} AS sui_node

# Create minimal final image
FROM ${BASE_IMAGE}
RUN apt-get update && \
    apt-get install sysstat -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc/* /var/cache/ldconfig/aux-cache /usr/lib/python3.9/__pycache__/ /usr/lib/python3.9/*/__pycache__/ /var/log/*
COPY --from=sui_node /usr/local/bin/sui-node /root/bin/mainnet/
