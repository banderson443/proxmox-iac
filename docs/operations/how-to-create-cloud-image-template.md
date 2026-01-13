# How to Create a Cloud Image Template

This guide explains how to create a VM template from a cloud image (recommended method for automation).

## Why Cloud Images

Cloud images are pre-configured OS images designed for cloud-init:
- Pre-installed cloud-init support
- Minimal base installation
- Optimized for cloning
- Faster than ISO installation
- Consistent across environments

**Recommended for production use.**

## Prerequisites

- Proxmox host access (SSH as root)
- Storage pool configured (see )
- Downloaded cloud image (see sources below)

## Cloud Image Sources

### Debian (Recommended)


### Ubuntu


### Other Distributions
- Rocky Linux: https://rockylinux.org/cloud-images/
- AlmaLinux: https://almalinux.org/get-almalinux/
- Fedora Cloud: https://fedoraproject.org/cloud/

## Step 1: Download Cloud Image

SSH to your Proxmox host:



Download the cloud image to appropriate storage location:



Verify download:


## Step 2: Create VM Shell

Create a new VM (ID 9000 is standard for templates):



## Step 3: Import Cloud Image as Disk

Import the qcow2 image to your storage:



This creates  in your storage.

## Step 4: Attach Disk and Configure VM

Attach the imported disk:


Add cloud-init drive:


Configure boot order:


Enable serial console (helps with troubleshooting):


Enable QEMU guest agent:


## Step 5: Set Cloud-Init Default User

**CRITICAL**: Set the default cloud-init user to match the OS:



**Why this matters**: Cloud images have default users built-in. Debian uses , Ubuntu uses . Terraforms cloudinit_user variable must match this.
