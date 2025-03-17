import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 6161;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_RPCKIND = "standard";

const GETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const OPTIMISM_API = "http://127.0.0.1:8547";
const DATADIR = node_env().protocol_data_path;
const OP_DIR = node_env().protocol_data_path + "/optimism";

const VARIANTS = #{
    "op-geth-mainnet-archive": #{
        sequencer_url: "https://mainnet-sequencer.optimism.io/",
        net_type: "main",
        url: "https://mainnet.optimism.io",
        l1_url: "http://eth-l1.blkjy.io",
        l1_beacon_url: "http://lighthouse.blkjy.io",
        snapshot_url: "https://datadirs.optimism.io/mainnet-bedrock.tar.zst",
        checkpoint: "https://beaconstate.ethstaker.cc",
        opnet: "mainnet",
        ethnet: "mainnet",
        chainid: 10,
    },
    "op-geth-testnet-archive": #{
        sequencer_url: "https://goerli-sequencer.optimism.io/",
        net_type: "test",
        url: "https://goerli.optimism.io",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        l1_beacon_url: "https://lighthouse-sepolia.blkjy.io",
        snapshot_url: "https://datadirs.optimism.io/goerli-bedrock.tar.zst",
        checkpoint: "https://goerli.beaconstate.ethstaker.cc",
        opnet: "sepolia",
        ethnet: "goerli",
        chainid: 11155420,
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANT.sequencer_url;
const L1_URL = VARIANT.l1_url;
const L1_BEACON_URL = VARIANT.l1_beacon_url;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::OP_DIR}`,
            ],
            jobs: [
                #{
                    name: "init_job",
                    run_sh: `openssl rand -hex 32 > ${global::OP_DIR}/jwt.txt`,
                }
            ]
        },
        services: [
            #{
                name: "op-geth",
                run_sh: `/root/bin/op-geth --ws --ws.port=${global::WS_PORT} --ws.addr=127.0.0.1 --ws.origins="*" --http --http.api="eth,net,web3,debug" --http.port=${global::RPC_PORT} --http.addr=127.0.0.1 --http.vhosts="*" --http.corsdomain="*" --authrpc.addr=127.0.0.1 --authrpc.jwtsecret=${global::OP_DIR}/jwt.txt --authrpc.port=8551 --authrpc.vhosts="*" --rollup.historicalrpc="http://127.0.0.1:8548" --gcmode=archive --verbosity=3 --rollup.sequencerhttp=${global::SEQUENCER_URL} --nodiscover --metrics --metrics.addr=127.0.0.1 --metrics.port=${global::METRICS_PORT} --syncmode=full --maxpeers=0 --datadir=${global::OP_DIR}/geth --snapshot=false --networkid=${global::VARIANT.chainid} --nat none --rollup.disabletxpoolgossip=true --nodiscover --op-network=op-${global::VARIANT.opnet} --cache 8192`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `/root/bin/op-node --network=${global::VARIANT.opnet} --rpc.addr=127.0.0.1 --rpc.port=8547 --l1=${global::L1_URL} --l1.beacon=${global::L1_BEACON_URL} --l1.trustrpc --l1.rpckind=${global::L1_RPCKIND} --l2=http://127.0.0.1:8551 --l2.jwt-secret=${global::OP_DIR}/jwt.txt`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-l2geth",
                run_sh: `USING_OVM=true ETH1_SYNC_SERVICE_ENABLE=false RPC_API=eth,rollup,net,web3,debug RPC_ADDR=127.0.0.1 RPC_CORS_DOMAIN=* RPC_ENABLE=true RPC_PORT=8548 RPC_VHOSTS=* /root/bin/op-l2geth --datadir ${global::OP_DIR}/l2geth --port 30304 --nousb`,
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
        scheduled: [],
    }
}

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
    let h = run_jrpc(#{host: global::OPTIMISM_API, method: "optimism_syncStatus"}).expect(200);

    let block_timestamp = h.result.unsafe_l2.timestamp;

    let current_timestamp = parse_int(system_timestamp);

    if block_timestamp < current_timestamp - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}
