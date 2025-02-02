import "base" as base;
import "aux" as aux;

// Define protocol-specific constants
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 9090;
const METRICS_PATH = "/metrics";
const CADDY_DIR = node_env().data_mount_point + "/caddy";
const EXAMPLE_DIR = node_env().protocol_data_path + "/example";

// Import auxiliary configuration
let AUX_CONFIG = aux::base_config(global::METRICS_PORT, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR);

// Merge with base configuration
const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

// Define protocol variants
const VARIANTS = #{
    "example-mainnet-full": #{
        network: "mainnet",
        extra_args: "--syncmode full",
    },
    "example-mainnet-archive": #{
        network: "mainnet",
        extra_args: "--syncmode full --gcmode archive",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;
const BABEL_VERSION = "0.1.0";

// Determine extra args based on variant
const EXTRA_ARGS = if node_env().node_variant.ends_with("-full") {
    "--prune htc"
} else {
    "--prune none"
};

// Plugin configuration
const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::EXAMPLE_DIR}`,
            `mkdir -p ${global::CADDY_DIR}`,
        ],
        jobs: [
            #{
                name: "init_job",
                run_sh: `openssl rand -hex 32 > ${global::EXAMPLE_DIR}/jwt.txt`,
            },
        ],
    },
    services: BASE_CONFIG.services + [
        #{
            name: "example-node",
            run_sh: `/usr/bin/example-node \
                    --datadir=${global::EXAMPLE_DIR} \
                    --network=${global::VARIANT.network} \
                    --http \
                    --http.addr=127.0.0.1 \
                    --http.port=${global::RPC_PORT} \
                    --http.api=eth,net,web3 \
                    --ws \
                    --ws.addr=127.0.0.1 \
                    --ws.port=${global::WS_PORT} \
                    --ws.api=eth,net,web3 \
                    --metrics \
                    --metrics.addr=127.0.0.1 \
                    --metrics.port=${global::METRICS_PORT} \
                    ${global::VARIANT.extra_args} \
                    ${global::EXTRA_ARGS}`,
            shutdown_timeout_secs: 120,
            use_blockchain_data: true,
            log_timestamp: false,
        },
    ],
    config_files: BASE_CONFIG.config_files,
};

// Required status functions
fn application_status() {
    let resp = parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_chainId"}).expect(200).result);
    
    if resp == 1 { // Example chain ID
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn height() {
    parse_hex(run_jrpc(#{ host: global::API_HOST, method: "eth_blockNumber"}).expect(200).result)
}

fn sync_status() {
    let resp = run_jrpc(#{host: global::API_HOST, method: "eth_syncing"}).expect(200);
    if resp.result == false {
        "synced"
    } else {
        "syncing"
    }
}
