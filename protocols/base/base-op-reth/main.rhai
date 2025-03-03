import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const AUTHRPC_PORT = 8551;
const OP_RPC_PORT = 7000;
const METRICS_PORT = 6665;
const METRICS_PATH = "/debug/metrics/prometheus";

const VARIANTS = #{
    "op-reth-mainnet-full": #{
        net: "base-mainnet",
        chain: "base",
        l1_rpckind: "standard",
        opnet: "base-mainnet",
        sequencer_url: "https://mainnet-sequencer.base.org",
        op_node_bootnodes: "enr:-J24QNz9lbrKbN4iSmmjtnr7SjUMk4zB7f1krHZcTZx-JRKZd0kA2gjufUROD6T3sOWDVDnFJRvqBBo62zuF-hYCohOGAYiOoEyEgmlkgnY0gmlwhAPniryHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQKNVFlCxh_B-716tTs-h1vMzZkSs1FTu_OYTNjgufplG4N0Y3CCJAaDdWRwgiQG,enr:-J24QH-f1wt99sfpHy4c0QJM-NfmsIfmlLAMMcgZCUEgKG_BBYFc6FwYgaMJMQN5dsRBJApIok0jFn-9CS842lGpLmqGAYiOoDRAgmlkgnY0gmlwhLhIgb2Hb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJ9FTIv8B9myn1MWaC_2lJ-sMoeCDkusCsk4BYHjjCq04N0Y3CCJAaDdWRwgiQG,enr:-J24QDXyyxvQYsd0yfsN0cRr1lZ1N11zGTplMNlW4xNEc7LkPXh0NAJ9iSOVdRO95GPYAIc6xmyoCCG6_0JxdL3a0zaGAYiOoAjFgmlkgnY0gmlwhAPckbGHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJwoS7tzwxqXSyFL7g0JM-KWVbgvjfB8JA__T7yY_cYboN0Y3CCJAaDdWRwgiQG,enr:-J24QHmGyBwUZXIcsGYMaUqGGSl4CFdx9Tozu-vQCn5bHIQbR7On7dZbU61vYvfrJr30t0iahSqhc64J46MnUO2JvQaGAYiOoCKKgmlkgnY0gmlwhAPnCzSHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQINc4fSijfbNIiGhcgvwjsjxVFJHUstK9L1T8OTKUjgloN0Y3CCJAaDdWRwgiQG,enr:-J24QG3ypT4xSu0gjb5PABCmVxZqBjVw9ca7pvsI8jl4KATYAnxBmfkaIuEqy9sKvDHKuNCsy57WwK9wTt2aQgcaDDyGAYiOoGAXgmlkgnY0gmlwhDbGmZaHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQIeAK_--tcLEiu7HvoUlbV52MspE0uCocsx1f_rYvRenIN0Y3CCJAaDdWRwgiQG",
    },
    "op-reth-mainnet-archive": #{
        net: "base-mainnet",
        chain: "base",
        l1_rpckind: "standard",
        opnet: "base-mainnet",
        sequencer_url: "https://mainnet-sequencer.base.org",
        op_node_bootnodes: "enr:-J24QNz9lbrKbN4iSmmjtnr7SjUMk4zB7f1krHZcTZx-JRKZd0kA2gjufUROD6T3sOWDVDnFJRvqBBo62zuF-hYCohOGAYiOoEyEgmlkgnY0gmlwhAPniryHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQKNVFlCxh_B-716tTs-h1vMzZkSs1FTu_OYTNjgufplG4N0Y3CCJAaDdWRwgiQG,enr:-J24QH-f1wt99sfpHy4c0QJM-NfmsIfmlLAMMcgZCUEgKG_BBYFc6FwYgaMJMQN5dsRBJApIok0jFn-9CS842lGpLmqGAYiOoDRAgmlkgnY0gmlwhLhIgb2Hb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJ9FTIv8B9myn1MWaC_2lJ-sMoeCDkusCsk4BYHjjCq04N0Y3CCJAaDdWRwgiQG,enr:-J24QDXyyxvQYsd0yfsN0cRr1lZ1N11zGTplMNlW4xNEc7LkPXh0NAJ9iSOVdRO95GPYAIc6xmyoCCG6_0JxdL3a0zaGAYiOoAjFgmlkgnY0gmlwhAPckbGHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJwoS7tzwxqXSyFL7g0JM-KWVbgvjfB8JA__T7yY_cYboN0Y3CCJAaDdWRwgiQG,enr:-J24QHmGyBwUZXIcsGYMaUqGGSl4CFdx9Tozu-vQCn5bHIQbR7On7dZbU61vYvfrJr30t0iahSqhc64J46MnUO2JvQaGAYiOoCKKgmlkgnY0gmlwhAPnCzSHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQINc4fSijfbNIiGhcgvwjsjxVFJHUstK9L1T8OTKUjgloN0Y3CCJAaDdWRwgiQG,enr:-J24QG3ypT4xSu0gjb5PABCmVxZqBjVw9ca7pvsI8jl4KATYAnxBmfkaIuEqy9sKvDHKuNCsy57WwK9wTt2aQgcaDDyGAYiOoGAXgmlkgnY0gmlwhDbGmZaHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQIeAK_--tcLEiu7HvoUlbV52MspE0uCocsx1f_rYvRenIN0Y3CCJAaDdWRwgiQG",
    },
};

