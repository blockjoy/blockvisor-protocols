import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 6665;

const VARIANTS = #{
    "reth-sepolia-full": #{
        net: "sepolia",
        url: "https://sepolia.beaconstate.info",
    },
    "reth-mainnet-full": #{
        net: "mainnet",
        url: "https://mainnet.checkpoint.sigp.io",
    },
    "reth-sepolia-archive": #{
        net: "sepolia",
        url: "https://sepolia.beaconstate.info",
    },
    "reth-mainnet-archive": #{
        net: "mainnet",
        url: "https://mainnet.checkpoint.sigp.io",
    },
};

const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;
const HOME = node_env().protocol_data_path + "/reth";
const LIGHTHOUSE_DIR = node_env().protocol_data_path + "/lighthouse";
const NET = VARIANTS[node_env().node_variant].net;
const CHECKPOINT_URL = VARIANTS[node_env().node_variant].url;

const RETH_EXTRA_ARGS = if node_env().node_variant.ends_with("-full") {
    "--full"
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
            name: "reth",
            run_sh: `export HOME=/root && /root/bin/reth node --datadir=${global::HOME} --chain=${global::NET} --http --http.addr=127.0.0.1 --http.port=${global::RPC_PORT} --http.api=eth,net,web3,debug,trace,txpool --ws --ws.addr=127.0.0.1 --ws.port=${global::WS_PORT} --ws.api=eth,net,web3,debug,trace,txpool --rpc.gascap 18446744073709551615 --metrics=127.0.0.1:${global::METRICS_PORT} --authrpc.jwtsecret=${global::HOME}/jwt.hex ${global::RETH_EXTRA_ARGS}`,
            shutdown_timeout_secs: 120,
        },
        #{
            name: "lighthouse",
            run_sh: `RUST_LOG=info /root/bin/lighthouse bn --network ${global::NET} --datadir ${global::LIGHTHOUSE_DIR} --checkpoint-sync-url ${global::CHECKPOINT_URL}  --disable-deposit-contract-sync --http  --http-address 127.0.0.1 --http-port 5052  --execution-endpoint http://127.0.0.1:8551  --execution-jwt ${global::HOME}/jwt.hex  --metrics --metrics-port 9002 --prune-blobs false --reconstruct-historic-states --block-cache-size 64 --genesis-backfill --historic-state-cache-size 4 --disable-backfill-rate-limiting`,
            shutdown_timeout_secs: 120,
        },
    ],
    alternative_download: #{
        run_sh: "echo dummy"
    },
    upload: #{
        exclude: [
            "jwt.hex",
        ]
    }
}}

fn protocol_status() {
    /// "uploading", "downloading", "initializing" statuses are automatically handled by BV if BABEL_CONFIG const is defined
    let resp = run_jrpc(#{host: global::API_HOST, method: "/"});

    if resp.status_code == 200 {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
    }
}

fn height() {
    parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_blockNumber"}).expect(200).result)
}


fn sync_status() {
    let resp = run_jrpc(#{host: global::API_HOST, method: "eth_syncing"}).expect(200);
    if resp.result == false {
        "synced"
    } else {
        "syncing"
    }
}
