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
const SONEIUM_API = "http://127.0.0.1:8547";
const SONEIUM_DIR = node_env().protocol_data_path + "/soneium";

const VARIANTS = #{
    // "geth-mainnet-full": #{
    //     sequencer_url: "https://soneium-mainnet-sequencer.g.alchemy.com",
    //     l1_url: "https://eth-l1.blkjy.io",
    //     beacon_url: "https://lighthouse.blkjy.io",
    //     op_network: "soneium-mainnet",
    //     network: "mainnet",
    // },
    "geth-sepolia-full": #{
        sequencer_url: "https://soneium-sepolia-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "soneium-minato-sepolia",
        node_bootnodes: "enr:-J24QMURlYGuLFCYQrA1YBg1l-y8BZAjtRSh8bJug3pkNkqOCBMMbTAo6xPLge-w9Oy31KOlrHZ9CSxWHlQ_ny_cSZ6GAZF5HPjtgmlkgnY0gmlwhDTB9VyHb3BzdGFja4OaDwCJc2VjcDI1NmsxoQOk1QANdV45CtjmbnqG72RUuR_c8aT7bDwNreMRHTPLp4N0Y3CCJAaDdWRwgo_p,enr:-J24QJwOeG7uCOBn6JJF3vPIQSTaMyyAlHawVMvz44mgtryyW39CaI5mSDh65MX16PItF2Sg-Yv9I-ObDemR2Qn3a-yGAZF5Pn4NgmlkgnY0gmlwhDRE6cCHb3BzdGFja4OaDwCJc2VjcDI1NmsxoQJyDu9Izw_A3pgqKicw5xyYPgVvQAgYB-eUUfN8f7FLhIN0Y3CCJAaDdWRwgqVe",
        static_peers: "/dns4/peering-01.prd.hypersonicl2.com/tcp/9222/p2p/16Uiu2HAm36ufaFmS3tjSjkUnwSJmQN8W8fZ8yXiu2AYL2o11EgcK,/dns4/peering-02.prd.hypersonicl2.com/tcp/9222/p2p/16Uiu2HAmPkRbG8kkhJ3JWmrqeiMvy1hWXFSz4s4rncVe8YiCJHmx",
        geth_bootnodes: "enode://6526c348274c54e7b4184014741897eb25e12ca388f588b0265bb2246caeea87ed5fcb2d55b7b08a90cd271a53bc76decb6d1ec37f219dbe4cd3ed53a888118b@52.193.245.92:30303,enode://34f172c255b11f64828d73c90a60395691e89782639423d434385594dd38b434ddffb78ad411da6fd37cbda6d0f93e17ceae399ac4f2594b0d54eb8c83c27de9@52.68.233.192:30303",
        network: "sepolia",
    },
    // "geth-mainnet-archive": #{
    //     sequencer_url: "https://soneium-mainnet-sequencer.g.alchemy.com",
    //     l1_url: "https://eth-l1.blkjy.io",
    //     beacon_url: "https://lighthouse.blkjy.io",
    //     op_network: "soneium-mainnet",
    //     network: "mainnet",
    // },
    "geth-sepolia-archive": #{
        sequencer_url: "https://soneium-sepolia-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "soneium-minato-sepolia",
        node_bootnodes: "enr:-J24QMURlYGuLFCYQrA1YBg1l-y8BZAjtRSh8bJug3pkNkqOCBMMbTAo6xPLge-w9Oy31KOlrHZ9CSxWHlQ_ny_cSZ6GAZF5HPjtgmlkgnY0gmlwhDTB9VyHb3BzdGFja4OaDwCJc2VjcDI1NmsxoQOk1QANdV45CtjmbnqG72RUuR_c8aT7bDwNreMRHTPLp4N0Y3CCJAaDdWRwgo_p,enr:-J24QJwOeG7uCOBn6JJF3vPIQSTaMyyAlHawVMvz44mgtryyW39CaI5mSDh65MX16PItF2Sg-Yv9I-ObDemR2Qn3a-yGAZF5Pn4NgmlkgnY0gmlwhDRE6cCHb3BzdGFja4OaDwCJc2VjcDI1NmsxoQJyDu9Izw_A3pgqKicw5xyYPgVvQAgYB-eUUfN8f7FLhIN0Y3CCJAaDdWRwgqVe",
        static_peers: "/dns4/peering-01.prd.hypersonicl2.com/tcp/9222/p2p/16Uiu2HAm36ufaFmS3tjSjkUnwSJmQN8W8fZ8yXiu2AYL2o11EgcK,/dns4/peering-02.prd.hypersonicl2.com/tcp/9222/p2p/16Uiu2HAmPkRbG8kkhJ3JWmrqeiMvy1hWXFSz4s4rncVe8YiCJHmx",
        geth_bootnodes: "enode://6526c348274c54e7b4184014741897eb25e12ca388f588b0265bb2246caeea87ed5fcb2d55b7b08a90cd271a53bc76decb6d1ec37f219dbe4cd3ed53a888118b@52.193.245.92:30303,enode://34f172c255b11f64828d73c90a60395691e89782639423d434385594dd38b434ddffb78ad411da6fd37cbda6d0f93e17ceae399ac4f2594b0d54eb8c83c27de9@52.68.233.192:30303",
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

