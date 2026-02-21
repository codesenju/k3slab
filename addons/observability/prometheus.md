# Prometheus & Grafana - Monitoring Stack

## What is Prometheus?

Prometheus is an open-source monitoring system with a dimensional data model, flexible query language, efficient time series database, and modern alerting approach.

### What is Grafana?

Grafana is the open source analytics & monitoring solution for every database.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Prometheus Stack                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌─────────────┐ │
│  │   Targets    │───▶│  Prometheus  │───▶│   TSDB     │ │
│  │ (k8s pods,   │    │   Server     │    │ (Storage)   │ │
│  │  node, etc)  │    │              │    │             │ │
│  └──────────────┘    └──────┬───────┘    └─────────────┘ │
│                             │                               │
│                             ▼                               │
│                      ┌──────────────┐                       │
│                      │  Alertmanager │                      │
│                      └──────┬───────┘                       │
│                             │                               │
│                             ▼                               │
│                      ┌──────────────┐                       │
│                      │   Grafana    │                       │
│                      │  (Dashboards)│                       │
│                      └──────────────┘                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

- **Prometheus Server** - Scrapes and stores metrics
- **Exporters** - Export metrics from applications
- **Alertmanager** - Handles alerts
- **Pushgateway** - For short-lived jobs
- **Grafana** - Visualization

## Quick Install

### Option 1: Use Ansible Playbook (Recommended)

```bash
cd ansible
ansible-playbook -i inventory.ini addons/prometheus.yaml
```

This will:
- Install kube-prometheus-stack via Helm
- Configure Prometheus, Alertmanager, Grafana
- Enable persistent storage

### Option 2: Manual Installation

```bash
# Create namespace
kubectl create namespace monitoring

# Add helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set prometheus.prometheusSpec.retention=15d \
  --set grafana.persistence.enabled=true
```

## Access the Stack

### Prometheus

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-stack 9090:9090
```

Open: http://localhost:9090

### Grafana

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Open: http://localhost:3000

**Default credentials:**
- Username: `admin`
- Password: `prom-operator` (or get from secret)

### Alertmanager

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-stack-alertmanager 9093:9093
```

## Using Prometheus

### 1. Explore Metrics

In Prometheus UI (http://localhost:9090):

```promql
# All metrics
up

# CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Pod CPU usage
rate(container_cpu_usage_seconds_total[5m])
```

### 2. Check Targets

Navigate to: Status → Targets

You should see:
- kube-apiserver
- kube-controller-manager
- kube-scheduler
- kubelet
- coredns
- kube-proxy

### 3. Create Recording Rules

Create `prometheus-rules.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: custom-rules
  namespace: monitoring
spec:
  groups:
  - name: application.rules
    rules:
    - record: job:http_requests_total:rate5m
      expr: |
        sum by (job) (rate(http_requests_total[5m]))
```

Apply:

```yaml
kubectl apply -f prometheus-rules.yaml
```

## Using Grafana

### 1. Add Data Source

1. Open Grafana → Configuration → Data Sources
2. Add Prometheus
3. URL: `http://prometheus-kube-prometheus-stack.monitoring.svc:9090`

### 2. Import Dashboards

Import these popular dashboards:

- **Kubernetes Cluster** - ID: 15757
- **Kubernetes Pods** - ID: 15837
- **Node Exporter** - ID: 1860
- **Nginx** - ID: 12708

### 3. Create Custom Dashboard

Create a dashboard:

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
    }
  ]
}
```

## Alerting

### 1. Create Alert Rules

Create `alerts.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: critical-alerts
  namespace: monitoring
spec:
  groups:
  - name: critical
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High CPU usage on {{ $labels.instance }}"
        description: "CPU usage is above 80% for 5 minutes"

    - alert: HighMemoryUsage
      expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage on {{ $labels.instance }}"

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

### 2. Configure Alertmanager

The stack includes Alertmanager. Add receivers:

```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: slack-config
  namespace: monitoring
spec:
  route:
    groupBy: ['alertname']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 4h
    receiver: 'slack'
  receivers:
  - name: 'slack'
    slackConfigs:
    - apiUrl: 'https://hooks.slack.com/services/XXX'
      channel: '#alerts'
      sendResolved: true
```

## Monitoring Applications

### 1. Export Prometheus Metrics

Add to your application:

```python
from prometheus_client import start_http_server, Counter

requests_total = Counter('requests_total', 'Total requests')

@app.route('/')
def hello():
    requests_total.inc()
    return 'Hello!'
```

### 2. Create ServiceMonitor

For Kubernetes-native monitoring:

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

## Troubleshooting

### Prometheus Not Scraping Targets

```bash
# Check service monitor
kubectl get servicemonitor -n monitoring

# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-stack 9090
# Then visit: Status → Targets
```

### Grafana Login Issues

```bash
# Reset Grafana admin password
kubectl exec -it prometheus-grafana-0 -n monitoring -- grafana-cli admin reset-admin-password newpassword
```

### Metrics Not Available

```bash
# Check if metrics endpoint is exposed
kubectl get endpoints -n <namespace>

# Check service monitor
kubectl describe servicemonitor <name> -n monitoring
```

## Useful Queries

### Kubernetes

```promql
# Pods by CPU
topk(10, sum by (pod) (rate(container_cpu_usage_seconds_total[5m])))

# Pods by Memory
topk(10, sum by (pod) (container_memory_working_set_bytes))

# Deployment status
kube_deployment_status_replicas_available / kube_deployment_status_replicas_updated * 100
```

### Node Exporter

```promql
# CPU
node_cpu_seconds_total

# Memory
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# Disk
node_filesystem_avail_bytes / node_filesystem_size_bytes * 100

# Network
rate(node_network_receive_bytes_total[5m])
```

## Best Practices

1. **Use recording rules** for frequently queried metrics
2. **Set appropriate retention** (15-30 days typical)
3. **Configure alerts** for critical metrics
4. **Use labels wisely** - Don't have high cardinality labels
5. **Monitor Prometheus itself**

## Uninstall

```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

## Related Addons

- [Loki](./loki.md) - Log aggregation
- [Alertmanager](./alertmanager.md) - Alert routing
- [Goldilocks](./goldilocks.md) - Resource recommendations
- [Mimir](./mimir.md) - Long-term metrics storage
