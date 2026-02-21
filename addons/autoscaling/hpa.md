# Horizontal Pod Autoscaler (HPA)

Automatically scale your pods based on CPU, memory, or custom metrics.

## Prerequisites

Metrics Server is included in k3s by default. Verify:

```bash
kubectl get deployment metrics-server -n kube-system
```

## Basic HPA Example

### Create Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

### Create HPA

```bash
kubectl autoscale deployment php-apache --cpu-percent=80 --min=1 --max=10
```

Or YAML:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## Check HPA Status

```bash
kubectl get hpa
kubectl describe hpa php-apache-hpa
```

## Generate Load for Testing

```bash
# In a separate terminal
kubectl run -it --rm load-generator --image=busybox -- /bin/sh
# Then run:
while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done
```

## Custom Metrics HPA

For custom metrics, you'll need Prometheus Adapter:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: 100
```

## HPA Behavior (Scaling Policies)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 1
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
```

## Common Issues

### Pods Not Scaling Up

1. Check metrics-server is running
2. Verify resource requests are set
3. Check HPA target matches deployment

```bash
kubectl top pods
kubectl get hpa -o yaml
```

### Pods Not Scaling Down

- Default stabilization window is 5 minutes
- Check for PodDisruptionBudget

```bash
kubectl get pdb
```

## Best Practices

1. **Set proper resource requests** - HPA needs requests to calculate utilization
2. **Don't set min replicas to 0** - Prevents cold starts
3. **Use appropriate thresholds** - 70-80% is usually good
4. **Monitor scaling behavior** - Check metrics over time
5. **Set max replicas appropriately** - Avoid runaway scaling
