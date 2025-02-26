fn config_files() {
    [
        #{
            template: "/var/lib/babel/templates/caddy-dashboard.template",
            destination: "/var/lib/grafana/dashboards/caddy-dashboard.json",
            params: #{
                node_name: node_env().node_name
            },
        },
        #{
            template: "/var/lib/babel/templates/grafana-datasource.template",
            destination: "/usr/share/grafana/conf/provisioning/datasources/datasource.yml",
            params: #{
                grafana_prometheus_key: get_secret("grafana-prometheus-key").as_string(),
                grafana_loki_key: get_secret("grafana-loki-key").as_string(),
            },
        }
    ]
}

fn aux_services() {
    [
        #{
            name: "grafana",
            run_sh: "GF_USERS_DEFAULT_ROLE=Viewer \
                    GF_AUTH_ANONYMOUS_ENABLED=true \
                    GF_AUTH_ANONYMOUS_ORG_ROLE=Viewer \
                    GF_ROLE_VIEWER_EDITORS_CAN_SAVE=false \
                    grafana-server --homepath /usr/share/grafana --config /etc/grafana/grafana.ini"
        },
    ]
}
