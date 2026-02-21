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

### On RHEL/CentOS

```bash
# Install NFS server
sudo yum install -y nfs-utils

# Create NFS export directory
sudo mkdir -p /mnt/nfs/k8s
sudo chmod 777 /mnt/nfs/k8s

# Add to exports
echo '/mnt/nfs/k8s *(rw,sync,no_subtree_check,no_root_squash)' | sudo tee /etc/exports

# Start services
sudo systemctl enable nfs-server
sudo systemctl start nfs-server

# Firewall (if enabled)
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --reload
```

## Verify NFS is Working

```bash
# Check NFS exports
showmount -e localhost

# Or mount locally to test
sudo mount -t nfs localhost:/mnt/nfs/k8s /mnt/test
sudo umount /mnt/test
```

## Install NFS Client on k3s Nodes

```bash
# Ubuntu/Debian
sudo apt install -y nfs-common

# RHEL/CentOS
sudo yum install -y nfs-utils
```

## Configure Kubernetes to Use NFS

### Option 1: NFS Subdir External Provisioner (Recommended)

This allows you to use NFS as a dynamic storage provisioner:

```bash
# Install NFS Client Provisioner
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/nfs-subdir-external-provisioner/master/deployyaml/manifests/deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/nfs-subdir-external-provisioner/master/deployyaml/manifests/rbac.yaml

# Create StorageClass
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-client
provisioner: k8s-sigs.io/nfs-subdir-external-provisioner
parameters:
  archiveOnDelete: "false"
  pathPattern: "\${namespace}-\${pvcName}"
  onDelete: "delete"
  server: localhost
  mountOptions:vers=4
  share: /mnt/nfs/k8s
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF
```

### Option 2: Static NFS Volumes

Create PVCs that use NFS directly:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: localhost
    path: /mnt/nfs/k8s
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  resources:
    requests:
      storage: 10Gi
```

## Use NFS Storage in Pods

### Dynamic Provisioning (Recommended)

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
---
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

## Update Existing Applications

### Longhorn to NFS

If you want to switch from Longhorn to NFS:

```bash
# Make NFS the default storage class
kubectl patch storageclass longhorn -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass nfs-client -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Or specify explicitly in PVCs
# Change storageClassName: longhorn to storageClassName: nfs-client
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

# Check NFS exports
exportfs -v
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
kubectl logs -n default -l app=nfs-subdir-external-provisioner

# Check PVC status
kubectl get pvc
kubectl describe pvc <pvc-name>

# Check PV status
kubectl get pv
kubectl describe pv <pv-name>
```

## Backup and Maintenance

### Backup NFS Data

```bash
# Create backup
sudo tar czf /backup/nfs-backup-$(date +%Y%m%d).tar.gz /mnt/nfs/k8s

# Restore
sudo tar xzf /backup/nfs-backup-YYYYMMDD.tar.gz -C /
```

### Monitoring Disk Space

```bash
# Check usage
df -h /mnt/nfs/k8s

# Set up alerts (see monitoring guide)
```

## Security Considerations

For production, consider:

```bash
# Limit NFS to localhost only (already done in this guide)
/mnt/nfs/k8s localhost(rw,sync,no_subtree_check,no_root_squash)

# Or use specific IP ranges
/mnt/nfs/k8s 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
```

## Next Steps

- [Configure NFS for specific applications](./addons/)
- [Set up backups](./backup.md)
- [Monitor NFS usage](./monitoring.md)
