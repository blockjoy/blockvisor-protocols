import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 9292;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_RPCKIND = "standard";

const GETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const BASE_API = "http://127.0.0.1:8547";
const DATADIR = node_env().protocol_data_path;
const BASE_DIR = node_env().protocol_data_path + "/base";

let AUX_CONFIG = aux::base_config(global::METRICS_PORT, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR, global::METRICS_PATH);

const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

const BABEL_VERSION = "0.9.0";

const VARIANTS = #{
    "geth-mainnet-archive": #{
        sequencer_url: "https://mainnet-sequencer.base.org",
        url: "https://mainnet.base.org",
        l1_url: "http://eth-l1.blkjy.io",
        l1_beacon_url: "http://lighthouse.blkjy.io",
        opnet: "base-mainnet",
        chainid: 8453,
        p2p_peers: "enode://87a32fd13bd596b2ffca97020e31aef4ddcc1bbd4b95bb633d16c1329f654f34049ed240a36b449fda5e5225d70fe40bc667f53c304b71f8e68fc9d448690b51@3.231.138.188:30301,enode://ca21ea8f176adb2e229ce2d700830c844af0ea941a1d8152a9513b966fe525e809c3a6c73a2c18a12b74ed6ec4380edf91662778fe0b79f6a591236e49e176f9@184.72.129.189:30301,enode://acf4507a211ba7c1e52cdf4eef62cdc3c32e7c9c47998954f7ba024026f9a6b2150cd3f0b734d9c78e507ab70d59ba61dfe5c45e1078c7ad0775fb251d7735a2@3.220.145.177:30301,enode://8a5a5006159bf079d06a04e5eceab2a1ce6e0f721875b2a9c96905336219dbe14203d38f70f3754686a6324f786c2f9852d8c0dd3adac2d080f4db35efc678c5@3.231.11.52:30301,enode://cdadbe835308ad3557f9a1de8db411da1a260a98f8421d62da90e71da66e55e98aaa8e90aa7ce01b408a54e4bd2253d701218081ded3dbe5efbbc7b41d7cef79@54.198.153.150:30301",
    },
    "geth-sepolia-archive": #{
        sequencer_url: "https://sepolia-sequencer.base.org",
        url: "https://sepolia.base.org",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        l1_beacon_url: "https://lighthouse-sepolia.blkjy.io",
        opnet: "base-sepolia",
        chainid: 84532,
        p2p_peers: "enode://548f715f3fc388a7c917ba644a2f16270f1ede48a5d88a4d14ea287cc916068363f3092e39936f1a3e7885198bef0e5af951f1d7b1041ce8ba4010917777e71f@18.210.176.114:30301,enode://6f10052847a966a725c9f4adf6716f9141155b99a0fb487fea3f51498f4c2a2cb8d534e680ee678f9447db85b93ff7c74562762c3714783a7233ac448603b25f@107.21.251.55:30301",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::BASE_DIR}`,
            "mkdir -p /opt/netdata/var/cache/netdata",
            "mkdir -p /opt/netdata/var/lib/netdata",
            "rm -rf /opt/netdata/var/lib/netdata/*",
            "chown -R root:root /opt/netdata/var/lib/netdata",
            "chown -R root:root /opt/netdata/var/cache/netdata",
        ],
        jobs: [
            #{
                name: "init_jwt",
                run_sh: `openssl rand -hex 32 > ${global::BASE_DIR}/jwt.txt`,
            }
        ],
    },
    services: [
        #{
            name: "op-geth",
            run_sh: `/root/bin/op-geth \
                    --datadir=${global::DATADIR} \
                    --http \
                    --http.corsdomain="*" \
                    --http.vhosts="*" \
                    --http.addr=127.0.0.1 \
                    --http.port=${global::RPC_PORT} \
                    --http.api=web3,debug,eth,txpool,net,engine,admin \
                    --ws \
                    --ws.addr=127.0.0.1 \
                    --ws.port=${global::WS_PORT} \
                    --ws.origins="*" \
                    --ws.api=debug,eth,txpool,net,engine,web3,admin \
                    --syncmode=full \
                    --gcmode=archive \
                    --maxpeers=100 \
                    --metrics \
                    --metrics.addr=127.0.0.1 \
                    --metrics.port=${global::METRICS_PORT} \
                    --authrpc.addr=127.0.0.1 \
                    --authrpc.port=8551 \
                    --authrpc.vhosts="*" \
                    --authrpc.jwtsecret=${global::BASE_DIR}/jwt.txt \
                    --rollup.sequencerhttp=${global::SEQUENCER_URL} \
                    --rollup.halt=major \
                    --rollup.disabletxpoolgossip=true \
                    --bootnodes=${global::VARIANT.p2p_peers} \
                    --port=30303 \
                    --nat none \
                    --op-network=${global::VARIANT.opnet}`,
            shutdown_timeout_secs: 120,
        },
        #{
            name: "op-node",
            run_sh: `/root/bin/op-node \
                    --network ${global::VARIANT.opnet} \
                    --l2=http://127.0.0.1:8551 \
                    --l2.jwt-secret=${global::BASE_DIR}/jwt.txt \
                    --rpc.addr=127.0.0.1 \
                    --rpc.port=8547 \
                    --l1=${global::VARIANT.l1_url} \
                    --l1.beacon=${global::VARIANT.l1_beacon_url} \
                    --l1.trustrpc \
                    --l1.rpckind=${global::L1_RPCKIND} \
                    --verifier.l1-confs=4 \
                    --p2p.listen.ip=0.0.0.0 \
                    --p2p.listen.tcp=9003 \
                    --p2p.listen.udp=9003 \
                    --p2p.scoring.peers=light \
                    --p2p.ban.peers \
                    --p2p.discovery.path=${global::BASE_DIR}/opnode_discovery_db \
                    --p2p.peerstore.path=${global::BASE_DIR}/opnode_peerstore_db \
                    --l2.backup-unsafe-sync-rpc=${global::VARIANT.url} \
                    --p2p.bootnodes=${global::VARIANT.p2p_peers} \
                    --rollup.load-protocol-versions=true`,
            shutdown_timeout_secs: 120,
        },
    ],
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
