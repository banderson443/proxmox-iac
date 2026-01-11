#!/bin/bash
# Convert VM 9000 to template

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

# Check VM status
VM_STATUS=$(proxmox_api GET "/nodes/$PROXMOX_NODE/qemu/$VM_ID/status/current")
if echo "$VM_STATUS" | grep -q '"status":"running"'; then
    echo "Error: VM $VM_ID is still running. Please shutdown first."
    exit 1
fi

# Convert to template
echo "Converting VM $VM_ID to template..."
proxmox_api POST "/nodes/$PROXMOX_NODE/qemu/$VM_ID/template" > /dev/null

if [ $? -eq 0 ]; then
    echo "Success! VM $VM_ID has been converted to template."
    echo "You can now use template ID 9000 in Terraform."
else
    echo "Error: Failed to convert VM to template"
    exit 1
fi

