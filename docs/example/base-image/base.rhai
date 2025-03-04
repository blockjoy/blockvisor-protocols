fn config_files() {
    [
        #{
            template: "/some/template.template",
            destination: "/some/destination/config",
            params: #{
                param1: "value1",
                param2: "value2",
            },
        },
    ]
}

fn aux_services() {
    [
        #{
            name: "binary1",
            run_sh: "/usr/bin/binary1 run",
        },
        #{
            name: "binary2",
            run_sh: "/usr/bin/binary2 run",
        }
    ]
}