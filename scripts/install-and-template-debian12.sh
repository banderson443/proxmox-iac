#!/bin/bash
# Helper script to start VM installation and convert to template
# This script helps with the manual installation steps

set -e

PROXMOX_HOST="${PROXMOX_HOST:-192.168.150.75}"
PROXMOX_API_URL="${PROXMOX_API_URL:-https://${PROXMOX_HOST}:8006/api2/json}"
PROXMOX_NODE="${PROXMOX_NODE:-pve}"
VM_ID=9000

if [ -z "$PROXMOX_API_TOKEN_ID" ] || [ -z "$PROXMOX_API_TOKEN_SECRET" ]; then
    echo "Error: PROXMOX_API_TOKEN_ID and PROXMOX_API_TOKEN_SECRET must be set"
    exit 1
fi

proxmox_api() {
    local method=$1
    shift
    local endpoint=$1
    shift
    curl -s -k -X "$method" \
        -H "Authorization: PVEAPIToken=$PROXMOX_API_TOKEN_ID=$PROXMOX_API_TOKEN_SECRET" \
        "$PROXMOX_API_URL$endpoint" "$@"
}

# Start VM
echo "Starting VM $VM_ID for installation..."
proxmox_api POST "/nodes/$PROXMOX_NODE/qemu/$VM_ID/status/start" > /dev/null

echo "VM started. Installation in progress..."
echo ""
echo "To connect to console, use Proxmox web UI or:"
echo "  ssh to Proxmox host and run: qm terminal $VM_ID"
echo ""
echo "After installation completes and VM shuts down, run:"
echo "  ./scripts/convert-to-template.sh"

