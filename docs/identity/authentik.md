# Authentik - Identity Provider

## Install Authentik

```bash
kubectl create namespace authentik
helm repo add authentik https://charts.goauthentik.io
helm install authentik authentik/authentik -n authentik
```

## Access Authentik

```bash
kubectl port-forward -n authentik svc/authentik-nginx 9000:80
```

## Initial Setup

1. Open http://localhost:9000
2. Create admin user
3. Configure OAuth/OIDC

## Configuration

```yaml
values.yaml:
ingress:
  enabled: true
  hostname: authentik.example.com

persistence:
  enabled: true
  size: 10Gi

authentik:
  secretKey: changeme
  encryptionKey: changeme
  # Error logging level (trace, debug, info, warn, error, fatal)
  logLevel: info

postgresql:
  enabled: true
  name: authentik
```

## OAuth/OIDC Setup

1. Create Application in Authentik
2. Create Provider (OAuth2/OpenID)
3. Configure redirect URIs

## Use with k3s

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: oauth2-proxy
type: Opaque
stringData:
  client-id: your-client-id
  client-secret: your-client-secret
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: oauth2-proxy
data:
  config.yaml: |
    provider: oidc
    client_id: your-client-id
    client_secret: your-client-secret
    oidc_issuer_url: https://authentik.example.com/application/o/authorize/
    email_domains: "*"
    upstream: "http://myapp"
```
