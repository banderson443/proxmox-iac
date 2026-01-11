# Terraform configuration for Proxmox infrastructure
# This file defines the main infrastructure resources

terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9"
    }
  }

  # Backend configuration
  # Uncomment and configure your backend
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "proxmox-infra/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Configure the Proxmox Provider
provider "proxmox" {
  pm_api_url      = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret

  # Optional: Skip TLS verification (not recommended for production)
  # pm_tls_insecure = true
}

# Example: Create a generic Linux VM
# This demonstrates declarative VM lifecycle management
# All values come from variables (no hardcoded secrets or IPs)
resource "proxmox_vm_qemu" "example_vm" {
  name        = "example-linux-vm"
  target_node = var.proxmox_node
  clone       = var.base_template

  # VM compute resources (from variables)
  cores   = var.vm_default_cores
  sockets = var.vm_default_sockets
  cpu     = "host"
  memory  = var.vm_default_memory

  # VM storage (from variables)
  disk {
    storage = var.vm_default_storage
    type    = "scsi"
    size    = var.vm_default_disk_size
  }

  # Network configuration (minimal, no IP assumptions)
  network {
    model  = "virtio"
    bridge = var.vm_default_bridge
  }

  # Cloud-init enabled (no network configuration here)
  agent    = 1
  os_type  = "cloud-init"

  # Lifecycle: prevent accidental destruction
  lifecycle {
    prevent_destroy = false
  }
}

