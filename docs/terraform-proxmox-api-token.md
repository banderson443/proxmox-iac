# Proxmox API Token Setup for Terraform

Terraform requires a Proxmox API token with specific permissions to manage VMs.

## Required Permissions

Terraform needs the following permissions for the Proxmox API token:

- **VM.Allocate** - Create new VMs
- **VM.Clone** - Clone from templates
- **VM.Config.Disk** - Configure VM disks
- **VM.Config.Network** - Configure VM network interfaces
- **VM.Config.Options** - Configure VM options (cloud-init, etc.)
- **VM.Monitor** - Monitor VM status (required for state management)
- **VM.PowerMgmt** - Start/stop VMs
- **Datastore.Allocate** - Allocate storage for VMs
- **Datastore.AllocateSpace** - Allocate space on datastores

## Creating API Token in Proxmox Web UI

1. **Login to Proxmox Web UI**
   - Navigate to: `https://192.168.150.75:8006`
   - Login with your credentials

2. **Go to API Tokens**
   - Click: **Datacenter** → **Permissions** → **API Tokens**
   - Click: **Add** → **API Token**

3. **Configure Token**
   - **Token ID**: `terraform` (or your preferred name)
   - **User**: Select user (e.g., `root@pam` or create dedicated user)
   - **Expiration**: Set expiration date (or leave blank for no expiration)
   - **Privilege Separation**: Enable if you want separate permissions

4. **Set Permissions**
   - **Path**: `/` (root path for all resources)
   - **Role**: Select role with required permissions, or create custom role
   - **Or use individual permissions**:
     - Check all required permissions listed above

5. **Create Token**
   - Click **Generate** or **Add**
   - **IMPORTANT**: Copy the token secret immediately (it won't be shown again)
   - Token format: `USER@REALM!TOKEN_ID=TOKEN_SECRET`

## Using Custom Role (Recommended)

Create a custom role with only required permissions:

1. **Go to Roles**
   - **Datacenter** → **Permissions** → **Roles**
   - Click **Create**

2. **Create Role**
   - **Role ID**: `terraform-vm-manager`
   - **Privileges**: Select:
     - `VM.Allocate`
     - `VM.Clone`
     - `VM.Config.Disk`
     - `VM.Config.Network`
     - `VM.Config.Options`
     - `VM.Monitor`
     - `VM.PowerMgmt`
     - `Datastore.Allocate`
     - `Datastore.AllocateSpace`

3. **Assign Role to Token**
   - When creating API token, assign the `terraform-vm-manager` role

## Using CLI (Alternative)

If you prefer CLI, you can create token via Proxmox API or `pvesh`:

```bash
# On Proxmox host
pvesh create /access/users/terraform@pam/token/terraform \
    --privsep 0 \
    --expire 0

# Then assign permissions via role or ACL
```

## Configure Terraform

Set the token in `terraform.tfvars` (not committed to git):

```hcl
proxmox_api_url          = "https://192.168.150.75:8006/api2/json"
proxmox_api_token_id     = "root@pam!terraform"
proxmox_api_token_secret = "your-token-secret-here"
```

Or via environment variables:

```bash
export TF_VAR_proxmox_api_url="https://192.168.150.75:8006/api2/json"
export TF_VAR_proxmox_api_token_id="root@pam!terraform"
export TF_VAR_proxmox_api_token_secret="your-token-secret-here"
```

## Verify Token Permissions

Test token with Terraform:

```bash
cd terraform
terraform init
terraform plan
```

If you see `VM.Monitor` permission error, the token needs that permission added.

## Security Best Practices

- **Use dedicated user**: Create `terraform@pam` user instead of using `root@pam`
- **Minimal permissions**: Only grant permissions needed for Terraform operations
- **Token expiration**: Set expiration date for tokens
- **Rotate tokens**: Rotate tokens periodically
- **Store secrets securely**: Never commit tokens to git
- **Use environment variables**: Prefer environment variables over `terraform.tfvars` for secrets

## Troubleshooting

### Error: "permissions for user/token are not sufficient"

**Solution**: Add missing permissions to the API token role.

Common missing permissions:
- `VM.Monitor` - Required for Terraform state management
- `VM.Clone` - Required when cloning from templates
- `Datastore.Allocate` - Required for VM disk creation

### Error: "401 Unauthorized"

**Solution**: Check token ID and secret are correct.

### Error: "403 Forbidden"

**Solution**: Token exists but lacks required permissions. Add missing permissions.

