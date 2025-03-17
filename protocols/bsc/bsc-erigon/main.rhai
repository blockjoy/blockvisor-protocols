import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 6161;
const METRICS_PATH = "/debug/metrics/prometheus";

const VARIANTS = #{
    "erigon-mainnet-archive": #{
        net: "bsc",
        chain_id: 56,
        network_name: "bsc",
    },
};

const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;
const HOME = node_env().protocol_data_path + "/bsc";
const NET = VARIANTS[node_env().node_variant].net;
const CHAIN_ID = VARIANTS[node_env().node_variant].chain_id;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::HOME}`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [
                #{
                    name: "create_jwt",
                    run_sh: `openssl rand -hex 32 > ${global::HOME}/jwt.hex`,
                }
            ]
        },
        services: [
            #{
                name: "bsc-erigon",
                run_sh: `export HOME=/root && /root/bin/erigon --port 30303 --http.vhosts "*" --http.corsdomain "*" --http.addr 127.0.0.1 --http.port ${global::RPC_PORT} --http.api=eth,erigon,web3,net,debug,trace,txpool --http.trace --rpc.returndata.limit 1000000 --rpc.batch.limit 500 --ws --ws.port ${global::WS_PORT} --txpool.disable --metrics --metrics.addr=127.0.0.1 --metrics.port=${global::METRICS_PORT} --log.console.verbosity=info --db.pagesize=16k --db.size.limit=13TB --datadir ${global::HOME} --private.api.addr 127.0.0.1:9090 --chain bsc --snapshots=true --rpc.gascap 100000000 --torrent.download.rate 500mb --maxpeers 6 --rpc.evmtimeout 600s --downloader.disable.ipv6=true`,
                shutdown_timeout_secs: 120,
            },
        ],
        upload: #{
            exclude: [
                "jwt.hex",
                "caddy/**",
            ],
        },
    }
}

fn protocol_status() {
    let resp = parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_chainId"}).expect(200).result);

    if resp == global::CHAIN_ID {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
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
