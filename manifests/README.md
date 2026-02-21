# Kubernetes Manifests

This directory contains reusable Kubernetes manifests for k3s deployments.

## Quick Deploy

```bash
# Deploy nginx
kubectl apply -f nginx-deployment.yaml

# Deploy with HPA
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-hpa.yaml

# Deploy with persistent storage
kubectl apply -f postgres-deployment.yaml
```

## Files

- `nginx-deployment.yaml` - Simple nginx deployment with ingress
- `postgres-deployment.yaml` - PostgreSQL with persistent storage
- `nginx-hpa.yaml` - Horizontal Pod Autoscaler
- `network-policies.yaml` - Network policy examples
- `resource-quota.yaml` - Resource quotas and limits
- `argocd-*.yaml` - ArgoCD Application manifests

## ArgoCD Integration

Deploy via ArgoCD:

```bash
kubectl apply -f argocd-nginx.yaml
```
