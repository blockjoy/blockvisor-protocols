const METADATA = #{
    min_babel_version: "1.7.1",
    kernel: "5.10.174-build.1+fc.ufw",
    node_version: "1.1.3",
    protocol: "polygon",
    node_type: "fullnode",
    description: "polygon fullnode",
    requirements: #{
        vcpu_count: 16,
        mem_size_mb: 32768,
        disk_size_gb: 6500,
    },
    /// Supported blockchain networks.
    nets: #{
        amoy: #{
            url: "https://testnet-api.helium.wtf/v1/",
            net_type: "test",
        },
        mainnet: #{
            url: "https://rpc.ankr.com/eth",
            net_type: "main",
        },
    },
    babel_config: #{
        swap_size_mb: 512,
        swap_file_location: "/swapfile",
    },
    /// Node firewall configuration.
    firewall: #{
        default_in: "deny",
        default_out: "allow",
        rules: [
            #{
                name: "Allowed incoming tcp traffic on port",
                action: "allow",
                direction: "in",
                protocol: "tcp",
                ports: [26656,30303,80,443],
            },
            #{
                name: "Allowed incoming udp traffic on ip and port",
                action: "allow",
                direction: "in",
                protocol: "udp",
                ports: [30303], 
            },
        ],
    },
};

const NETS = #{
    amoy: #{
        net_type: "test",
        p2p_seeds: "",
        network: "amoy",
        bootnodes: "",
    },
    mainnet: #{
        net_type: "main",
        p2p_seeds: "--p2p.seeds 1500161dd491b67fb1ac81868952be49e2509c9f@52.78.36.216:26656,dd4a3f1750af5765266231b9d8ac764599921736@3.36.224.80:26656,8ea4f592ad6cc38d7532aff418d1fb97052463af@34.240.245.39:26656,e772e1fb8c3492a9570a377a5eafdb1dc53cd778@54.194.245.5:26656,6726b826df45ac8e9afb4bdb2469c7771bd797f1@52.209.21.164:26656",
        network: "mainnet",
        bootnodes: "-bootnodes enode://b8f1cc9c5d4403703fbf377116469667d2b1823c0daf16b7250aa576bacf399e42c3930ccfcb02c5df6879565a2b8931335565f0e8d3f8e72385ecf4a4bf160a@3.36.224.80:30303,enode://8729e0c825f3d9cad382555f3e46dcff21af323e89025a0e6312df541f4a9e73abfa562d64906f5e59c51fe6f0501b3e61b07979606c56329c020ed739910759@54.194.245.5:30303",
    },
};
const API_HOST = "http://127.0.0.1:8545/";
const HEIMDALL_DIR = BLOCKCHAIN_DATA_PATH + "/heimdall";
const BOR_DIR = BLOCKCHAIN_DATA_PATH + "/bor";
const NET =  global::NETS[node_params().NETWORK];
const CADDY_DIR = DATA_DRIVE_MOUNT_POINT + "caddy";

