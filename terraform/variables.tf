# Variable definitions for Terraform Proxmox configuration

variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://proxmox.example.com:8006/api2/json)"
  type        = string
  # Set via environment variable TF_VAR_proxmox_api_url or terraform.tfvars
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID (e.g., root@pam!terraform)"
  type        = string
  sensitive   = true
  # Set via environment variable TF_VAR_proxmox_api_token_id or terraform.tfvars
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
  # Set via environment variable TF_VAR_proxmox_api_token_secret or terraform.tfvars
}

variable "proxmox_node" {
  description = "Proxmox node name where resources will be created"
  type        = string
  default     = "pve"
}

variable "base_template" {
  description = "Base VM template to clone from (must exist in Proxmox)"
  type        = string
  default     = "ubuntu-cloud-template"
}

# VM default configuration
variable "vm_default_cores" {
  description = "Default number of CPU cores per VM"
  type        = number
  default     = 2
}

variable "vm_default_sockets" {
  description = "Default number of CPU sockets per VM"
  type        = number
  default     = 1
}

variable "vm_default_memory" {
  description = "Default memory allocation per VM (in MB)"
  type        = number
  default     = 2048
}

variable "vm_default_disk_size" {
  description = "Default disk size per VM (e.g., '20G', '50G')"
  type        = string
  default     = "20G"
}

variable "vm_default_storage" {
  description = "Default storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "vm_default_bridge" {
  description = "Default network bridge for VM network interfaces"
  type        = string
  default     = "vmbr0"
}

# Cloud-init configuration for VM bootstrap
variable "cloudinit_user" {
  description = "Username for cloud-init (will be created with sudo access)"
  type        = string
  default     = "admin"
}

variable "cloudinit_ssh_keys" {
  description = "List of SSH public keys to inject via cloud-init (enables Ansible access)"
  type        = list(string)
  default = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAExampleKey1 comment@example",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQExampleKey2 comment@example"
  ]
}

