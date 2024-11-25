export const BASE_CONFIG = #{
    config_files: [
        #{
            template: "/var/lib/babel/templates/netdata-conf.template",
            destination: "/etc/netdata/netdata.conf",
            params: #{}
        },
        #{
            template: "/var/lib/babel/templates/netdata-stream-conf.template",
            destination: "/etc/netdata/stream.conf",
            params: #{}
        },
        #{
            template: "/var/lib/babel/templates/caddy-dashboard.template",
            destination: "/var/lib/grafana/dashboards/caddy-dashboard.json",
            params: #{
                node_name: node_env().node_name
            },
        },
    ],
    services : [
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
