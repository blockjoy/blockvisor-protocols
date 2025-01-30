fn base_config(data_dir, metrics_port, metrics_path, rpc_port, caddy_dir, network) {
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
                    ws_port: `${rpc_port}`,  // Using same port for WebSocket
                }
            },
            #{
                template: "/var/lib/babel/templates/fullnode-mainnet-yaml.template",
                destination: "/root/bin/mainnet/fullnode.yaml",
                params: #{
                    rpc_port: "${rpc_port}",
                    metrics_port: "${metrics_port}",
                    node_ip: node_env().node_ip,
                    global_dir: `${data_dir}`,
                    network: `${network}`,
                }
            },
            #{
                template: "/var/lib/babel/templates/fullnode-yaml.template",
                destination: "/root/bin/fullnode.yaml",
                params: #{
                    rpc_port: "${rpc_port}",
                    metrics_port: "${metrics_port}",
                    node_ip: node_env().node_ip,
                    global_dir: `${data_dir}`,
                    network: `${network}`,
                }
            },
        ],
        services: [
            #{
              name: "alloy",
              run_sh: `/usr/bin/alloy run --server.http.listen-addr=0.0.0.0:12345 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy`,
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
