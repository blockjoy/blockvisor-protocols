import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const OP_NODE_RPC_PORT = 8547;
const OP_NODE_METRICS_PORT = 5151;
const AUTHRPC_PORT = 8551;
const METRICS_PORT = 4141;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_RPCKIND = "standard";

const GETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const MODE_API = "http://127.0.0.1:" + global::OP_NODE_RPC_PORT;
const MODE_DIR = node_env().protocol_data_path + "/mode";

const VARIANTS = #{
    "geth-mainnet-full": #{
        sequencer_url: "https://mode-mainnet-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "mode-mainnet",
        network: "mainnet",
        chain_id: "34443",
    },
    "geth-sepolia-full": #{
        sequencer_url: "https://mode-sepolia-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "mode-sepolia",
        network: "sepolia",
        chain_id: "919",
    },
    "geth-mainnet-archive": #{
        sequencer_url: "https://mode-mainnet-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "mode-mainnet",
        network: "mainnet",
        chain_id: "34443",
    },
    "geth-sepolia-archive": #{
        sequencer_url: "https://mode-sepolia-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "mode-sepolia",
        network: "sepolia",
        chain_id: "919",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;
const L1_URL = VARIANTS[node_env().node_variant].l1_url;
const BEACON_URL = VARIANTS[node_env().node_variant].beacon_url;
const OP_NETWORK = VARIANTS[node_env().node_variant].op_network;
const CHAIN_ID = VARIANTS[node_env().node_variant].chain_id;

const GETH_EXTRA_ARGS = if node_env().node_variant.ends_with("archive") {
    "--gcmode=archive";
} else {
    "";
};

const GETH_NETWORK_ARGS = if CHAIN_ID == "919" {
    "--rollup.superchain-upgrades --op-network mode-sepolia --rollup.halt=major";
} else if CHAIN_ID == "34443" {
    "--override.canyon=1704992401 --rollup.halt=major";
} else {
    "";
};

const NETWORK = VARIANTS[node_env().node_variant].network;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::MODE_DIR}/geth`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [
                #{
                    name: "init_job",
                    run_sh: `openssl rand -hex 32 > ${global::MODE_DIR}/jwt.txt`,
                }
            ]
        },
        services: [
            #{
                name: "op-geth",
                run_sh: `/root/bin/op-geth \
                        --datadir=${global::MODE_DIR} \
                        --http \
                        --http.corsdomain=* \
                        --http.vhosts=* \
                        --http.addr=127.0.0.1 \
                        --http.port=${global::RPC_PORT} \
                        --http.api=web3,debug,eth,txpool,net,engine \
                        --authrpc.addr=127.0.0.1 \
                        --authrpc.port=${global::AUTHRPC_PORT} \
                        --authrpc.vhosts=* \
                        --authrpc.jwtsecret=${global::MODE_DIR}/jwt.txt \
                        --ws \
                        --ws.addr=127.0.0.1 \
                        --ws.port=${global::WS_PORT} \
                        --ws.origins=* \
                        --ws.api=debug,eth,txpool,net,engine \
                        --metrics \
                        --metrics.addr=127.0.0.1 \
                        --metrics.port=${global::METRICS_PORT} \
                        --syncmode=full \
                        --maxpeers=100 \
                        --networkid=${global::CHAIN_ID} \
                        --rollup.sequencerhttp=${global::SEQUENCER_URL} \
                        --port=30303 \
                        --rollup.disabletxpoolgossip=false \
                        --rpc.allow-unprotected-txs=true \
                        ${global::GETH_EXTRA_ARGS} \
                        ${global::GETH_NETWORK_ARGS}`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `/root/bin/op-node \
                        --l1=${global::L1_URL} \
                        --l2=http://127.0.0.1:${global::AUTHRPC_PORT} \
                        --l2.jwt-secret=${global::MODE_DIR}/jwt.txt \
                        --l1.trustrpc=true \
                        --l1.beacon=${global::BEACON_URL} \
                        --rpc.addr=127.0.0.1 \
                        --rpc.port=${global::OP_NODE_RPC_PORT} \
                        --p2p.priv.path=${global::MODE_DIR}/p2p.key \
                        --p2p.discovery.path=${global::MODE_DIR}/p2p.db \
                        --p2p.peerstore.path=${global::MODE_DIR}/p2p-peerstore.db \
                        --metrics.enabled=true \
                        --metrics.addr=127.0.0.1 \
                        --metrics.port=${global::OP_NODE_METRICS_PORT} \
                        --network=${global::OP_NETWORK} \
                        --verifier.l1-confs=4 \
                        --p2p.ban.peers=false`,
                shutdown_timeout_secs: 120,
            },
        ],
        download: #{
            max_connections: 5,
        },
        upload: #{
            exclude: [
                "jwt.txt",
                "p2p.key",
                "p2p.db",
                "p2p-peerstore.db",
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
    let h = run_jrpc(#{host: global::MODE_API, method: "optimism_syncStatus"}).expect(200);

    let block_timestamp = h.result.unsafe_l2.timestamp;

    let current_timestamp = parse_int(system_timestamp);

    if block_timestamp < current_timestamp - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}
