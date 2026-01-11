#!/bin/bash
# Create Debian 12 cloud-init template using Proxmox API (works from remote machine)
# Fully automated - no manual interaction required

set -e

# Configuration
PROXMOX_HOST="${PROXMOX_HOST:-192.168.150.75}"
PROXMOX_API_URL="${PROXMOX_API_URL:-https://${PROXMOX_HOST}:8006/api2/json}"
PROXMOX_NODE="${PROXMOX_NODE:-pve}"
STORAGE="${VM_DEFAULT_STORAGE:-local-lvm}"
BRIDGE="${VM_DEFAULT_BRIDGE:-vmbr0}"
VM_ID=9000
VM_NAME="debian-12-cloudinit-template"

# API credentials - must be set via environment variables
if [ -z "$PROXMOX_API_TOKEN_ID" ] || [ -z "$PROXMOX_API_TOKEN_SECRET" ]; then
    echo "Error: PROXMOX_API_TOKEN_ID and PROXMOX_API_TOKEN_SECRET must be set"
    echo "Example:"
    echo "  export PROXMOX_API_TOKEN_ID='root@pam!terraform'"
    echo "  export PROXMOX_API_TOKEN_SECRET='your-secret-here'"
    exit 1
fi

# Function to call Proxmox API
proxmox_api() {
    local method=$1
    shift
    local endpoint=$1
    shift
    curl -s -k -X "$method" \
        -H "Authorization: PVEAPIToken=$PROXMOX_API_TOKEN_ID=$PROXMOX_API_TOKEN_SECRET" \
        "$PROXMOX_API_URL$endpoint" "$@"
}

# Find Debian 12 ISO
echo "Finding Debian 12 ISO in storage..."
ISO_LIST=$(proxmox_api GET "/storage/local/content?content=iso")
ISO_FILE=$(echo "$ISO_LIST" | grep -o '"volid":"[^"]*debian-12[^"]*"' | head -1 | cut -d'"' -f4 || echo "")

if [ -z "$ISO_FILE" ]; then
    echo "Error: Debian 12 ISO not found in Proxmox storage (local)"
    echo "Available ISOs:"
    echo "$ISO_LIST" | grep -o '"volid":"[^"]*"' | cut -d'"' -f4 || echo "  (none found)"
    exit 1
fi

echo "Using ISO: $ISO_FILE"
echo "Node: $PROXMOX_NODE"
echo "Storage: $STORAGE"
echo "Bridge: $BRIDGE"

# Check if VM 9000 already exists and remove it
VM_STATUS=$(proxmox_api GET "/nodes/$PROXMOX_NODE/qemu/$VM_ID/status/current" 2>/dev/null || echo "")
if [ -n "$VM_STATUS" ] && ! echo "$VM_STATUS" | grep -q "does not exist\|404"; then
    echo "VM $VM_ID already exists. Removing it first..."
    proxmox_api DELETE "/nodes/$PROXMOX_NODE/qemu/$VM_ID?destroy-unreferenced-disks=1&purge=1"
    echo "Waiting for VM removal..."
    sleep 3
fi

# Create VM 9000
echo "Creating VM $VM_ID..."
proxmox_api POST "/nodes/$PROXMOX_NODE/qemu" \
    -d "vmid=$VM_ID" \
    -d "name=$VM_NAME" \
    -d "memory=2048" \
    -d "cores=2" \
    -d "net0=virtio,bridge=$BRIDGE" \
    -d "scsihw=virtio-scsi-pci" \
    -d "scsi0=$STORAGE:32,format=raw" \
    -d "boot=order=scsi0" \
    -d "agent=1" \
    -d "serial0=socket" \
    -d "vga=serial0" > /dev/null

if [ $? -ne 0 ]; then
    echo "Error: Failed to create VM"
    exit 1
fi

echo "VM created successfully"

# Attach ISO
echo "Attaching Debian 12 ISO..."
proxmox_api POST "/nodes/$PROXMOX_NODE/qemu/$VM_ID/config" \
    -d "ide2=$ISO_FILE,media=cdrom" > /dev/null

# Add cloud-init drive
echo "Adding cloud-init drive..."
proxmox_api POST "/nodes/$PROXMOX_NODE/qemu/$VM_ID/config" \
    -d "ide0=$STORAGE:cloudinit" > /dev/null

# Enable cloud-init
echo "Configuring cloud-init..."
proxmox_api POST "/nodes/$PROXMOX_NODE/qemu/$VM_ID/config" \
    -d "ciuser=root" \
    -d "ipconfig0=ip=dhcp" > /dev/null

echo ""
echo "VM $VM_ID created and configured successfully!"
echo ""
echo "Next steps:"
echo "1. Start VM for installation:"
echo "   proxmox_api POST \"/nodes/$PROXMOX_NODE/qemu/$VM_ID/status/start\""
echo ""
echo "2. Connect to console and install Debian 12 with:"
echo "   - SSH server enabled"
echo "   - QEMU guest agent installed (qemu-guest-agent package)"
echo ""
echo "3. After installation completes, shutdown VM"
echo ""
echo "4. Convert to template:"
echo "   proxmox_api POST \"/nodes/$PROXMOX_NODE/qemu/$VM_ID/template\""
echo ""
echo "Or use the helper script: scripts/install-and-template-debian12.sh"
