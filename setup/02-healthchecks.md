# k3s Health Checks

## Verify Your Cluster is Healthy

### 1. Check Node Status

```bash
kubectl get nodes
```

Expected output:
```
NAME          STATUS   ROLES           AGE   VERSION
k3s-server   Ready    control-plane   10m   v1.34.4+k3s1
```

### 2. Check System Pods

```bash
kubectl get pods -A
```

Expected system pods:
- `coredns-*` - DNS resolution
- `local-path-provisioner-*` - Storage
- `metrics-server-*` - Metrics collection
- `traefik-*` - Ingress controller (if enabled)

### 3. Check Component Status

```bash
kubectl get componentstatuses
```

Or (newer k8s):
```bash
kubectl get --raw='/healthz'
```

### 4. Check Resource Usage

```bash
kubectl top nodes
kubectl top pods -A
```

### 5. Check Logs

```bash
kubectl logs -n kube-system -l k8s-app=kube-proxy
kubectl logs -n kube-system -l k8s-app=kube-dns
```

## Common Issues

### Node Not Ready

```bash
kubectl describe node <node-name>
```

Check for:
- Disk pressure
- Memory pressure
- PID pressure
- Network issues

### Pods Not Starting

```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

## Monitoring Scripts

Create `health-check.sh`:

```bash
#!/bin/bash
echo "=== k3s Health Check ==="

echo -e "\n[1] Node Status:"
kubectl get nodes

echo -e "\n[2] System Pods:"
kubectl get pods -A -l k8s-app=kube-dns

echo -e "\n[3] CoreDNS:"
kubectl get pods -n kube-system -l k8s-app=kube-dns

echo -e "\n[4] Metrics Server:"
kubectl get pods -n kube-system -l k8s-app=metrics-server

echo -e "\n[5] API Server Health:"
kubectl get --raw='/healthz' && echo "OK" || echo "FAILED"

echo -e "\n[6] etcd Health:"
kubectl get --raw='/healthz/etcd' && echo "OK" || echo "FAILED"

echo -e "\n=== Done ==="
```

Make it executable:
```bash
chmod +x health-check.sh
```

## Next Steps

- [Remote Access](./03-remote-access.md)
- [First Application](./04-first-app.md)
