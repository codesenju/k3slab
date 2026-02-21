# KEDA - Event-Driven Autoscaling

## Install KEDA

```bash
kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.14.0/keda-2.14.0.yaml
```

## Create ScaledObject

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: myapp-scaler
spec:
  scaleTargetRef:
    name: myapp
  pollingInterval: 15
  cooldownPeriod: 300
  minReplicaCount: 0
  maxReplicaCount: 100
  triggers:
  - type: cpu
    metricType: Utilization
    metadata:
      value: "70"
  - type: memory
    metricType: Utilization
    metadata:
      value: "70"
```

## Scale Based on RabbitMQ

```yaml
triggers:
- type: rabbitmq
  metadata:
    queueName: my-queue
    host: rabbitmq-service.default.svc
    queueLength: "10"
```

## Scale Based on Kafka

```yaml
triggers:
- type: kafka
  metadata:
    bootstrapServers: kafka:9092
    consumerGroup: my-group
    topic: my-topic
    lagThreshold: "100"
```

## Scale Based on HTTP

```yaml
triggers:
- type: http
  metadata:
    url: "https://my-metrics-api.com/metrics"
    method: "GET"
    threshold: "50"
```

## Check Status

```bash
kubectl get scaledobject
kubectl get scaledobject myapp-scaler -o yaml
```
