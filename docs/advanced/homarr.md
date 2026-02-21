# Homarr - Dashboard

## Install Homarr

```bash
kubectl create namespace homarr
helm repo add homarr https://homarr.github.io/homarr-charts
helm install homarr homarr/homarr -n homarr
```

## Access Homarr

```bash
kubectl port-forward -n homarr svc/homarr 7575:80
```

## Configuration

```yaml
values.yaml:
ingress:
  enabled: true
  hostname: homarr.example.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  tls:
  - secretName: homarr-tls
    hosts:
    - homarr.example.com

persistence:
  enabled: true
  size: 1Gi

config:
  theme: dark
  defaultView: dashboard

security:
  defaultApiKeysEnabled: false
```

## Add Widgets

After login, add widgets:
- Docker containers
- Kubernetes pods
- System resources
- Weather
- Calendar
- Custom links
