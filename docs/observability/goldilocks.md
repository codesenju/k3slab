# Goldilocks - Resource Recommendations

## Install Goldilocks

```bash
kubectl create namespace goldilocks
helm repo add fairwinds-charts https://charts.fairwinds.com/stable
helm install goldilocks fairwinds-charts/goldilocks -n goldilocks
```

## Enable for Namespace

```bash
kubectl label namespace default goldilocks.fairwinds.com/enabled=true
```

## View Dashboard

```bash
kubectl port-forward -n goldilocks svc/goldilocks 8080:80
```

## Recommendations

Goldilocks analyzes pod resource requests and provides:
- CPU recommendations
- Memory recommendations
- Right-sizing suggestions

## Create VPA (Vertical Pod Autoscaler)

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto"
```

## View Recommendations

```bash
kubectl get vpa -A
kubectl describe vpa myapp-vpa
```
