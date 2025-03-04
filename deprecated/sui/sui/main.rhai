import "base" as base;
import "aux" as aux;

const WORKDIR = "/root";
const DATA_DIR = node_env().protocol_data_path + "/sui";
const RPC_PORT = 9000;
const METRICS_PORT = 9184;
const METRICS_PATH = "/metrics";
const CADDY_DIR = node_env().data_mount_point + "/caddy";
const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;

const VARIANTS = #{
    "sui-node-mainnet-full": #{
        url: "https://docs.sui.io/guides/operator",
        net_type: "main",
        network: "mainnet",
        rpc: "https://rpc-mainnet.suiscan.xyz",
    },
};

const NET = VARIANTS[node_env().node_variant].network;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::DATA_DIR, global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::CADDY_DIR, global::NET),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::DATA_DIR}/db`,
                `mkdir -p ${global::DATA_DIR}/config`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [
                #{
                    name: "init",
                    run_sh: `curl -fLJO https://github.com/MystenLabs/sui-genesis/raw/main/${global::NET}/genesis.blob --output-dir ${global::DATA_DIR}/config/`,
                }
            ]
        },
        services: [
            #{
                name: "sui",
                run_sh: `/root/bin/sui-node --config-path /root/bin/fullnode.yaml`,
            },
        ],
        upload: #{
            exclude: [
                "caddy/**",
            ],
        },
        scheduled: [],
    }
}

fn application_status() {
    let resp = run_jrpc(#{host: global::API_HOST, method: "sui_getChainIdentifier", headers: [["content-type", "application/json"]]}).expect(200).result.to_string();

    if resp == "35834a8a" {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
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
