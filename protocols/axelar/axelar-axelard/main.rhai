import "base" as base;
import "celo-geth" as celo_geth;

const CADDY_DIR = node_env().data_mount_point + "caddy";
const RPC_PORT = 26657;
const P2P_PORT = 26656;
const REST_PORT = 1317;
const GRPC_WEB_PORT = 9091;
const GRPC_PORT = 9090;
const METRICS_PORT = 26660;
const METRICS_PATH = "/metrics";
const API_HOST = "http://127.0.0.1:${global::RPC_PORT}";
const DIR = node_env().protocol_data_path + "/axelar";

let AXELAR_AXELARD_CONFIG = axelar_axelard::base_config(global::METRICS_PORT, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR, global::METRICS_PATH);

const BASE_CONFIG = #{
    config_files: AXELAR_AXELARD_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AXELAR_AXELARD_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "axelard-mainnet-full": #{
    },
};

const VARIANT = VARIANTS[node_env().node_variant];

const BABEL_VERSION = "0.9.0";

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::CELO_DIR}`,
            `mkdir -p ${global::CADDY_DIR}`,
        ],
        jobs: []
    },
    services: [
        #{
            name: "geth",
            run_sh: `/root/bin/geth --verbosity 3 --syncmode full --gcmode ${global::SYNC_TYPE} --http --http.port ${global::RPC_PORT} --http.addr 127.0.0.1 --http.api eth,net,web3,debug,admin,personal --http.timeout.read 300 --http.timeout.write 300 --http.timeout.idle 300 --http.vhosts "*" --ws --ws.addr 127.0.0.1 --ws.port ${global::WS_PORT} --ws.api eth,net,web3,debug,admin,personal --ws.origins "*" --port ${global::P2P_PORT} --metrics --metrics.addr 127.0.0.1 --metrics.port ${global::METRICS_PORT} --light.serve 90 --light.maxpeers 1000 --maxpeers 1100 --datadir ${global::CELO_DIR} --txlookuplimit 0 --cache.preimages --rpc.gascap 0`,
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