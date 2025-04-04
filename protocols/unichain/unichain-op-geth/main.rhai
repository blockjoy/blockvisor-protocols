import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const OP_NODE_RPC_PORT = 8547;
const AUTHRPC_PORT = 8551;
const METRICS_PORT = 4141;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_RPCKIND = "standard";

const GETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const UNICHAIN_API = "http://127.0.0.1:8547";
const UNICHAIN_DIR = node_env().protocol_data_path + "/unichain";

const VARIANTS = #{
    "geth-mainnet-full": #{
        sequencer_url: "https://unichain-mainnet-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "unichain-mainnet",
        network: "mainnet",
    },
    "geth-sepolia-full": #{
        sequencer_url: "https://unichain-sepolia-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "unichain-sepolia",
        node_bootnodes: "enr:-J24QIHsjbBldFkaVUTEkEdwYa51AeCOAWd8bJbUOqGqsWDhScaPGnPERVfRgcCJbK2X8vI-9eB-VTDDNRl7S4e1zPyGAZKhaRjagmlkgnY0gmlwhAOSdXaHb3BzdGFja4OVCgCJc2VjcDI1NmsxoQI0_WNHeARGz-kjyK_s7MjZkTf5xYSHrm7nL4C5LwbyJ4N0Y3CCJAaDdWRwgiQG,enr:-J24QH_0BbED1p4R8lZe0Wk6V9pFonqXMw48X_IVKQhbNsekdWlDkKUUaDWV4FHqWVQpfGPI5IjeqKOaIrTBnup8Ro2GAZKhZyO6gmlkgnY0gmlwhDQPNgiHb3BzdGFja4OVCgCJc2VjcDI1NmsxoQOKqwdtPsP4czpXIFwx56PmThevWwxQJ78gY0QaQxNdU4N0Y3CCJAaDdWRwgiQG,enr:-J24QKCDaIQdjhYZAvhLp__sApHypx1zgiKaFAiSP55klZCpVpiFLvaR8LKSICO0sc_xE3SL-rW2JBbQrtXg9yGcFQuGAZKhaBnzgmlkgnY0gmlwhAOS1UGHb3BzdGFja4OVCgCJc2VjcDI1NmsxoQL0xHUDIhXHIn_8yAKupnuK3c2TbqDdhRIn-IiYV2Wxe4N0Y3CCJAaDdWRwgiQG",
        geth_bootnodes: "enode://9e138a8ec4291c4f2fe5851aaee44fc73ae67da87fb26b75e3b94183c7ffc15b2795afc816b0aa084151b95b3a3553f1cd0d1e9dd134dcf059a84d4e0b429afc@3.146.117.118:30303,enode://34d87d649e5c58a17a43c1d59900a2020bd82d5b12ea39467c3366bee2946aaa9c759c77ede61089624691291fb2129eeb2a47687b50e2463188c78e1f738cf2@52.15.54.8:30303,enode://c2405194166fe2c0e6c61ee469745fed1a6802f51c8fc39e1c78c21c9a6a15a7c55304f09ee37e430da9a1ce8117ca085263c6b0f474f6946811e398347611ef@3.146.213.65:30303",
        network: "sepolia",
    },
    "geth-mainnet-archive": #{
        sequencer_url: "https://unichain-mainnet-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "unichain-mainnet",
        network: "mainnet",
    },
    "geth-sepolia-archive": #{
        sequencer_url: "https://unichain-sepolia-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "unichain-sepolia",
        node_bootnodes: "enr:-J24QIHsjbBldFkaVUTEkEdwYa51AeCOAWd8bJbUOqGqsWDhScaPGnPERVfRgcCJbK2X8vI-9eB-VTDDNRl7S4e1zPyGAZKhaRjagmlkgnY0gmlwhAOSdXaHb3BzdGFja4OVCgCJc2VjcDI1NmsxoQI0_WNHeARGz-kjyK_s7MjZkTf5xYSHrm7nL4C5LwbyJ4N0Y3CCJAaDdWRwgiQG,enr:-J24QH_0BbED1p4R8lZe0Wk6V9pFonqXMw48X_IVKQhbNsekdWlDkKUUaDWV4FHqWVQpfGPI5IjeqKOaIrTBnup8Ro2GAZKhZyO6gmlkgnY0gmlwhDQPNgiHb3BzdGFja4OVCgCJc2VjcDI1NmsxoQOKqwdtPsP4czpXIFwx56PmThevWwxQJ78gY0QaQxNdU4N0Y3CCJAaDdWRwgiQG,enr:-J24QKCDaIQdjhYZAvhLp__sApHypx1zgiKaFAiSP55klZCpVpiFLvaR8LKSICO0sc_xE3SL-rW2JBbQrtXg9yGcFQuGAZKhaBnzgmlkgnY0gmlwhAOS1UGHb3BzdGFja4OVCgCJc2VjcDI1NmsxoQL0xHUDIhXHIn_8yAKupnuK3c2TbqDdhRIn-IiYV2Wxe4N0Y3CCJAaDdWRwgiQG",
        geth_bootnodes: "enode://9e138a8ec4291c4f2fe5851aaee44fc73ae67da87fb26b75e3b94183c7ffc15b2795afc816b0aa084151b95b3a3553f1cd0d1e9dd134dcf059a84d4e0b429afc@3.146.117.118:30303,enode://34d87d649e5c58a17a43c1d59900a2020bd82d5b12ea39467c3366bee2946aaa9c759c77ede61089624691291fb2129eeb2a47687b50e2463188c78e1f738cf2@52.15.54.8:30303,enode://c2405194166fe2c0e6c61ee469745fed1a6802f51c8fc39e1c78c21c9a6a15a7c55304f09ee37e430da9a1ce8117ca085263c6b0f474f6946811e398347611ef@3.146.213.65:30303",
        network: "sepolia",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;
