import "base" as base;
import "reth" as reth;

const CADDY_DIR = DATA_DRIVE_MOUNT_POINT + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 6665;

let RETH_CONFIG = reth::base_config(global::METRICS_PORT,global::RPC_PORT,global::WS_PORT,global::CADDY_DIR);

const BASE_CONFIG  = #{
    config_files: RETH_CONFIG.config_files+base::BASE_CONFIG.config_files,
    services: RETH_CONFIG.services+base::BASE_CONFIG.services,
};

const VARIANTS = #{
    reth_sepolia_full: #{
        net: "sepolia",
    },
    reth_mainnet_full: #{
        net: "mainnet",
    },
    reth_sepolia_archive: #{
        net: "sepolia",
    },
    reth_mainnet_archive: #{
        net: "mainnet",
    },
};

const API_HOST = `http://127.0.0.1:${global::RPC_PORT}`;
const HOME = PROTOCOL_DATA_PATH + "/reth";
const NET = VARIANTS[node_env().node_variant].net;
const CADDY_DIR = DATA_DRIVE_MOUNT_POINT + "/caddy";

const RETH_EXTRA_ARGS = if node_params().nodetype == "full" {
    "--db-mode=full --pruning.block-limit=1048576"
} else {
    "--db-mode=archive"
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
            name: "reth",
            run_sh: `export HOME=/root && /root/bin/reth node \
                    --datadir=${global::HOME} \
                    --chain=${global::NET} \
                    --http \
                    --http.addr=127.0.0.1 \
                    --http.port=${global::RPC_PORT} \
                    --http.api=eth,net,web3,debug,trace,txpool \
                    --ws \
                    --ws.addr=127.0.0.1 \
                    --ws.port=${global::WS_PORT} \
                    --ws.api=eth,net,web3,debug,trace,txpool \
                    --metrics=127.0.0.1:${global::METRICS_PORT} \
                    --authrpc.jwtsecret=${global::HOME}/jwt.hex \
                    ${global::RETH_EXTRA_ARGS}`,
            shutdown_timeout_secs: 120,
            use_blockchain_data: true,
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