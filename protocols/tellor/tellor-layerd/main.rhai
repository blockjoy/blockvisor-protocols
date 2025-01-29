import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const PROTOCOL_DIR = node_env().protocol_data_path + "/tellor";
const RPC_PORT = 26657;
const P2P_PORT = 26656;
const REST_PORT = 1317;
const GRPC_WEB_PORT = 9091;
const GRPC_PORT = 9090;
const METRICS_PORT = 26660;
const METRICS_PATH = "/metrics";
const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;


let AUX_CONFIG = aux::base_config(global::PROTOCOL_DIR, global::METRICS_PORT, global::P2P_PORT, global::RPC_PORT, global::REST_PORT, global::GRPC_WEB_PORT, global::GRPC_PORT, global::CADDY_DIR, global::METRICS_PATH);

const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "layerd-testnet-full": #{
        hostname: node_env().node_name,
        chain_id: "layertest-2",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const HOSTNAME = VARIANT.hostname;
const CHAIN_ID = VARIANT.chain_id;

const BABEL_VERSION = "0.9.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::PROTOCOL_DIR}/.layer/config`,
            `mkdir -p ${global::CADDY_DIR}`,
            `mv /root/configs/* ${global::PROTOCOL_DIR}/.layer/config/`,
        ],
        jobs: [
            #{
                name: "init",
                run_sh: `export HOME=${global::PROTOCOL_DIR} && \
                /root/bin/layerd init ${global::HOSTNAME} --overwrite --home ${global::PROTOCOL_DIR}/ --chain-id ${global::CHAIN_ID}`,
            }
        ]
    },
    services: [
        #{
            name: "layerd",
            run_sh: `export DAEMON_HOME=${global::PROTOCOL_DIR}/.layer && \
                export DAEMON_NAME=layerd && \
                export UNSAFE_SKIP_BACKUP=true && \
                export HOME=${global::PROTOCOL_DIR} && \
                /root/bin/layerd start`,
            shutdown_timeout_secs: 300,
        },
    ],
    download: #{
        max_connections: 5,
    },
    upload: #{
        exclude: [
            "tellor/.layer/config/**",
        ],
    },
};

fn application_status() {
    let result = run_jrpc(#{
            host: global::API_HOST,
            method: "status",
            headers: [["content-type", "application/json"]]
        }).expect(200);

    if result.result.sync_info.catching_up == false {
        "broadcasting"
    } else {
        "delinquent"
    }
}


fn height() {
    parse_int(run_jrpc(#{ 
        host: global::API_HOST, 
        method: "status",
        headers: [["content-type", "application/json"]]
    }).expect(200).result.sync_info.latest_block_height)
}

fn sync_status() {
    let result = run_jrpc(#{
            host: global::API_HOST,
            method: "status",
            headers: [["content-type", "application/json"]]
        }).expect(200);

    if result.result.sync_info.catching_up == false {
        "synced"
    } else if result.result.sync_info.catching_up == true {
        "syncing"
    }
    
}
