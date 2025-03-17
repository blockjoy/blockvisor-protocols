import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const P2P_PORT = 30303;
const METRICS_PORT = 7770;
const METRICS_PATH = "/debug/metrics/prometheus";

const CELO_API = "http://127.0.0.1:" + global::RPC_PORT;
const CELO_DIR = node_env().protocol_data_path + "/celo";

const VARIANTS = #{
    "geth-mainnet-archive": #{
        network_name: "celo",
        sync_type: "archive"
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const NETWORK_NAME = VARIANT.network_name;
const SYNC_TYPE = VARIANT.sync_type;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::CELO_DIR}`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: []
        },
        services: [
            #{
                name: "geth",
                run_sh: `/root/bin/geth --verbosity 3 --syncmode full --gcmode ${global::SYNC_TYPE} --http --http.port ${global::RPC_PORT} --http.addr 127.0.0.1 --http.api eth,net,web3,debug,admin,personal --http.timeout.read 300 --http.timeout.write 300 --http.timeout.idle 300 --http.vhosts "*" --ws --ws.addr 127.0.0.1 --ws.port ${global::WS_PORT} --ws.api eth,net,web3,debug,admin,personal --ws.origins "*" --port ${global::P2P_PORT} --metrics --metrics.addr 127.0.0.1 --metrics.port ${global::METRICS_PORT} --light.serve 90 --light.maxpeers 1000 --maxpeers 1100 --datadir ${global::CELO_DIR} --txlookuplimit 0 --cache.preimages --rpc.gascap 0`,
                shutdown_timeout_secs: 300,
            },
        ],
        download: #{
            max_connections: 5,
        },
        upload: #{
            exclude: [],
        },
    }
}

fn protocol_status() {
    let resp = parse_hex(run_jrpc(#{host: global::CELO_API, method: "eth_chainId"}).expect(200).result);

    if resp == 42220 {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
    }
}

fn height() {
    let resp = run_jrpc(#{host: global::CELO_API, method: "eth_blockNumber"});
    if resp.status_code != 200 {
        throw resp;
    }
    let h = parse_json(resp.body);
    parse_int(sub_string(h.result,2),16)
}

fn sync_status() {
    let resp = run_jrpc(#{host: global::CELO_API, method: "eth_syncing"}).expect(200);
    if resp.result == false {
        "synced"
    } else {
        "syncing"
    }
}
