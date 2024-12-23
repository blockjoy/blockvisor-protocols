fn base_config(metrics_port, rpc_port, ws_port, caddy_dir) { 
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
                    metrics_path: "/metrics",
                }
            },
            #{
                template: "/var/lib/babel/templates/Caddyfile.template",
                destination: "/etc/caddy/Caddyfile",
                params: #{
                    rpc_port: `${rpc_port}`,
                    ws_port: `${ws_port}`,
                    hostname: node_env().node_name,
                    node_ip: node_env().node_ip,
                    tld: ".n0des.xyz",
                    data_dir: `${caddy_dir}`,
                }
            }
        ],
        services: [
            #{
                name: "alloy-t3",
                run_sh: "/usr/bin/alloy run --server.http.listen-addr=127.0.0.1:12346 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy"
            },
            #{
                name: "caddy",
                run_sh: "/usr/bin/caddy run --config /etc/caddy/Caddyfile"
            }
        ]
    }
}
