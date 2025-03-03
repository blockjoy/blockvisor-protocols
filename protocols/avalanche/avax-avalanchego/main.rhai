import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 9650;
const METRICS_PORT = 9651;
const METRICS_PATH = "/ext/metrics";

const NETS = #{
    mainnet: #{
        url: "https://api.avax.network/",
        net_type: "main",
    },
    testnet: #{
        url: "https://api.avax-test.network/",
        net_type: "test",
    },
};

const API_HOST = "http://127.0.0.1:9650/";
const EXTERNAL_API_HOST = "https://api.avax.network/";
const DATA_DIRECTORY = node_env().protocol_data_path + "/avalanche";
const CONFIG_DIR = "/root/avalanche";

const BABEL_VERSION = "0.9.0";

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::DATA_DIRECTORY}`,
                `cp -a ${global::CONFIG_DIR}/* ${global::DATA_DIRECTORY}`,
            ],
            jobs: []
        },
        services: [
            #{
                name: "avax",
                run_sh: `/root/bin/avalanchego --data-dir ${global::DATA_DIRECTORY} --chain-config-dir ${global::DATA_DIRECTORY}/configs/chains`,
                shutdown_timeout_secs: 150,
                log_buffer_capacity_mb: 256,
                use_blockchain_data: true,
                log_timestamp: false,
            },
        ],
        pre_upload: #{
            commands: [
                `rm -rf ${global::DATA_DIRECTORY}/staking/*`,
            ],
            jobs: []
        },
        upload: #{
            exclude: [
                "logs",
                "plugins",
                "*LOCK",
                "staking",
                "configs"
            ],
        },
        alternative_download: #{
            run_sh: "echo dummy"
        },
    }
}

fn application_status() {
    let path = "ext/health";
    let data = #{host: global::API_HOST + path, 
        method: "health.health", 
        headers: #{"content-type": "application/json"}
    };
    let resp = run_jrpc(data);
    let result = parse_json(resp.body);
    
    if result.healthy == "false" {
        if result.result.checks.bootstrapped.error == "subnets not bootstrapped" {
            "broadcasting"
        } else {
            "delinquent"
        }
    } else {
        "broadcasting"
    }
}

fn height() {
    let path = "ext/bc/C/rpc";
    let data = #{host: global::API_HOST + path, 
        method: "eth_blockNumber", 
        headers: #{"content-type": "application/json"}
    };
    let resp = run_jrpc(data);

    if resp.status_code != 200 {
        throw resp.status_code;
    }

    let hex = parse_json(resp.body);
    parse_int(sub_string(hex.result,2),16)
}

fn sync_status() {
    let localBlockHeight;
    try {
        localBlockHeight = height();
    } catch {
        return "syncing";
    }

    let latestBlockHeight = get_latest_block_height_from_external_api();

    if localBlockHeight < latestBlockHeight - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}

fn get_latest_block_height_from_external_api() {
    let path = "ext/bc/C/rpc";
    let data = #{host: global::EXTERNAL_API_HOST + path, 
        method: "eth_blockNumber", 
        headers: #{"content-type": "application/json"}
    };
    let resp = run_jrpc(data);
    if resp.status_code != 200 {
        throw "Latest block height from the external API not found";
    }

    let hex = parse_json(resp.body);
    parse_int(sub_string(hex.result,2),16)
}