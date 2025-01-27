import "base" as base;
import "geth" as geth;

const CADDY_DIR = node_env().data_mount_point + "caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const OP_NODE_RPC_PORT = 8547;
const AUTHRPC_PORT = 8551;
const METRICS_PORT = 4141;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_RPCKIND = "standard";

const GETH_API = `http://127.0.0.1:${global::RPC_PORT}`;
const SHAPE_API = "http://127.0.0.1:8547";
const SHAPE_DIR = node_env().protocol_data_path + "/shape";

let SHAPE_GETH_CONFIG = geth::base_config(global::METRICS_PORT, global::RPC_PORT, global::WS_PORT, global::OP_NODE_RPC_PORT, global::AUTHRPC_PORT, global::CADDY_DIR, global::METRICS_PATH);

const BASE_CONFIG = #{
    config_files: SHAPE_GETH_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: SHAPE_GETH_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "geth-mainnet-full": #{
        sequencer_url: "https://shape-mainnet-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        op_network: "shape-mainnet",
        bootnodes: "enode://ae31be7c6596f4bc3657f90b65a1569c7b0db10c976649f06fe5cfb26139064d78d22b41aede293aa7358fc336d086051ac7fce78f063dce89e1da19c7b88aee@34.228.226.23:0?discport=30301,enode://0bea78f02c9bee58326b3a612dae63dc5a0193fb3dfc9be687c9757d25606405ef9f87810157598fce35688bdb5b3834dc6283afab6dc5774abbd6c5a7b17cea@3.85.27.162:0?discport=30301",
        network: "mainnet",
    },
    "geth-sepolia-full": #{
        sequencer_url: "https://shape-sepolia-sequencer.g.alchemy.com",
        l1_url: "https://eth-l1-sepolia.blkjy.io",
        beacon_url: "https://lighthouse-sepolia.blkjy.io",
        op_network: "shape-sepolia",
        bootnodes: "enode://34fc07c447b843f3915f72cae27daeda7f2f8c3ea4b9132aed188387d3208d1d5cd7eeea58d30d038c14f985a5b108ad6b2172815ed8b757c9de9f609741b2a6@34.228.9.78:0?discport=30301,enode://61841b7682f808f5ce8222f15d7de7f118a2c2c3e342fe42ea41e987ae22fb90e49ef2b5f394897e791c33c6fc59d7ad064851ee653badb2d6ece7a94040944b@54.91.75.177:0?discport=30301",
        network: "sepolia",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;
const L1_URL = VARIANTS[node_env().node_variant].l1_url;
const BEACON_URL = VARIANTS[node_env().node_variant].beacon_url;
const OP_NETWORK = VARIANTS[node_env().node_variant].op_network;
const BOOTNODES = VARIANTS[node_env().node_variant].bootnodes;
const NETWORK = VARIANTS[node_env().node_variant].network;

const CONFIG_DIR = "/root/config/${global::NETWORK}";

const BABEL_VERSION = "0.9.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::SHAPE_DIR}/geth`,
            `mkdir -p ${global::CADDY_DIR}`,
            `cp -a ${global::CONFIG_DIR}/rollup.json ${global::SHAPE_DIR} &&\
             cp -a ${global::CONFIG_DIR}/genesis.json ${global::SHAPE_DIR}/geth`,
        ],
        jobs: [
            #{
                name: "init_job",
                run_sh: `openssl rand -hex 32 > ${global::SHAPE_DIR}/jwt.txt`,
            }
        ]
    },
    services: [
        #{
            name: "op-geth",
            run_sh: `/root/bin/op-geth --op-network ${global::OP_NETWORK} --syncmode=snap --ws --ws.port=${global::WS_PORT} --ws.addr=127.0.0.1 --ws.origins="*" --http --http.api="eth,net,web3,debug" --http.port=${global::RPC_PORT} --http.addr=127.0.0.1 --http.vhosts="*" --http.corsdomain="*" --authrpc.addr=127.0.0.1 --authrpc.jwtsecret=${global::SHAPE_DIR}/jwt.txt --authrpc.port=${global::AUTHRPC_PORT} --authrpc.vhosts="*" --verbosity=3 --rollup.sequencerhttp=${global::SEQUENCER_URL} --metrics --metrics.addr=127.0.0.1 --metrics.port=${global::METRICS_PORT} --datadir=${global::SHAPE_DIR}/ --rollup.disabletxpoolgossip=true --nodiscover --maxpeers=0`,
            shutdown_timeout_secs: 120,
        },
        #{
            name: "op-node",
            run_sh: `/root/bin/op-node --network ${global::OP_NETWORK} --p2p.bootnodes=${global::BOOTNODES} --rpc.addr=127.0.0.1 --rpc.port=${global::OP_NODE_RPC_PORT} --l1=${global::L1_URL} --l1.beacon=${global::BEACON_URL} --l1.rpckind=${global::L1_RPCKIND} --l2=http://127.0.0.1:${global::AUTHRPC_PORT} --l2.jwt-secret=${global::SHAPE_DIR}/jwt.txt`,
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
        let system_timestamp = run_sh (`date +%s`).unwrap();
        let h = run_jrpc(#{host: global::SHAPE_API, method: "optimism_syncStatus"}).expect(200);

        let block_timestamp = h.result.unsafe_l2.timestamp;
        
        let current_timestamp = parse_int(system_timestamp);
        
        if block_timestamp < current_timestamp - 100 {
            return "syncing";
        } else {
            return "synced";
    }
}
