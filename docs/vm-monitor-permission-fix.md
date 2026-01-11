# VM.Monitor Permission Fix

## Probleem

Terraform provider nõuab `VM.Monitor` õigust, aga see ei ole Proxmox CLI-s kehtiv privilege nimi.

## Lahendus

`VM.Monitor` õigus tuleb lisada **Proxmox Web UI kaudu**, kuna see ei ole CLI kaudu seadistatav.

## Sammud

1. **Ava Proxmox Web UI:**
   - URL: `https://192.168.150.75:8006`
   - Logi sisse

2. **Mine API Token'ite juurde:**
   - **Datacenter** → **Permissions** → **API Tokens**
   - Leia token: `root@pam!terraform`

3. **Lisa VM.Monitor õigus:**
   - Kliki token'i peale
   - **Permissions** sektsioonis:
     - **Path**: `/`
     - **Role**: Vali **Administrator** (sisaldab kõiki õigusi)
     - Või lisa käsitsi: **VM.Monitor** privilege
   - Salvesta

4. **Testi:**
   ```bash
   cd terraform
   export TF_VAR_proxmox_api_token_id='root@pam!terraform'
   export TF_VAR_proxmox_api_token_secret='b5ea4bb6-b8c7-4472-9b85-86c248631297'
   export TF_VAR_proxmox_api_url='https://192.168.150.75:8006/api2/json'
   export TF_VAR_proxmox_node='proxmox'
   terraform plan
   ```

## Märkused

- `VM.Monitor` ei ole Proxmox CLI-s (`pveum`) kehtiv privilege
- See on Proxmox 9.1 uus nõue või Terraform provider'i spetsiifiline nõue
- Administrator roll peaks sisaldama kõiki õigusi, sealhulgas VM.Monitor
- Kui probleem püsib, võib olla Terraform provider'i bug

## Alternatiivne lahendus

Kui Web UI kaudu ei saa, võib olla vaja:
- Uuendada Terraform provider'i uusimasse versiooni
- Või kasutada mõnda teist provider'i seadet

