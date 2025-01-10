import "base" as base;
import "erigon" as erigon;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 6161;

let ERIGON_CONFIG = erigon::base_config(global::METRICS_PORT,global::RPC_PORT,global::WS_PORT,global::CADDY_DIR);

const BASE_CONFIG  = #{
    config_files: ERIGON_CONFIG.config_files+base::BASE_CONFIG.config_files,
    services: ERIGON_CONFIG.services+base::BASE_CONFIG.services,
};

const VARIANTS = #{
    erigon_goerli_full: #{
        net: "goerli",
    },
    erigon_sepolia_full: #{
        net: "sepolia",
    },
    erigon_mainnet_full: #{
        net: "mainnet",
    },
    erigon_goerli_archive: #{
        net: "goerli",
    },
    erigon_sepolia_archive: #{
        net: "sepolia",
    },
    erigon_mainnet_archive: #{
        net: "mainnet",
    },
};


const API_HOST = `http://127.0.0.1:${global::RPC_PORT}`;

const HOME = PROTOCOL_DATA_PATH + "/erigon";

const NET = VARIANTS[node_env().node_variant].net;

const EXTRA_ERIGON_ARGS = if node_params().nodetype == "full" {
    "--prune=htcr"
} else {
    ""
};

const BABEL_VERSION = "0.9.0";

const PLUGIN_CONFIG = #{
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
            run_sh: `export HOME=/root && /root/bin/erigon --datadir=${global::HOME} \
                    --chain=${global::NET} --healthcheck=true --port=30303 --http.port=8545 --authrpc.port=8551 \
                    --torrent.port=42069 --private.api.addr=127.0.0.1:9090 --http --ws --ws.port 8546 \
                    --http.api=eth,debug,net,trace,web3,erigon --nat=none --authrpc.jwtsecret=${global::HOME}/jwt.hex \
                    --torrent.download.rate=100mb --metrics --metrics.port=6666 --metrics.addr=127.0.0.1 \
                    --http.vhosts localhost --downloader.disable.ipv6 --caplin.backfilling=true \
                    --caplin.backfilling.blob=true --caplin.backfilling.blob.no-pruning=true --caplin.archive=true \
                    --beacon.api=beacon,builder,config,debug,node,validator,lighthouse --internalcl \
                    ${global::EXTRA_ERIGON_ARGS}`,
            shutdown_timeout_secs: 120,
            use_blockchain_data: true,
        },
    ],
    alternative_download: #{
        run_sh: "echo dummy"
    },
    upload: #{
        exclude: [
            "caddy/**",
        ]
    }
};

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
