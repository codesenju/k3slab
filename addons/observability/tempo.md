# Tempo - Distributed Tracing

## Install Tempo

```bash
kubectl create namespace tempo
helm repo add grafana https://grafana.github.io/helm-charts
helm install tempo grafana/tempo-distributed -n tempo
```

## Access Tempo

```bash
kubectl port-forward -n tempo svc/tempo-distributed 3100:3100
```

## Configuration

```yaml
values.yaml:
persistence:
  enabled: true
  size: 10Gi

storage:
  trace:
    backend: s3
    s3:
      endpoint: minio.minio.svc:9000
      bucket: tempo
      access_key: minioadmin
      secret_key: minioadmin

traces:
  otlp:
    grpc:
      enabled: true
    http:
      enabled: true

config: |
  server:
    http_listen_port: 3100
    grpc_listen_port: 9096
  distributor:
    receivers:
      jaeger:
        protocols:
          thrift_http:
          grpc:
          thrift_tls:
      otlp:
        protocols:
          grpc:
          http:
      zipkin:
  ingester:
    max_block_duration: 5m
  compactor:
    compaction:
      block_retention: 1h
  storage:
    trace:
      backend: s3
      s3:
        bucket: tempo
```

## Query in Grafana

1. Add Tempo as data source
2. Query by trace ID or search
3. View trace details
