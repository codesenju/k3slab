# Traefik

Traefik comes pre-installed with k3s. Here's how to configure it.

## Default Installation

k3s includes Traefik by default. Check:

```bash
kubectl get pods -n kube-system | grep traefik
```

## Custom Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: traefik-config
  namespace: kube-system
data:
  traefik.yaml: |
    entryPoints:
      web:
        address: ":80"
      websecure:
        address: ":443"
    providers:
      kubernetesingress: {}
      file:
        directory: /config
        watch: true
```

## Create Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 80
```

## TLS

```yaml
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
```

## Middleware

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: strip-prefix
spec:
  stripPrefix:
    prefixes:
    - /prefix
```
