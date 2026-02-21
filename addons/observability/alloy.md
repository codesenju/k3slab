# Alloy - Grafana Alloy (formerly Grafana Agent)

## Install Alloy

```bash
kubectl create namespace alloy
helm repo add grafana https://grafana.github.io/helm-charts
helm install alloy grafana/alloy -n alloy
```

## Configuration

```yaml
values.yaml:
configMap:
  create: true
  content: |
    logging {
      level  = "info"
      format = "json"
    }

    discovery.kubernetes "pods" {
      role = "pod"
    }

    prometheus.scrure "pods" {
      forward_to = [prometheus.remote_write.default.receiver]
    }

    prometheus.remote_write "default" {
      endpoint {
        url = "http://prometheus:9090/api/v1/write"
      }
    }

    loki.process "pods" {
      forward_to = [loki.write.default.receiver]
    }

    loki.write "default" {
      endpoint {
        url = "http://loki:3100/loki/api/v1/push"
      }
    }

    otelcol.receiver.otlp "default" {
      grpc {}
      http {}
      output {
        signals = {}
        traces = {}
        metrics = {}
      }
    }
```

## Deploy

```bash
kubectl apply -f values.yaml
```
