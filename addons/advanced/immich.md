# Immich - Photo Management

## Install Immich

```bash
kubectl create namespace immich
helm repo add immich https://immich-app.github.io/immich-charts
helm install immich immich/immich -n immich
```

## Access Immich

```bash
kubectl port-forward -n immich svc/immich-server 2281:3001
```

## Configuration

```yaml
values.yaml:
nginx:
  enabled: true
  service:
    type: LoadBalancer

database:
  enabled: true
  postgresDatabase: immich
  postgresUsername: immich
  postgresPassword: changeme

redis:
  enabled: true

persistence:
  library:
    enabled: true
    size: 100Gi
  upload:
    enabled: true
    size: 20Gi
  thumbs:
    enabled: true
    size: 10Gi
```

## Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: immich
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  rules:
  - host: photos.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: immich-server
            port:
              number: 3001
```

## Upload Photos

Use the web UI or mobile app to upload and organize your photos.