const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;
const HOME = node_env().protocol_data_path + "/base";
const VARIANT = VARIANTS[node_env().node_variant];
const NET = VARIANT.net;
const CHAIN = VARIANT.chain;
const SEQUENCER_URL = VARIANT.sequencer_url;
const OP_NODE_BOOTNODES = VARIANT.op_node_bootnodes;
const L1_URL = "https://eth-l1.blkjy.io";
const L1_BEACON_URL = "https://lighthouse.blkjy.io";

const OP_RETH_EXTRA_ARGS = if node_env().node_variant.ends_with("-full") {
    "--full"
} else {
    ""
};

const BABEL_VERSION = "0.9.0";

fn plugins_config() {
    #{
        aux_services: base::aux_services() + aux::aux_services(),
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT,global::METRICS_PATH,global::RPC_PORT,global::WS_PORT,global::AUTHRPC_PORT,global::OP_RPC_PORT,global::CADDY_DIR),
        init: #{
            commands: [
                `mkdir -p ${global::HOME}`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [
                #{
                    name: "create_jwt",
                    run_sh: `export HOME=/root && openssl rand -hex 32 | tr -d "\n" > ${global::HOME}/jwt.hex`,
                }
            ]
        },
        services: [
            #{
                name: "op-reth",
                run_sh: `export HOME=/root && /root/bin/op-reth node --chain ${global::CHAIN} --rollup.sequencer-http ${global::SEQUENCER_URL} --http --http.addr 127.0.0.1 --http.port ${global::RPC_PORT} --http.corsdomain "*" --ws --ws.port ${global::WS_PORT} --authrpc.port ${global::AUTHRPC_PORT} --http.api eth,web3,net,txpool,debug,trace --authrpc.jwtsecret ${global::HOME}/jwt.hex --datadir ${global::HOME} --metrics 127.0.0.1:${global::METRICS_PORT} --log.file.directory ${global::HOME} --rpc.gascap 18446744073709551615`,
                shutdown_timeout_secs: 120,
            },
            #{
                name: "op-node",
                run_sh: `export HOME=/root && /root/bin/op-node --network=${global::NET} --rpc.addr=127.0.0.1 --rpc.port=${global::OP_RPC_PORT} --l1=${global::L1_URL} --l1.beacon=${global::L1_BEACON_URL} --l1.trustrpc --l2.enginekind=reth --l2=http://127.0.0.1:${global::AUTHRPC_PORT} --l2.jwt-secret=${global::HOME}/jwt.hex --syncmode=execution-layer --p2p.bootnodes=${global::OP_NODE_BOOTNODES}`,
                shutdown_timeout_secs: 120,
            },
        ],
        alternative_download: #{
            run_sh: "echo dummy"
        },
        upload: #{
            exclude: [
                "jwt.hex",
            ]
        }
    }
}

fn application_status() {
    /// "uploading", "downloading", "initializing" statuses are automatically handled by BV if BABEL_CONFIG const is defined
    let resp = run_jrpc(#{host: global::API_HOST, method: "/"});

    if resp.status_code == 200 {
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn height() {
    parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_blockNumber"}).expect(200).result)
}


fn sync_status() {
    let resp = run_jrpc(#{host: global::API_HOST, method: "eth_syncing"}).expect(200);
    if resp.result == false {
        "synced"
    } else {
        "syncing"
    }
}
