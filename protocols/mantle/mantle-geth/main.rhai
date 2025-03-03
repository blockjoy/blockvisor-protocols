import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 8181;
const METRICS_PATH = "/debug/metrics/prometheus";

const GETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const MANTLE_API = "http://127.0.0.1:8547";
const DATADIR = node_env().protocol_data_path;
const MANTLE_DIR = node_env().protocol_data_path + "/mantle";

const VARIANTS = #{
    "geth-mainnet-archive": #{
        sequencer_url: "https://rpc.mantle.xyz",
        l1_url: "https://eth-l1.blkjy.io",
        l1_beacon_url: "https://lighthouse.blkjy.io",
        l1_rpc_kind: "basic",
        chainid: 5000,
        p2p_peers: "/dns4/peer0.mantle.xyz/tcp/9003/p2p/16Uiu2HAmKVKzUAns2gLhZAz1PYcbnhY3WpxNxUZYeTN1x29tNBAW,/dns4/peer1.mantle.xyz/tcp/9003/p2p/16Uiu2HAm1AiZtVp8f5C8LvpSTAXC6GtwqAVKnB3VLawWYSEBmcFN,/dns4/peer2.mantle.xyz/tcp/9003/p2p/16Uiu2HAm2UHVKiPXpovs8VbbUQVPr7feBAqBJdFsH1z5XDiLEvHT",
        config_set: "mainnet",
        extra_args: `--config=${global::MANTLE_DIR}/config.toml`,
    },
    "geth-sepolia-archive": #{
        sequencer_url: "https://rpc.sepolia.mantle.xyz",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        l1_beacon_url: "https://lighthouse-sepolia.blkjy.io",
        l1_rpc_kind: "basic",
        chainid: 5003,
        p2p_peers: "/dns4/peer0.mantle.xyz/tcp/9003/p2p/16Uiu2HAmKVKzUAns2gLhZAz1PYcbnhY3WpxNxUZYeTN1x29tNBAW,/dns4/peer1.mantle.xyz/tcp/9003/p2p/16Uiu2HAm1AiZtVp8f5C8LvpSTAXC6GtwqAVKnB3VLawWYSEBmcFN,/dns4/peer2.mantle.xyz/tcp/9003/p2p/16Uiu2HAm2UHVKiPXpovs8VbbUQVPr7feBAqBJdFsH1z5XDiLEvHT",
        config_set: "sepolia",
    },
};

const L1_URL = VARIANTS[node_env().node_variant].l1_url;
const L1_BEACON_URL = VARIANTS[node_env().node_variant].l1_beacon_url;
const L1_RPCKIND = VARIANTS[node_env().node_variant].l1_rpc_kind;

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;

const CONFIG_SET = VARIANTS[node_env().node_variant].config_set;

const EXTRA_GETH_ARGS = if CONFIG_SET == "mainnet" {
    "--config=${global::MANTLE_DIR}/config.toml"
} else {
    ""
};

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::MANTLE_DIR}`,
                `cp -a /root/config/${CONFIG_SET}/* ${global::MANTLE_DIR}/`,
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
                    --rollup.historicalrpc=${global::SEQUENCER_URL} \
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
                    --cache 8192
                    ${EXTRA_GETH_ARGS}`,
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
                    --p2p.listen.tcp=9003 \
                    --p2p.listen.udp=9003 \
                    --p2p.scoring.peers=light \
                    --p2p.ban.peers=true \
                    --p2p.discovery.path=${global::MANTLE_DIR}/opnode_discovery_db \
                    --p2p.peerstore.path=${global::MANTLE_DIR}/opnode_peerstore_db \
                    --da.indexer-enable=true \
                    --da.indexer-socket=da-indexer-api.mantle.xyz:80 \
                    --l2.backup-unsafe-sync-rpc=${global::VARIANT.sequencer_url} \
                    --l2.engine-sync \
                    --l2.skip-sync-start-check \
                    --p2p.sync.req-resp`,
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
    }
}

fn application_status() {
    let resp = run_jrpc(#{host: global::GETH_API, method: ""});

    if resp.status_code == 200 {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
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
