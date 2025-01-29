import "base" as base;
import "aux" as aux;

const BABEL_VERSION = "1.11.0";
const WORKDIR = "/root";
const DATADIR = node_env().protocol_data_path + "/subsquid";
const KEYPATH = DATADIR + "/.subsquid-key";
const METRICS_API = "http://127.0.0.1:8000/metrics";
const METRICS_PORT = 4141;
const METRICS_PATH = "/debug/metrics/prometheus";
const ENV = node_env();
const CADDY_DIR = DATADIR + "/caddy";

let AUX_CONFIG = aux::base_config(global::DATADIR, global::KEYPATH, global::METRICS_PORT, global::METRICS_PATH, global::CADDY_DIR);

const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

const VARIANTS = #{
    "sqd-worker-mainnet": #{
        url: "https://testnet-api.helium.wtf/v1/",
        network: "main",
        env_file: ".mainnet.env"
    },
    "sqd-worker-testnet": #{
        url: "https://testnet-api.helium.wtf/v1/",
        network: "test",
        env_file: ".tethys.env"
    },
};

print(`Debug - network value: ${node_env().node_variant}`);
const ENV_FILE = VARIANTS[node_env().node_variant].env_file;

const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::CADDY_DIR}`,
            `mkdir -p ${global::DATADIR}`,
        ],
        jobs: [
            #{
                name: "init",
                run_sh: `echo`,
            }
        ]
    },
    services: [
        #{
            name: "sqd",
            run_sh: `. /root/${global::ENV_FILE} && /root/bin/worker | tee ${global::DATADIR}/subsquid.log`,
        },
    ],
    alternative_download: #{
        run_sh: `echo TBD`,
        restart_config: #{
            backoff_timeout_ms: 60000,
            backoff_base_ms: 10000,
            max_retries: 3,
        },
    },
    upload: #{
        exclude: [
            ".subsquid-key",
            "**/*",
        ],
    },
    scheduled: [
        #{
            /// Unique name of the task.
            name: "clear_log",
            /// Cron schedule expression.
            schedule: "0 0 0 */4 * * *",
            /// Function name to be executed according to schedule.
            function: "clear_log",
            /// [optional] Parameter to ba passed to function.
            param: "param",
        },
    ],
};

fn application_status() {
    let result = run_sh(`curl --write-out '%{http_code}' --silent --output /dev/null ${global::METRICS_API}`).unwrap();
    if result == "200" {
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn peer_id () {
    let peer_id = run_sh(`cat ${global::DATADIR}/peer_id`).unwrap();
    peer_id
}

fn name() {
    let peer_id = peer_id();
    try {
        let result = run_rest(#{url: `https://subsquid.squids.live/subsquid-network-mainnet/graphql?query=query%20MyQuery%7Bworkers%28where%3A%7BpeerId_eq%3A%22${peer_id}%22%7D%29%7Bname%20online%20jailed%20status%20peerId%7D%7D%0A`}).expect(200).data.workers[0];
        result.name
    } catch {
        "Unregistered"
    }
}

fn address() {
    let name = name();
    let peer_id = peer_id();
    if name == () {
        "Unregistered: " + peer_id;
    } else {
        "Name: " + name + "/PeerID: " + peer_id;
    }
}

fn clear_log() {
    run_sh(`head -n 2 ${global::DATADIR}/subsquid.log > /tmp/ss.log && mv /tmp/ss.log ${global::DATADIR}/subsquid.log`);
}

fn netdata_update() {
    run_sh(`wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --stable-channel --disable-telemetry --non-interactive --dont-start-it --native-only --disable-cloud`);
}

fn sync_status() {
    "synced"
}

fn test_height_value(param) {
    if height() < 0 {
        throw "Invalid node height value: " + height();
    }
}
