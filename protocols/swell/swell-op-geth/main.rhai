import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const OP_NODE_RPC_PORT = 8547;
const OP_NODE_METRICS_PORT = 5151;
const AUTHRPC_PORT = 8551;
const METRICS_PORT = 4141;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_RPCKIND = "standard";

const GETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const SWELL_API = "http://127.0.0.1:" + global::OP_NODE_RPC_PORT;
const SWELL_DIR = node_env().protocol_data_path + "/swell";

const VARIANTS = #{
    "geth-mainnet-full": #{
        sequencer_url: "https://swell-mainnet.alt.technology/",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "swell-mainnet",
        network: "mainnet",
        chain_id: 1923,
        bootnodes: "enode://71cc695fd5317998d25b6311a06901e37ea06f2cc3e31b0ce90b27b7ed2c88957739892a07fcf9042266bb52678a1c705555d8c012f74cd0f6f1228ae4cc9130@swell-mux.altlayer.network:30239,enode://a7ede29f0c2aee9c2894b878dbfd58a026e2d7d1fb17d3486c8f8ef3a7231a9a9426d655a4d44543948a9e8f436cb9aa120000ea907e992a42d5aa3b7e1c6867@swell-mux.altlayer.network:32105,enode://72ba41a98a8b158f61ac22ab282fade95d16c1559c3c48fc543d9a86cc723ffcbd7c8028ce4f5caae34df81bc8e06d0b43737752f549ca6175c27539291f58c4@swell-mux.altlayer.network:30533",
        p2p_static: "/dns/swell-mux.altlayer.network/tcp/30659/p2p/16Uiu2HAmVYZ79ta2QFs2P2Y1n83gaRVRrGg7o7qps2nQPBW2DKRp,/dns/swell-mux.altlayer.network/tcp/30259/p2p/16Uiu2HAmPxWph3g2j6drH5G4LEgSquJkp613sr2orveVVSp1pTE9,/dns/swell-mux.altlayer.network/tcp/30605/p2p/16Uiu2HAm39XBcL8NXy7nm4YpqewLuHT6ZiSwMySYWczpezSCpksu",
    },
    "geth-mainnet-archive": #{
        sequencer_url: "https://swell-mainnet.alt.technology/",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "swell-mainnet",
        network: "mainnet",
        chain_id: 1923,
        bootnodes: "enode://71cc695fd5317998d25b6311a06901e37ea06f2cc3e31b0ce90b27b7ed2c88957739892a07fcf9042266bb52678a1c705555d8c012f74cd0f6f1228ae4cc9130@swell-mux.altlayer.network:30239,enode://a7ede29f0c2aee9c2894b878dbfd58a026e2d7d1fb17d3486c8f8ef3a7231a9a9426d655a4d44543948a9e8f436cb9aa120000ea907e992a42d5aa3b7e1c6867@swell-mux.altlayer.network:32105,enode://72ba41a98a8b158f61ac22ab282fade95d16c1559c3c48fc543d9a86cc723ffcbd7c8028ce4f5caae34df81bc8e06d0b43737752f549ca6175c27539291f58c4@swell-mux.altlayer.network:30533",
        p2p_static: "/dns/swell-mux.altlayer.network/tcp/30659/p2p/16Uiu2HAmVYZ79ta2QFs2P2Y1n83gaRVRrGg7o7qps2nQPBW2DKRp,/dns/swell-mux.altlayer.network/tcp/30259/p2p/16Uiu2HAmPxWph3g2j6drH5G4LEgSquJkp613sr2orveVVSp1pTE9,/dns/swell-mux.altlayer.network/tcp/30605/p2p/16Uiu2HAm39XBcL8NXy7nm4YpqewLuHT6ZiSwMySYWczpezSCpksu",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;
const L1_URL = VARIANTS[node_env().node_variant].l1_url;
const BEACON_URL = VARIANTS[node_env().node_variant].beacon_url;
const OP_NETWORK = VARIANTS[node_env().node_variant].op_network;
const CHAIN_ID = VARIANTS[node_env().node_variant].chain_id;
const BOOTNODES = VARIANTS[node_env().node_variant].bootnodes;
const P2P_STATIC = VARIANTS[node_env().node_variant].p2p_static;

