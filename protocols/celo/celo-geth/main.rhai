import "base" as base;
import "celo-geth" as celo_geth;

const CADDY_DIR = node_env().data_mount_point + "/caddy";
const RPC_PORT = 8545;
const WS_PORT = 8546;
const P2P_PORT = 30303;
const METRICS_PORT = 7770;
const METRICS_PATH = "/debug/metrics/prometheus";

const CELO_API = "http://127.0.0.1:${global::RPC_PORT}";
const CELO_DIR = node_env().protocol_data_path + "/celo";

let CELO_GETH_CONFIG = celo_geth::base_config(global::METRICS_PORT, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR, global::METRICS_PATH);

const BASE_CONFIG = #{
    config_files: CELO_GETH_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: CELO_GETH_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "geth-mainnet-archive": #{
        network_name: "celo",
        sync_type: "archive"
    },
};

const VARIANT = VARIANTS[node_env().node_variant];
const NETWORK_NAME = VARIANT.network_name;
const SYNC_TYPE = VARIANT.sync_type;

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