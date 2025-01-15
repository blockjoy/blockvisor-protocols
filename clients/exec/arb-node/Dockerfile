ARG BASE_IMAGE=ghcr.io/blockjoy/node-base:v20250109.3
ARG ARB_NODE_IMAGE=offchainlabs/arb-node:v1.4.5-e97c1a4

FROM ${ARB_NODE_IMAGE} AS arb_node

# Create minimal final image
FROM ${BASE_IMAGE}
RUN apt-get update && \
    apt-get install -y libgmp10 libsnappy1v5 libgflags2.2 libzstd1 libunwind8 libstdc++6 libatomic1 libc6 libbz2-1.0 liblzma5 && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc/* /var/cache/ldconfig/aux-cache /usr/lib/python3.9/__pycache__/ /usr/lib/python3.9/*/__pycache__/ /var/log/*

COPY --from=arb_node /usr/lib/librocksdb.so.6.20 /usr/lib/librocksdb.so.6.20
COPY --from=arb_node /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1
COPY --from=arb_node /usr/lib/x86_64-linux-gnu/libtcmalloc.so.4 /usr/lib/x86_64-linux-gnu/libtcmalloc.so.4
COPY --from=arb_node /home/user/go/bin/arb-node /root/bin/arb-node
