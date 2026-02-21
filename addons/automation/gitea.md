# Gitea - Self-Hosted Git Service

## Install Gitea

```bash
kubectl create namespace gitea
helm repo add gitea https://dl.gitea.io/charts
helm install gitea gitea/gitea -n gitea
```

## Access Gitea

```bash
kubectl port-forward -n gitea svc/gitea-http 3000:3000
```

## Configuration

```yaml
values.yaml:
persistence:
  enabled: true
  size: 10Gi

service:
  http:
    type: LoadBalancer

gitea:
  admin:
    username: admin
    password: changeme
    email: admin@example.com
  
  config:
    server:
      DOMAIN: gitea.example.com
      ROOT_URL: https://gitea.example.com/
    
    database:
      DB_TYPE: postgres
      HOST: postgres-gitea:5432
```

## Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gitea
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  rules:
  - host: gitea.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gitea-http
            port:
              number: 3000
```
