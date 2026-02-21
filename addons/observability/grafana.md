# Grafana on k3s

## Install with Prometheus Stack

Grafana comes bundled with `kube-prometheus-stack`:

```bash
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

## Standalone Install

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana -n monitoring
```

## Access Grafana

```bash
# Get password
kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 -d

# Port forward
kubectl port-forward -n monitoring svc/grafana 3000:80
```

## Sample Dashboards

### k3s Cluster Overview

```json
{
  "title": "k3s Cluster Overview",
  "panels": [
    {
      "title": "CPU Usage",
      "type": "graph",
      "targets": [
        {
          "expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
        }
      ]
    },
    {
      "title": "Memory Usage",
      "type": "graph", 
      "targets": [
        {
          "expr": "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100"
        }
      ]
    },
    {
      "title": "Pod Count",
      "type": "stat",
      "targets": [
        {
          "expr": "count(kube_pod_info)"
        }
      ]
    }
  ]
}
```

## Add Data Source

1. Go to Configuration → Data Sources
2. Add Prometheus
3. URL: `http://prometheus-server.monitoring.svc.cluster.local:9090`

## Import Dashboards

Import from Grafana.com:
- 15757 - Kubernetes cluster monitoring (via Prometheus)
- 15837 - Kubernetes Views & Dashboards

## Persistent Storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-pvc
  namespace: monitoring
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: grafana
  namespace: monitoring
spec:
  containers:
  - name: grafana
    volumeMounts:
    - name: grafana-storage
      mountPath: /var/lib/grafana
  volumes:
  - name: grafana-storage
    persistentVolumeClaim:
      claimName: grafana-pvc
```
