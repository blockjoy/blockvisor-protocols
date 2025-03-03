import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 6262;
const METRICS_PATH = "/debug/metrics/prometheus";

const VARIANTS = #{
    "erigon-mainnet-full": #{
        url: "https://checkpoint.gnosischain.com",
        extra_erigon_args: "--prune=htcr",
    },
    "erigon-mainnet-archive": #{
        url: "https://checkpoint.gnosischain.com",
        extra_lighthouse_args: "--genesis-backfill --disable-backfill-rate-limiting",
    },
};

const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;
const HOME = node_env().protocol_data_path + "/erigon";
const NET = "gnosis";
const CHECKPOINT_URL = VARIANTS[node_env().node_variant].url;

const ERIGON_ARGS = if VARIANTS[node_env().node_variant].keys().contains("extra_erigon_args") {
    VARIANTS[node_env().node_variant].extra_erigon_args
} else {
    ""
};

const LIGHTHOUSE_ARGS = if VARIANTS[node_env().node_variant].keys().contains("extra_lighthouse_args") {
    VARIANTS[node_env().node_variant].extra_lighthouse_args
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
            jobs: [
                #{
                    name: "create_jwt",
                    run_sh: `export HOME=/root && openssl rand -hex 32 | tr -d "\n" > ${global::HOME}/jwt.hex`,
                }
            ]
        },
        services: [
            #{
                name: "erigon",
                run_sh: `export HOME=/root && mkdir -p ${global::HOME} && /root/bin/erigon --datadir=${global::HOME} --chain=${global::NET} --healthcheck=true --port=30303 --http.port=${global::RPC_PORT} --authrpc.addr=127.0.0.1 --authrpc.port=8551 --torrent.port=42069 --private.api.addr=127.0.0.1:9090 --http --ws --ws.port ${global::WS_PORT} --http.addr=127.0.0.1 --http.api=eth,debug,net,trace,web3,erigon --nat=none --authrpc.jwtsecret=${global::HOME}/jwt.hex --torrent.download.rate=100mb --metrics --metrics.port=${global::METRICS_PORT} --metrics.addr=127.0.0.1 --http.vhosts="*" --downloader.disable.ipv6 --beacon.api.addr=127.0.0.1 ${global::ERIGON_ARGS}`,
                shutdown_timeout_secs: 120,
                use_blockchain_data: true,
            },
            #{
                name: "lighthouse",
                run_sh: `/root/bin/lighthouse bn --datadir ${global::HOME}/lighthouse --network ${global::NET} --checkpoint-sync-url ${global::CHECKPOINT_URL} --http --http-address 127.0.0.1 --http-port 6868 --execution-endpoint http://127.0.0.1:8551 --execution-jwt ${global::HOME}/jwt.hex --metrics ${global::LIGHTHOUSE_ARGS}`,
                shutdown_timeout_secs: 120,
                use_blockchain_data: true,
            },
        ],
        alternative_download: #{
            run_sh: "echo dummy"
        },
    }
}

fn application_status() {
    let resp = run_jrpc(#{host: global::API_HOST, method: ""});
    
    if resp.status_code == 200 {
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn address() {
    parse_json(run_jrpc(global::API_HOST, "eth_coinbase")).result.to_string()
}

fn height() {
    let resp = run_jrpc(#{host: global::API_HOST, method: "eth_blockNumber"});
    if resp.status_code != 200 {
        throw resp;
    }
    let h = parse_json(resp.body);
    parse_int(sub_string(h.result,2),16)
}

fn sync_status() {
    let data1 = #{url: global::API_HOST+"/health",
            method: "eth_getBlockByNumber",
            headers: [
                ["X-ERIGON-HEALTHCHECK", "synced"],
                ["X-ERIGON-HEALTHCHECK", "min_peer_count10"]
            ]
    };

    let resp1 = run_rest(data1);

    let data2 =  #{host: global::API_HOST,
            method: "eth_getBlockByNumber",
            params: ["latest", true],
            headers: [["content-type", "application/json"]],
    };

    let t = run_jrpc(data2).expect(200);

    let block_timestamp = parse_hex(t.result.timestamp);

    let system_timestamp = run_sh (`date +%s`).unwrap();
    let current_timestamp = parse_int(system_timestamp);
    
    if resp1.status_code > 225 {
        "syncing"
    } else if (block_timestamp < current_timestamp - 100) {
        "syncing"
    } else {
        "synced"
    }
}
