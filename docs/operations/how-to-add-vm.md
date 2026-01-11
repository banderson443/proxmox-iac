# How to Add a VM

This guide walks through the complete process of adding a new VM to the infrastructure.

## Prerequisites

- Terraform initialized and configured
- Proxmox API access configured
- SSH keys available for cloud-init
- Ansible inventory file (`ansible/inventory.yml`) exists

## Step 1: Add VM to Terraform

### 1.1 Edit Terraform Configuration

Open `terraform/main.tf` and add a new VM resource:

```hcl
resource "proxmox_vm_qemu" "my_new_vm" {
  name        = "my-new-vm"
  target_node = var.proxmox_node
  clone       = var.base_template

  # VM compute resources
  cores   = var.vm_default_cores
  sockets = var.vm_default_sockets
  cpu     = "host"
  memory  = var.vm_default_memory

  # VM storage
  disk {
    storage = var.vm_default_storage
    type    = "scsi"
    size    = var.vm_default_disk_size
  }

  # Network configuration
  network {
    model  = "virtio"
    bridge = var.vm_default_bridge
  }

  # Cloud-init configuration
  agent    = 1
  os_type  = "cloud-init"
  ciuser   = var.cloudinit_user
  sshkeys  = join("\n", var.cloudinit_ssh_keys)
  ipconfig0 = "ip=dhcp"
}
```

### 1.2 Add VM to Terraform Outputs

Update `terraform/main.tf` outputs section:

```hcl
output "vms" {
  value = {
    example_vm = {
      name        = proxmox_vm_qemu.example_vm.name
      ssh_user    = var.cloudinit_user
      ansible_host = "<replace_with_vm_ip_or_use_proxmox_api>"
    }
    my_new_vm = {
      name        = proxmox_vm_qemu.my_new_vm.name
      ssh_user    = var.cloudinit_user
      ansible_host = "<replace_with_vm_ip_or_use_proxmox_api>"
    }
  }
}
```

**Note**: Replace `<replace_with_vm_ip_or_use_proxmox_api>` with actual IP after VM is created, or use Proxmox API for discovery.

## Step 2: Apply Terraform

### 2.1 Review Changes

```bash
cd terraform
terraform plan
```

Review the plan to ensure:
- VM name is correct
- Resource allocation is appropriate
- No unintended changes

### 2.2 Apply Changes

```bash
terraform apply
```

Confirm when prompted. Terraform will:
- Create the VM from template
- Configure cloud-init
- Inject SSH keys
- Start the VM

## Step 3: Verify cloud-init

### 3.1 Wait for VM Boot

Wait 1-2 minutes for the VM to:
- Boot completely
- Run cloud-init
- Configure network (DHCP)
- Create user account
- Inject SSH keys

### 3.2 Discover VM IP Address

**Option A: Proxmox Web UI**
- Navigate to Proxmox web interface
- Find the VM in the node
- Check network configuration or console

**Option B: Proxmox API**
- Use Proxmox API to query VM network information
- See `ansible/inventory/terraform.py` for example

**Option C: DHCP Server Logs**
- Check DHCP server logs for new lease
- Match by MAC address if known

### 3.3 Test SSH Access

```bash
ssh -i ~/.ssh/your_key admin@<vm_ip_address>
```

Replace:
- `~/.ssh/your_key` with your private key path
- `<vm_ip_address>` with the VM's IP address
- `admin` with the `cloudinit_user` value from Terraform

**Expected**: You should be able to SSH into the VM without password.

## Step 4: Add VM to Ansible Inventory

### Option A: Static Inventory (Recommended)

Edit `ansible/inventory.yml`:

```yaml
all:
  children:
    vms:
      hosts:
        my_new_vm:
          ansible_host: "<vm_ip_address>"
```

**Note**: Use the same username as `cloudinit_user` from Terraform (default: `admin`).

### Option B: Dynamic Inventory (Terraform Output)

If using dynamic inventory:

1. Update Terraform outputs with actual IP:
   ```hcl
   my_new_vm = {
     name        = proxmox_vm_qemu.my_new_vm.name
     ssh_user    = var.cloudinit_user
     ansible_host = "192.168.1.100"  # Actual IP
   }
   ```

2. Verify dynamic inventory:
   ```bash
   ansible-inventory -i ansible/inventory/terraform.py --list
   ```

## Step 5: Run Base Configuration

### 5.1 Test Ansible Connectivity

```bash
ansible -i ansible/inventory.yml my_new_vm -m ping
```

**Expected**: `SUCCESS` response.

### 5.2 Apply Base Configuration

```bash
ansible-playbook -i ansible/inventory.yml ansible/playbooks/vm-base.yml --limit my_new_vm
```

This will:
- Install base packages
- Configure timezone
- Enable qemu-guest-agent
- Apply basic SSH safety

### 5.3 Verify Configuration

```bash
ansible -i ansible/inventory.yml my_new_vm -a "docker --version"  # If Docker enabled
ansible -i ansible/inventory.yml my_new_vm -a "systemctl status qemu-guest-agent"
```

## Troubleshooting

### VM Not Accessible via SSH

1. **Check VM status in Proxmox**: Ensure VM is running
2. **Verify cloud-init completed**: Check VM console for errors
3. **Verify SSH keys**: Ensure keys were injected correctly
4. **Check network**: Verify VM received IP address via DHCP
5. **Check firewall**: Ensure no firewall blocking SSH

### Ansible Cannot Connect

1. **Verify IP address**: Ensure `ansible_host` is correct
2. **Test SSH manually**: `ssh admin@<vm_ip>`
3. **Check username**: Ensure `ansible_user` matches `cloudinit_user`
4. **Verify SSH key**: Ensure your SSH key is in `cloudinit_ssh_keys` in Terraform

### cloud-init Not Running

1. **Check VM console**: Look for cloud-init errors
2. **Verify template**: Ensure base template has cloud-init installed
3. **Check Proxmox logs**: Review Proxmox host logs for issues

## Next Steps

After base configuration:
- Enable optional services (Docker, etc.) via `group_vars`
- Add application-specific configuration
- Add VM to monitoring
- Document VM purpose and configuration

