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
const INK_API = "http://127.0.0.1:8547";
const INK_DIR = node_env().protocol_data_path + "/ink";

const VARIANTS = #{
    "geth-mainnet-full": #{
        sequencer_url: "https://rpc-gel.inkonchain.com",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "ink-mainnet",
        bootnodes: "enr:-Iu4QCqTQZVBnbPWXcdUxcakGoCCzCFr5vVzDfNTOr-Pi3KaOJZMXlnqTR9r9p4EemXS8fS59EdQaX8qrkyE01nvsNcBgmlkgnY0gmlwhCIgwYaJc2VjcDI1NmsxoQMW3w0F1AibYelKqJUKaie5RuKc7S9sPfWvH4lSJw4Fo4N0Y3CCIyuDdWRwgiMs",
        network: "mainnet",
    },
    "geth-sepolia-full": #{
        sequencer_url: "https://rpc-gel-sepolia.inkonchain.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "ink-sepolia",
        bootnodes: "enr:-Iu4QN7Ohk84lCZMSAbuPbU1vSMF93J7FUUab2_JBNX8q6wSPBeWrGu85ENsL-s2fcf9gvYc_Eiw8ZzdBzP5i05g9DwBgmlkgnY0gmlwhCP2ulGJc2VjcDI1NmsxoQLqBVn4RC7vvLvOB95odV2bp6zKCQHPw7j60wBG68qGJYN0Y3CCIyuDdWRwgiMs",
        network: "sepolia",
    },
    "geth-mainnet-archive": #{
        sequencer_url: "https://rpc-gel.inkonchain.com",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "ink-mainnet",
        bootnodes: "enr:-Iu4QCqTQZVBnbPWXcdUxcakGoCCzCFr5vVzDfNTOr-Pi3KaOJZMXlnqTR9r9p4EemXS8fS59EdQaX8qrkyE01nvsNcBgmlkgnY0gmlwhCIgwYaJc2VjcDI1NmsxoQMW3w0F1AibYelKqJUKaie5RuKc7S9sPfWvH4lSJw4Fo4N0Y3CCIyuDdWRwgiMs",
        network: "mainnet",
    },
    "geth-sepolia-archive": #{
        sequencer_url: "https://rpc-gel-sepolia.inkonchain.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "ink-sepolia",
        bootnodes: "enr:-Iu4QN7Ohk84lCZMSAbuPbU1vSMF93J7FUUab2_JBNX8q6wSPBeWrGu85ENsL-s2fcf9gvYc_Eiw8ZzdBzP5i05g9DwBgmlkgnY0gmlwhCP2ulGJc2VjcDI1NmsxoQLqBVn4RC7vvLvOB95odV2bp6zKCQHPw7j60wBG68qGJYN0Y3CCIyuDdWRwgiMs",
        network: "sepolia",
    },

};

const GETH_EXTRA_ARGS = if node_env().node_variant.ends_with("-archive") {
    "--gcmode archive"
} else {
    ""
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;
const L1_URL = VARIANTS[node_env().node_variant].l1_url;
const BEACON_URL = VARIANTS[node_env().node_variant].beacon_url;
const OP_NETWORK = VARIANTS[node_env().node_variant].op_network;
const BOOTNODES = VARIANTS[node_env().node_variant].bootnodes;
const NETWORK = VARIANTS[node_env().node_variant].network;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::INK_DIR}/geth`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [
                #{
                    name: "init_job",
                    run_sh: `openssl rand -hex 32 > ${global::INK_DIR}/jwt.txt`,
                }
            ]
        },
        services: [
            #{
                name: "op-geth",
                run_sh: `/root/bin/op-geth --op-network ${global::OP_NETWORK} --syncmode=full --ws \
                        --ws.port=${global::WS_PORT} --ws.addr=127.0.0.1 --ws.origins="*" --http --http.api="eth,net,web3,debug" \
                        --http.port=${global::RPC_PORT} --http.addr=127.0.0.1 --http.vhosts="*" --http.corsdomain="*" \
                        --authrpc.addr=127.0.0.1 --authrpc.jwtsecret=${global::INK_DIR}/jwt.txt --authrpc.port=${global::AUTHRPC_PORT} \
                        --authrpc.vhosts="*" --verbosity=3 --rollup.sequencerhttp=${global::SEQUENCER_URL} --metrics \
                        --metrics.addr=127.0.0.1 --metrics.port=${global::METRICS_PORT} --datadir=${global::INK_DIR}/ \
                        --rollup.disabletxpoolgossip=true --nodiscover --maxpeers=0 ${global::GETH_EXTRA_ARGS}`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `/root/bin/op-node --network ${global::OP_NETWORK} --p2p.bootnodes=${global::BOOTNODES} --p2p.scoring=none \
                        --rpc.addr=127.0.0.1 --rpc.port=${global::OP_NODE_RPC_PORT} --l1=${global::L1_URL} --l1.beacon=${global::BEACON_URL} \
                        --l1.rpckind=${global::L1_RPCKIND} --l2=http://127.0.0.1:${global::AUTHRPC_PORT} --l2.jwt-secret=${global::INK_DIR}/jwt.txt \
                        --rollup.load-protocol-versions=true --rollup.halt=major`,
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
    let h = run_jrpc(#{host: global::INK_API, method: "optimism_syncStatus"}).expect(200);

    let block_timestamp = h.result.unsafe_l2.timestamp;

    let current_timestamp = parse_int(system_timestamp);

    if block_timestamp < current_timestamp - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}
