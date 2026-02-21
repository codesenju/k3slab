# Longhorn - Cloud-Native Storage for k3s

Longhorn provides persistent block storage for Kubernetes.

## Install Longhorn

```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/deploy/longhorn.yaml
```

## Wait for Deployment

```bash
kubectl get pods -n longhorn-system
```

## Access Longhorn UI

```bash
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80
```

Open: http://localhost:8080

## Create StorageClass

Longhorn is automatically configured as default storage class.

```bash
kubectl get storageclass
```

## Use PersistentVolumeClaim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-data
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 1Gi
```

## Deploy with PVC

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-data
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 5Gi
```

## Backup to S3

```yaml
apiVersion: longhorn.io/v1beta2
kind: BackupVolume
metadata:
  name: backup-volume
spec:
  backupTarget:
    s3:
      bucket: longhorn-backups
      region: us-east-1
      endpoint: s3.amazonaws.com
```

## Volume Snapshots

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: my-snapshot
spec:
  volumeSnapshotClassName: longhorn
  source:
    persistentVolumeClaimName: postgres-pvc
```

## Restore from Snapshot

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restored-pvc
spec:
  storageClassName: longhorn
  dataSource:
    name: my-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  resources:
    requests:
      storage: 5Gi
```

## Monitoring

```bash
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/monitoring/prometheus.yaml
```

## Uninstall

```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/uninstall/uninstall.yaml
kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/uninstall/uninstall.yaml
```

## Troubleshooting

### Check Longhorn Pods

```bash
kubectl get pods -n longhorn-system -o wide
```

### Check Volume Status

```bash
kubectl get volumes.longhorn.io -n longhorn-system
```

### Common Issues

1. **Volume stuck attaching** - Check node connectivity
2. **Replica rebuilding** - Normal after node failure
3. **Disk space low** - Add more disks or clean up backups
