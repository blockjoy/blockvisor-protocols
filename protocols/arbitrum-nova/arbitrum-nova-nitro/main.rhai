import "base" as base;
import "nitro" as nitro;

const RPC_PORT = 8547;
const WS_PORT = 8548;
const METRICS_PORT = 6767;

let NITRO_CONFIG = nitro::base_config(global::METRICS_PORT, "", global::RPC_PORT, global::WS_PORT, global::CADDY_DIR, "/debug/metrics/prometheus");

const BASE_CONFIG = #{
    config_files: NITRO_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: NITRO_CONFIG.services + base::BASE_CONFIG.services,
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
const HOME = BLOCKCHAIN_DATA_PATH + "/arbitrum";
const CADDY_DIR = BLOCKCHAIN_DATA_PATH + "/caddy";

const VARIANT = VARIANTS[node_env().node_variant];

const BABEL_VERSION = "1.11.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::HOME}`,
            `mkdir -p ${global::CADDY_DIR}`,
        ],
        jobs: [
            #{
                name: "migrate_old_dir",
                run_sh: `[ -d "/blockjoy/arbitrum" ] && mv /blockjoy/arbitrum ${BLOCKCHAIN_DATA_PATH} && rm -rf /blockjoy/arbitrum || true`,
            },
        ],
    },
    services: [
        #{
            name: "nitro",           
            run_sh: `HOME=${global::HOME} && /usr/bin/nitro \
                    --parent-chain.connection.url=${global::VARIANT.l1_url} \
                    --chain.id=42170 \
                    --metrics \
                    --metrics-server.addr=127.0.0.1 \
                    --metrics-server.port=${global::METRICS_PORT} \
                    --http.api=net,web3,eth,arb \
                    --http.corsdomain=* \
                    --http.addr=127.0.0.1 \
                    --http.port=${global::RPC_PORT} \
                    --http.vhosts=* \
                    --ws.rpcprefix=/ \
                    --ws.addr=127.0.0.1 \
                    --ws.api=net,web3,eth,arb \
                    --ws.origins=* \
                    --ws.port=${global::WS_PORT} \
                    --execution.caching.archive \
                    --parent-chain.blob-client.beacon-url=${global::VARIANT.beacon_url} \
                    --validation.wasm.allowed-wasm-module-roots=${global::VARIANT.wasm_root} \
                    --persistent.chain=${global::HOME} \
                    --persistent.global-config=${global::HOME} \
                    --persistent.log-dir=${global::HOME}`,
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
