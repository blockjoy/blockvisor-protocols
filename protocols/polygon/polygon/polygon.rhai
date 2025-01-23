const BASE_CONFIG = #{   
    config_files: [
        #{
            template: "/var/lib/babel/templates/config-alloy.template",
            destination: "/etc/alloy/config.alloy",
            params: #{
                hostname: node_env().node_name,
                tld: ".n0des.xyz",
                blockchain: node_env().blockchain_type,
                metrics_port: "7071",
                metrics_path: "/debug/metrics/prometheus",
            }
        },
        #{
            template: "/var/lib/babel/templates/Caddyfile.template",
            destination: "/etc/caddy/Caddyfile",
            params: #{
                rpc_port: "8545",
                ws_port: "8546",                    
                metrics_port: "7071",
                hostname: node_env().node_name,
                node_ip: node_env().node_ip,
                tld: ".n0des.xyz",
                data_dir: `${global::CADDY_DIR}`,
            },
        },
    ],    
    services: [
        #{
            name: "alloy",
            run_sh: `/usr/bin/alloy run --server.http.listen-addr=0.0.0.0:12345 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy`,
        },
        #{
            name: "caddy",
            run_sh: "/usr/bin/caddy run --config /etc/caddy/Caddyfile",
            log_timestamp: false,
        },       
    ],
}
