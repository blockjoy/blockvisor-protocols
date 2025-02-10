import "base" as base;
import "aux" as aux;

const RPC_PORT = 8547; // RPC_PORT
const WS_PORT = 8548;
const METRICS_PORT = 6767;
const METRICS_PATH = "/debug/metrics/prometheus";
const CADDY_DIR = node_env().data_mount_point + "/caddy";

let AUX_CONFIG = aux::base_config(METRICS_PORT, RPC_PORT, WS_PORT, CADDY_DIR, METRICS_PATH);

const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "nitro-mainnet-archive": #{
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        net_type: "main",
        wasm_root: "0x8b104a2e80ac6165dc58b9048de12f301d70b02a0ab51396c22b4b4b802a16a4",
    },
};

const API_HOST = `http://127.0.0.1:${RPC_PORT}`;
const HOME = node_env().protocol_data_path + "/arbitrum";

const VARIANT = VARIANTS[node_env().node_variant];

const BABEL_VERSION = "1.11.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${HOME}`,
            `mkdir -p ${CADDY_DIR}`,
        ],
        jobs: [
            #{
                name: "migrate_old_dir",
                run_sh: `[ -d "/blockjoy/arbitrum" ] && mv /blockjoy/arbitrum ${HOME} && rm -rf /blockjoy/arbitrum || true`,
            },
        ],
    },
    services: [
        #{
            name: "nitro",           
            run_sh: `HOME=${HOME} && /root/bin/nitro --parent-chain.connection.url=${VARIANT.l1_url} --chain.id=42170 --metrics --metrics-server.addr=127.0.0.1 --metrics-server.port=${METRICS_PORT} --http.api=net,web3,eth,arb --http.corsdomain=* --http.addr=127.0.0.1 --http.port=${RPC_PORT} --http.vhosts=* --ws.rpcprefix=/ --ws.addr=127.0.0.1 --ws.api=net,web3,eth,arb --ws.origins=* --ws.port=${WS_PORT} --execution.caching.archive --parent-chain.blob-client.beacon-url=${VARIANT.beacon_url} --validation.wasm.allowed-wasm-module-roots=${VARIANT.wasm_root} --persistent.chain=${HOME} --persistent.global-config=${HOME} --persistent.log-dir=${HOME}`,
            shutdown_timeout_secs: 300,
            log_timestamp: false,
        }
    ],
    upload: #{
        exclude: [
            "caddy/**",
        ],
    },
};

fn application_status() {
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

fn test_height_value(param) {
    if height() < 0 {
        throw "Invalid node height value: " + height();
    }
    param
}
