fn base_config(metrics_port, rpc_port, caddy_dir) {
    #{
        config_files: [
            #{
                template: "/var/lib/babel/templates/Caddyfile.template",
                destination: "/etc/caddy/Caddyfile",
                params: #{
                    rpc_port: `${rpc_port}`,
                    ws_port: `${rpc_port}`,   
                    metrics_port: `${metrics_port}`,
                    metrics_path: "/ext/metrics",
                    hostname: node_env().node_name,
                    node_ip: node_env().node_ip,
                    tld: ".n0des.xyz",
                    data_dir: `${caddy_dir}`,
                },
            },
            #{
                template: "/var/lib/babel/templates/config-alloy.template",
                destination: "/etc/alloy/config.alloy",
                params: #{
                    hostname: node_env().node_name,
                    tld: ".n0des.xzy",
                    blockchain: node_env().blockchain_type,
                    metrics_port: `${metrics_port}`,
                    metrics_path: "/ext/metrics",
                }
            },
        ],
        services: [
            #{
                name: "alloy",
                run_sh: `/usr/bin/alloy run --server.http.listen-addr=0.0.0.0:12346 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy`,
            },
            #{
                name: "caddy",
                run_sh: "/usr/bin/caddy run --config /etc/caddy/Caddyfile",
                log_timestamp: false,
            }
        ],
    }
}
