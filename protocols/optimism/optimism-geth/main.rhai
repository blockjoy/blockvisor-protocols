import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 6161;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_URL = "https://eth-l1.blkjy.io";
const L1_BEACON_URL = "https://lighthouse.blkjy.io";
const L1_RPCKIND = "standard";

const GETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const OPTIMISM_API = "http://127.0.0.1:8547";
const DATADIR = node_env().protocol_data_path;
const OP_DIR = node_env().protocol_data_path + "/optimism";

let AUX_CONFIG = aux::base_config(global::METRICS_PORT, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR, global::METRICS_PATH);

const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "op-geth-mainnet-archive": #{
        sequencer_url: "https://mainnet-sequencer.optimism.io/",
        net_type: "main",
        url: "https://mainnet.optimism.io",
        l1_url: "http://173.231.60.133",
        snapshot_url: "https://datadirs.optimism.io/mainnet-bedrock.tar.zst",
        checkpoint: "https://beaconstate.ethstaker.cc",
        opnet: "mainnet",
        ethnet: "mainnet",
        chainid: 10,
    },
    "op-geth-testnet-archive": #{
        sequencer_url: "https://goerli-sequencer.optimism.io/",
        net_type: "test",
        url: "https://goerli.optimism.io",
        l1_url: "https://gorilla01.lax.blockjoy.com",
        snapshot_url: "https://datadirs.optimism.io/goerli-bedrock.tar.zst",
        checkpoint: "https://goerli.beaconstate.ethstaker.cc",
        opnet: "sepolia",
        ethnet: "goerli",
        chainid: 11155420,
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;

const BABEL_VERSION = "0.9.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::OP_DIR}`,
            "mkdir -p /opt/netdata/var/cache/netdata",
            "mkdir -p /opt/netdata/var/lib/netdata",
            "rm -rf /opt/netdata/var/lib/netdata/*",
            "rm -rf /opt/netdata/var/cache/netdata/*",
        ],
        jobs: [
            #{
                name: "init_job",
                run_sh: `openssl rand -hex 32 > ${global::OP_DIR}/jwt.txt`,
            }
        ]
    },
    services: [
        #{
            name: "op-geth",
            run_sh: `/root/bin/op-geth \
                    --ws \
                    --ws.port=${global::WS_PORT} \
                    --ws.addr=0.0.0.0 \
                    --ws.origins="*" \
                    --http \
                    --http.api="eth,net,web3,debug" \
                    --http.port=${global::RPC_PORT} \
                    --http.addr=0.0.0.0 \
                    --http.vhosts="*" \
                    --http.corsdomain="*" \
                    --authrpc.addr=127.0.0.1 \
                    --authrpc.jwtsecret=${global::OP_DIR}/jwt.txt \
                    --authrpc.port=8551 \
                    --authrpc.vhosts="*" \
                    --rollup.historicalrpc="http://127.0.0.1:8548" \
                    --gcmode=archive \
                    --verbosity=3 \
                    --rollup.sequencerhttp=${global::SEQUENCER_URL} \
                    --nodiscover \
                    --metrics \
                    --metrics.addr=127.0.0.1 \
                    --metrics.port=${global::METRICS_PORT} \
                    --syncmode=full \
                    --maxpeers=0 \
                    --datadir=${global::OP_DIR}/geth \
                    --snapshot=false \
                    --networkid=${global::VARIANT.chainid} \
                    --nat none \
                    --rollup.disabletxpoolgossip=true \
                    --nodiscover \
                    --op-network=op-${global::VARIANT.opnet} \
                    --cache 8192`,
            shutdown_timeout_secs: 120,
        },
        #{
            name: "op-node",
            run_sh: `/root/bin/op-node \
                    --network=${global::VARIANT.opnet} \
                    --rpc.addr=0.0.0.0 \
                    --rpc.port=8547 \
                    --l1=${global::L1_URL} \
                    --l1.beacon=${global::L1_BEACON_URL} \
                    --l1.trustrpc \
                    --l1.rpckind=${global::L1_RPCKIND} \
                    --l2=http://127.0.0.1:8551 \
                    --l2.jwt-secret=${global::OP_DIR}/jwt.txt`,
            shutdown_timeout_secs: 120,
        },
        #{
            name: "op-l2geth",
            run_sh: `USING_OVM=true \
                    ETH1_SYNC_SERVICE_ENABLE=false \
                    RPC_API=eth,rollup,net,web3,debug \
                    RPC_ADDR=127.0.0.1 \
                    RPC_CORS_DOMAIN=* \
                    RPC_ENABLE=true \
                    RPC_PORT=8548 \
                    RPC_VHOSTS=* \
                    /root/bin/op-l2geth \
                    --datadir ${global::OP_DIR}/l2geth \
                    --port 30304 \
                    --nousb`,
            shutdown_timeout_secs: 120,
        },
    ],
    download: #{
        max_connections: 5,
    },
    upload: #{
        exclude: [
            "jwt.txt",
            "bedrock.tar.zst",
            "bedrock.tar",
            "caddy/**",
        ],
    },
    scheduled: [
        #{
            name: "netdata_update",
            schedule: "30 15 12 * * * *",
            function: "netdata_update",
            param: "param",        
        }
    ],
};

fn netdata_update() {
    run_sh(`wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --stable-channel --disable-telemetry --non-interactive --dont-start-it --native-only --disable-cloud`);
}

fn application_status() {
    let resp = run_jrpc(#{host: global::GETH_API, method: ""});

    if resp.status_code == 200 {
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn height() {
    parse_hex(run_jrpc(#{ host: global::GETH_API, method: "eth_blockNumber"}).expect(200).result)
}

fn sync_status() {
        let system_timestamp = run_sh (`date +%s`).unwrap();
        let h = run_jrpc(#{host: global::OPTIMISM_API, method: "optimism_syncStatus"}).expect(200);

        let block_timestamp = h.result.unsafe_l2.timestamp;
        
        let current_timestamp = parse_int(system_timestamp);
        
        if block_timestamp < current_timestamp - 100 {
            return "syncing";
        } else {
            return "synced";
    }
}
