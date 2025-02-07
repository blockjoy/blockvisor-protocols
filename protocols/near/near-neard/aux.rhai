fn base_config(data_dir, metrics_port, metrics_path, rpc_port, caddy_dir) {
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
                    metrics_port: `${metrics_port}`,
                    metrics_path: `${metrics_path}`,
                    hostname: node_env().node_name,
                    node_ip: node_env().node_ip,
                    tld: ".n0des.xyz",
                    data_dir: `${caddy_dir}`,
                    rpc_port: `${rpc_port}`,
                    cloudflare_cert_key: get_secret("cloudflare_cert_key").as_string(),
                }
            },
            #{
                template: "/var/lib/babel/templates/config-json.template",
                destination: "/root/bin/config.json",
                params: #{
                    rpc_port: `${rpc_port}`
                },
            },
        ],
        services: [
            #{
              name: "alloy",
              run_sh: `/usr/bin/alloy run --server.http.listen-addr=127.0.0.1:12346 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy`,
              log_timestamp: false,
            },
            #{
              name: "caddy",
              run_sh: "/usr/bin/caddy run --config /etc/caddy/Caddyfile",
              log_timestamp: false
            }
        ],
   } 
}
