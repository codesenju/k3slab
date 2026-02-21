# n8n - Workflow Automation

## Install n8n

```bash
kubectl create namespace n8n
helm repo add n8n https://n8n-io.github.io/n8n-helm-chart
helm install n8n n8n/n8n -n n8n
```

## Access n8n

```bash
kubectl port-forward -n n8n svc/n8n 5678:80
```

## Configuration

```yaml
values.yaml:
ingress:
  enabled: true
  hostname: n8n.example.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  tls:
  - secretName: n8n-tls
    hosts:
    - n8n.example.com

persistence:
  enabled: true
  size: 10Gi

database:
  type: postgres
  postgres:
    host: postgres
    port: 5432
    database: n8n
    user: n8n
    password: changeme

env:
  - name: N8N_BASIC_AUTH_ACTIVE
    value: "true"
  - name: N8N_BASIC_AUTH_USER
    value: admin
  - name: N8N_BASIC_AUTH_PASSWORD
    value: changeme
  - name: N8N_HOST
    value: n8n.example.com
  - name: N8N_PROTOCOL
    value: https
```

## Webhooks

```bash
# Set webhook URL in n8n
https://n8n.example.com/webhook/test
```
