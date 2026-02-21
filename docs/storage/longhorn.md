# Longhorn - Cloud-Native Distributed Block Storage

## What is Longhorn?

Longhorn is a cloud-native, distributed block storage system for Kubernetes. It provides persistent storage for workloads that require persistent data, such as databases.

### Key Features

- **Cloud-Native** - Built for Kubernetes
- **UI Dashboard** - Easy management
- **Snapshots** - Point-in-time backups
- **Backups** - Off-cluster backup to S3
- **Replication** - Cross-node data redundancy
- **Live Migration** - Migrate volumes without downtime

## Why Use Persistent Storage?

By default, Kubernetes pods are ephemeral - when they die, their data is lost. Longhorn provides persistent volumes that survive pod restarts.

```
┌─────────────────────────────────────────────┐
│              Application                    │
│  (PostgreSQL, MySQL, etc.)                 │
└────────────────┬────────────────────────────┘
                 │ Mounts
                 ▼
┌─────────────────────────────────────────────┐
│         PersistentVolumeClaim               │
│         (PVC - 10Gi)                       │
└────────────────┬────────────────────────────┘
                 │ Bound to
                 ▼
┌─────────────────────────────────────────────┐
│           Longhorn Volume                   │
│  ┌─────────────────────────────────────┐   │
│  │  Replica 1 (Node 1)                 │   │
│  ├─────────────────────────────────────┤   │
│  │  Replica 2 (Node 2)                 │   │
│  ├─────────────────────────────────────┤   │
│  │  Replica 3 (Node 3)                 │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Prerequisites

- k3s cluster with at least 3 nodes (recommended)
- Sufficient disk space on each node

## Quick Install

### Option 1: Use Ansible Playbook (Recommended)

```bash
cd ansible
ansible-playbook -i inventory.ini addons/longhorn.yaml
```

This will:
- Install Longhorn via manifest
- Configure storage class
- Set Longhorn as default storage class

### Option 2: Manual Installation

```bash
# Install Longhorn
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/deploy/longhorn.yaml

# Wait for deployment
kubectl get pods -n longhorn-system

# Verify installation
kubectl get storageclass | grep longhorn
```

## Access Longhorn UI

### Port Forward (Development)

```bash
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80
```

Open: http://localhost:8080

## Using Longhorn

### 1. Create a PersistentVolumeClaim

Create `pvc.yaml`:

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
      storage: 10Gi
```

Apply:

```bash
kubectl apply -f pvc.yaml
```

### 2. Use PVC in a Pod

Create `pod-with-pvc.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres
spec:
  containers:
  - name: postgres
    image: postgres:15
    volumeMounts:
    - name: data
      mountPath: /var/lib/postgresql/data
    env:
    - name: POSTGRES_PASSWORD
      value: changeme
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-data
```

### 3. Deploy a Database with PVC

Create `postgres-deployment.yaml`:

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
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        env:
        - name: POSTGRES_DB
          value: myapp
        - name: POSTGRES_USER
          value: admin
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
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
      storage: 20Gi
---
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: Opaque
stringData:
  password: changeme123
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

Apply:

```bash
kubectl apply -f postgres-deployment.yaml
```

## Snapshots and Backups

### Create a Snapshot

```bash
# Via UI: Volume → Create Snapshot

# Or via kubectl
kubectl apply -f - <<EOF
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: my-snapshot
spec:
  volumeSnapshotClassName: longhorn
  source:
    persistentVolumeClaimName: postgres-pvc
EOF
```

### Restore from Snapshot

```bash
kubectl apply -f - <<EOF
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
      storage: 20Gi
EOF
```

### Backup to S3

```bash
# Create backup target
kubectl apply -f - <<EOF
apiVersion: longhorn.io/v1beta2
kind: BackupTarget
metadata:
  name: my-backup-target
spec:
  backupTargetURL: s3.us-east-1.amazonaws.com
  backupSecret:
    name: aws-credentials
    namespace: longhorn-system
  pollInterval: 12h
EOF

# Create recurring backup
kubectl apply -f - <<EOF
apiVersion: longhorn.io/v1beta2
kind: RecurringJob
metadata:
  name: daily-backup
spec:
  task: backup
  cron: "0 2 * * *"
  retention: 7
  concurrency: 1
  groups:
  - default
  fromBackup:
    name: ""
EOF
```

## Longhorn Settings

### Storage Class Parameters

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn
provisioner: driver.longhorn.io
parameters:
  numberOfReplicas: "3"
  staleReplicaTimeout: "30"
  fromBackup: ""
  dataLocality: "best-effort"
  replicaAutoBalance: "best-effort"
  diskSelector: "SSD"
  nodeSelector: "storage=true"
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
```

## Monitoring Longhorn

### Prometheus Integration

Longhorn exposes metrics via Prometheus. Add to your Prometheus config:

```yaml
- job_name: 'longhorn'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - longhorn-system
  relabel_configs:
  - source_labels: [__meta_kubernetes_endpoints_name]
    action: keep
    regex: longhorn-prometheus-metrics
```

### View Metrics in Grafana

Import the Longhorn dashboard from Grafana.com (ID: 13032)

## Troubleshooting

### Volume Stuck in Detaching

```bash
# Force delete volume attachment
kubectl exec -it longhorn-manager-xxx -n longhorn-system -- \
  longhornctl volume detach <volume-name>
```

### Replica Rebuilding

```bash
# Check replica status
kubectl get volumes.longhorn.io -n longhorn-system

# View replica details
kubectl describe volumes.longhorn.io <volume-name> -n longhorn-system
```

### Disk Space Issues

```bash
# Add new disk
kubectl apply -f - <<EOF
apiVersion: longhorn.io/v1beta2
kind: Disk
metadata:
  name: new-disk
  node: <node-name>
spec:
  path: /var/lib/longhorn/replicas
  storageReserved: 1024Gi
EOF
```

## Best Practices

1. **Use 3 replicas** for production data
2. **Regular backups** to S3-compatible storage
3. **Monitor disk space** on all nodes
4. **Set appropriate PVC size** - PVCs can only grow, not shrink
5. **Test restore** - Regularly test backup restoration

## Uninstall

```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/uninstall/uninstall.yaml
kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/uninstall/uninstall.yaml
```

## Related Addons

- [MinIO](./storage/minio.md) - S3-compatible storage for backups
- [PostgreSQL](./database/postgresql.md) - Database using Longhorn
- [Velero](./storage/velero.md) - Cluster backups
