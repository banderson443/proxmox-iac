# Grafana Configuration

Grafana visualizes metrics collected by Prometheus.

## Architecture

**Read-only visualization:**
- Grafana queries Prometheus (read-only)
- No direct access to Proxmox hosts
- Dashboards display metrics only
- No write operations

## Data Source

**Prometheus:**
- Primary data source for all dashboards
- Connection: `http://prometheus:9090` (example)
- No authentication required (internal network)

## Dashboards

**Location**: `dashboards/`

Dashboards will be added here for:
- Proxmox host metrics (CPU, memory, disk, network)
- VM status and resource usage
- Storage pool utilization
- Cluster health

## Setup

1. Configure Prometheus as data source in Grafana UI
2. Import dashboards from `dashboards/` directory
3. Dashboards use Prometheus queries (read-only)

## Security

- Grafana runs read-only (queries Prometheus only)
- No direct Proxmox API access
- Authentication configured separately (not in this repo)
- Network access should be restricted

