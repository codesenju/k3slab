# Remote Access to k3s

## Configure Local Machine

### 1. Copy kubeconfig from Server

On your k3s server:
```bash
cat /etc/rancher/k3s/k3s.yaml
```

### 2. Save Locally

```bash
mkdir -p ~/.kube
nano ~/.kube/config
```

Update the `server` line:
```yaml
server: https://your-k3s-server-ip:6443
```

### 3. Test Connection

```bash
kubectl get nodes
```

## Using SSH Tunnel (Alternative)

```bash
ssh -L 6443:localhost:6443 user@your-k3s-server
```

Then use `127.0.0.1` in kubeconfig.

## Dashboard Access

### k9s (Terminal UI)

```bash
brew install k9s  # macOS
# or
sudo apt install k9s  # Linux

k9s
```

### Lens (GUI)

Download from: https://k8slens.dev

## Security Best Practices

1. **Don't expose API server to internet**
2. **Use VPN or SSH tunnel**
3. **Configure RBAC properly**
4. **Rotate tokens regularly**

## Next Steps

- [k3s Architecture](./05-architecture.md)
