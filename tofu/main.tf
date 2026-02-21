# OpenTofu Configuration for k3s on Proxmox

This directory contains OpenTofu configurations to provision a k3s cluster on Proxmox.

## Requirements

- OpenTofu or Terraform >= 1.0
- Proxmox VE access
- SSH key

## Directory Structure

```
tofu/
├── main.tf
├── variables.tf
├── outputs.tf
├── scripts/
│   └── install-k3s.sh
└── README.md
```

## variables.tf

```hcl
variable "proxmox_host" {
  description = "Proxmox host IP"
  type        = string
  default     = "192.168.1.100"
}

variable "proxmox_user" {
  description = "Proxmox user"
  type        = string
  default     = "root@pam"
}

variable "vm_template" {
  description = "VM template ID"
  type        = string
  default     = "ubuntu-2204-cloudinit"
}

variable "k3s_version" {
  description = "k3s version to install"
  type        = string
  default     = "v1.34.4+k3s1"
}

variable "k3s_nodes" {
  description = "k3s cluster nodes"
  type = list(object({
    name       = string
    ip         = string
    cpu_cores  = number
    memory_mb  = number
    disk_gb    = number
    is_master  = bool
  }))
  default = [
    {
      name      = "k3s-master"
      ip        = "192.168.1.10"
      cpu_cores = 2
      memory_mb = 2048
      disk_gb   = 20
      is_master = true
    },
    {
      name      = "k3s-agent-1"
      ip        = "192.168.1.11"
      cpu_cores = 2
      memory_mb = 2048
      disk_gb   = 30
      is_master = false
    }
  ]
}
```

## main.tf

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.proxmox_host}:8006/api2/json"
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = true
}

# VM resource for each k3s node
resource "proxmox_vm_qemu" "k3s_node" {
  count = length(var.k3s_nodes)
  
  name        = var.k3s_nodes[count.index].name
  target_node = var.proxmox_node
  
  clone       = var.vm_template
  cores       = var.k3s_nodes[count.index].cpu_cores
  memory      = var.k3s_nodes[count.index].memory_mb
  disk {
    size        = "${var.k3s_nodes[count.index].disk_gb}G"
    storage     = "local-lvm"
  }
  
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  ipconfig0 = "ip=${var.k3s_nodes[count.index].ip}/24,gw=192.168.1.1"
  
  sshkeys = file("~/.ssh/id_rsa.pub")
  
  provisioner "remote-exec" {
    inline = var.k3s_nodes[count.index].is_master ? <<-EOF
      curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
    EOF
    : <<-EOF
      curl -sfL https://get.k3s.io | K3S_URL=https://${var.k3s_nodes[0].ip}:6443 K3S_TOKEN=${proxmox_vm_qemu.k3s_node[0].k3s_token} sh -
    EOF
  }
}

# Output the k3s kubeconfig
output "kubeconfig" {
  value     = proxmox_vm_qemu.k3s_node[0].kubeconfig
  sensitive = true
}
```

## scripts/cloud-init.yml

```yaml
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB...

packages:
  - curl
  - wget
  - git

runcmd:
  - curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
```

## Usage

```bash
# Initialize
tofu init

# Plan
tofu plan

# Apply
tofu apply

# Destroy
tofu destroy
```

## Proxmox Provider Setup

```bash
export PROXMOX_VE_PASSWORD="your-password"
tofu apply
```

## Note

For production, consider using:
- External database for etcd
- Multiple master nodes for HA
- Separate network segments
