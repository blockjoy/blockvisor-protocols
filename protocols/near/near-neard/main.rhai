import "base" as base;
import "aux" as aux;

const BABEL_VERSION = "1.13.1";
const WORKDIR = "/root";
const DATA_DIR = node_env().protocol_data_path + "/near";
const RPC_PORT = 3030;
const METRICS_PORT = 9184;
const METRICS_PATH = "/metrics";
const CADDY_DIR = node_env().data_mount_point + "/caddy";
const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;

const VARIANTS = #{
    testnet: #{ 
        url: "https://near-nodes.io/",
        net_type: "test",
        network: "testnet",
        bootnodes: "ed25519:4k9csx6zMiXy4waUvRMPTkEtAS2RFKLVScocR5HwN53P@34.73.25.182:24567,ed25519:4keFArc3M4SE1debUQWi3F1jiuFZSWThgVuA2Ja2p3Jv@34.94.158.10:24567,\
        ed25519:D2t1KTLJuwKDhbcD9tMXcXaydMNykA99Cedz7SkJkdj2@35.234.138.23:24567,ed25519:CAzhtaUPrxCuwJoFzceebiThD9wBofzqqEMCiupZ4M3E@34.94.177.51:24567",
        extra_args: "--num-shards 0",
        config_file: "/root/bin/files/config.json.testnet"
    },
    mainnet: #{
        url: "https://near-nodes.io/",
        net_type: "main",
        network: "mainnet",
        bootnodes: "ed25519:86EtEy7epneKyrcJwSWP7zsisTkfDRH5CFVszt4qiQYw@35.195.32.249:24567,ed25519:BFB78VTDBBfCY4jCP99zWxhXUcFAZqR22oSx2KEr8UM1@35.229.222.235:24567,\
        ed25519:Cw1YyiX9cybvz3yZcbYdG7oDV6D7Eihdfc8eM1e1KKoh@35.195.27.104:24567,ed25519:33g3PZRdDvzdRpRpFRZLyscJdbMxUA3j3Rf2ktSYwwF8@34.94.132.112:24567,\
        ed25519:CDQFcD9bHUWdc31rDfRi4ZrJczxg8derCzybcac142tK@35.196.209.192:24567",
        extra_args: "--num-shards 0",
        config_file: "/root/bin/files/config.json.mainnet"
    },
};

const NET = VARIANTS[node_env().node_variant].network;

let AUX_CONFIG = aux::base_config(global::DATA_DIR, global::METRICS_PORT, global::METRICS_PATH, global::CADDY_DIR);

const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::CADDY_DIR}`,
        ],
        jobs: [
            #{
                name: "init",
                run_sh: `/root/bin/neard --home=${global::DATA_DIR} init --chain-id ${global::NET} --download-genesis --boot-nodes ${global::VARIANTS[global::NET].bootnodes} && rm ${global::DATA_DIR}/config.json && mv /root/bin/config.json ${global::DATA_DIR}/config.json`,
            }
        ]
    },
    services: [
        #{
            name: "near",
            run_sh: `/root/bin/neard --home=${global::DATA_DIR} run --rpc-prometheus-addr 127.0.0.1:6667`,
            shutdown_timeout_secs: 300,
            needs: [],
            log_timestamp: false,
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
};

fn application_status() {
    let result = run_jrpc(#{
            host: global::API_HOST,
            method: "status",
            headers: [["content-type", "application/json"]]
        }).expect(200);

    if result.result.sync_info.syncing == false {
        return "broadcasting";
    } else {
        return "delinquent";
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