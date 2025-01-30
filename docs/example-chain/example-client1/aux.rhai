fn base_config(metrics_port, rpc_port, ws_port) { 
    #{   
        config_files: [
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
                    metrics_path: `${metrics_path}`,
                    metrics_port: `${metrics_port}`,
                },
            },
        ],
        services: [
            #{
                name: "caddy",
                run_sh: `/usr/bin/caddy run --config /etc/caddy/Caddyfile`,
                log_timestamp: false,
             },
        ],
    }
}
