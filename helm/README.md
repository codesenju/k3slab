# Helm Charts for k3s

This directory contains example Helm charts and configurations for common k3s deployments.

## Quick Commands

### Add Repositories

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add longhorn https://charts.longhorn.io
helm repo update
```

## Example: Nginx Deployment

### Install Nginx

```bash
helm install nginx bitnami/nginx-ingress -n ingress
```

### Custom Values

```yaml
# nginx-values.yaml
controller:
  replicaCount: 2
  service:
    type: LoadBalancer
    externalTrafficPolicy: Local
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
```

```bash
helm install nginx bitnami/nginx-ingress -n ingress -f nginx-values.yaml
```

## Example: PostgreSQL

```yaml
# postgresql-values.yaml
auth:
  username: appuser
  password: changeme
  database: myapp
primary:
  persistence:
    size: 10Gi
replication:
  enabled: true
  readReplicas: 2
```

```bash
helm install postgres bitnami/postgresql -n database -f postgresql-values.yaml
```

## Example: Redis

```yaml
# redis-values.yaml
architecture: replication
auth:
  password: changeme
replica:
  replicaCount: 3
master:
  persistence:
    size: 8Gi
```

```bash
helm install redis bitnami/redis -n cache -f redis-values.yaml
```

## Create Custom Chart

```bash
helm create myapp
```

### Chart Structure

```
myapp/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── _helpers.tpl
└── charts/
```

### Simple Deployment Template

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - name: http
          containerPort: {{ .Values.service.port }}
```

## Helmfile for Multiple Apps

```yaml
# helmfile.yaml
repositories:
  - name: bitnami
    url: https://charts.bitnami.com/bitnami
  - name: prometheus-community
    url: https://prometheus-community.github.io/helm-charts

releases:
  - name: nginx
    namespace: ingress
    chart: bitnami/nginx-ingress

  - name: postgres
    namespace: database
    chart: bitnami/postgresql
    values:
      - persistence:
          size: 10Gi

  - name: redis
    namespace: cache
    chart: bitnami/redis

  - name: prometheus
    namespace: monitoring
    chart: prometheus-community/kube-prometheus-stack
```

Install helmfile:
```bash
brew install helmfile
helmfile sync
```

## Best Practices

1. **Use namespaces** - Organize by function
2. **Version control** - Keep values in Git
3. **Secrets** - Use external secrets or Vault
4. **Templates** - Create reusable charts
5. **Helmfile** - Manage multiple releases
