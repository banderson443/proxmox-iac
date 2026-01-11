# Prometheus Configuration

Prometheus collects metrics from Proxmox infrastructure for monitoring and alerting.

## Architecture

**Read-only monitoring:**
- Prometheus scrapes metrics from exporters
- No write operations to Proxmox hosts
- No credentials stored in Prometheus config
- All metrics are pulled (not pushed)

## Configuration

**File**: `prometheus.yml.example`
- Example configuration with placeholders
- Copy to `prometheus.yml` and update with real targets
- No secrets or credentials in configuration

## Scrape Jobs

### node-exporter
- **Port**: 9100
- **Location**: Runs on each Proxmox host
- **Metrics**: CPU, memory, disk I/O, network, system load
- **Safety**: Read-only, no authentication required

### proxmox-exporter
- **Port**: 9221
- **Location**: Runs on monitoring server
- **Metrics**: VM status, storage usage, cluster health
- **Safety**: Read-only API queries, credentials via environment variables

## Setup

1. Copy example configuration:
   ```bash
   cp prometheus.yml.example prometheus.yml
   ```

2. Update targets with real hostnames/IPs

3. Configure credentials via environment variables (not in config file)

4. Start Prometheus with the configuration

## Data Retention

Default retention is 15 days. Adjust `--storage.tsdb.retention.time` flag as needed.

## Security

- No credentials in configuration files
- Use environment variables for sensitive data
- Prometheus runs read-only (scrapes only)
- Network access should be restricted to monitoring network

