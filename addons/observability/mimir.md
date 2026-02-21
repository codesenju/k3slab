# Mimir - Metrics Storage

## Install Mimir

```bash
kubectl create namespace mimir
helm repo add grafana https://grafana.github.io/helm-charts
helm install mimir grafana/mimir-distributed -n mimir
```

## Access Mimir

```bash
kubectl port-forward -n mimir svc/mimir-nginx 8080:80
```

## Configuration

```yaml
values.yaml:
ingress:
  enabled: true
  hostname: mimir.example.com

persistence:
  enabled: true
  size: 50Gi

storage:
  type: s3
  s3:
    endpoint: minio.minio.svc:9000
    bucket: mimir
    access_key_id: minioadmin
    secret_access_key: minioadmin
```

## Configure Prometheus to Remote Write

```yaml
remote_write:
- url: http://mimir-nginx.mimir.svc:80/api/v1/push
```

## Query via Grafana

1. Add Mimir as data source
2. URL: http://mimir-nginx.mimir.svc:80
3. Use PromQL queries

## Architecture

- Mimir is horizontally scalable
- Stores metrics long-term
- Compatible with Prometheus
- Lower storage costs than Thanos
