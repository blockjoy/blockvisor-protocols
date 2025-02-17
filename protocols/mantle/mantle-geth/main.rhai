import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 8181;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_URL = "https://eth-l1.blkjy.io";
const L1_BEACON_URL = "https://lighthouse.blkjy.io";
const L1_RPCKIND = "basic";

const GETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const MANTLE_API = "http://127.0.0.1:8547";
const DATADIR = node_env().protocol_data_path;
const MANTLE_DIR = node_env().protocol_data_path + "/mantle";

let AUX_CONFIG = aux::base_config(global::METRICS_PORT, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR, global::METRICS_PATH);

const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "mantle-geth-mainnet-archive": #{
        sequencer_url: "https://rpc.mantle.xyz",
        net_type: "main",
        url: "https://rpc.mantle.xyz",
        l1_url: global::L1_URL,
        snapshot_url: "https://snapshots.mantle.xyz/mainnet.tar.zst",
        checkpoint: "https://beaconstate.ethstaker.cc",
        opnet: "mainnet",
        ethnet: "mainnet",
        chainid: 5000,
        p2p_peers: "/dns4/peer0.mantle.xyz/tcp/9003/p2p/16Uiu2HAmKVKzUAns2gLhZAz1PYcbnhY3WpxNxUZYeTN1x29tNBAW,/dns4/peer1.mantle.xyz/tcp/9003/p2p/16Uiu2HAm1AiZtVp8f5C8LvpSTAXC6GtwqAVKnB3VLawWYSEBmcFN,/dns4/peer2.mantle.xyz/tcp/9003/p2p/16Uiu2HAm2UHVKiPXpovs8VbbUQVPr7feBAqBJdFsH1z5XDiLEvHT",
    },
    "mantle-geth-testnet-archive": #{
        sequencer_url: "https://rpc.testnet.mantle.xyz",
        net_type: "test",
        url: "https://rpc.testnet.mantle.xyz",
        l1_url: global::L1_URL,
        snapshot_url: "https://snapshots.mantle.xyz/testnet.tar.zst",
        checkpoint: "https://goerli.beaconstate.ethstaker.cc",
        opnet: "testnet",
        ethnet: "goerli",
        chainid: 5001,
        p2p_peers: "/dns4/peer0.mantle.xyz/tcp/9003/p2p/16Uiu2HAmKVKzUAns2gLhZAz1PYcbnhY3WpxNxUZYeTN1x29tNBAW,/dns4/peer1.mantle.xyz/tcp/9003/p2p/16Uiu2HAm1AiZtVp8f5C8LvpSTAXC6GtwqAVKnB3VLawWYSEBmcFN,/dns4/peer2.mantle.xyz/tcp/9003/p2p/16Uiu2HAm2UHVKiPXpovs8VbbUQVPr7feBAqBJdFsH1z5XDiLEvHT",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;

const BABEL_VERSION = "0.9.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::MANTLE_DIR}`,
            "mkdir -p /opt/netdata/var/cache/netdata",
            "mkdir -p /opt/netdata/var/lib/netdata",
            "rm -rf /opt/netdata/var/lib/netdata/*",
            "rm -rf /opt/netdata/var/cache/netdata/*",
        ],
        jobs: [
            #{
                name: "init_job",
                run_sh: `openssl rand -hex 32 > ${global::MANTLE_DIR}/jwt.txt`,
            }
        ]
    },
    services: [
        #{
            name: "mantle-geth",
            run_sh: `/root/bin/mantle-geth \
                    --ws \
                    --ws.port=${global::WS_PORT} \
                    --ws.addr=127.0.0.1 \
                    --ws.origins="*" \
                    --ws.api=web3,eth,debug,txpool,net \
                    --http \
                    --http.api=web3,eth,debug,txpool,net \
                    --http.port=${global::RPC_PORT} \
                    --http.addr=127.0.0.1 \
                    --http.vhosts="*" \
                    --http.corsdomain="*" \
                    --authrpc.addr=127.0.0.1 \
                    --authrpc.jwtsecret=${global::MANTLE_DIR}/jwt.txt \
                    --authrpc.port=8551 \
                    --authrpc.vhosts="*" \
                    --gcmode=archive \
                    --verbosity=3 \
                    --rollup.sequencerhttp=${global::SEQUENCER_URL} \
                    --nodiscover \
                    --metrics \
                    --metrics.addr=127.0.0.1 \
                    --metrics.port=${global::METRICS_PORT} \
                    --syncmode=full \
                    --maxpeers=0 \
                    --datadir=${global::MANTLE_DIR}/geth \
                    --snapshot=false \
                    --networkid=${global::VARIANT.chainid} \
                    --nat none \
                    --rollup.disabletxpoolgossip=true \
                    --nodiscover \
                    --cache 8192`,
            shutdown_timeout_secs: 120,
        },
        #{
            name: "mantle-node",
            run_sh: `/root/bin/mantle-node \
                    --l2=http://127.0.0.1:8551 \
                    --l2.jwt-secret=${global::MANTLE_DIR}/jwt.txt \
                    --rollup.config=${global::MANTLE_DIR}/rollup.json \
                    --rpc.addr=127.0.0.1 \
                    --rpc.port=8547 \
                    --l1=${global::L1_URL} \
                    --l1.beacon=${global::L1_BEACON_URL} \
                    --l1.trustrpc \
                    --l1.rpckind=${global::L1_RPCKIND} \
                    --verifier.l1-confs=3 \
                    --p2p.static=${global::VARIANT.p2p_peers} \
                    --p2p.listen.ip=0.0.0.0 \
                    --p2p.listen.tcp.port=9003 \
                    --p2p.listen.udp.port=9003 \
                    --p2p.peer-scoring=light \
                    --p2p.peer-banning=true \
                    --metrics.enabled=true \
                    --metrics.addr=127.0.0.1 \
                    --metrics.port=${global::METRICS_PORT} \
                    --p2p.discovery.path=${global::MANTLE_DIR}/opnode_discovery_db \
                    --p2p.peerstore.path=${global::MANTLE_DIR}/opnode_peerstore_db \
                    --indexer.enable=true \
                    --indexer.socket=da-indexer-api.mantle.xyz:80 \
                    --l2.backup-unsafe-sync-rpc=${global::VARIANT.url}`,
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
};

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
    let system_timestamp = run_sh(`date +%s`).unwrap();
    let h = run_jrpc(#{host: global::MANTLE_API, method: "optimism_syncStatus"}).expect(200);
    
    let block_timestamp = h.result.unsafe_l2.timestamp;
    let current_timestamp = parse_int(system_timestamp);
    
    if block_timestamp < current_timestamp - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}
