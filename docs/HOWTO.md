# Protocol Development Guide

This guide explains how to create and maintain protocol implementations for the BlockJoy platform.

## BlockJoy API Integration

The protocol implementation interacts with the BlockJoy API through a combination of metadata configuration and runtime interface files.

### Protocol Metadata (babel.yaml)

The `babel.yaml` file defines the protocol's metadata that the BlockJoy API needs to:
- Set up resource requirements (CPU, memory, disk)
- Configure networking and firewall rules
- Define available protocol variants
- Establish container settings
- Set protocol visibility and access properties

This metadata is used by the API for deployment planning and resource allocation, but the actual protocol configuration and runtime behavior are controlled through the RHAI files.

### Runtime Interface (RHAI Files)

The RHAI files (`main.rhai` and `aux.rhai`) serve as the primary configuration interface between your protocol and the BlockJoy API. These files:
1. Access the protocol metadata through the `node_env()` function
2. Configure protocol behavior based on the selected variant
3. Initialize and manage protocol services
4. Report node status back to the API

### Node Environment Configuration

The API provides access to deployment configuration through the `node_env()` function in RHAI files. This function exposes metadata from `babel.yaml` along with runtime information:

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
const PLUGIN_CONFIG = #{
    services: [
        #{
            name: "example-node",
            run_sh: `/usr/bin/example-node \
                    --network=${VARIANT.network} \
                    ${VARIANT.extra_args}`,
        },
    ],
};
```

### Implementation Flow

When implementing a new blockchain protocol:

1. **Define Protocol Metadata** (`babel.yaml`):
   - Set protocol identification (version, SKU, description)
   - Define available variants and their resource requirements
   - Configure network access rules
   - Set visibility and access properties

2. **Create Runtime Interface** (`main.rhai`):
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
   - Add protocol-specific dependencies
   - Configure runtime environment

The BlockJoy API uses the metadata from `babel.yaml` to plan and create node deployments, while the RHAI files control how the node actually operates within those parameters.

## Protocol Structure

Each protocol should follow this structure:
```bash
protocols/
└── your-protocol/
    └── your-protocol-client/
        ├── babel.yaml    # Protocol configuration and metadata
        ├── main.rhai     # Main protocol configuration
        ├── aux.rhai      # Auxiliary functions and configurations
        └── Dockerfile    # Protocol-specific Docker configuration
```

## Configuration Files

### 1. babel.yaml - Protocol metadata and versioning
```yaml
version: 0.1.0                                      # Protocol version
container_uri: docker://ghcr.io/org/image:tag      # Container image
sku_code: YOUR-PROTOCOL                            # Unique protocol identifier
org_id: null                                       # Organization ID (if applicable)
variants:
  - key: example-mainnet-full
    min_cpu: 4
    min_memory_mb: 16000
    min_disk_gb: 1000
    sku_code: EXPL-MF
```

### 2. main.rhai - Main protocol configuration
```rhai
import "base" as base;
import "aux" as aux;

// Define protocol-specific constants
const RPC_PORT = 8545;
const WS_PORT = 8546;
const METRICS_PORT = 9090;
const METRICS_PATH = "/metrics";
const CADDY_DIR = node_env().data_mount_point + "/caddy";
const EXAMPLE_DIR = node_env().protocol_data_path + "/example";

// Import auxiliary configuration
let AUX_CONFIG = aux::base_config(global::METRICS_PORT, global::RPC_PORT, global::WS_PORT, global::CADDY_DIR);

// Merge with base configuration
const BASE_CONFIG = #{
    config_files: AUX_CONFIG.config_files + base::BASE_CONFIG.config_files,
    services: AUX_CONFIG.services + base::BASE_CONFIG.services,
};

// Define protocol variants
const VARIANTS = #{
    "example-mainnet-full": #{
        network: "mainnet",
        extra_args: "--syncmode full",
    },
};

const VARIANT = VARIANTS[node_env().node_variant];

// Plugin configuration
const PLUGIN_CONFIG = #{
    init: #{
        commands: [
            `mkdir -p ${global::EXAMPLE_DIR}`,
            `mkdir -p ${global::CADDY_DIR}`,
        ],
    },
    services: [
        #{
            name: "example-node",
            run_sh: `/usr/bin/example-node \
                    --datadir=${global::EXAMPLE_DIR} \
                    --network=${global::VARIANT.network} \
                    ${global::VARIANT.extra_args}`,
            shutdown_timeout_secs: 120,
            use_blockchain_data: true,
            log_timestamp: false,
        },
    ],
};

// Required status functions
fn application_status() {
    let resp = parse_hex(run_jrpc(#{host: `http://127.0.0.1:${global::RPC_PORT}`, method: "eth_chainId"}).expect(200).result);
    
    if resp == 1 { // Example chain ID
        "broadcasting"
    } else {
        "delinquent"
    }
}

fn height() {
    parse_hex(run_jrpc(#{ host: `http://127.0.0.1:${global::RPC_PORT}`, method: "eth_blockNumber"}).expect(200).result)
}

fn sync_status() {
    let resp = run_jrpc(#{host: `http://127.0.0.1:${global::RPC_PORT}`, method: "eth_syncing"}).expect(200);
    if resp.result == false {
        "synced"
    } else {
        "syncing"
    }
}
```

### 3. aux.rhai - Auxiliary configurations
```rhai
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
                    tld: ".n0des.xyz",
                    data_dir: `${caddy_dir}`,
                }
            }
        ],
        services: [
            #{
                name: "caddy",
                run_sh: `/usr/bin/caddy run --config /etc/caddy/Caddyfile`,
                log_timestamp: false,
            }
        ]
    }
}
```

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

### 5. Templates and Configuration Files

The protocol implementation includes template files that are processed during node initialization:

**Caddyfile.template** - Reverse proxy configuration:
```
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

## Required Functions

Your protocol must implement these functions in `main.rhai`:

1. `application_status()` - Returns the node's operational status:
   - `"broadcasting"` - Node is operational
   - `"delinquent"` - Node has issues

2. `height()` - Returns the current block height as an integer

3. `sync_status()` - Returns the node's sync status:
   - `"synced"` - Node is up to date
   - `"syncing"` - Node is catching up

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

The example chain protocol in `docs/example-chain/` demonstrates how to implement a protocol.