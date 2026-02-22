# Tutorial: Set Up Monitoring

In this tutorial, you'll set up comprehensive monitoring for your k3s cluster using Prometheus and Grafana.

## What You'll Learn

- ✅ Install Prometheus and Grafana
- ✅ Create custom dashboards
- ✅ Set up alerting
- ✅ Monitor applications

## Step 1: Install Prometheus Stack

```bash
# Create namespace
kubectl create namespace monitoring

# Add Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set prometheus.prometheusSpec.retention=15d \
  --set grafana.persistence.enabled=true \
  --set grafana.persistence.size=10Gi
```

## Step 2: Access Grafana

```bash
# Port forward to Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Open http://localhost:3000

**Default credentials:**
- Username: `admin`
- Password: `prom-operator`

## Step 3: Add Prometheus Data Source

1. Open Grafana → Configuration → Data Sources
2. Add Prometheus
3. URL: `http://prometheus-kube-prometheus-stack.monitoring.svc:9090`

## Step 4: Create Dashboard

### Dashboard 1: Cluster Overview

```json
{
  "title": "k3s Cluster Overview",
  "panels": [
    {
      "title": "CPU Usage",
      "type": "graph",
      "targets": [
        {
          "expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
          "legendFormat": "{{instance}}"
        }
      ]
    },
    {
      "title": "Memory Usage",
      "type": "graph",
      "targets": [
        {
          "expr": "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100",
          "legendFormat": "{{instance}}"
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
    },
    {
      "title": "Node Status",
      "type": "table",
      "targets": [
        {
          "expr": "kube_node_status_condition{condition=\"Ready\"}",
          "format": "table"
        }
      ]
    }
  ]
}
```

### Dashboard 2: Application Metrics

```json
{
  "title": "Application Metrics",
  "panels": [
    {
      "title": "Requests per Second",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(http_requests_total[5m])",
          "legendFormat": "{{method}} {{path}}"
        }
      ]
    },
    {
      "title": "Response Time",
      "type": "graph",
      "targets": [
        {
          "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
          "legendFormat": "p95"
        },
        {
          "expr": "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))",
          "legendFormat": "p99"
        }
      ]
    }
  ]
}
```

## Step 5: Set Up Alerts

Create alert rules:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: app-alerts
  namespace: monitoring
spec:
  groups:
  - name: application.rules
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
        summary: "Memory usage above 85% on {{ $labels.instance }}"
    
    - alert: PodDown
      expr: up == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Pod {{ $labels.instance }} is down"
```

Apply:

```bash
kubectl apply -f alerts.yaml
```

## Step 6: Monitor Custom Applications

### Add Metrics to Your App

Python example:

```python
from prometheus_client import Counter, generate_latest

requests_total = Counter('http_requests_total', 'Total HTTP requests')

@app.route('/metrics')
def metrics():
    return generate_latest()
```

### Create ServiceMonitor

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

Apply:

```bash
kubectl apply -f servicemonitor.yaml
```

## Step 7: Import Dashboards

Import from Grafana.com:

| Dashboard ID | Name |
|-------------|------|
| 15757 | Kubernetes cluster monitoring |
| 15837 | Kubernetes views and dashboards |
| 1860 | Node Exporter |
| 12708 | NGINX Ingress Controller |

## Step 8: View Metrics

### Useful Queries

```promql
# CPU by node
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory by node
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Pods by namespace
count by (namespace) (kube_pod_info)

# Deployment status
kube_deployment_status_replicas_available / kube_deployment_status_replicas * 100

# Persistent volumes
kube_persistentvolume_capacity_bytes
```

## Step 9: Set Up Alert Notifications

### Slack Integration

```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: slack-config
  namespace: monitoring
spec:
  route:
    groupBy: ['alertname']
    receiver: 'slack'
  receivers:
  - name: 'slack'
    slackConfigs:
    - apiUrl: 'https://hooks.slack.com/services/XXX'
      channel: '#alerts'
      sendResolved: true
```

## Step 10: Clean Up

```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

## What You Learned

- ✅ Install Prometheus and Grafana
- ✅ Create custom dashboards
- ✅ Set up alerting rules
- ✅ Monitor custom applications
- ✅ Create ServiceMonitors
- ✅ Configure notifications

## Next Steps

- [Set up logging with Loki](./02-logging.md)
- [Add tracing with Jaeger](./03-tracing.md)
- [Implement auto-scaling](./04-autoscaling.md)
