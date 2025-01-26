import "base" as base;
import "erigon" as erigon;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 6161;
const METRICS_PATH = "/debug/metrics/prometheus";

let ERIGON_CONFIG = erigon::base_config(global::METRICS_PORT, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR, global::METRICS_PATH);

const BASE_CONFIG = #{
    config_files: ERIGON_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: ERIGON_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "erigon-mainnet-archive": #{
        net: "bsc",
        chain_id: 56,
        network_name: "bsc",
    },
};

const API_HOST = `http://127.0.0.1:${global::RPC_PORT}`;
const HOME = node_env().protocol_data_path + "/bsc";
const NET = VARIANTS[node_env().node_variant].net;
const CHAIN_ID = VARIANTS[node_env().node_variant].chain_id;

const BABEL_VERSION = "1.11.0";

const PLUGIN_CONFIG = #{
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
            run_sh: `export HOME=/root && /root/bin/bsc-erigon \
                    --port 30303 \
                    --http.vhosts "*" \
                    --http.corsdomain "*" \
                    --http.addr 127.0.0.1 \
                    --http.port ${global::RPC_PORT} \
                    --http.api=eth,erigon,web3,net,debug,trace,txpool \
                    --http.trace \
                    --rpc.returndata.limit 1000000 \
                    --rpc.batch.limit 500 \
                    --ws \
                    --ws.port ${global::WS_PORT} \
                    --txpool.disable \
                    --metrics \
                    --metrics.addr=127.0.0.1 \
                    --metrics.port=${global::METRICS_PORT} \
                    --log.console.verbosity=info \
                    --db.pagesize=16k \
                    --db.size.limit=13TB \
                    --datadir ${global::HOME} \
                    --private.api.addr 127.0.0.1:9090 \
                    --chain bsc \
                    --snapshots=true \
                    --rpc.gascap 100000000 \
                    --torrent.download.rate 500mb \
                    --maxpeers 6 \
                    --rpc.evmtimeout 600s \
                    --downloader.disable.ipv6=true`,
            shutdown_timeout_secs: 120,
            use_blockchain_data: true,
            log_timestamp: false,
        },
    ],
    upload: #{
        exclude: [
            "jwt.hex",
            "caddy/**",
        ],
    },
};

fn application_status() {
    let resp = parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_chainId"}).expect(200).result);

    if resp == global::CHAIN_ID {
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
