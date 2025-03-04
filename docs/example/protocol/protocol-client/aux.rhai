fn base_config(metrics_port, rpc_port, ws_port, caddy_dir) {
    #{
        config_files: [
            #{
                template: "/var/lib/babel/templates/Caddyfile.template",
                destination: "/etc/caddy/Caddyfile",
                params: #{
                    rpc_port: `${rpc_port}`,
                    ws_port: `${ws_port}`,
                    metrics_port: `${metrics_port}`,
                    hostname: node_env().node_name,
                    node_ip: node_env().node_ip,
                    tld: ".n0des.xyz",
                    data_dir: `${caddy_dir}`,
                }
            }
        ],
        services: [
            #{
                name: "caddy",
                run_sh: `/usr/bin/caddy run --config /etc/caddy/Caddyfile`,
            }
        ]
    }
}
