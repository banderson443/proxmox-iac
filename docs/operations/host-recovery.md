# Host Recovery Procedures

This guide covers recovery procedures for Proxmox hosts, focusing on SSH access recovery and safe rollback procedures.

## Overview

Proxmox hosts are hardened with SSH key-only access. This guide helps recover access if:
- SSH keys are lost or compromised
- SSH hardening needs to be rolled back
- Console access is needed for recovery

## Recovery Methods

### Method 1: Console Access (Physical/Remote)

**When to use**: SSH is completely locked out, no network access available.

**Steps**:

1. **Access Proxmox Console**
   - Physical: Connect keyboard/monitor to host
   - Remote: Use Proxmox web UI → VM/Host → Console
   - IPMI/iDRAC: Use out-of-band management if available

2. **Login as Root**
   - Use root password (if still set)
   - Or use recovery mode if password is lost

3. **Verify SSH Service**
   ```bash
   systemctl status ssh
   ```

4. **Temporarily Allow Password Authentication** (if needed)
   ```bash
   sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
   systemctl restart ssh
   ```

5. **Add SSH Key**
   ```bash
   mkdir -p /root/.ssh
   echo "ssh-ed25519 AAAA... your_key_here" >> /root/.ssh/authorized_keys
   chmod 700 /root/.ssh
   chmod 600 /root/.ssh/authorized_keys
   ```

6. **Test SSH Access**
   - From another machine: `ssh root@<host_ip>`
   - Verify key-based access works

7. **Re-apply Hardening** (optional)
   - Run Ansible playbook to restore hardening
   - Or manually revert password authentication

### Method 2: Rollback SSH Hardening

**When to use**: SSH hardening is too restrictive, need to relax settings.

**Steps**:

1. **SSH into Host** (using existing access method)

2. **Edit SSH Configuration**
   ```bash
   vi /etc/ssh/sshd_config
   ```

3. **Modify Settings** (examples)
   ```bash
   # Allow password authentication temporarily
   PasswordAuthentication yes
   
   # Allow root login with password
   PermitRootLogin yes
   
   # Increase login grace time
   LoginGraceTime 60
   ```

4. **Restart SSH Service**
   ```bash
   systemctl restart ssh
   ```

5. **Test Access**
   - Verify new settings work
   - Test from multiple clients if needed

6. **Update Ansible Configuration** (if permanent change)
   - Edit `ansible/group_vars/proxmox_hosts.yml`
   - Adjust `sshd_settings` as needed
   - Re-run playbook to make permanent

### Method 3: Using Ansible to Rollback

**When to use**: Ansible access still works, need to rollback hardening.

**Steps**:

1. **Temporarily Modify Group Vars**
   
   Create temporary override file or edit `ansible/group_vars/proxmox_hosts.yml`:
   ```yaml
   sshd_settings:
     - option: PasswordAuthentication
       value: "yes"  # Temporarily allow passwords
     - option: PermitRootLogin
       value: "yes"  # Temporarily allow root login
   ```

2. **Run Playbook**
   ```bash
   ansible-playbook -i ansible/inventory.yml ansible/playbooks/proxmox-host.yml
   ```

3. **Verify Access**
   - Test password authentication
   - Test root login

4. **Restore Hardening** (when ready)
   - Revert group_vars changes
   - Re-run playbook

### Method 4: Emergency Access via Proxmox API

**When to use**: Proxmox web UI is accessible, SSH is not.

**Steps**:

1. **Access Proxmox Web UI**
   - Login to Proxmox web interface
   - Navigate to host node

2. **Use Shell/Console**
   - Proxmox web UI → Shell
   - Or use VM console if host is virtualized

3. **Follow Console Access Steps** (see Method 1)

## SSH Key Recovery

### Add New SSH Key

1. **Generate New Key** (on your workstation)
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/proxmox_recovery
   ```

2. **Add Key to Host** (via console or existing access)
   ```bash
   echo "ssh-ed25519 AAAA... recovery_key" >> /root/.ssh/authorized_keys
   chmod 600 /root/.ssh/authorized_keys
   ```

3. **Test Access**
   ```bash
   ssh -i ~/.ssh/proxmox_recovery root@<host_ip>
   ```

4. **Update Ansible Configuration**
   - Add key to `ansible/group_vars/proxmox_hosts.yml`
   - Or use Ansible Vault for sensitive keys

### Remove Compromised Key

1. **SSH into Host** (using safe key)

2. **Edit authorized_keys**
   ```bash
   vi /root/.ssh/authorized_keys
   ```

3. **Remove Compromised Key**
   - Delete the line containing the compromised key
   - Save and exit

4. **Verify Access**
   - Test remaining keys still work
   - Verify compromised key no longer works

## Safe Console Access

### Best Practices

1. **Use Read-Only Commands First**
   ```bash
   # Check status without changes
   systemctl status ssh
   cat /etc/ssh/sshd_config
   ```

2. **Backup Before Changes**
   ```bash
   cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
   ```

3. **Test Changes Incrementally**
   - Make one change at a time
   - Test after each change
   - Keep console session open until verified

4. **Document Changes**
   - Note what was changed and why
   - Update Ansible configuration to match

## Prevention

### Before Applying SSH Hardening

1. **Verify SSH Keys Exist**
   ```bash
   ansible -i ansible/inventory.yml proxmox_hosts -m stat -a 'path=/root/.ssh/authorized_keys'
   ```

2. **Test SSH Access**
   ```bash
   ansible -i ansible/inventory.yml proxmox_hosts -m ping
   ```

3. **Keep Console Access Available**
   - Ensure physical/remote console is accessible
   - Test console access before hardening

### Regular Maintenance

1. **Rotate SSH Keys Periodically**
   - See `docs/operations/ssh-key-rotation.md`

2. **Keep Backup Keys**
   - Store recovery keys securely
   - Test backup keys periodically

3. **Monitor SSH Access**
   - Review SSH logs regularly
   - Check for failed login attempts

## References

- **Recovery Plan**: `docs/recovery-plan.md` - General disaster recovery procedures
- **SSH Key Policy**: `docs/ssh-key-policy.md` - SSH key management policy
- **Architecture**: `docs/architecture.md` - SSH hardening configuration details

## Emergency Contacts

Document your emergency procedures:
- Who to contact for console access
- Where recovery keys are stored
- Escalation procedures

**Note**: Keep this information secure and accessible only to authorized personnel.

