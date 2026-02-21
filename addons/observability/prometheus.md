# Prometheus on k3s

## Quick Install

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

## Access Grafana

```bash
# Get Grafana password
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d

# Port forward
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

## Default Credentials

- Username: `admin`
- Password: (from command above)

## Key Metrics for k3s

### Node Metrics
```promql
node_cpu_seconds_total
node_memory_MemAvailable_bytes
node_filesystem_avail_bytes
```

### Pod Metrics
```promql
container_cpu_usage_seconds_total
container_memory_working_set_bytes
```

### k3s Specific
```promql
k3s_container_runtime_version
k3s_kubelet_health
```

## ServiceMonitor Example

Create `myapp-monitor.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: myapp
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: myapp
  endpoints:
  - port: metrics
    interval: 15s
```

## Alert Rules Example

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: k3s-alerts
  namespace: monitoring
spec:
  groups:
  - name: k3s.rules
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage on {{ $labels.instance }}"
    
    - alert: HighMemoryUsage
      expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage on {{ $labels.instance }}"
```

## Uninstall

```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```
