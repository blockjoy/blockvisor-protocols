import "base" as base;
import "aux" as aux;

const METRICS_PORT = "6070";
const ARB_NODE_RPC_PORT = "8546";
const RPC_PORT = "8547";
const WS_PORT = "8549";
const METRICS_PATH = "/debug/metrics/prometheus";
const CADDY_DIR = node_env().data_mount_point + "/caddy";
const CLASSIC_RPC = "http://127.0.0.1:8546";

let AUX_CONFIG = aux::base_config(global::METRICS_PORT, global::ARB_NODE_RPC_PORT, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR, global::METRICS_PATH);

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
    "nitro-mainnet-full": #{
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        net_type: "main",
        wasm_root: "0x8b104a2e80ac6165dc58b9048de12f301d70b02a0ab51396c22b4b4b802a16a4",
    },
};

const API_HOST = "http://127.0.0.1:8547/";
const HOME = node_env().protocol_data_path;
const ONE_DIR = node_env().protocol_data_path + "/arb-one";
const NITRO_DIR = node_env().protocol_data_path + "/nitro";

const VARIANT = VARIANTS[node_env().node_variant];

const NITRO_EXTRA_ARGS = if node_env().node_variant.ends_with("-archive") {
    `--execution.rpc.classic-redirect=${global::CLASSIC_RPC}`
} else {
    ""
};

const BABEL_VERSION = "0.9.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::ONE_DIR}`,
            `mkdir -p ${global::NITRO_DIR}`,
            `mkdir -p ${global::CADDY_DIR}`,
        ],
        jobs: [
            #{
                name: "init_job",
                run_sh: `openssl rand -hex 32 > ${global::ONE_DIR}/jwt.txt`,
            },
        ],
    },
    services: {
        let base_services = [
            #{
                name: "nitro",           
                run_sh: `HOME=${global::NITRO_DIR} && /root/bin/nitro --parent-chain.connection.url=${global::VARIANT.l1_url} --chain.id=42161 --metrics --metrics-server.addr=127.0.0.1 --metrics-server.port=${global::METRICS_PORT} --http.api=net,web3,eth,arb,debug --http.corsdomain=* --http.addr=127.0.0.1 --http.port=${global::RPC_PORT} --http.vhosts=* --ws.addr=127.0.0.1 --ws.api=net,web3,eth,arb,debug --ws.origins=* --ws.port=${global::WS_PORT} --execution.caching.archive --parent-chain.blob-client.beacon-url=${global::VARIANT.beacon_url} --validation.wasm.allowed-wasm-module-roots=${global::VARIANT.wasm_root}  ${global::NITRO_EXTRA_ARGS}`,
                shutdown_timeout_secs: 300,
                log_timestamp: false,
            }
        ];

        if global::NITRO_EXTRA_ARGS != "" {
            base_services + [
                #{
                    name: "arb-node",
                    run_sh: `HOME=${global::ONE_DIR} && /root/bin/arb-node --l1.url=${global::VARIANT.l1_url} --node.chain-id=42161 --l2.disable-upstream --node.cache.allow-slow-lookup --node.rpc.port=${global::ARB_NODE_RPC_PORT} --core.checkpoint-gas-frequency=156250000 --core.lazy-load-core-machine`,
                    log_timestamp: false,
                }
            ]
        } else {
            base_services
        }
    },
    upload: #{
        exclude: [
            "caddy/**",
        ],
    },
};

fn application_status() {
    let resp = parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_chainId"}).expect(200).result);

    if resp == 42161 {
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

fn test_height_value(param) {
    if height() < 0 {
        throw "Invalid node height value: " + height();
    }
}
