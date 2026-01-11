# Proxmox Exporter

Proxmox Exporter collects Proxmox-specific metrics via API.

## What It Collects

**Proxmox Metrics:**
- VM status (running, stopped, paused)
- VM resource usage (CPU, memory per VM)
- Storage pool utilization
- Cluster node status
- Network bridge information
- Backup job status (if configured)

**Why It's Safe:**
- **Read-only API**: Uses Proxmox API with read-only permissions
- **No VM operations**: Cannot start, stop, or modify VMs
- **No storage changes**: Cannot create or delete storage pools
- **No configuration changes**: Cannot modify Proxmox settings
- **API token**: Uses read-only API token (not root password)

## Installation

Proxmox Exporter runs on monitoring server (not on Proxmox hosts).

**Not managed by this repository:**
- Install manually or via deployment method
- Runs as service or container
- Listens on port 9221

## Configuration

**Port**: 9221 (default)
**Path**: `/metrics`
**Example**: `http://monitoring-server:9221/metrics`

**API Credentials:**
- Configured via environment variables (not in config files)
- Requires Proxmox API token with read-only permissions
- Example: `PVE_USER=monitoring@pve` and `PVE_TOKEN_SECRET=...`

## Prometheus Scrape

Prometheus scrapes metrics every 15 seconds (configurable).

**Example scrape config:**
```yaml
- job_name: 'proxmox-exporter'
  static_configs:
    - targets: ['monitoring-server:9221']
```

## API Token Setup

**Create read-only token in Proxmox:**
1. Proxmox Web UI → Datacenter → Permissions → API Tokens
2. Create token for user (e.g., `monitoring@pve`)
3. Grant read-only permissions (no VM/Storage/System permissions)
4. Use token ID and secret in exporter configuration

## Security Considerations

- **Read-only token**: Use API token with minimal permissions
- **Network isolation**: Run on internal monitoring network
- **No root access**: Do not use root credentials
- **Token rotation**: Rotate API tokens periodically
- **Environment variables**: Store credentials securely (not in config files)

## Typical Metrics

- `pve_up` - Proxmox API connectivity
- `pve_cluster_node_info` - Cluster node information
- `pve_vm_info` - VM status and configuration
- `pve_storage_info` - Storage pool information
- `pve_vm_memory_bytes` - VM memory usage
- `pve_vm_cpu_usage` - VM CPU usage percentage

## Data Flow

1. Exporter queries Proxmox API (read-only)
2. Exporter exposes metrics on `/metrics` endpoint
3. Prometheus scrapes metrics from exporter
4. Grafana queries Prometheus for visualization

**No direct connection from Grafana to Proxmox.**

