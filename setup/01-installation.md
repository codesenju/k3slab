# k3s Installation Guide

## Quick Install (One-Liner)

The fastest way to install k3s:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
```

## Installation Options

### Option 1: Single Node (Development)

```bash
curl -sfL https://get.k3s.io | sh -
```

### Option 2: With Traefik (Default Ingress)

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
```

### Option 3: Without Traefik

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --disable=traefik" sh -
```

### Option 4: With Specific Version

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.0+k3s1 sh -
```

## Post-Installation

### 1. Check Cluster Status

```bash
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A
```

### 2. Configure kubectl

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
sed -i 's|127.0.0.1|your-server-ip|g' ~/.kube/config
```

### 3. Install kubectl Locally (Optional)

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

## Uninstall

```bash
/usr/local/bin/k3s-uninstall.sh
```

## Upgrade

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
```

## Troubleshooting

### Check Logs

```bash
sudo journalctl -u k3s -f
```

### Check Running Processes

```bash
sudo k3s check-config
```

## Next Steps

- [Health Checks](./02-healthchecks.md)
- [Remote Access](./03-remote-access.md)
