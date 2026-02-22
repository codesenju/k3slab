# k3s Installation Guide

In this guide, you'll install k3s - a lightweight Kubernetes distribution - on your machine.

## What You'll Learn

- ✅ Install k3s using the official installer
- ✅ Configure kubectl for local access
- ✅ Verify your cluster is working
- ✅ Understand what gets installed

## Prerequisites

Before installing, make sure you have:

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| CPU | 1 core | 2+ cores |
| RAM | 512MB | 2GB+ |
| Disk | 5GB free | 20GB+ free |
| OS | Ubuntu 20.04+ / Debian 11+ / RHEL 8+ | Same |

## Quick Install (Recommended)

The fastest way to install k3s:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
```

Let's break down what this does:

| Part | Meaning |
|------|---------|
| `curl -sfL` | Download installer script silently |
| `INSTALL_K3S_EXEC` | Pass options to k3s |
| `--write-kubeconfig-mode 644` | Make config readable |

## Installation Options

### Option 1: Default Installation

Includes Traefik (ingress controller) and Local Path Provisioner (storage):

```bash
curl -sfL https://get.k3s.io | sh -
```

### Option 2: Without Traefik

If you want to install your own ingress controller:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
```

### Option 3: Specific Version

Install a specific k3s version:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.0+k3s1 sh -
```

### Option 4: With Custom Network

```bash
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --cluster-cidr=10.42.0.0/16 --service-cidr=10.43.0.0/16" \
  sh -
```

## Post-Installation

### 1. Verify Installation

Check that your node is running:

```bash
sudo k3s kubectl get nodes
```

Expected output:
```
NAME          STATUS   ROLES           AGE   VERSION
workstation   Ready    control-plane   30s   v1.34.4+k3s1
```

### 2. Check System Pods

```bash
sudo k3s kubectl get pods -A
```

You should see these system components:
- **coredns** - DNS resolution
- **local-path-provisioner** - Storage (included with k3s)
- **metrics-server** - Resource metrics
- **traefik** - Ingress controller

### 3. Configure kubectl

Set up kubectl for non-root access:

```bash
# Create .kube directory
mkdir -p ~/.kube

# Copy k3s config
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

# Fix permissions
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config

# Test it
export KUBECONFIG=~/.kube/config
kubectl get nodes
```

To make this permanent, add to your shell:

```bash
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

### 4. Install kubectl Locally (Optional)

For a standalone kubectl command:

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify
kubectl version --client
```

## Understanding What Gets Installed

k3s includes everything needed for Kubernetes:

```
┌─────────────────────────────────────────────┐
│              k3s Binary                     │
├─────────────────────────────────────────────┤
│  ✓ API Server                              │
│  ✓ Scheduler                               │
│  ✓ Controller Manager                      │
│  ✓ etcd (embedded SQLite)                 │
│  ✓ Container Runtime (containerd)          │
│  ✓ CNI (Flannel)                          │
│  ✓ Traefik (Ingress)                     │
│  ✓ Service LB (Klipper)                   │
│  ✓ Local Path Provisioner                  │
│  ✓ Metrics Server                         │
└─────────────────────────────────────────────┘
```

## Uninstall

If you need to remove k3s:

```bash
# On the server
/usr/local/bin/k3s-uninstall.sh

# On agents only
/usr/local/bin/k3s-agent-uninstall.sh
```

## Upgrade k3s

To upgrade to the latest version:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
```

Or a specific version:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.0+k3s1 sh -
```

## Troubleshooting

### Check Service Status

```bash
sudo systemctl status k3s
sudo journalctl -u k3s -f
```

### Verify Configuration

```bash
sudo k3s check-config
```

### Common Issues

**Installation hangs**
- Check internet connection
- Ensure port 6443 is not in use

**Pods not starting**
- Run: `sudo k3s kubectl get pods -A`
- Check logs: `sudo journalctl -u k3s -n 50`

## Next Steps

Now that k3s is installed:

1. [Verify cluster health](./02-healthchecks.md)
2. [Configure remote access](./03-remote-access.md)
3. [Deploy your first app](./04-first-app.md)
4. [Set up NFS storage](./06-nfs-server.md)

## Commands Summary

```bash
# Check nodes
kubectl get nodes

# Check all pods
kubectl get pods -A

# Check system services
sudo systemctl status k3s

# View logs
sudo journalctl -u k3s -f

# Uninstall
/usr/local/bin/k3s-uninstall.sh
```
