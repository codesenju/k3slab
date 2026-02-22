# Remote Access to k3s

In this guide, you'll configure kubectl to access your k3s cluster from your local machine.

## What You'll Learn

- ✅ Configure kubectl for single-node access
- ✅ Install kubectl on your local machine
- ✅ Use graphical tools (k9s, Lens)
- ✅ Set up SSH tunneling

## Quick Setup (Single VM)

For a single VM running k3s locally, use this simple setup:

```bash
# Configure kubectl
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
chmod 600 ~/.kube/config

# Test connection
export KUBECONFIG=~/.kube/config
kubectl get nodes
```

## Configure kubectl

### Option 1: Local Machine Access

If accessing k3s from another machine:

```bash
# On the k3s server, copy the config
cat /etc/rancher/k3s/k3s.yaml

# Save to your local ~/.kube/config
```

Update the server address:

```yaml
# Change this:
server: https://127.0.0.1:6443

# To your server's IP:
server: https://192.168.1.100:6443
```

### Option 2: SSH Tunnel

For security, use SSH tunneling:

```bash
# Create SSH tunnel
ssh -L 6443:localhost:6443 user@your-k3s-server

# In another terminal, use localhost
export KUBECONFIG=~/.kube/config
sed -i 's|https://.*:6443|https://127.0.0.1:6443|g' ~/.kube/config
kubectl get nodes
```

## Install kubectl

### Linux

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

### macOS

```bash
# Using Homebrew
brew install kubectl

# Or download
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
```

### Windows

```bash
# Using Chocolatey
choco install kubernetes-cli

# Or download from https://dl.k8s.io/release/stable.txt
```

## Access from IDE

### VS Code

1. Install "Kubernetes" extension
2. Set kubeconfig path in settings
3. Select your cluster

### IntelliJ IDEA

1. Install "Kubernetes" plugin
2. Add kubeconfig file
3. Browse clusters

## Graphical Tools

### k9s (Terminal UI)

k9s is a terminal-based Kubernetes dashboard:

```bash
# Install
brew install k9s        # macOS
sudo apt install k9s   # Linux
choco install k9s      # Windows

# Run
k9s
```

**Useful shortcuts:**
- `:` → Command mode
- `kubectl get pods` → Type commands
- `Ctrl+a` → Show all resources
- `l` → View logs
- `d` → Describe resource
- `Ctrl+c` → Quit

### Lens (Desktop App)

Lens provides a graphical interface:

1. Download from https://k8slens.dev
2. Install and launch
3. Add kubeconfig
4. Browse your cluster

### Headlamp

A modern Kubernetes dashboard:

```bash
# Install via Helm
helm repo add headlamp https://headlamp-k8s.github.io/headlamp/helm-charts
helm install headlamp headlamp/headlamp -n headlamp

# Access
kubectl port-forward -n headlamp svc/headlamp 8080:80
```

Open http://localhost:8080

## Security Best Practices

### 1. Protect Your Kubeconfig

```bash
# Set restrictive permissions
chmod 600 ~/.kube/config

# Never commit to git
echo "*.kubeconfig" >> ~/.gitignore
```

### 2. Use RBAC

Create limited user accounts:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: developer
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "deployments"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
subjects:
- kind: ServiceAccount
  name: developer
roleRef:
  kind: Role
  name: developer-role
```

### 3. Don't Expose to Internet

- Use VPN for remote access
- Use SSH tunneling
- Use kubectl proxy for web UIs

## Troubleshooting

### Connection Refused

```bash
# Check if k3s is running
sudo systemctl status k3s

# Check port
sudo ss -tlnp | grep 6443
```

### Certificate Errors

```bash
# Regenerate certificates
sudo k3s cert rotate

# Or update kubeconfig
sudo k3s kubectl config view --flatten > ~/.kube/config
```

### Timeout Errors

```bash
# Check firewall
sudo ufw status

# Check network
ping your-k3s-server
telnet your-k3s-server 6443
```

## Next Steps

- [Deploy your first app](./04-first-app.md)
- [Understand k3s architecture](./05-architecture.md)
- [Set up NFS storage](./06-nfs-server.md)

## Commands Summary

```bash
# Configure kubectl
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

# Set environment
export KUBECONFIG=~/.kube/config

# Test
kubectl get nodes

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```
