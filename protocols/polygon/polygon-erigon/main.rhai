import "base" as base;
import "aux" as aux;


const HEIMDALL_DIR = node_env().protocol_data_path + "/heimdall";
const ERIGON_DIR = node_env().protocol_data_path + "/erigon";
const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const HEIMDALL_PORT = 1317;
const METRICS_PORT = 7071;
const METRICS_PATH = "/debug/metrics/prometheus";

let AUX_CONFIG = aux::base_config(global::METRICS_PORT,global::METRICS_PATH,global::RPC_PORT,global::WS_PORT,global::CADDY_DIR);
const BASE_CONFIG  = #{
    config_files: AUX_CONFIG.config_files+base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services+base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "erigon-mainnet-archive": #{
        p2p_seeds: "1500161dd491b67fb1ac81868952be49e2509c9f@52.78.36.216:26656,dd4a3f1750af5765266231b9d8ac764599921736@3.36.224.80:26656,8ea4f592ad6cc38d7532aff418d1fb97052463af@34.240.245.39:26656,e772e1fb8c3492a9570a377a5eafdb1dc53cd778@54.194.245.5:26656,6726b826df45ac8e9afb4bdb2469c7771bd797f1@52.209.21.164:26656",
        network: "bor-mainnet",
        bootnodes: "enode://b8f1cc9c5d4403703fbf377116469667d2b1823c0daf16b7250aa576bacf399e42c3930ccfcb02c5df6879565a2b8931335565f0e8d3f8e72385ecf4a4bf160a@3.36.224.80:30303,enode://8729e0c825f3d9cad382555f3e46dcff21af323e89025a0e6312df541f4a9e73abfa562d64906f5e59c51fe6f0501b3e61b07979606c56329c020ed739910759@54.194.245.5:30303",
    },
};

const API_HOST = `http://127.0.0.1:${global::RPC_PORT}`;
const P2P_SEEDS = VARIANTS[node_env().node_variant].p2p_seeds;
const BOOTNODES = VARIANTS[node_env().node_variant].bootnodes;
const NETWORK = VARIANTS[node_env().node_variant].network;

const BABEL_VERSION = "1.7.1";
const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::CADDY_DIR}`,
            `mkdir -p ${global::ERIGON_DIR}`,
            `mkdir -p ${global::HEIMDALL_DIR}`,
        ],
        jobs: []
    },
    services: [
        #{
            name: "heimdall",
            run_sh: `/root/bin/heimdalld start --home=${global::HEIMDALL_DIR} --chain=${global::NETWORK} --bor_rpc_url ${global::API_HOST} --rest-server --seeds ${global::P2P_SEEDS} --node tcp://127.0.0.1:26657`,
        },
        #{
            name: "erigon",
            run_sh: `/root/bin/erigon --datadir ${global::ERIGON_DIR} --chain ${global::NETWORK} --snapshots=false --bootnodes=${global::BOOTNODES} --trustedpeers=${global::P2P_SEEDS}  --staticpeers=${global::P2P_SEEDS}  --maxpeers=400 --snap.stop --http.addr 127.0.0.1 --http.port ${global::RPC_PORT} --http.compression --http.vhosts=* --http.corsdomain=* --http.api=eth,debug,net,trace,web3,erigon,bor --ws --ws.port ${global::WS_PORT} --ws.compression --rpc.gascap=300000000 --metrics --metrics.addr=127.0.0.1 --metrics.port=${global::METRICS_PORT} --bodies.cache=5G --rpc.batch.limit=200000 --db.pagesize=16k --batchSize=2048MB --p2p.protocol=66 --db.size.limit=14TB --rpc.returndata.limit=1000000 --downloader.disable.ipv6 --bor.heimdall=http://127.0.0.1:${global::HEIMDALL_PORT}`,
        },
    ],
    upload: #{
        exclude: [],
    },
};


fn application_status() {
    let res = run_jrpc(#{
        host: `${global::API_HOST}`,
        method: "eth_blockNumber",
        params: [],
        headers: #{"Content-Type" : "application/json"},
      });
    if res.status_code != 200 {
       "delinquent";
    } else {
        "broadcasting";
    }
}

fn height(){
    let res = run_jrpc(#{
        host: `${global::API_HOST}`,
        method: "eth_blockNumber",
        params: [],
        headers: #{"Content-Type" : "application/json"},
      });
    if res.status_code != 200 {
        throw res.status_code;
    }
    let hex = parse_json(res.body);
    parse_int(sub_string(hex.result,2),16)
}

fn sync_status() {
    let data1 = #{url: `${global::API_HOST}` +"/health",
            method: "eth_getBlockByNumber",
            headers: [
                ["X-ERIGON-HEALTHCHECK", "synced"],
                ["X-ERIGON-HEALTHCHECK", "min_peer_count10"]
            ]
    };

    let resp1 = run_rest(data1);

    let data2 =  #{host: `${global::API_HOST}`,
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
