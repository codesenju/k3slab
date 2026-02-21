# OpenTelemetry - Observability

## Install OpenTelemetry Operator

```bash
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml
```

## Create OpenTelemetry Collector

```yaml
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: otel-collector
spec:
  config: |
    receivers:
      otlp:
        protocols:
          grpc:
          http:
      jaeger:
        protocols:
          thrift_http:
          grpc:
          thrift_tls:
      zipkin:
    processors:
      batch:
    exporters:
      otlp:
        endpoint: "https://your-otlp-endpoint:4317"
        tls:
          insecure: false
      logging:
    service:
      pipelines:
        traces:
          receivers: [otlp, jaeger, zipkin]
          processors: [batch]
          exporters: [otlp, logging]
        metrics:
          receivers: [otlp]
          processors: [batch]
          exporters: [otlp, logging]
```

## Instrument Application

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: myapp
        env:
        - name: OTEL_EXPORTER_OTLP_ENDPOINT
          value: "http://otel-collector:4317"
        - name: OTEL_SERVICE_NAME
          value: myapp
```

## Auto-Instrumentation

```yaml
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: myapp-instrumentation
spec:
  exporter:
    endpoint: http://otel-collector:4317
  propagators:
    - tracecontext
    - baggage
  java:
    image: ghcr.io/open-telemetry/opentelemetry-java-instrumentation/autoinstrumentation:latest
```
