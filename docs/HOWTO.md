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
1. **Create client(s) used by protocol being implemented:
   - Define Dockerfile for each client
     - Setup build for client
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
   - Use related client images
   - Add protocol-specific dependencies
   - Configure runtime environment
   - Put all necessary Rhai scripts (`main.rhai` in particular) into the container (`/var/lib/babel/plugin/`)

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

2. Configure variant-specific behavior in RHAI files:
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

The `base.rhai` file is part of the base image and provides common utility functions used by all protocols. It is located at `/usr/lib/babel/plugin/base.rhai` in the container:

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

### 2. aux.rhai - Auxiliary, client specific configurations and functions
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

Base and aux functions are imported in `main.rhai` using:
```rhai
import "base" as base;        // Inherrited from the base-image used
import "aux" as aux;          // Inherrited from the aux.rhai in protocol directory

// Import auxiliary configuration
fn plugin_config() {
        aux_services: base::aux_services() + aux::aux_services(), // pull from base.rhai and aux.rhai
        config_files: base::config_files() + aux::config_files(global::METRICS_PORT,global::METRICS_PATH,global::RPC_PORT,global::WS_PORT,global::AUTHRPC_PORT,global::OP_RPC_PORT,global::CADDY_DIR), // use global variables to interpolate into configs and pull them in
        services : [
            #{
                name: "example-node",   
                run_sh: `/usr/bin/example-node \
                        --network=${global::VARIANT.network} \
                        ${global::VARIANT.extra_args}`,
            },
        ]
}

### 3. Templates and Configuration Files

The protocol implementation may includes template files that are processed during node initialization:

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

These templates are referenced in the auxiliary configuration (`aux.rhai`) and are processed with values from the node environment.


### 4. Dockerfile - Protocol image configuration
```dockerfile
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache make gcc musl-dev linux-headers git

# Build example client
RUN git clone https://github.com/example/example-client.git /src
WORKDIR /src
RUN make build

FROM ghcr.io/blockjoy/node-base:latest
COPY --from=builder /src/build/example-node /usr/bin/
COPY . /var/lib/babel/
COPY templates/Caddyfile.template /var/lib/babel/templates/
```

## Best Practices

1. **Version Management**:
   - Use semantic versioning in `babel.yaml`
   - Update the version when making protocol changes

2. **Configuration**:
   - Use environment variables for configurable values
   - Document all configuration options
   - Follow the example protocols for structure

3. **Service Management**:
   - Implement proper shutdown handling
   - Use appropriate timeouts
   - Monitor service health

4. **Metrics**:
   - Expose Prometheus metrics when possible
   - Use standard metric paths
   - Include basic health metrics

## Example Implementation

The example protocol implementation in [example/](example/) demonstrates how to implement a protocol.

See also docs and examples delivered with BV bundle in `/opt/blockvisor/current/docs/`.