const STATIC_PEERS = if node_env().node_variant.contains("sepolia") {
    "--p2p.static=" + VARIANTS[node_env().node_variant].static_peers;
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

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::SONEIUM_DIR}/geth`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [
                #{
                    name: "init_job",
                    run_sh: `openssl rand -hex 32 > ${global::SONEIUM_DIR}/jwt.txt`,
                }
            ]
        },
        services: [
            #{
                name: "op-geth",
                run_sh: `/root/bin/op-geth --datadir=${global::SONEIUM_DIR}/ --http --http.corsdomain=* --http.vhosts=* \
                        --http.addr=127.0.0.1 --http.api=web3,debug,eth,txpool,net,engine --ws \
                        --ws.addr=127.0.0.1 --ws.port=${global::WS_PORT} --ws.origins=* --ws.api=debug,eth,txpool,net,engine \
                        --syncmode=full ${global::GETH_EXTRA_ARGS} --maxpeers=100 --authrpc.vhosts=* \
                        --authrpc.addr=127.0.0.1 --authrpc.port=${global::AUTHRPC_PORT} --authrpc.jwtsecret=${global::SONEIUM_DIR}/jwt.txt --metrics \
                        --metrics.addr=127.0.0.1 --metrics.expensive --metrics.port=${global::METRICS_PORT} \
                        --rollup.disabletxpoolgossip=false --rpc.allow-unprotected-txs=true --db.engine=pebble --state.scheme=hash \
                        --port=30303 \
                        ${global::GETH_BOOTNODES} \
                        --op-network=${global::OP_NETWORK}`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `/root/bin/op-node --l1=${global::L1_URL} --l2=http://127.0.0.1:${global::AUTHRPC_PORT} \
                        --rpc.addr=127.0.0.1 --rpc.port=${global::OP_NODE_RPC_PORT} \
                        --l2.jwt-secret=${global::SONEIUM_DIR}/jwt.txt --l1.trustrpc=true --l1.beacon=${global::BEACON_URL} \
                        --syncmode=execution-layer --l1.rpckind=${global::L1_RPCKIND} ${global::STATIC_PEERS} \
                        --p2p.priv.path=${global::SONEIUM_DIR}/p2p.key --p2p.discovery.path=${global::SONEIUM_DIR}/p2p.db \
                        --p2p.peerstore.path=${global::SONEIUM_DIR}/p2p-peerstore.db --metrics.enabled=true \
                        --p2p.ban.peers=false \
                        ${global::NODE_BOOTNODES} \
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
    let h = run_jrpc(#{host: global::SONEIUM_API, method: "optimism_syncStatus"}).expect(200);

    let block_timestamp = h.result.unsafe_l2.timestamp;

    let current_timestamp = parse_int(system_timestamp);

    if block_timestamp < current_timestamp - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}
