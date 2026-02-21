# Loki - Log Aggregation

## Install with Grafana Stack

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack -n monitoring
```

## Standalone Install

```bash
helm install loki grafana/loki -n monitoring
```

## Install Promtail (Log Collector)

```bash
helm install promtail grafana/promtail -n monitoring
```

## Configure Promtail for k3s

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: promtail-config
  namespace: monitoring
data:
  promtail.yaml: |
    clients:
      - url: http://loki:3100/loki/api/v1/push
    scrape_configs:
    - job_name: kubernetes-pods
      kubernetes_sd_configs:
      - role: pods
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: pod
```

## Access Logs via Grafana

1. Open Grafana
2. Explore → Select Loki
3. Query examples:

```logql
{job="kubernetes-pods"}
| json
| pod_name =~ "nginx.*"
| line_format "{{.pod_name}} - {{.message}}"
```

## Useful LogQL Queries

### All Logs from a Namespace
```logql
{namespace="default"}
```

### Error Logs
```logql
{namespace="production"} |= "ERROR"
```

### JSON Parsing
```logql
{job="myapp"} | json | level="error"
```

## Retention

```yaml
helm upgrade loki grafana/loki -n monitoring \
  --set config.limits.enforce_metric_name=false \
  --set 'config.table_manager.retention_deletes[0]=30d' \
  --set 'config.table_manager.retention_periods[0]=30d'
```

## S3 Storage for Production

```yaml
config:
  storage:
    bucket_names:
      - your-loki-bucket
    s3:
      endpoint: http://minio:9000
      secretAccessKey: supersecret
      accessKeyId: minioadmin
      s3ForcePathStyle: true
      insecure: false
```
