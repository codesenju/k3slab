# Ntfy - Notifications

## Install Ntfy

```bash
kubectl create namespace ntfy
helm repo add ntfy https://ntfy.github.io/ntfy-charts
helm install ntfy ntfy/ntfy -n ntfy
```

## Access Ntfy

```bash
kubectl port-forward -n ntfy svc/ntfy 8080:80
```

## Configuration

```yaml
values.yaml:
persistence:
  enabled: true
  size: 5Gi

ingress:
  enabled: true
  hostname: ntfy.example.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prot

service:
  type: LoadBalancer

env:
  - name: NTFY_BASE_URL
    value: https://ntfy.example.com
  - name: NTFY_AUTH_DEFAULT_ACCESS
    value: "deny-all"
```

## Send Notification

```bash
# From CLI
curl -d "Build complete!" https://ntfy.example.com/my-topic

# From app
curl -X POST https://ntfy.example.com/my-topic \
  -H "Title: Deployment" \
  -d "Production deployment complete!"
```

## k3s Integration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: myapp
    image: myapp:latest
    env:
    - name: NTFY_URL
      value: https://ntfy.example.com/my-topic
```

## Alertmanager Integration

```yaml
route:
  receiver: ntfy
receivers:
- name: ntfy
  webhook_configs:
  - url: https://ntfy.example.com/alerts
    send_resolved: true
```
