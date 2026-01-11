# How to Enable Docker

This guide explains how to enable Docker on VMs, with different approaches for lab and production environments.

## Overview

Docker is managed via the `docker` role, which is:
- **Disabled by default** (safe)
- **Enabled via variable** (`docker_enabled: true`)
- **Environment-aware** (lab vs prod)

## Environment Behavior

### Lab Environment

**Default**: Docker is **enabled** in lab
- File: `ansible/group_vars/lab.yml`
- `docker_enabled: true`
- More permissive for testing

### Production Environment

**Default**: Docker is **disabled** in prod
- File: `ansible/group_vars/prod.yml`
- `docker_enabled: false`
- Conservative defaults

## Method 1: Enable Docker for All VMs in an Environment

### For Lab Environment

Docker is already enabled by default in `ansible/group_vars/lab.yml`:

```yaml
docker_enabled: true
docker_users:
  - "admin"
```

No changes needed. Run the playbook:

```bash
ansible-playbook -i ansible/inventory.yml ansible/playbooks/vm-base.yml --limit vms --extra-vars "env=lab"
```

### For Production Environment

Edit `ansible/group_vars/prod.yml`:

```yaml
docker_enabled: true
docker_users:
  - "admin"  # Replace with actual username
```

Then run:

```bash
ansible-playbook -i ansible/inventory.yml ansible/playbooks/vm-base.yml --limit vms --extra-vars "env=prod"
```

## Method 2: Enable Docker for Specific VMs

### Using Host Variables in Inventory

Edit `ansible/inventory.yml`:

```yaml
all:
  children:
    vms:
      hosts:
        my_vm:
          ansible_host: "<vm_ip>"
          docker_enabled: true
          docker_users:
            - "admin"
```

Then run:

```bash
ansible-playbook -i ansible/inventory.yml ansible/playbooks/vm-base.yml --limit my_vm
```

### Using Extra Variables

Run with extra variables (overrides group vars):

```bash
ansible-playbook -i ansible/inventory.yml ansible/playbooks/vm-base.yml \
  --limit my_vm \
  --extra-vars "docker_enabled=true docker_users=['admin']"
```

## Method 3: Enable Docker for a Group of VMs

### Create a Custom Group

Edit `ansible/inventory.yml`:

```yaml
all:
  children:
    vms:
      children:
        docker_vms:
          hosts:
            vm1:
              ansible_host: "<vm1_ip>"
            vm2:
              ansible_host: "<vm2_ip>"
          vars:
            docker_enabled: true
            docker_users:
              - "admin"
```

Then run:

```bash
ansible-playbook -i ansible/inventory.yml ansible/playbooks/vm-base.yml --limit docker_vms
```

## Verification Steps

### 1. Check Docker Installation

```bash
ansible -i ansible/inventory.yml <vm_name> -a "docker --version"
```

**Expected output**: Docker version information

### 2. Check Docker Service

```bash
ansible -i ansible/inventory.yml <vm_name> -a "systemctl status docker"
```

**Expected**: Service is `active (running)`

### 3. Test Docker as User

If you added users to `docker_users`, test Docker access:

```bash
ssh admin@<vm_ip>
docker ps
```

**Expected**: No permission errors (user can run Docker without sudo)

### 4. Verify docker-compose Plugin

```bash
ansible -i ansible/inventory.yml <vm_name> -a "docker compose version"
```

**Expected**: docker-compose version information

## Adding Users to Docker Group

### Update Configuration

Edit the appropriate file:
- `ansible/group_vars/lab.yml` (for lab)
- `ansible/group_vars/prod.yml` (for prod)
- Or use host/group vars in inventory

```yaml
docker_users:
  - "admin"
  - "deploy_user"  # Add additional users
```

### Apply Changes

```bash
ansible-playbook -i ansible/inventory.yml ansible/playbooks/vm-base.yml --limit <vm_or_group>
```

The role will add users to the `docker` group. Users may need to log out and back in for group changes to take effect.

## Disabling Docker

### For Specific VM

Set `docker_enabled: false` in inventory:

```yaml
my_vm:
  ansible_host: "<vm_ip>"
  docker_enabled: false
```

### For Environment

Edit environment file:
- `ansible/group_vars/lab.yml`: Set `docker_enabled: false`
- `ansible/group_vars/prod.yml`: Already `false` by default

**Note**: Disabling Docker does not uninstall it. To remove Docker, you would need a separate task (not included in this role).

## Troubleshooting

### Docker Not Installed

1. **Check variable**: Ensure `docker_enabled: true` is set
2. **Check playbook run**: Verify playbook completed successfully
3. **Check logs**: Review Ansible output for errors

### User Cannot Run Docker

1. **Verify user in group**: `groups` command should show `docker`
2. **Log out and back in**: Group changes require new session
3. **Check docker_users**: Ensure user is in `docker_users` list

### docker-compose Not Found

1. **Verify plugin installed**: Check `docker compose version`
2. **Check package**: Ensure `docker-compose-plugin` was installed
3. **Re-run playbook**: May need to reapply configuration

## Best Practices

- **Lab**: Enable Docker freely for testing
- **Production**: Enable Docker only when needed
- **Users**: Add only necessary users to docker group
- **Verification**: Always verify after enabling Docker
- **Documentation**: Document which VMs have Docker enabled and why