const L1_URL = VARIANTS[node_env().node_variant].l1_url;
const BEACON_URL = VARIANTS[node_env().node_variant].beacon_url;
const OP_NETWORK = VARIANTS[node_env().node_variant].op_network;

const NODE_BOOTNODES = if node_env().node_variant.contains("sepolia") {
    "--p2p.bootnodes=" + VARIANTS[node_env().node_variant].node_bootnodes;
} else {
     "";
};

const GETH_BOOTNODES = if node_env().node_variant.contains("sepolia") {
    "--bootnodes=" + VARIANTS[node_env().node_variant].geth_bootnodes;
} else {
    "";
};

const GETH_EXTRA_ARGS = if node_env().node_variant.ends_with("archive") {
    "--gcmode=archive";
} else {
    "";
};

const NETWORK = VARIANTS[node_env().node_variant].network;

const CONFIG_DIR = `/root/config/${global::NETWORK}`;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::UNICHAIN_DIR}/geth`,
                `mkdir -p ${global::CADDY_DIR}`,
                `cp -a ${global::CONFIG_DIR}/rollup.json ${global::UNICHAIN_DIR}`,
                `cp -a ${global::CONFIG_DIR}/genesis.json ${global::UNICHAIN_DIR}/geth`,
            ],
            jobs: [
                #{
                    name: "init_job",
                    run_sh: `openssl rand -hex 32 > ${global::UNICHAIN_DIR}/jwt.txt`,
                }
            ]
        },
        services: [
            #{
                name: "op-geth",
                run_sh: `/root/bin/op-geth --op-network ${global::OP_NETWORK} --syncmode=snap --ws --ws.port=${global::WS_PORT} \
                        --ws.addr=127.0.0.1 --ws.origins="*" --http --http.api="eth,net,web3,debug" --http.port=${global::RPC_PORT} \
                        --http.addr=127.0.0.1 --http.vhosts="*" --http.corsdomain="*" --authrpc.addr=127.0.0.1 \
                        --authrpc.jwtsecret=${global::UNICHAIN_DIR}/jwt.txt --authrpc.port=${global::AUTHRPC_PORT} --authrpc.vhosts="*" \
                        --verbosity=3 --rollup.sequencerhttp=${global::SEQUENCER_URL} --metrics --metrics.addr=127.0.0.1 \
                        --metrics.port=${global::METRICS_PORT} --datadir=${global::UNICHAIN_DIR}/ --rollup.disabletxpoolgossip=true \
                        --nodiscover --maxpeers=0 ${global::GETH_BOOTNODES} ${global::GETH_EXTRA_ARGS}`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `/root/bin/op-node --network ${global::OP_NETWORK} --rpc.addr=127.0.0.1 --rpc.port=${global::OP_NODE_RPC_PORT} \
                        --l1=${global::L1_URL} --l1.beacon=${global::BEACON_URL} --l1.rpckind=${global::L1_RPCKIND} \
                        --l2=http://127.0.0.1:${global::AUTHRPC_PORT} --l2.jwt-secret=${global::UNICHAIN_DIR}/jwt.txt \
                        ${global::NODE_BOOTNODES}`,
                shutdown_timeout_secs: 120,
            },
        ],
        download: #{
            max_connections: 5,
        },
        upload: #{
            exclude: [
                "jwt.txt",
                "bedrock.tar.zst",
                "bedrock.tar",
                "caddy/**",
            ],
        },
}}

fn protocol_status() {
    let resp = run_jrpc(#{host: global::GETH_API, method: ""});

    if resp.status_code == 200 {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
    }
}

fn height() {
    parse_hex(run_jrpc(#{ host: global::GETH_API, method: "eth_blockNumber"}).expect(200).result)
}

fn sync_status() {
    let system_timestamp = run_sh (`date +%s`).unwrap();
    let h = run_jrpc(#{host: global::UNICHAIN_API, method: "optimism_syncStatus"}).expect(200);

    let block_timestamp = h.result.unsafe_l2.timestamp;

    let current_timestamp = parse_int(system_timestamp);

    if block_timestamp < current_timestamp - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}
