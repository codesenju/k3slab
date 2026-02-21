# k3s Ansible Playbooks

This directory contains Ansible playbooks to install and configure k3s clusters.

## Quick Start

```bash
# Install k3s on all hosts
ansible-playbook -i inventory.ini install-k3s.yaml

# Deploy addons via ArgoCD
ansible-playbook -i inventory.ini addons.yaml

# Or deploy specific addon
ansible-playbook -i inventory.ini addons/argocd.yaml
```

## Directory Structure

```
ansible/
├── inventory.ini          # Inventory file
├── install-k3s.yaml       # Main k3s installation
├── addons.yaml            # Deploy all addons
├── addons/                # Individual addon playbooks
├── vars/                  # Variables
└── manifests/             # ArgoCD Application manifests
```

## Inventory

Edit `inventory.ini` to match your setup:

```ini
[k3s-master]
k3s-01 ansible_host=192.168.1.10 ansible_user=ubuntu

[k3s-agent]
k3s-02 ansible_host=192.168.1.11 ansible_user=ubuntu
k3s-03 ansible_host=192.168.1.12 ansible_user=ubuntu

[k3s:children]
k3s-master
k3s-agent
```

## Variables

Set variables in `vars/main.yaml` or `group_vars/all.yaml`:

```yaml
k3s_version: v1.34.4+k3s1
k3s_token: your-secure-token
k3s_install_flags:
  - --write-kubeconfig-mode 644
  - --cluster-cidr=10.42.0.0/16
  - --service-cidr=10.43.0.0/16
```

## Requirements

- Ansible 2.9+
- SSH access to target nodes
- sudo privileges
