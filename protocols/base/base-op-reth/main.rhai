import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const AUTHRPC_PORT = 8551;
const OP_RPC_PORT = 7000;
const METRICS_PORT = 6665;
const METRICS_PATH = "/debug/metrics/prometheus";

let AUX_CONFIG = aux::base_config(global::METRICS_PORT,global::METRICS_PATH,global::RPC_PORT,global::WS_PORT,global::AUTHRPC_PORT,global::OP_RPC_PORT,global::CADDY_DIR);
const BASE_CONFIG  = #{
    config_files: AUX_CONFIG.config_files+base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services+base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "op-reth-mainnet-full": #{
        net: "base-mainnet",
        chain: "base",
        l1_rpckind: "standard",
        opnet: "base-mainnet",
        sequencer_url: "https://mainnet-sequencer.base.org",
    },
    "op-reth-mainnet-archive": #{
        net: "base-mainnet",
        chain: "base",
        l1_rpckind: "standard",
        opnet: "base-mainnet",
        sequencer_url: "https://mainnet-sequencer.base.org",
    },
};

const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;
const HOME = node_env().protocol_data_path + "/base";
const NET = VARIANTS[node_env().node_variant].net;
const CHAIN = VARIANTS[node_env().node_variant].chain;
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;
const L1_URL = "https://eth-l1.blkjy.io";
const L1_BEACON_URL = "https://lighthouse.blkjy.io";

const OP_RETH_EXTRA_ARGS = if node_env().node_variant.ends_with("-full") {
    "--full"
} else {
    ""
};

const BABEL_VERSION = "0.9.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::HOME}`,
            `mkdir -p ${global::CADDY_DIR}`,
        ],
        jobs: [
            #{
                name: "create_jwt",
                run_sh: `export HOME=/root && openssl rand -hex 32 | tr -d "\n" > ${global::HOME}/jwt.hex`,
            }
        ]
    },
    services: [
        #{
            name: "op-reth",
            run_sh: `export HOME=/root && /root/bin/op-reth node --chain ${global::CHAIN} --rollup.sequencer-http ${global::SEQUENCER_URL} --http --http.addr 127.0.0.1 --http.port ${global::RPC_PORT} --http.corsdomain "*" --ws --ws.port ${global::WS_PORT} --authrpc.port ${global::AUTHRPC_PORT} --http.api eth,web3,net,txpool,debug,trace --authrpc.jwtsecret ${global::HOME}/jwt.hex --datadir ${global::HOME} --metrics 127.0.0.1:${global::METRICS_PORT} --log.file.directory ${global::HOME} --rpc.gascap 18446744073709551615`,
            shutdown_timeout_secs: 120,
            use_blockchain_data: true,
            log_timestamp: false,
        },
        #{
            name: "op-node",
            run_sh: `export HOME=/root && /root/bin/op-node --network=${global::NET} --rpc.addr=127.0.0.1 --rpc.port=${global::OP_RPC_PORT} --l1=${global::L1_URL} --l1.beacon=${global::L1_BEACON_URL} --l1.trustrpc --l2.enginekind=reth --l2=http://127.0.0.1:${global::AUTHRPC_PORT} --l2.jwt-secret=${global::HOME}/jwt.hex --syncmode=execution-layer`,
            shutdown_timeout_secs: 120,
            use_blockchain_data: true,
            log_timestamp: false,
        },  
    ],
    alternative_download: #{
        run_sh: "echo dummy"
    },
    upload: #{
        exclude: [
            "jwt.hex",
        ]
    }
};

fn application_status() {
    /// "uploading", "downloading", "initializing" statuses are automatically handled by BV if BABEL_CONFIG const is defined
    let resp = run_jrpc(#{host: global::API_HOST, method: "/"});
    
    if resp.status_code == 200 {
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn height() {
    parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_blockNumber"}).expect(200).result)
}


fn sync_status() {
    let resp = run_jrpc(#{host: global::API_HOST, method: "eth_syncing"}).expect(200);
    if resp.result == false {
        "synced"
    } else {
        "syncing"
    }
}