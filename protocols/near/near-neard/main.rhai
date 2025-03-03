import "base" as base;
import "aux" as aux;

const BABEL_VERSION = "1.13.1";
const WORKDIR = "/root";
const DATA_DIR = node_env().protocol_data_path + "/near";
const RPC_PORT = 3030;
const METRICS_PORT = 6667;
const METRICS_PATH = "/metrics";
const CADDY_DIR = node_env().data_mount_point + "/caddy";
const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;

const VARIANTS = #{
    "near-mainnet-full": #{
        url: "https://near-nodes.io/",
        net_type: "main",
        network: "mainnet",
        bootnodes: "ed25519:86EtEy7epneKyrcJwSWP7zsisTkfDRH5CFVszt4qiQYw@35.195.32.249:24567,ed25519:BFB78VTDBBfCY4jCP99zWxhXUcFAZqR22oSx2KEr8UM1@35.229.222.235:24567,\
        ed25519:Cw1YyiX9cybvz3yZcbYdG7oDV6D7Eihdfc8eM1e1KKoh@35.195.27.104:24567,ed25519:33g3PZRdDvzdRpRpFRZLyscJdbMxUA3j3Rf2ktSYwwF8@34.94.132.112:24567,\
        ed25519:CDQFcD9bHUWdc31rDfRi4ZrJczxg8derCzybcac142tK@35.196.209.192:24567",
    },
};

const NET = VARIANTS[node_env().node_variant].network;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [
                #{
                    name: "init",
                    run_sh: `/root/bin/neard --home=${global::DATA_DIR} init --chain-id ${global::NET} --download-genesis --boot-nodes ${global::VARIANTS[node_env().node_variant].bootnodes} && rm ${global::DATA_DIR}/config.json && mv /root/bin/config.json ${global::DATA_DIR}/config.json`,
                }
            ]
        },
        services: [
            #{
                name: "near",
                run_sh: `/root/bin/neard --home=${global::DATA_DIR} run --rpc-prometheus-addr 127.0.0.1:${global::METRICS_PORT}`,
                shutdown_timeout_secs: 300,
                needs: [],
            }
        ],
        pre_upload: #{
            commands: [
                `echo "Preparing to upload"`,
            ],
            jobs: [
                #{
                    name: "upload_prep",
                    run_sh: `sleep 300`,
                }
            ]
        },
        upload: #{
            exclude: [
                "caddy/**",
            ],
        },
        scheduled: [],
    }
}

fn application_status() {
    let result = run_jrpc(#{
            host: global::API_HOST,
            method: "status",
            headers: [["content-type", "application/json"]]
        }).expect(200);

    if result.result.sync_info.syncing == false {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
    }
}

fn height() {
    run_jrpc(#{ host: global::API_HOST, method: "status"}).expect(200).result.sync_info.latest_block_height
}

fn sync_status() {
    let sync_status = run_jrpc(#{ host: global::API_HOST, method: "status"}).expect(200).result.sync_info.syncing;

    if sync_status == false {
        return "synced";
    } else {
        return "syncing";
    }
}

/// Test functions starting with test_ COULD be implemented as part of test harness
/// Running `bv node check ID_OR_NAME` will execute all defined test_* functions
/// MAY be implemented
fn test_height_value(param) {
    if height() < 0 {
        throw "Invalid node height value: " + height();
    }
}
