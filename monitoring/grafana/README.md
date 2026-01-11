# Grafana Configuration

Grafana visualizes metrics collected by Prometheus.

## Grafana Role Purpose

The Grafana Ansible role (`ansible/roles/grafana/`):
- Installs Grafana from official repository
- Configures Prometheus as default datasource
- Enables and starts Grafana service
- Provides read-only visualization of metrics

## Architecture

**Read-only visualization:**
- Grafana queries Prometheus (read-only)
- No direct access to Proxmox hosts
- Dashboards display metrics only
- No write operations

## Prometheus Datasource Explanation

**How Grafana connects to Prometheus:**

1. **Datasource Configuration**
   - File: `/etc/grafana/provisioning/datasources/prometheus.yml`
   - Automatically provisioned by Ansible role
   - URL: `http://monitoring-prometheus:9090` (example, update with actual hostname)

2. **Connection Type**
   - **Proxy mode**: Grafana queries Prometheus on behalf of users
   - No direct browser access to Prometheus needed
   - Centralized through Grafana

3. **Query Flow**
   ```
   User → Grafana UI → Prometheus API → Metrics
   ```
   - User creates dashboard in Grafana
   - Grafana sends PromQL queries to Prometheus
   - Prometheus returns metrics
   - Grafana visualizes results

4. **Why this is safe:**
   - Grafana only reads from Prometheus (read-only)
   - No write operations to Prometheus
   - No direct Proxmox access
   - No credentials in datasource config (internal network)

## Data Source

**Prometheus:**
- Primary data source for all dashboards
- Connection: `http://monitoring-prometheus:9090` (update with actual hostname)
- No authentication required (internal network)
- Automatically configured by Ansible role

## Dashboards

**Location**: `dashboards/`

Dashboards are automatically provisioned on Grafana service start. No manual import required.

### Available Dashboards

1. **Proxmox VE Dashboard** (`proxmox-dashboard.json`)
   - **Purpose**: Main Proxmox overview dashboard (similar to Proxmox Web UI)
   - **Sections**:
     - **Node Summary**: CPU, Memory, Disk, Uptime, Status, CPU cores
     - **VM Summary**: Total VMs, Running, Stopped, Templates
     - **Storage Summary**: Storages count, Total, Used, Available
     - **Network Summary**: Networks count, Network In, Network Out
   - **Data Source**: Prometheus (uses datasource name, not ID)
   - **Refresh**: 30 seconds

2. **Node Exporter Full** (`node-exporter-full.json`)
   - **Purpose**: Host-level metrics from Node Exporter
   - **Metrics**:
     - CPU usage and load average
     - Memory usage (used/available)
     - Disk I/O wait time
     - Network traffic (RX/TX)
     - Disk space usage
   - **Variables**: `instance` (select specific Proxmox hosts)
   - **Data Source**: Prometheus (uses datasource name, not ID)

3. **Proxmox VE Cluster / Node Overview** (`proxmox-cluster-overview.json`)
   - **Purpose**: Proxmox cluster and VM overview
   - **Metrics**:
     - Cluster node status
     - VM status (running/stopped count)
     - VM CPU usage per VM
     - VM memory usage per VM
     - Storage pool usage
     - VM count by node
   - **Variables**: `node` (select specific Proxmox nodes)
   - **Data Source**: Prometheus (uses datasource name, not ID)

### Auto-Provisioning

Dashboards are automatically loaded from `/etc/grafana/provisioning/dashboards/` on Grafana service start:
- **Folder**: `Proxmox`
- **Overwrite**: Enabled (updates existing dashboards)
- **Update Interval**: 10 seconds
- **No manual import required**: Dashboards appear automatically in Grafana UI

### Dashboard Features

- **No hardcoded IPs**: All queries use Prometheus datasource by name
- **Variables for filtering**: Select specific hosts/nodes via dashboard variables
- **Read-only**: All queries are read-only PromQL queries
- **Auto-refresh**: Dashboards refresh every 30 seconds

## Setup

1. Prometheus datasource is automatically configured by Ansible role
2. Dashboards are automatically provisioned on service start
3. Access Grafana UI: `http://grafana-vm:3000`
4. Navigate to Dashboards → Proxmox folder
5. Dashboards use Prometheus queries (read-only)

## Security Notes

**Read-only operation:**
- Grafana queries Prometheus only (read-only)
- No write operations to Prometheus or Proxmox
- Cannot modify metrics or configuration
- Cannot start/stop VMs or change Proxmox settings

**No writes:**
- Grafana does not write data to Prometheus
- Grafana does not write to Proxmox API
- All operations are read-only queries
- Dashboards are stored locally in Grafana database

**Network isolation:**
- Should only be accessible from monitoring network
- No direct Proxmox API access
- Authentication configured separately (not in this repo)
- Default admin password should be changed on first login

**Data flow safety:**
```
Proxmox Hosts → node_exporter → Prometheus ← Grafana (read-only queries)
```

Grafana is the final read-only layer in the monitoring stack.

