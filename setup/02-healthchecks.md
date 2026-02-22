# k3s Health Checks

In this guide, you'll learn how to verify your k3s cluster is healthy and troubleshoot common issues.

## What You'll Learn

- ✅ Check node status
- ✅ Verify system pods
- ✅ Check component health
- ✅ Monitor resource usage
- ✅ Create automated health checks

## Quick Health Check

Run this one-liner to check cluster health:

```bash
kubectl get nodes && kubectl get pods -A && kubectl get --raw='/healthz'
```

## Detailed Checks

### 1. Check Node Status

Your node is the foundation of the cluster:

```bash
kubectl get nodes
```

Expected output:
```
NAME          STATUS   ROLES           AGE   VERSION
workstation   Ready    control-plane   10m   v1.34.4+k3s1
```

**What the columns mean:**
| Column | Meaning |
|--------|---------|
| NAME | Your node's hostname |
| STATUS | Ready = healthy |
| ROLES | control-plane = master node |
| AGE | Time since installation |
| VERSION | k3s version |

### 2. Check System Pods

System pods keep Kubernetes running:

```bash
kubectl get pods -A
```

Expected system pods:

| Pod | Purpose |
|-----|---------|
| coredns-* | DNS resolution |
| local-path-provisioner-* | Storage |
| metrics-server-* | Resource metrics |
| traefik-* | Ingress controller |
| svclb-traefik-* | Load balancer |

### 3. Check Component Health

Verify core Kubernetes components are working:

```bash
kubectl get componentstatuses
```

Or use the health check endpoint:

```bash
kubectl get --raw='/healthz'
```

Expected: `{"kind":"Status","apiVersion":"v1","status":"Success"}`

### 4. Check etcd Health

```bash
kubectl get --raw='/healthz/etcd'
```

### 5. Check Resource Usage

See how much CPU and memory your cluster is using:

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -A
```

### 6. Check Network

```bash
# DNS resolution test
kubectl run dns-test --rm -it --image=busybox --restart=Never -- nslookup kubernetes.default

# Network connectivity test
kubectl run net-test --rm -it --image=busybox --restart=Never -- wget -qO- http://kubernetes.default.svc
```

## Create a Health Check Script

Save this as `health-check.sh`:

```bash
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "       k3s Cluster Health Check"
echo "=========================================="

# Check nodes
echo -e "\n${YELLOW}[1] Node Status:${NC}"
NODE_STATUS=$(kubectl get nodes -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}')
if [ "$NODE_STATUS" == "True" ]; then
    echo -e "${GREEN}✓${NC} Node is Ready"
    kubectl get nodes
else
    echo -e "${RED}✗${NC} Node is Not Ready!"
    kubectl get nodes
fi

# Check system pods
echo -e "\n${YELLOW}[2] System Pods:${NC}"
kubectl get pods -n kube-system -o wide

# Check API server
echo -e "\n${YELLOW}[3] API Server Health:${NC}"
API_HEALTH=$(kubectl get --raw='/healthz' 2>/dev/null)
if echo "$API_HEALTH" | grep -q "Success"; then
    echo -e "${GREEN}✓${NC} API Server is healthy"
else
    echo -e "${RED}✗${NC} API Server issue detected"
fi

# Check etcd
echo -e "\n${YELLOW}[4] etcd Health:${NC}"
ETCD_HEALTH=$(kubectl get --raw='/healthz/etcd' 2>/dev/null)
if echo "$ETCD_HEALTH" | grep -q "ok"; then
    echo -e "${GREEN}✓${NC} etcd is healthy"
else
    echo -e "${YELLOW}⚠${NC} Could not check etcd (may need auth)"
fi

# Check storage
echo -e "\n${YELLOW}[5] Storage Classes:${NC}"
kubectl get storageclass

# Check ingress
echo -e "\n${YELLOW}[6] Ingress Controller:${NC}"
kubectl get pods -n kube-system | grep traefik

echo -e "\n=========================================="
echo "         Health Check Complete"
echo "=========================================="
```

Make it executable:

```bash
chmod +x health-check.sh
./health-check.sh
```

## Common Issues & Solutions

### Issue: Node Not Ready

**Symptoms:** Node shows `NotReady` status

**Solution:**
```bash
# Check what's wrong
kubectl describe node <node-name>

# Common fixes:
# 1. Disk space
df -h

# 2. Memory
free -h

# 3. Restart kubelet
sudo systemctl restart k3s
```

### Issue: Pods Not Starting

**Symptoms:** Pod stuck in `Pending` or `ContainerCreating`

**Solution:**
```bash
# Check pod details
kubectl describe pod <pod-name> -n <namespace>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Issue: DNS Not Working

**Symptoms:** Pods can't resolve names

**Solution:**
```bash
# Check CoreDNS
kubectl get pods -n kube-system | grep coredns

# Restart CoreDNS
kubectl rollout restart deployment/coredns -n kube-system
```

### Issue: No Metrics

**Symptoms:** `kubectl top` returns error

**Solution:**
```bash
# Check metrics-server
kubectl get pods -n kube-system | grep metrics-server

# Restart metrics-server
kubectl rollout restart deployment/metrics-server -n kube-system
```

## Monitoring Tools

### k9s (Terminal UI)

Install and use k9s for a better terminal experience:

```bash
# Install
brew install k9s  # macOS
# or
sudo apt install k9s  # Linux

# Run
k9s
```

### Lens (GUI)

Download from https://k8slens.dev for a graphical interface.

## Next Steps

- [Configure remote access](./03-remote-access.md)
- [Deploy your first app](./04-first-app.md)
- [Set up persistent storage](./06-nfs-server.md)

## Commands Summary

```bash
# Quick health check
kubectl get nodes && kubectl get pods -A

# Detailed checks
kubectl top nodes
kubectl top pods -A
kubectl get componentstatuses
kubectl get --raw='/healthz'

# View logs
kubectl logs -n kube-system -l k8s-app=kube-proxy
kubectl logs -n kube-system -l k8s-app=kube-dns
```