const BABEL_VERSION = "1.7.1";
const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::CADDY_DIR}`
        ],
        jobs: [
            #{
                name: "init_job",
                run_sh: `openssl rand -hex 32 > /dev/null`,
            }
        ]
    },
    /// list of services to be started once init jobs and download is finished
    services: [
        #{
            name: "heimdall",
            run_sh: `/root/bin/heimdalld start --moniker blockjoy --home ${global::HEIMDALL_DIR} ${global::NET.p2p_seeds} --bor_rpc_url http://127.0.0.1:8545 --chain ${global::NET.network} --rest-server`,
        },
        #{
            name: "bor",
            run_sh: `/root/bin/bor server -datadir ${global::BOR_DIR} -chain ${global::NET.network} -syncmode full -metrics -metrics.prometheus-addr 127.0.0.1:7071 -maxpeers 200 -bor.heimdall http://127.0.0.1:1317 -http -http.addr 127.0.0.1 -http.port 8545 -http.corsdomain "*" -http.api eth,net,web3,txpool,bor -ws -ws.addr 127.0.0.1 -ws.port 8546 -ws.origins "*" -ws.api eth,net,web3,txpool,bor -gcmode full -rpc.evmtimeout 300s -rpc.gascap 0 -rpc.returndatalimit 0 ${global::NET.bootnodes}`,
        },
    ],
    /// [optional] download configuration
    /// built-in download will be started once all init jobs are finished
    //download: #{
        /// [optional] Maximum number of parallel opened connections.
        /// If not set default to 3.
        //max_connections: 5,
        /// [optional] Maximum number of parallel workers.
        /// If not set default to 8.
        //max_runners: 8,
        /// [optional] Job restart config.
        /// If not set default to:
        /// #{
        ///    backoff_timeout_ms: 600000,
        ///    backoff_base_ms: 500,
        ///    max_retries: 10,
        /// }
        //restart_config: #{
            //backoff_timeout_ms: 60000,
            //backoff_base_ms: 1000,
            //max_retries: 5,
        //},
    //},
    /// [optional] alternative download if archive for standard one is not available
    //alternative_download: #{
        /// Sh script body.
        //run_sh: `/usr/bin/wget -q -O - some_url`,
        /// [optional] InitJob restart config.
        /// If not set default to "never".
        //restart_config: #{
            //backoff_timeout_ms: 60000,
            //backoff_base_ms: 10000,
            //max_retries: 3,
        //},
        /// [optional] Run job as a different user.
        //run_as: "some_user",
        /// [optional] Capacity of log buffer (in lines).
        /// If not set default to 128.
        //log_buffer_capacity_mb: 64,
    //},
    /// [optional] post-download sh jobs, to be started after download
    //post_download: [
        //#{
            //name: "post_download_job",
            //run_sh: `echo restoreDB`,
        //}
    //],
    /// [optional] pre-upload action
    ///pre_upload: #{        
    ///    commands: [
    ///        `echo pruning`,
    ///    ],        
    ///    jobs: [
    ///        #{
    ///            name: "prune",
    ///            run_sh: `/usr/bin/bor snapshot prune-state --datadir ${global::BOR_DIR}`,
    ///        }
    ///    ]
    ///},
    /// [optional] upload configuration
    /// built-in upload can be manually triggered with `bv node run upload`
    upload: #{
        /// [optional] List of exclude patterns. Files in `BLOCKCHAIN_DATA_PATH` directory that match any of pattern,
        /// won't be taken into account.
        exclude: [
        ],
        /// [optional] Compression to be used on chunks.
        /// If not set default to `ZSTD: 3`.
        //compression: #{
            //ZSTD: 5, /// compression level
        //},
        /// [optional] Maximum number of parallel opened connections.
        /// If not set default to 3.
        //max_connections: 4,
        /// [optional] Maximum number of parallel workers.
        /// If not set default to 8.
        //max_runners: 12,
        /// [optional] Number of chunks that blockchain data should be split into.
        /// Recommended chunk size is about 1GB. Estimated by BV based on data size, if not provided.
        /// If not set calculated automatically by BV.
        //number_of_chunks: 700,
        /// [optional] Seconds after which presigned urls in generated `UploadManifest` may expire.
        /// If not set calculated automatically by BV.
        //url_expires_secs: 240000,
        /// [optional] Version number for uploaded data. Auto-assigned if not provided.
        /// If not set calculated automatically by Blockvisor API.
        //data_version: 3,
        /// [optional] Job restart config.
        /// If not set default to:
        /// #{
        ///    backoff_timeout_ms: 600000,
        ///    backoff_base_ms: 500,
        ///    max_retries: 10,
        /// }
        //restart_config: #{
            //backoff_timeout_ms: 60000,
            //backoff_base_ms: 1000,
            //max_retries: 5,
        //},
    },
    /// [optional] post-upload sh jobs, to be started after upload
    //post_upload: [
        //#{
            //name: "post_upload_job",
            //run_sh: `echo cleanup_after_upload`,
        //}
    //],
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

fn test_height_value(param) {
    if height() < 0 {
        throw "Invalid node height value: " + height();
    }
}
