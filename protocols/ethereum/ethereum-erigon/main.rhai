import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 6161;

const VARIANTS = #{
    "erigon-goerli-full": #{
        net: "goerli",
        url: "https://prater.beaconstate.info",
    },
    "erigon-sepolia-full": #{
        net: "sepolia",
        url: "https://sepolia.beaconstate.info",
    },
    "erigon-mainnet-full": #{
        net: "mainnet",
        url: "https://mainnet.checkpoint.sigp.io",
    },
    "erigon-goerli-archive": #{
        net: "goerli",
        url: "https://prater.beaconstate.info",
    },
    "erigon-sepolia-archive": #{
        net: "sepolia",
        url: "https://sepolia.beaconstate.info",
    },
    "erigon-mainnet-archive": #{
        net: "mainnet",
        url: "https://mainnet.checkpoint.sigp.io",
    },
};

const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;

const HOME = node_env().protocol_data_path + "/erigon";

const LIGHTHOUSE_DIR = node_env().protocol_data_path + "/lighthouse";

const NET = VARIANTS[node_env().node_variant].net;

const CHECKPOINT_URL = VARIANTS[node_env().node_variant].url;

const EXTRA_ERIGON_ARGS = if node_env().node_variant.ends_with("-full") {
    "--prune=htcr"
} else {
    ""
};

fn plugin_config() {#{
    config_files: base::config_files() + aux::config_files(global::METRICS_PORT,global::RPC_PORT,global::WS_PORT,global::CADDY_DIR),
    aux_services: base::aux_services() + aux::aux_services(),
    init: #{
        commands: [
            `mkdir -p ${global::HOME}`,
            `mkdir -p ${global::LIGHTHOUSE_DIR}`,
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
            run_sh: `export HOME=/root && /root/bin/erigon --datadir=${global::HOME} --chain=${global::NET} --healthcheck=true --port=30303 --http.port=${global::RPC_PORT} --authrpc.port=8551 --torrent.port=42069 --private.api.addr=127.0.0.1:9090 --http --ws --ws.port=${global::WS_PORT} --http.api=eth,debug,net,trace,web3,erigon --nat=none --authrpc.jwtsecret=${global::HOME}/jwt.hex --metrics --metrics.port=${global::METRICS_PORT} --metrics.addr=127.0.0.1 --torrent.download.rate=100mb --http.vhosts 127.0.0.1 --downloader.disable.ipv6 --caplin.backfilling=true --caplin.backfilling.blob=true --caplin.backfilling.blob.no-pruning=true --caplin.archive=true --beacon.api=beacon,builder,config,debug,node,validator,lighthouse --internalcl ${global::EXTRA_ERIGON_ARGS}`,
            shutdown_timeout_secs: 120,
        },
        #{
            name: "lighthouse",
            run_sh: `RUST_LOG=info /root/bin/lighthouse bn --network ${global::NET} --datadir ${global::LIGHTHOUSE_DIR} --checkpoint-sync-url ${global::CHECKPOINT_URL} --disable-deposit-contract-sync --http --http-address 127.0.0.1 --http-port 5052 --execution-endpoint http://127.0.0.1:8551 --execution-jwt ${global::HOME}/jwt.hex --metrics --metrics-port 9002 --prune-blobs false --reconstruct-historic-states --block-cache-size 64 --genesis-backfill --historic-state-cache-size 4 --disable-backfill-rate-limiting`,
            shutdown_timeout_secs: 120,
        },
    ],
    alternative_download: #{
        run_sh: "echo dummy"
    },
    upload: #{
        exclude: [
            "jwt.hex",
            "caddy/**",
        ]
    }
}}

fn protocol_status() {
    let resp = run_jrpc(#{host: global::API_HOST, method: ""});

    if resp.status_code == 200 {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
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
