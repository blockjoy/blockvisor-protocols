import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8551;
const WS_PORT = 8552;
const METRICS_PORT = 61001;
const METRICS_PATH = "/metrics";

const VARIANTS = #{
    "ken-mainnet-full": #{
        network_name: "cypress",
        sync_type: "full",
    },
    "ken-mainnet-archive": #{
        network_name: "cypress",
        sync_type: "archive",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;
const HOME = node_env().protocol_data_path + "/kaia/data";
const CHAIN = VARIANT.network_name;
const SYNC_TYPE = VARIANT.sync_type;

const KAIA_KEN_EXTRA_ARGS = if node_env().node_variant.ends_with("-archive") {
    "--db.leveldb.cache-size 8096 --state.cache-size 8096 --cache.memory 64"
} else {
    ""
};

const BABEL_VERSION = "0.9.0";

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::HOME}`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [],
        },
        services: [
            #{
                name: "ken",
                run_sh: `/root/bin/ken --${global::CHAIN} --gcmode ${global::SYNC_TYPE} --datadir ${global::HOME} --rpc.concurrencylimit 8000 --rpcreadtimeout 180 --rpcexecutiontimeout 180 --rpc --rpcaddr 127.0.0.1 --rpcapi klay,eth,net,web3,rpc,debug --rpcport ${global::RPC_PORT} --ws --wsaddr 127.0.0.1 --wsapi klay,eth,net,web3,rpc,debug --wsport ${global::WS_PORT} --wsorigins "*" --metrics --prometheus --prometheusport ${global::METRICS_PORT} ${global::KAIA_KEN_EXTRA_ARGS}`,
                shutdown_timeout_secs: 120,
            },
        ],
        upload: #{
            exclude: [],
            url_expires_secs: 604799,
        }
    }
}

fn application_status() {
    let resp = run_jrpc(#{ host: global::API_HOST, method: "eth_syncing"});

    if resp.status_code == 200 {
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn height() {
    parse_hex(run_jrpc(#{ host: global::API_HOST, method: "eth_blockNumber"}).expect(200).result)
}

fn sync_status() {
    let is_syncd = run_jrpc(#{ host: global::API_HOST, method: "eth_syncing"}).expect(200);

    if is_syncd.result == false {
        "synced"
    } else {
        "syncing"
    }
}
