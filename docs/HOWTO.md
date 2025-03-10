# Protocol Development Guide

This guide explains how to create and maintain protocol implementations for the BlockJoy platform.

## Overview
- [File Structure](#file-structure)
- [BlockJoy API Integration](#blockjoy-api-integration)
  - [Protocol Metadata (protocols.yaml)](#protocol-metadata-protocolsyaml)
  - [Protocol Image Metadata (babel.yaml)](#protocol-image-metadata-babelyaml)
  - [Runtime Interface (Rhai scripts)](#runtime-interface-rhai-scripts)
  - [Node Environment Configuration](#node-environment-configuration)
  - [Protocol Variants and Configuration](#protocol-variants-and-configuration)
  - [Implementation Flow](#implementation-flow)
- [Configuration Files](#configuration-files)
  - [base.rhai - Common protocol functions](#1-base-rhai-common-protocol-functions)
  - [aux.rhai - Auxiliary, client specific configurations and functions](#2-aux-rhai-auxiliary-client-specific-configurations-and-functions)
  - [Templates and Configuration Files](#3-templates-and-configuration-files)
  - [Dockerfile - Protocol image configuration](#4-dockerfile-protocol-image-configuration)
- [Testing and Deploying Protocols](#testing-and-deploying-protocols)
  - [Checking Protocol Syntax and Configuration](#checking-protocol-syntax-and-configuration)
  - [Testing Protocol Nodes](#testing-protocol-nodes)
  - [Deploying to the BlockJoy API](#deploying-to-the-blockjoy-api)
- [Best Practices](#best-practices)
- [Example Implementation](#example-implementation)
  - [Example](./example/)


## File Structure
```bash
base-images/
└── base_image/
    ├── config/                   # (Optional)
        └── config_files.yaml     # Base image with config files
    └── templates/                # (Optional)
        └── file_base.template    # Common templates for all images
    └── base.rhai                 # Common base rhai configuration
    └── Dockerfile                # Base Dockerfile with common utilities
clients/
└── consensus/
    ├── consensus_client/
        └── Dockerfile            # Client-specific Docker configuration
└── exec/
    ├── exec_client/
        └── Dockerfile            # Client-specific Docker configuration
└── ...                           # Other client types (e.g., load-balancer, observability, etc.)
protocols/
└── protocols.yaml                # Root entity for all protocol implementations
└── your_protocol/
    └── your_protocol-exec_client/
        └── templates/
        ├── babel.yaml            # Protocol configuration and metadata
        ├── main.rhai             # Main protocol configuration
        ├── aux.rhai              # Auxiliary functions and configurations
        └── Dockerfile            # Protocol-specific Docker configuration
└── ...                           # Other protocols (e.g., ethereum, optimism, etc.)
```


## BlockJoy API Integration

The protocol implementation interacts with the BlockJoy API through a combination of metadata configuration (aka `babel.yaml`) and runtime interface files (aka Rhai scripts).

### Protocol Metadata (protocols.yaml)

First make sure that the protocol you're creating an image for is defined in `protocols.yaml`. This is the root entity that groups all implementations of the same protocol.

### Protocol Image Metadata (babel.yaml)

The `babel.yaml` file defines the protocol image's metadata that the BlockJoy API needs to:
- Define available image variants
- Set up resource requirements (CPU, memory, disk)
- Configure networking and firewall rules
- Establish container settings
- Set variant visibility and access properties

This metadata is used by the API for deployment planning and resource allocation, but the actual protocol image configuration and runtime behavior are controlled through the RHAI files.

### Runtime Interface (Rhai scripts)

The Rhai scripts (`main.rhai` and other imported scripts like `aux.rhai`) serve as the primary configuration interface between your protocol image and the BlockJoy API. These files:
1. Access the protocol image metadata from `babel.yaml` through the `node_env()` function
2. Configure protocol image behavior based on the selected `babel.yaml` variant
3. Initialize and manage protocol services
4. Report node status back to the API

### Node Environment Configuration

The API provides access to deployment configuration through the `node_env()` function in Rhai script. This function exposes metadata from `babel.yaml` along with runtime information:

```rust
pub struct NodeEnv {
    /// Node id.
    pub node_id: String,
    /// Node name.
    pub node_name: String,
    /// Node version.
    pub node_version: String,
    /// Node protocol.
    pub node_protocol: String,
    /// Node variant.
    pub node_variant: String,    // Maps to variant key in babel.yaml
    /// Node IP.
    pub node_ip: String,
    /// Node gateway IP.
    pub node_gateway: String,
    /// Indicate if node run in dev mode.
    pub dev_mode: bool,
    /// Host id.
    pub bv_host_id: String,
    /// Host name.
    pub bv_host_name: String,
    /// API url used by host.
    pub bv_api_url: String,
    /// Organisation id to which node belongs to.
    pub org_id: String,
    /// Absolute path to directory where data drive is mounted.
    pub data_mount_point: String,
    /// Absolute path to directory where protocol data are stored.
    pub protocol_data_path: String,
}
```

### Implementation Flow

When implementing a new blockchain protocol image:
1. **Create client(s) used by the protocol being implemented:**
   - Define Dockerfile for each client
   - Setup build for client(s)
   - Copy client binaries to common location for future use
   - Copy client specific libraries to common location for future use

2. **Define Protocol Image Metadata** (`babel.yaml`):
   - Set protocol image identification (version, SKU, description)
   - Define available variants and their resource requirements
   - Configure network access rules
   - Set visibility and access properties

3. **Create Runtime Interface** (`main.rhai`):
   - Import base configurations
   - Define protocol-specific constants
   - Map `node_env().node_variant` to protocol configurations
   - Configure services and initialization steps
   - Implement required status functions

3. **Add Auxiliary Functions** (`aux.rhai`):
   - Define reusable configurations
   - Set up template processing
   - Configure additional services

4. **Set Up Container** (`Dockerfile`):
   - Use appropriate base image
   - Copy related client binaries from the previously built client images (or use external images where required) 
   - Add protocol-specific dependencies
   - Configure runtime environment
   - Place all necessary Rhai scripts (`main.rhai` in particular) into the container (`/var/lib/babel/plugin/`)

The BlockJoy API uses the metadata from `babel.yaml` to plan and create node deployments, while the RHAI files control how the node actually operates within those parameters.


### Protocol Variants and Configuration

1. Define available variants in `babel.yaml`:
```yaml
variants:
  - key: client-mainnet-full    # This key is accessed via node_env().node_variant
    min_cpu: 4
    min_memory_mb: 16000
    min_disk_gb: 1000
    sku_code: EXPL-MF
```

2. Configure variant-specific behavior in the protocol's `main.rhai`:
```rhai
// Map node_env().node_variant to protocol configuration
const VARIANTS = #{
    "client-mainnet-full": #{
        network: "mainnet",
        extra_args: "--syncmode full",
    },
};

// Access current variant configuration
const VARIANT = VARIANTS[node_env().node_variant];

// Use in service configuration
fn plugin_config() {#{
        aux_services: base::aux_services() + aux::aux_services(), // explained below
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT,global::METRICS_PATH,global::RPC_PORT,global::WS_PORT, global::AUTHRPC_PORT,global::OP_RPC_PORT,global::CADDY_DIR), // explained below
    services: [
            #{
                name: "example-node",
                run_sh: `/usr/bin/example-node \
                        --network=${global::VARIANT.network} \
                        ${global::VARIANT.extra_args}`,
            },
        ],
}}
```

## Configuration Files

See docs and examples with comments, delivered with BV bundle in `/opt/blockvisor/current/docs/` for more details on `babel.yaml` and Rhai scripts.

### 1. base.rhai - Common protocol functions

The `base.rhai` file is part of the base image and provides common services and their configurations that are used by all protocols. It is located at `/usr/lib/babel/plugin/base.rhai` in the container:

```rhai
// Base configuration that protocols can extend
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
```

### 2. aux.rhai - Auxiliary, client specific services and configurations
```rhai
fn config_files() {
        [
            #{
                template: "/var/lib/babel/templates/Caddyfile.template",
                destination: "/etc/caddy/Caddyfile",
                params: #{
                    rpc_port: `${rpc_port}`,
                    ws_port: `${ws_port}`,
                    metrics_port: `${metrics_port}`,
                    hostname: node_env().node_name,
                    tld: ".n0des.xyz",
                    data_dir: `${caddy_dir}`,
                }
            }
        ]
}
fn aux_services() {            
        [
            #{
                name: "caddy",
                run_sh: `/usr/bin/caddy run --config /etc/caddy/Caddyfile`,
            },
        ]
}

```

Base and aux functions are imported into the protocol's `main.rhai` using:
```rhai
import "base" as base;        // Inherited from the base-image used
import "aux" as aux;          // Inherited from the aux.rhai in protocol directory

// Import auxiliary configuration
fn plugin_config() {
        aux_services: base::aux_services() + aux::aux_services(), // pull from base.rhai and aux.rhai
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT,global::METRICS_PATH,global::RPC_PORT,global::WS_PORT,global::AUTHRPC_PORT,global::OP_RPC_PORT,global::CADDY_DIR), // use global variables to interpolate into configs and pull them in the `main.rhai`
        services : [
            #{
                name: "erigon",
                run_sh: `/root/bin/erigon \
                        --network=${global::VARIANT.network} \
                        ${global::VARIANT.extra_args}`,
            },
        ]
}
```

The `main.rhai` also contains protocol specific functions that the API uses to communicate with the running services and assess the node's health or status:

```rhai
fn protocol_status() {
    let resp = parse_hex(run_jrpc(#{host: global::API_HOST, method: "eth_chainId"}).expect(200).result);

    if resp == 1 { // Example chain ID
        #{state: "broadcasting", health: "healthy"}
    } else {
        #{state: "delinquent", health: "healthy"}
    }
}

fn height() {
    parse_hex(run_jrpc(#{ host: global::API_HOST, method: "eth_blockNumber"}).expect(200).result)
}

fn sync_status() {
    let resp = run_jrpc(#{host: global::API_HOST, method: "eth_syncing"}).expect(200);
    if resp.result == false {
        "synced"
    } else {
        "syncing"
    }
}
```

Comprehensive documentation on the plugin's configuration and supported functions can be found here: [Protocol RHAI Plugin Guide](https://github.com/blockjoy/blockvisor/blob/master/babel_api/rhai_plugin_guide.md).

### 3. Templates and Configuration Files

The protocol implementation may include template files that are processed during node initialization. These templates are used to create configuration files for node services, such as the reverse proxy, and may also include additional configuration for the node.

**Caddyfile.template** - Reverse proxy configuration:
```bash
{hostname}{tld} {
    reverse_proxy /debug/metrics/prometheus localhost:{metrics_port}
    reverse_proxy /ws localhost:{ws_port}
    reverse_proxy localhost:{rpc_port}

    tls {
        dns cloudflare {env.CF_API_TOKEN}
    }

    log {
        output file {data_dir}/access.log
        format json
    }
}
```

These templates are referenced in the auxiliary configuration (`aux.rhai`) and are processed with values from the node `main.rhai` to ensure consistency across services.

### 4. Dockerfile - Protocol image configuration
```dockerfile
FROM privaterepo/erigon as erigon
FROM privaterepo/lighthouse as lighthouse

FROM privaterepo/debian-bookworm-base

RUN mkdir -p /root/bin /root/lib
COPY --from=erigon /root/bin/erigon /root/bin/
COPY --from=erigon /root/lib/libsilkworm_capi.so /root/lib/
COPY --from=lighthouse /root/bin/lighthouse /root/bin/

COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/
```

## Testing and Deploying Protocols

### Checking Protocol Syntax and Configuration

Before deploying your protocol, you should check its syntax and configuration using `nib`. This tool is used in our CI/CD pipeline to validate protocols before they are built and deployed.

To check a protocol's syntax:
```bash
nib image check --variant <variant-name> --path <path-to-babel-yaml> plugin
```

For example:
```bash
nib image check --variant mainnet --path protocols/your_protocol/your_protocol-exec_client/babel.yaml plugin
```

This will validate:
- The `babel.yaml` file structure and required fields
- The presence and syntax of required Rhai scripts
- The configuration templates and their variables

### Testing Protocol Nodes

Once the syntax check passes, you can test your protocol nodes. There are two main types of checks:

1. Service Status Checks - Verify that all services defined in your protocol start correctly (doesn't check for service restarts, only service startup):
```bash
nib image check --variant <variant-name> --path <path-to-babel-yaml> --cleanup jobs-status
```

2. Service Restart Checks - Verify that your protocol handles service restarts properly (besides checking for proper service start, it will also check if the service fails and restarts):
```bash
nib image check --variant <variant-name> --path <path-to-babel-yaml> --cleanup jobs-restarts
```

Notes:
`babel` (the component running on the node as part of the blockvisor suite) is responsible for starting and monitoring the node services. If a service isn't configured properly, it will start and eventually fail, so babel will restart start it according to the restart policy of the service. This will register as a service restart and is detected by the `job-restarts` check (`job-status` will only detect the initial failure to execute), but shouldn't be considered a critical error since some jobs won't start without specific requirements (for example, some execution clients won't start without a dataset since syncing from genesis isn't possible). These restarts are expected and can be normal behavior of the node, but they need to be checked thoroughly in order to identify configuration issues early on. In case of automated workflows, it's recommended to not fail the workflow on these errors, instead they should trigger a soft alert and get double-checked.

### Deploying to the BlockJoy API

#### Pushing the protocols.yaml File

When you've added a new protocol or modified protocol metadata in `protocols.yaml`, you need to push these changes to the API:

```bash
nib protocol push --path protocols/protocols.yaml
```

#### Deploying Individual Protocol Images

To deploy a specific protocol implementation:

```bash
nib image push --path <path-to-babel-yaml>
```

For example:
```bash
nib image push --path protocols/your_protocol/your_protocol-exec_client/babel.yaml
```
Notes:
- The `nib` CLI tool is part of `bv` bundle released as part of the [bv-host-setup](https://github.com/blockjoy/bv-host-setup) repository.
- The `--path` argument is optional and added throughout for clarity

## Best Practices

1. **Version Management**:
   - Use semantic versioning in `babel.yaml`
   - Update the version when making any changes to the protocol implementation

2. **Configuration**:
   - Use environment variables for configurable values
   - Follow the example protocols for structure

3. **Service Management**:
   - Use appropriate timeouts
   - Ensure all functions required by the API are implemented
   - Test functions to ensure they work as expected

4. **Metrics**:
   - Expose Prometheus metrics when possible

## Example Implementation

The example protocol implementation in [example/](example/) demonstrates how to implement a protocol.

See also docs and examples delivered with BV bundle in `/opt/blockvisor/current/docs/`.
