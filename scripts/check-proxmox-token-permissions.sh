#!/bin/bash
# Check Proxmox API token permissions
# Helps identify missing permissions for Terraform

set -e

PROXMOX_HOST="${PROXMOX_HOST:-192.168.150.75}"
PROXMOX_API_URL="${PROXMOX_API_URL:-https://${PROXMOX_HOST}:8006/api2/json}"

if [ -z "$PROXMOX_API_TOKEN_ID" ] || [ -z "$PROXMOX_API_TOKEN_SECRET" ]; then
    if [ -n "$TF_VAR_proxmox_api_token_id" ] && [ -n "$TF_VAR_proxmox_api_token_secret" ]; then
        PROXMOX_API_TOKEN_ID="$TF_VAR_proxmox_api_token_id"
        PROXMOX_API_TOKEN_SECRET="$TF_VAR_proxmox_api_token_secret"
    else
        echo "Error: PROXMOX_API_TOKEN_ID and PROXMOX_API_TOKEN_SECRET must be set"
        echo "Or set TF_VAR_proxmox_api_token_id and TF_VAR_proxmox_api_token_secret"
        exit 1
    fi
fi

echo "Checking Proxmox API token permissions..."
echo "Token ID: $PROXMOX_API_TOKEN_ID"
echo "API URL: $PROXMOX_API_URL"
echo ""

# Test API connection
echo "Testing API connection..."
RESPONSE=$(curl -s -k -X GET \
    -H "Authorization: PVEAPIToken=$PROXMOX_API_TOKEN_ID=$PROXMOX_API_TOKEN_SECRET" \
    "$PROXMOX_API_URL/version" 2>&1)

if echo "$RESPONSE" | grep -q "401\|Unauthorized"; then
    echo "ERROR: Authentication failed. Check token ID and secret."
    exit 1
elif echo "$RESPONSE" | grep -q "403\|Forbidden"; then
    echo "ERROR: Token exists but lacks permissions."
    exit 1
elif echo "$RESPONSE" | grep -q "version"; then
    echo "✓ API connection successful"
else
    echo "WARNING: Unexpected response. Token may have issues."
    echo "Response: $RESPONSE"
fi

echo ""
echo "Required permissions for Terraform:"
echo "  - VM.Allocate"
echo "  - VM.Clone"
echo "  - VM.Config.Disk"
echo "  - VM.Config.Network"
echo "  - VM.Config.Options"
echo "  - VM.Monitor (CRITICAL - often missing)"
echo "  - VM.PowerMgmt"
echo "  - Datastore.Allocate"
echo "  - Datastore.AllocateSpace"
echo ""
echo "To add missing permissions:"
echo "1. Login to Proxmox Web UI: https://$PROXMOX_HOST:8006"
echo "2. Go to: Datacenter → Permissions → API Tokens"
echo "3. Find token: $PROXMOX_API_TOKEN_ID"
echo "4. Edit token and add missing permissions (especially VM.Monitor)"
echo "5. Or assign a role with all required permissions"
echo ""
echo "See docs/terraform-proxmox-api-token.md for detailed instructions."

