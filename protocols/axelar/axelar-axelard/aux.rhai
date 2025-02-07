fn base_config(axelar_dir, metrics_port, p2p_port, rpc_port, rest_port, grpc_web_port, grpc_port, caddy_dir, metrics_path) { 
    #{   
        config_files: [
            #{
                template: "/var/lib/babel/templates/config-alloy.template",
                destination: "/etc/alloy/config.alloy",
                params: #{
                    hostname: node_env().node_name,
                    tld: ".n0des.xyz",
                    blockchain: node_env().node_protocol,
                    metrics_port: `${metrics_port}`,
                    metrics_path: `${metrics_path}`,
                    grafana_loki_key: get_secret("grafana_loki_key").as_string(),
                    grafana_prometheus_key: get_secret("grafana_prometheus_key").as_string(),
                }
            },
            #{
                template: "/var/lib/babel/templates/Caddyfile.template",
                destination: "/etc/caddy/Caddyfile",
                params: #{
                    rpc_port: `${rpc_port}`,
                    rest_port: `${rest_port}`,
                    grpc_web_port: `${grpc_web_port}`,
                    grpc_port: `${grpc_port}`,
                    hostname: node_env().node_name,
                    tld: ".n0des.xyz",
                    data_dir: `${caddy_dir}`,
                    metrics_path: `${metrics_path}`,
                    metrics_port: `${metrics_port}`,
                    cloudflare_cert_key: get_secret("cloudflare_cert_key").as_string(),
                }
            },
            #{
                template: "/var/lib/babel/templates/config-toml.template",
                destination: "/root/configs/config.toml",
                params: #{
                    rpc_port: `${rpc_port}`,
                    p2p_port: `${p2p_port}`,
                    metrics_port: `${metrics_port}`,
                    hostname: node_env().node_name,
                    node_ip: node_env().node_ip,
                }
            },
            #{
                template: "/var/lib/babel/templates/app-toml.template",
                destination: "/root/configs/app.toml",
                params: #{},
            },
            #{
                template: "/var/lib/babel/templates/addrbook-json.template",
                destination: "/root/configs/addrbook.json",
                params: #{},
            },
            #{
                template: "/var/lib/babel/templates/genesis-json.template",
                destination: "/root/configs/genesis.json",
                params: #{},
            },
        ],
        services: [
            #{
                name: "alloy",
                run_sh: `/usr/bin/alloy run --server.http.listen-addr=127.0.0.1:12346 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy`,
            },
            #{
                name: "caddy",
                run_sh: "/usr/bin/caddy run --config /etc/caddy/Caddyfile",
                log_timestamp: false,
             },
        ],
    }
}