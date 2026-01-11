# Node Exporter

Node Exporter collects host-level metrics from Proxmox hosts.

## What It Collects

**System Metrics:**
- CPU usage and load average
- Memory usage (total, free, cached, buffers)
- Disk I/O (read/write operations, throughput)
- Disk space usage (per filesystem)
- Network I/O (bytes sent/received, errors)
- System uptime and boot time

**Why It's Safe:**
- **Read-only**: Only reads `/proc` and `/sys` filesystems
- **No authentication**: Metrics endpoint is public (internal network only)
- **No write operations**: Cannot modify system state
- **No credentials**: Does not access Proxmox API or sensitive data
- **Standard metrics**: Same as any Linux monitoring tool

## Installation

Node Exporter runs on each Proxmox host.

**Not managed by this repository:**
- Install manually or via Ansible role (future)
- Runs as systemd service
- Listens on port 9100

## Configuration

**Port**: 9100 (default)
**Path**: `/metrics`
**Example**: `http://proxmox-host:9100/metrics`

## Prometheus Scrape

Prometheus scrapes metrics every 15 seconds (configurable).

**Example scrape config:**
```yaml
- job_name: 'node-exporter'
  static_configs:
    - targets: ['proxmox-host:9100']
```

## Security Considerations

- **Network isolation**: Run on internal monitoring network only
- **Firewall**: Restrict access to port 9100
- **No secrets**: Metrics contain no credentials or sensitive data
- **Read-only**: Cannot be used to modify system

## Typical Metrics

- `node_cpu_seconds_total` - CPU time by mode
- `node_memory_MemTotal_bytes` - Total memory
- `node_filesystem_size_bytes` - Filesystem sizes
- `node_disk_io_time_seconds_total` - Disk I/O time
- `node_network_receive_bytes_total` - Network receive

