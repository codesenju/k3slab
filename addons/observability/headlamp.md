# Headlamp - Kubernetes Dashboard

## Install Headlamp

```bash
kubectl create namespace headlamp
helm repo add headlamp https://headlamp-k8s.github.io/headlamp/helm-charts
helm install headlamp headlamp/headlamp -n headlamp
```

## Access Headlamp

```bash
kubectl port-forward -n headlamp svc/headlamp 8080:80
```

## Configuration

```yaml
values.yaml:
config:
  settings:
    theme: light
    showNativeColors: false
  
  clusterName: k3s-cluster

plugins: []

ingress:
  enabled: true
  hostname: headlamp.example.com
```

## Authenticate

Headlamp uses your kubeconfig. Access is controlled by Kubernetes RBAC.

## Features

- Visual cluster overview
- Workloads management
- Resource visualization
- Logs viewer
- Terminal integration
- Plugin system
