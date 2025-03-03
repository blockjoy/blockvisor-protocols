import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const OP_NODE_RPC_PORT = 8547;
const AUTHRPC_PORT = 8551;
const OP_NODE_METRICS_PORT = 7777;
const METRICS_PORT = 8889;
const METRICS_PATH = "/debug/metrics/prometheus";

const L1_RPCKIND = "standard";

const GETH_API = "http://127.0.0.1:" + global::RPC_PORT;
const BLAST_API = `http://127.0.0.1:${global::OP_NODE_RPC_PORT}`;
const BLAST_DIR = node_env().protocol_data_path + "/blast";

const VARIANTS = #{
    "geth-mainnet-archive": #{
        sequencer_url: "https://sequencer.blast.io",
        l1_url: "https://eth-l1.blkjy.io",
        beacon_url: "https://lighthouse.blkjy.io",
        p2p_nodes: "enr:-J64QGwHl9uYLfC_cnmxSA6wQH811nkOWJDWjzxqkEUlJoZHWvI66u-BXgVcPCeMUmg0dBpFQAPotFchG67FHJMZ9OSGAY3d6wevgmlkgnY0gmlwhANizeSHb3BzdGFja4Sx_AQAiXNlY3AyNTZrMaECg4pk0cskPAyJ7pOmo9E6RqGBwV-Lex4VS9a3MQvu7PWDdGNwgnZhg3VkcIJ2YQ,enr:-J64QDge2jYBQtcNEpRqmKfci5E5BHAhNBjgv4WSdwH1_wPqbueq2bDj38-TSW8asjy5lJj1Xftui6Or8lnaYFCqCI-GAY3d6wf3gmlkgnY0gmlwhCO2D9yHb3BzdGFja4Sx_AQAiXNlY3AyNTZrMaEDo4aCTq7pCEN8om9U5n_VyWdambGnQhwHNwKc8o-OicaDdGNwgnZhg3VkcIJ2YQ",
        network: "mainnet"
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const SEQUENCER_URL = VARIANTS[node_env().node_variant].sequencer_url;
const L1_URL = VARIANTS[node_env().node_variant].l1_url;
const BEACON_URL = VARIANTS[node_env().node_variant].beacon_url;
const P2P_NODES = VARIANTS[node_env().node_variant].p2p_nodes;
const CONFIG_DIR = "/root/config/" + global::VARIANT.network;

const BABEL_VERSION = "0.9.0";

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::METRICS_PATH, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::BLAST_DIR}/geth`,
                `mkdir -p ${global::CADDY_DIR}`,
                `cp -a ${global::CONFIG_DIR}/* ${global::BLAST_DIR}`,
            ],
            jobs: [
                #{
                    name: "init_job",
                    run_sh: `openssl rand -hex 32 > ${global::BLAST_DIR}/jwt.txt`,
                }
            ]
        },
        services: [
            #{
                name: "op-geth",
                run_sh: `/root/bin/blast-geth --datadir=${global::BLAST_DIR} --http --http.corsdomain="*" --http.vhosts="*" --http.addr=127.0.0.1 --http.port=${global::RPC_PORT} --http.api=web3,debug,eth,txpool,net,engine --ws --ws.addr=127.0.0.1 --ws.port=${global::WS_PORT} --ws.origins="*" --ws.api=debug,eth,txpool,net,engine --authrpc.addr=127.0.0.1 --authrpc.port=${global::AUTHRPC_PORT} --authrpc.vhosts="*" --authrpc.jwtsecret=${global::BLAST_DIR}/jwt.txt --syncmode=full --gcmode=archive --nodiscover --maxpeers=100 --rollup.disabletxpoolgossip=true --rollup.sequencerhttp=${global::SEQUENCER_URL} --metrics --metrics.addr=127.0.0.1 --metrics.port ${global::METRICS_PORT} --override.canyon=0 --override.ecotone=1716843599`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `/root/bin/blast-node --l1=${global::L1_URL} --l1.rpckind=basic --l1.beacon=${global::BEACON_URL} --l2=http://127.0.0.1:${global::AUTHRPC_PORT} --l2.jwt-secret=${global::BLAST_DIR}/jwt.txt --rollup.config=${global::BLAST_DIR}/rollup.json --p2p.bootnodes=${global::P2P_NODES} --metrics.enabled --metrics.addr=127.0.0.1 --metrics.port=${global::OP_NODE_METRICS_PORT}`,
                shutdown_timeout_secs: 120,
            },
        ],
        download: #{
            max_connections: 5,
        },
        upload: #{
            exclude: [
                "jwt.txt",
            ],
        },
    }
}

fn application_status() {
    let resp = parse_hex(run_jrpc(#{host: global::GETH_API, method: "eth_chainId"}).expect(200).result);

    if resp == 81457 {
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn height() {
    parse_hex(run_jrpc(#{ host: global::GETH_API, method: "eth_blockNumber"}).expect(200).result)
}

fn sync_status() {
    let resp = run_jrpc(#{host: global::GETH_API, method: "eth_syncing"}).expect(200);
    if resp.result == false {
        "synced"
    } else {
        "syncing"
    }
}
