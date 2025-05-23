fn config_files(metrics_port, rpc_port, ws_port, caddy_dir) {
    [
        #{
            template: "/var/lib/babel/templates/config-alloy.template",
            destination: "/etc/alloy/config.alloy",
            params: #{
                hostname: node_env().node_name,
                tld: ".n0des.xyz",
                blockchain: node_env().node_protocol,
                metrics_port: `${metrics_port}`,
                metrics_path: "/debug/metrics/prometheus",
                grafana_loki_key: get_secret("grafana-loki-key").as_string(),
                grafana_prometheus_key: get_secret("grafana-prometheus-key").as_string(),
            }
        },
        #{
            template: "/var/lib/babel/templates/Caddyfile.template",
            destination: "/etc/caddy/Caddyfile",
            params: #{
                rpc_port: `${rpc_port}`,
                ws_port: `${ws_port}`,
                metrics_port: `${metrics_port}`,
                metrics_path: "/debug/metrics/prometheus",
                hostname: node_env().node_name,
                node_ip: node_env().node_ip,
                tld: ".n0des.xyz",
                data_dir: `${caddy_dir}`,
                cloudflare_cert_key: get_secret("cloudflare-cert-key").as_string(),
            }
        }
    ]
}

fn aux_services() {
    [
        #{
            name: "alloy",
            run_sh: "/usr/bin/alloy run --server.http.listen-addr=127.0.0.1:12346 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy"
        },
        #{
            name: "caddy",
            run_sh: "/usr/bin/caddy run --config /etc/caddy/Caddyfile"
        }
    ]
}
