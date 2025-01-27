import "base" as base;
import "axelar-axelard" as axelar_axelard;

const CADDY_DIR = node_env().data_mount_point + "caddy";
const AXELAR_DIR = node_env().protocol_data_path + "/axelar";
const RPC_PORT = 26657;
const P2P_PORT = 26656;
const REST_PORT = 1317;
const GRPC_WEB_PORT = 9091;
const GRPC_PORT = 9090;
const METRICS_PORT = 26660;
const METRICS_PATH = "/metrics";
const API_HOST = "http://127.0.0.1:${global::RPC_PORT}";


let AXELAR_AXELARD_CONFIG = axelar_axelard::base_config(global::METRICS_PORT, global::P2P_PORT, global::RPC_PORT, global::REST_PORT, global::GRPC_WEB_PORT, global::GRPC_PORT, global::CADDY_DIR, global::METRICS_PATH);

const BASE_CONFIG = #{
    config_files: AXELAR_AXELARD_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AXELAR_AXELARD_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "axelard-mainnet-full": #{
        hostname: node_env().node_name,
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const HOSTNAME = VARIANT.hostname;

const BABEL_VERSION = "0.9.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::AXELAR_DIR}`,
            `mkdir -p ${global::CADDY_DIR}`,
        ],
        jobs: [
            #{
                name: "init",
                run_sh: `export HOME=${global::AXELAR_DIR} && \
                /root/bin/axelard init ${global::HOSTNAME} --overwrite --home ${global::AXELAR_DIR}/.axelar --chain-id axelar-dojo-1`,
            }
        ]
    },
    services: [
        #{
            name: "axelar",
            run_sh: `export DAEMON_HOME=${global::AXELAR_DIR}/.axelar && \
                export DAEMON_NAME=axelard && \
                export UNSAFE_SKIP_BACKUP=true && \
                export HOME=${global::AXELAR_DIR} && \
                /root/bin/axelard start`,
            shutdown_timeout_secs: 300,
        },
    ],
    download: #{
        max_connections: 5,
    },
    upload: #{
        exclude: [],
    },
};

fn application_status() {
    let resp = parse_hex(run_jrpc(#{host: global::CELO_API, method: "eth_chainId"}).expect(200).result);
  
    if resp == 42220 {
        "broadcasting"
    } else {
        "delinquent"
    }
  }
  
  fn height() {
    let resp = run_jrpc(#{host: global::CELO_API, method: "eth_blockNumber"});
    if resp.status_code != 200 {
      throw resp;
    }
    let h = parse_json(resp.body);
    parse_int(sub_string(h.result,2),16)
  }
  
  fn sync_status() {
      let resp = run_jrpc(#{host: global::CELO_API, method: "eth_syncing"}).expect(200);
      if resp.result == false {
          "synced"
      } else {
          "syncing"
      }
  }