# Proxmox Monitoring Stack

Complete monitoring solution for Proxmox infrastructure using Prometheus and Grafana.

## Architecture

**Read-only monitoring:**
- **Prometheus**: Collects metrics from exporters
- **Grafana**: Visualizes metrics from Prometheus
- **Exporters**: Collect metrics from Proxmox hosts
- **No write operations**: Monitoring does not modify infrastructure

## Components

### Prometheus
- Time-series database for metrics storage
- Scrapes metrics from exporters
- Provides query API for Grafana
- **Location**: `prometheus/`

### Grafana
- Visualization and dashboards
- Queries Prometheus (read-only)
- No direct Proxmox access
- **Location**: `grafana/`

### Exporters

**node-exporter:**
- Runs on each Proxmox host
- Collects host metrics (CPU, memory, disk, network)
- Port 9100
- **Documentation**: `exporters/node-exporter.md`

**proxmox-exporter:**
- Runs on monitoring server
- Queries Proxmox API (read-only)
- Collects VM and cluster metrics
- Port 9221
- **Documentation**: `exporters/proxmox-exporter.md`

## Data Flow

```
Proxmox Hosts → node-exporter → Prometheus ← Grafana
                                      ↑
Proxmox API → proxmox-exporter ──────┘
```

**Key points:**
- Exporters collect metrics (read-only)
- Prometheus scrapes exporters
- Grafana queries Prometheus
- No direct Grafana → Proxmox connection
- No write operations anywhere

## Safety

**Why this is safe:**
- **Read-only**: All components are read-only
- **No credentials in config**: Credentials via environment variables
- **No Proxmox host installation**: Exporters run separately (except node-exporter)
- **API tokens**: Use read-only API tokens for Proxmox exporter
- **Network isolation**: Run on monitoring network

## Typical Dashboards

**Host Metrics:**
- CPU usage and load
- Memory usage
- Disk I/O and space
- Network throughput

**VM Metrics:**
- VM status (running/stopped)
- VM CPU and memory usage
- VM count per host

**Storage Metrics:**
- Storage pool utilization
- Disk space per pool
- Storage I/O

**Cluster Metrics:**
- Node status
- Cluster health
- Resource distribution

## Setup

1. **Install exporters** (see exporter documentation)
2. **Configure Prometheus** (copy `prometheus.yml.example` to `prometheus.yml`)
3. **Start Prometheus** with configuration
4. **Configure Grafana** with Prometheus as data source
5. **Import dashboards** (when available)

## Security

- **No secrets in config files**: Use environment variables
- **Read-only API tokens**: Minimal permissions for Proxmox exporter
- **Network isolation**: Restrict access to monitoring network
- **No root access**: Use dedicated monitoring user/token

## Future Enhancements

- Alerting rules (Prometheus Alertmanager)
- Pre-built Grafana dashboards
- Ansible roles for exporter installation
- Docker Compose for easy deployment

## Documentation

- **Prometheus**: `prometheus/README.md`
- **Grafana**: `grafana/README.md`
- **Node Exporter**: `exporters/node-exporter.md`
- **Proxmox Exporter**: `exporters/proxmox-exporter.md`

