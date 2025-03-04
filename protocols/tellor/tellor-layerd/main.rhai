import "base" as base;
import "aux" as aux;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const PROTOCOL_DIR = node_env().protocol_data_path + "/tellor";
const RPC_PORT = 26657;
const P2P_PORT = 26656;
const REST_PORT = 1317;
const GRPC_WEB_PORT = 9091;
const GRPC_PORT = 9090;
const METRICS_PORT = 26660;
const METRICS_PATH = "/metrics";
const API_HOST = "http://127.0.0.1:" + global::RPC_PORT;

const VARIANTS = #{
    "layerd-testnet-full": #{
        hostname: node_env().node_name,
        chain_id: "layertest-3",
        key_name: "alice",
        key_ring: "test",
        eth_rpc_url: "https://eth-l1-sepolia.blkjy.io",
        token_bridge_contract: "0x6ac02f3887b358591b8b2d22cfb1f36fa5843867",
        seeds: "f4786bc2a40172e29784b9f8d69567c474de8a8c@13.212.32.99:26656,7f2c8cad741c28d7a01d9f1cf2e1a87eb751afa3@52.53.226.18:26656,d87d655453277514d150df82e6305b307f138d06@54.234.103.186:26656,59fd40b86c9b65ca717b29ce37b08fdb82c8e61d@3.144.113.220:26656",
        trust_hash: "1BCB0F657CEF35FDD28E00824F79A38E2FC9414348712B82F85B25209B02DAE5",
        trust_height: "415637",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const HOSTNAME = VARIANT.hostname;
const CHAIN_ID = VARIANT.chain_id;
const KEY_NAME = VARIANT.key_name;
const KEY_RING = VARIANT.key_ring;
const ETH_RPC_URL = VARIANT.eth_rpc_url;
const TOKEN_BRIDGE_CONTRACT = VARIANT.token_bridge_contract;
const SEEDS = VARIANT.seeds;
const TRUST_HASH = VARIANT.trust_hash;
const TRUST_HEIGHT = VARIANT.trust_height;

fn plugin_config() {
    #{
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT, global::P2P_PORT, global::RPC_PORT, global::REST_PORT, global::GRPC_WEB_PORT, global::GRPC_PORT, global::CADDY_DIR, global::METRICS_PATH, global::KEY_RING, global::SEEDS, global::TRUST_HASH, global::TRUST_HEIGHT),
        aux_services: base::aux_services() + aux::aux_services(),
        init: #{
            commands: [
                `mkdir -p ${global::PROTOCOL_DIR}/config`,
                `mkdir -p ${global::CADDY_DIR}`,
            ],
            jobs: [
                #{
                    name: "init",
                    run_sh: `if [ ! -f ${global::PROTOCOL_DIR}/config/node_key.json ]; then /root/bin/layerd init ${global::HOSTNAME} --overwrite --home ${global::PROTOCOL_DIR}/ --chain-id ${global::CHAIN_ID}; else echo "Already initialized"; fi;`,
                },
                #{
                    name: "config",
                    run_sh: `cp -f /root/configs/* ${global::PROTOCOL_DIR}/config/`,
                    needs: ["init"],
                },
                #{
                    name: "add-key",
                    run_sh: `if [ ! -f ${global::PROTOCOL_DIR}/keyring-test/alice.info ]; then /root/bin/layerd keys add ${global::KEY_NAME} --keyring-backend ${global::KEY_RING} --home ${global::PROTOCOL_DIR}/; else echo "Key already exists"; fi; `,
                    needs: ["init", "config"],
                },
            ]
        },
        services: [
            #{
                name: "layerd",
                run_sh: `export ETH_RPC_URL="${global::ETH_RPC_URL}" && export TOKEN_BRIDGE_CONTRACT="${global::TOKEN_BRIDGE_CONTRACT}" &&/root/bin/layerd start --home ${global::PROTOCOL_DIR}/ --api.enable --api.swagger --price-daemon-enabled=false --panic-on-daemon-failure-enabled=false --key-name ${global::KEY_NAME}`,
                shutdown_timeout_secs: 300,
            },
        ],
        download: #{
            max_connections: 5,
        },
        upload: #{
            exclude: [
                "tellor/config/**",
            ],
        },
    }
}

fn application_status() {
    let result = run_jrpc(#{
            host: global::API_HOST,
            method: "status",
            headers: [["content-type", "application/json"]]
        }).expect(200);

    if result.result.sync_info.catching_up == false {
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
    }
}

fn height() {
    parse_int(run_jrpc(#{
        host: global::API_HOST,
        method: "status",
        headers: [["content-type", "application/json"]]
    }).expect(200).result.sync_info.latest_block_height)
}

fn sync_status() {
    let result = run_jrpc(#{
            host: global::API_HOST,
            method: "status",
            headers: [["content-type", "application/json"]]
        }).expect(200);

    if result.result.sync_info.catching_up == false {
        "synced"
    } else if result.result.sync_info.catching_up == true {
        "syncing"
    }
}
