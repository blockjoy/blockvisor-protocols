import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const OPT_API_PORT = 7000;
const METRICS_PORT = 6060;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_URL = "https://eth-l1.blkjy.io";
const L1_BEACON_URL = "https://lighthouse.blkjy.io";
const L1_RPCKIND = "standard";

const RETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const OPTIMISM_API = "http://127.0.0.1:" + global::OPT_API_PORT;

const VARIANTS = #{
    "op-reth-mainnet-archive": #{
        sequencer_url: "https://mainnet-sequencer.optimism.io/",
        opnet: "op-mainnet",
        chain: "optimism",
    },
    "op-reth-mainnet-full": #{
        sequencer_url: "https://mainnet-sequencer.optimism.io/",
        opnet: "op-mainnet",
        chain: "optimism",
        extra_reth_args: "--full",
    },
};

const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;
const HOME = node_env().protocol_data_path + "/op-reth";
const DATADIR = node_env().protocol_data_path;
const OP_DIR = node_env().protocol_data_path + "/optimism";

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANT.sequencer_url;
const OPNET = VARIANT.opnet;
const CHAIN = VARIANT.chain;
const EXTRA_RETH_ARGS = if VARIANT.keys().contains("extra_reth_args") {
    VARIANT.extra_reth_args
} else {
    ""
};

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
                    run_sh: `mkdir -p ${global::OP_DIR} && openssl rand -hex 32 > ${global::OP_DIR}/jwt.txt`,
                },
            ],
        },
        services: [
            #{
                name: "op-reth",
                run_sh: `/root/bin/op-reth node --chain ${global::CHAIN} --rollup.sequencer-http ${global::SEQUENCER_URL} --http --http.addr 0.0.0.0 --http.port ${global::RPC_PORT} --http.corsdomain "*" --ws --ws.port ${global::WS_PORT} --ws.origins "*" --authrpc.port 8551 --http.api eth,web3,net,txpool,debug,trace --authrpc.jwtsecret ${global::OP_DIR}/jwt.txt --datadir ${global::OP_DIR}/op-reth --metrics 127.0.0.1:${global::METRICS_PORT} --rpc.max-blocks-per-filter=0 --rpc.gascap 18446744073709551615 --log.file.directory ${global::OP_DIR}/op-reth ${global::EXTRA_RETH_ARGS}`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `/root/bin/op-node --network=${global::OPNET} --rpc.addr=0.0.0.0 --rpc.port=${global::OPT_API_PORT} --l1=${global::L1_URL} --l1.beacon=${global::L1_BEACON_URL} --l1.trustrpc --l1.rpckind=${global::L1_RPCKIND} --l2=http://127.0.0.1:8551 --l2.jwt-secret=${global::OP_DIR}/jwt.txt --syncmode=execution-layer`,
                shutdown_timeout_secs: 120,
            },
        ],
        download: #{
            max_connections: 5,
        },
        alternative_download: #{
            run_sh: "echo this",
            restart: "never",
        },
        upload: #{
            exclude: [
                "jwt.txt",
                "bedrock.tar.zst",
                "bedrock.tar",
                "**/*.log*",
            ],
        },
        scheduled: [],
    }
}

fn application_status() {
    let resp = run_jrpc(#{host: global::RETH_API, method: ""});

    if resp.status_code == 200 {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
    }
}

fn height() {
    let resp = run_jrpc(#{host: global::RETH_API, method: "eth_blockNumber"});
    if resp.status_code != 200 {
        throw resp;
    }
    let h = parse_json(resp.body);
    parse_int(sub_string(h.result,2),16)
}

fn sync_status() {
    let system_timestamp = run_sh (`date +%s`).unwrap();
    let opresp = run_jrpc(#{host: global::OPTIMISM_API, method: "optimism_syncStatus"});
    let h = parse_json(opresp.body);

    let rethresp = run_jrpc(#{host: global::RETH_API, method: "eth_syncing"}).expect(200);

    let block_timestamp = h.result.unsafe_l2.timestamp;

    let current_timestamp = parse_int(system_timestamp);

    if rethresp.result != false || block_timestamp < current_timestamp - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}
