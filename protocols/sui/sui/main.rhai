import "base" as base;
import "aux" as aux;

const BABEL_VERSION = "1.13.1";
const WORKDIR = "/root";
const DATA_DIR = node_env().protocol_data_path + "/sui";
const METRICS_API = "http://127.0.0.1:8000/metrics";
const METRICS_PORT = 4141;
const METRICS_PATH = "/debug/metrics/prometheus";
const ENV = node_env();
const CADDY_DIR = DATADIR + "/caddy";
const API_HOST = "http://127.0.0.1:9000/";

const VARIANTS = #{
    "sui-testnet": #{
        url: "https://docs.sui.io/guides/operator",
        net_type: "test",
        network: "testnet",
        rpc: "https://rpc-testnet.suiscan.xyz"
    },
    "sui-mainnet": #{
        url: "https://docs.sui.io/guides/operator",
        net_type: "main",
        network: "mainnet",
        rpc: "https://rpc-mainnet.suiscan.xyz",
    },
};

const NET = VARIANTS[node_env().node_variant].network;

let AUX_CONFIG = aux::base_config(global::DATA_DIR, global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::CADDY_DIR, global::NET);

const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::DATA_DIR}/db`,
            `mkdir -p ${global::DATA_DIR}/config`,
            `mkdir -p ${global::CADDY_DIR}`,
        ],
        jobs: [
            #{
                name: "init",
                run_sh: `curl -fLJO https://github.com/MystenLabs/sui-genesis/raw/main/${global::NET.network}/genesis.blob --output-dir ${global::DATA_DIR}/config/`,
            }
        ]
    },
    services: [
        #{
            name: "sui",
            run_sh: `/root/bin/${global::NET.network}/sui-node --config-path /root/bin/fullnode.yaml`,
        },
    ],
    upload: #{
        exclude: [
            "caddy/**",
        ],
    },
    scheduled: [],
};

fn application_status() {
    let resp = run_jrpc(#{host: global::API_HOST, method: "sui_getChainIdentifier", headers: [["content-type", "application/json"]]}).expect(200).result.to_string();

    if resp == "35834a8a" {
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn height() {
    parse_int(run_jrpc(#{ host: global::API_HOST, method: "sui_getLatestCheckpointSequenceNumber"}).expect(200).result)
}

fn sync_status() {
    let local_checkpoint = parse_int(run_jrpc(#{ host: global::API_HOST, method: "sui_getLatestCheckpointSequenceNumber"}).expect(200).result);
    let network_checkpoint = parse_int(run_jrpc(#{ host: global::NET.rpc, method: "sui_getLatestCheckpointSequenceNumber"}).expect(200).result);

    if network_checkpoint - local_checkpoint < "500" {
        "synced"
    } else {
        "syncing"
    }
}