import "base" as base;
import "aux" as aux;

const HEIMDALL_DIR = node_env().protocol_data_path + "/heimdall";
const BOR_DIR = node_env().protocol_data_path + "/bor";
const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const HEIMDALL_PORT = 1317;
const METRICS_PORT = 7071;
const METRICS_PATH = "/debug/metrics/prometheus";

const VARIANTS = #{
    "bor-mainnet-full": #{
        p2p_seeds: "e019e16d4e376723f3adc58eb1761809fea9bee0@35.234.150.253:26656,7f3049e88ac7f820fd86d9120506aaec0dc54b27@34.89.75.187:26656,1f5aff3b4f3193404423c3dd1797ce60cd9fea43@34.142.43.240:26656,2d5484feef4257e56ece025633a6ea132d8cadca@35.246.99.203:26656,17e9efcbd173e81a31579310c502e8cdd8b8ff2e@35.197.233.240:26656,72a83490309f9f63fdca3a0bef16c290e5cbb09c@35.246.95.65:26656,00677b1b2c6282fb060b7bb6e9cc7d2d05cdd599@34.105.180.11:26656,721dd4cebfc4b78760c7ee5d7b1b44d29a0aa854@34.147.169.102:26656,4760b3fc04648522a0bcb2d96a10aadee141ee89@34.89.55.74:26656",
        network: "mainnet",
        bootnodes: "enode://b8f1cc9c5d4403703fbf377116469667d2b1823c0daf16b7250aa576bacf399e42c3930ccfcb02c5df6879565a2b8931335565f0e8d3f8e72385ecf4a4bf160a@3.36.224.80:30303,enode://8729e0c825f3d9cad382555f3e46dcff21af323e89025a0e6312df541f4a9e73abfa562d64906f5e59c51fe6f0501b3e61b07979606c56329c020ed739910759@54.194.245.5:30303",
        chain_id: 137,
    },
};

const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;
const P2P_SEEDS = VARIANTS[node_env().node_variant].p2p_seeds;
const BOOTNODES = VARIANTS[node_env().node_variant].bootnodes;
const NETWORK = VARIANTS[node_env().node_variant].network;
const CHAIN_ID = VARIANTS[node_env().node_variant].chain_id;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
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
                run_sh: `/root/bin/heimdalld start --moniker blockjoy --home ${global::HEIMDALL_DIR} --p2p.seeds ${global::P2P_SEEDS} --bor_rpc_url http://127.0.0.1:${global::RPC_PORT} --chain ${global::NETWORK} --rest-server`,
            },
            #{
                name: "bor",
                run_sh: `/root/bin/bor server -datadir ${global::BOR_DIR} -chain ${global::NETWORK} -syncmode full -metrics -metrics.prometheus-addr 127.0.0.1:${global::METRICS_PORT} -maxpeers 200 -bor.heimdall http://127.0.0.1:${global::HEIMDALL_PORT} -http -http.addr 127.0.0.1 -http.port ${global::RPC_PORT} -http.corsdomain "*" -http.api eth,net,web3,txpool,bor -ws -ws.addr 127.0.0.1 -ws.port ${global::WS_PORT} -ws.origins "*" -ws.api eth,net,web3,txpool,bor -gcmode full -rpc.evmtimeout 300s -rpc.gascap 0 -rpc.returndatalimit 0 -bootnodes ${global::BOOTNODES}`,
            },
        ],
        upload: #{
            exclude: [],
        },
    }
}

fn protocol_status() {
    let resp = parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_chainId"}).expect(200).result);

    if resp == global::CHAIN_ID {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
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