const GETH_EXTRA_ARGS = if node_env().node_variant.ends_with("archive") {
    "--gcmode=archive";
} else {
    "--gcmode=full";
};

const NETWORK = VARIANTS[node_env().node_variant].network;
const CONFIG_DIR = "/root/config/" + NETWORK;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::SWELL_DIR}/geth`,
                `mkdir -p ${global::CADDY_DIR}`,
                `cp -a ${global::CONFIG_DIR}/rollup.json ${global::SWELL_DIR}/`,
                `cp -a ${global::CONFIG_DIR}/genesis.json ${global::SWELL_DIR}/geth/`
            ],
            jobs: [
                #{
                    name: "init_job",
                    run_sh: `openssl rand -hex 32 > ${global::SWELL_DIR}/jwt.txt`,
                }
            ]
        },
        services: [
            #{
                name: "op-geth",
                run_sh: `/root/bin/op-geth --datadir=${global::SWELL_DIR}/ --genesis.file=${global::SWELL_DIR}/geth/genesis.json \
                        --http --http.corsdomain=* --http.vhosts=* --http.addr=127.0.0.1 \
                        --http.api=web3,debug,eth,txpool,net,engine --ws --ws.addr=127.0.0.1 \
                        --ws.port=${global::WS_PORT} --ws.origins=* --ws.api=debug,eth,txpool,net,engine \
                        --syncmode=full ${global::GETH_EXTRA_ARGS} --maxpeers=100 --authrpc.vhosts=* \
                        --authrpc.addr=127.0.0.1 --authrpc.port=${global::AUTHRPC_PORT} --authrpc.jwtsecret=${global::SWELL_DIR}/jwt.txt \
                        --metrics --metrics.addr=127.0.0.1 --metrics.expensive --metrics.port=${global::METRICS_PORT} \
                        --rollup.disabletxpoolgossip=false --rpc.allow-unprotected-txs=true --db.engine=pebble --state.scheme=hash \
                        --port=30303 \
                        --bootnodes=${global::BOOTNODES} \
                        --op-network=${global::OP_NETWORK}`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `/root/bin/op-node --l1=${global::L1_URL} --l2=http://127.0.0.1:${global::AUTHRPC_PORT} \
                        --rpc.addr=127.0.0.1 --rpc.port=${global::OP_NODE_RPC_PORT} \
                        --l2.jwt-secret=${global::SWELL_DIR}/jwt.txt --l1.trustrpc=false --l1.beacon=${global::BEACON_URL} \
                        --syncmode=execution-layer --l1.rpckind=${global::L1_RPCKIND} \
                        --p2p.static=${global::P2P_STATIC} \
                        --p2p.priv.path=${global::SWELL_DIR}/p2p.key --p2p.discovery.path=${global::SWELL_DIR}/p2p.db \
                        --p2p.peerstore.path=${global::SWELL_DIR}/p2p-peerstore.db --metrics.enabled=true \
                        --p2p.ban.peers=false \
                        --metrics.port=${global::OP_NODE_METRICS_PORT} \
                        --rollup.config=${global::SWELL_DIR}/rollup.json \
                        --sequencer.enabled=false \
                        --sequencer.stopped=true \
                        --l2.engine-sync=true \
                        --rpc.enable-admin \
                        --p2p.sync.req-resp=true \
                        --plasma.enabled=false \
                        --txmgr.sequencer.http=${global::SEQUENCER_URL} \
                        --network=${global::OP_NETWORK}`,
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
            ],
        },
}}

fn protocol_status() {
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
    let system_timestamp = run_sh (`date +%s`).unwrap();
    let h = run_jrpc(#{host: global::SWELL_API, method: "optimism_syncStatus"}).expect(200);

    let block_timestamp = h.result.unsafe_l2.timestamp;

    let current_timestamp = parse_int(system_timestamp);

    if block_timestamp < current_timestamp - 100 {
        return "syncing";
    } else {
        return "synced";
    }
}
