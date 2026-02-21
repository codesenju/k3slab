# NFS Server Setup for k3s

This guide explains how to set up NFS server on your k3s VM and configure Kubernetes to use it.

## What is NFS?

Network File System (NFS) allows you to share directories across your network. In a single-VM setup, we'll configure NFS locally so Kubernetes can use it for persistent storage.

## Why NFS for k3s?

- **Simple** - No complex storage solutions needed
- **Persistent** - Data survives pod restarts
- **Lightweight** - Perfect for single-node k3s
- **Learning** - Great for understanding Kubernetes storage

## Install NFS Server

### On Ubuntu/Debian

```bash
# Install NFS server
sudo apt update
sudo apt install -y nfs-kernel-server

# Create NFS export directory
sudo mkdir -p /mnt/nfs/k8s
sudo chmod 777 /mnt/nfs/k8s

# Add to exports
echo '/mnt/nfs/k8s *(rw,sync,no_subtree_check,no_root_squash)' | sudo tee /etc/exports

# Export the shares
sudo exportfs -a

# Start NFS server
sudo systemctl enable nfs-server
sudo systemctl start nfs-server

# Verify
sudo showmount -e localhost
```

Expected output:
```
Export list for localhost:
/mnt/nfs/k8s *
```

## Install NFS Client on k3s Nodes

```bash
# Ubuntu/Debian
sudo apt install -y nfs-common
```

## Install NFS Provisioner in Kubernetes

We'll use the NFS Subdir External Provisioner to dynamically provision NFS volumes.

### Option 1: Using Helm (Recommended)

```bash
# Install Helm if not already installed
curl -fsSL https://get.helm.sh/helm-v3.15.0-linux-amd64.tar.gz | tar -xz -C /tmp/
sudo mv /tmp/linux-amd64/helm /usr/local/bin/

# Add NFS provisioner helm repo
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm repo update

# Install NFS provisioner
helm install nfs-subdir-external-provisioner \
  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=localhost \
  --set nfs.path=/mnt/nfs/k8s
```

### Option 2: Using kubectl

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/nfs-subdir-external-provisioner/v4.5.0/deploy/objects/deployment.yaml
```

## Verify Installation

```bash
kubectl get pods -l app=nfs-subdir-external-provisioner
kubectl get storageclass | grep nfs
```

Expected output:
```
NAME                   PROVISIONER                                     RECLAIMPOLICY   VOLUMEBINDINGMODE
nfs-client             cluster.local/nfs-subdir-external-provisioner   Delete          Immediate
```

## Use NFS Storage in Pods

### Create a PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-data
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-client
  resources:
    requests:
      storage: 1Gi
```

Apply:
```bash
kubectl apply -f my-pvc.yaml
```

### Use in a Pod

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-nfs
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-nfs
  template:
    metadata:
      labels:
        app: nginx-nfs
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        volumeMounts:
        - name: nfs-data
          mountPath: /usr/share/nginx/html
      volumes:
      - name: nfs-data
        persistentVolumeClaim:
          claimName: my-data
```

## Test NFS Storage

```bash
# Create a test PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-nfs
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-client
  resources:
    requests:
      storage: 1Mi
EOF

# Check status
kubectl get pvc test-nfs

# Should show: Bound
```

## Troubleshooting

### NFS Mount Issues

```bash
# Check NFS server status
sudo systemctl status nfs-server

# Check logs
sudo journalctl -u nfs-server -f

# Test mount manually
sudo mount -t nfs -o vers=4 localhost:/mnt/nfs/k8s /mnt/test
```

### Permission Issues

```bash
# Check directory permissions
ls -la /mnt/nfs/k8s

# Fix permissions
sudo chown -R nobody:nogroup /mnt/nfs/k8s
sudo chmod 777 /mnt/nfs/k8s
```

### Kubernetes Issues

```bash
# Check provisioner logs
kubectl logs -l app=nfs-subdir-external-provisioner

# Check PVC status
kubectl describe pvc <pvc-name>
```

## Make NFS the Default Storage Class

```bash
# Set NFS as default
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass nfs-client -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Next Steps

- Deploy applications with persistent storage
- Set up backups for NFS data
- Explore Longhorn for more advanced storage features
