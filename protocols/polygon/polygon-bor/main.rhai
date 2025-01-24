import "base" as base;
import "polygon_bor" as polygon_bor;


const HEIMDALL_DIR = BLOCKCHAIN_DATA_PATH + "/heimdall";
const BOR_DIR = BLOCKCHAIN_DATA_PATH + "/bor";
const CADDY_DIR = DATA_DRIVE_MOUNT_POINT + "caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const HEIMDALL_PORT = 1317;
const METRICS_PORT = 7071;
const METRICS_PATH = "/debug/metrics/prometheus";

let POLYGON_BOR_CONFIG = polygon_bor::base_config(global::METRICS_PORT,global::METRICS_PATH,global::RPC_PORT,global::WS_PORT,global::CADDY_DIR);
const BASE_CONFIG  = #{
    config_files: POLYGON_BOR_CONFIG.config_files+base::BASE_CONFIG.config_files,
    services: POLYGON_BOR_CONFIG.services+base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "polygon-bor-mainnet-full": #{
        net_type: "main",
        p2p_seeds: "--p2p.seeds 1500161dd491b67fb1ac81868952be49e2509c9f@52.78.36.216:26656,dd4a3f1750af5765266231b9d8ac764599921736@3.36.224.80:26656,8ea4f592ad6cc38d7532aff418d1fb97052463af@34.240.245.39:26656,e772e1fb8c3492a9570a377a5eafdb1dc53cd778@54.194.245.5:26656,6726b826df45ac8e9afb4bdb2469c7771bd797f1@52.209.21.164:26656",
        network: "mainnet",
        bootnodes: "-bootnodes enode://b8f1cc9c5d4403703fbf377116469667d2b1823c0daf16b7250aa576bacf399e42c3930ccfcb02c5df6879565a2b8931335565f0e8d3f8e72385ecf4a4bf160a@3.36.224.80:30303,enode://8729e0c825f3d9cad382555f3e46dcff21af323e89025a0e6312df541f4a9e73abfa562d64906f5e59c51fe6f0501b3e61b07979606c56329c020ed739910759@54.194.245.5:30303",
    },
};

const API_HOST = "http://127.0.0.1:${global::RPC_PORT}";
const NET =  VARIANT[node_env().node_variant].net_type;
const P2P_SEEDS = VARIANT[node_env().node_variant].p2p_seeds;
const BOOTNODES = VARIANT[node_env().node_variant].bootnodes;
const NETWORK = VARIANT[node_env().node_variant].network;

const BABEL_VERSION = "1.7.1";
const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::CADDY_DIR}`,
            `mkdir -p ${global::BOR_DIR}`,
            `mkdir -p ${global::HEIMDALL_DIR}`,
        ],
        jobs: []
    },
    services: [
        #{
            name: "heimdall",
            run_sh: `/root/bin/heimdalld start --moniker blockjoy --home ${global::HEIMDALL_DIR} ${global::P2P_SEEDS} --bor_rpc_url http://127.0.0.1:${global::RPC_PORT} --chain ${global::NETWORK} --rest-server`,
        },
        #{
            name: "bor",
            run_sh: `/root/bin/bor server -datadir ${global::BOR_DIR} -chain ${global::NETWORK} -syncmode full -metrics -metrics.prometheus-addr 127.0.0.1:${global::METRICS_PORT} -maxpeers 200 -bor.heimdall http://127.0.0.1:${global::HEIMDALL_PORT} -http -http.addr 127.0.0.1 -http.port ${global::RPC_PORT} -http.corsdomain "*" -http.api eth,net,web3,txpool,bor -ws -ws.addr 127.0.0.1 -ws.port ${global::WS_PORT} -ws.origins "*" -ws.api eth,net,web3,txpool,bor -gcmode full -rpc.evmtimeout 300s -rpc.gascap 0 -rpc.returndatalimit 0 ${global::BOOTNODES}`,
        },
    ],
    upload: #{
        exclude: [],
    },
};


fn application_status() {
    let resp = parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_chainId"}).expect(200).result);

    if 137 | 80002 == resp {
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn height() {
    parse_hex(run_jrpc(#{ host: global::API_HOST, method: "eth_blockNumber"}).expect(200).result)
}

fn sync_status() {
    let result = run_jrpc(#{ host: global::API_HOST, method: "eth_syncing" }).expect(200).result;
    if result == false {
        "synced"
    } else {
        "syncing"
    }
}
