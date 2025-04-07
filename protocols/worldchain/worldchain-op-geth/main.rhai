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
const WORLDCHAIN_API = "http://127.0.0.1:" + global::OP_NODE_RPC_PORT;
const WORLDCHAIN_DIR = node_env().protocol_data_path + "/worldchain";

const VARIANTS = #{
    "geth-mainnet-full": #{
        sequencer_url: "https://worldchain-mainnet-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "worldchain-mainnet",
        network: "mainnet",
    },
    "geth-sepolia-full": #{
        sequencer_url: "https://worldchain-sepolia-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "worldchain-sepolia",
        network: "sepolia",
    },
    "geth-mainnet-archive": #{
        sequencer_url: "https://worldchain-mainnet-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "worldchain-mainnet",
        network: "mainnet",
    },
    "geth-sepolia-archive": #{
        sequencer_url: "https://worldchain-sepolia-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "worldchain-sepolia",
        network: "sepolia",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;
const L1_URL = VARIANTS[node_env().node_variant].l1_url;
const BEACON_URL = VARIANTS[node_env().node_variant].beacon_url;
const OP_NETWORK = VARIANTS[node_env().node_variant].op_network;

const GETH_EXTRA_ARGS = if node_env().node_variant.ends_with("archive") {
    "--gcmode=archive";
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
                `mkdir -p ${global::WORLDCHAIN_DIR}/geth`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [
                #{
                    name: "init_job",
                    run_sh: `openssl rand -hex 32 > ${global::WORLDCHAIN_DIR}/jwt.txt`,
                }
            ]
        },
        services: [
            #{
                name: "op-geth",
                run_sh: `/root/bin/op-geth --datadir=${global::WORLDCHAIN_DIR}/ --http --http.corsdomain=* --http.vhosts=* \
                        --http.addr=127.0.0.1 --http.api=web3,debug,eth,txpool,net,engine --ws \
                        --ws.addr=127.0.0.1 --ws.port=${global::WS_PORT} --ws.origins=* --ws.api=debug,eth,txpool,net,engine \
                        --syncmode=full ${global::GETH_EXTRA_ARGS} --maxpeers=100 --authrpc.vhosts=* \
                        --authrpc.addr=127.0.0.1 --authrpc.port=${global::AUTHRPC_PORT} --authrpc.jwtsecret=${global::WORLDCHAIN_DIR}/jwt.txt --metrics \
                        --metrics.addr=127.0.0.1 --metrics.expensive --metrics.port=${global::METRICS_PORT} \
                        --rollup.disabletxpoolgossip=false --rpc.allow-unprotected-txs=true --db.engine=pebble --state.scheme=hash \
                        --port=30303 \
                        --op-network=${global::OP_NETWORK}`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `/root/bin/op-node --l1=${global::L1_URL} --l2=http://127.0.0.1:${global::AUTHRPC_PORT} \
                        --rpc.addr=127.0.0.1 --rpc.port=${global::OP_NODE_RPC_PORT} \
                        --l2.jwt-secret=${global::WORLDCHAIN_DIR}/jwt.txt --l1.trustrpc=true --l1.beacon=${global::BEACON_URL} \
                        --syncmode=execution-layer --l1.rpckind=${global::L1_RPCKIND} \
                        --p2p.priv.path=${global::WORLDCHAIN_DIR}/p2p.key --p2p.discovery.path=${global::WORLDCHAIN_DIR}/p2p.db \
                        --p2p.peerstore.path=${global::WORLDCHAIN_DIR}/p2p-peerstore.db --metrics.enabled=true \
                        --p2p.ban.peers=false \
                        --metrics.port=${global::OP_NODE_METRICS_PORT} \
                        --network=${global::OP_NETWORK}`,
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
    let h = run_jrpc(#{host: global::WORLDCHAIN_API, method: "optimism_syncStatus"}).expect(200);

    let block_timestamp = h.result.unsafe_l2.timestamp;

    let current_timestamp = parse_int(system_timestamp);

    if block_timestamp < current_timestamp - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}
