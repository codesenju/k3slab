# External DNS - Automatic DNS Records

## Install External DNS

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/external-dns/master/deploy/charts/external-dns.yaml
```

## Configure for Cloudflare

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-key
type: Opaque
stringData:
  api-key: your-cloudflare-api-key
---
apiVersion: externaldns.nginx.org/v1
kind: DNSEndpoint
metadata:
  name: external-dns
spec:
  endpoints:
  - dnsName: myapp.example.com
    recordTTL: 300
    recordType: A
    targets:
    - 1.2.3.4
```

## Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    external-dns.alpha.kubernetes.io/hostname: myapp.example.com
    external-dns.alpha.kubernetes.io/ttl: "300"
spec:
  ingressClassName: nginx
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

## Provider Options

- cloudflare
- aws-route53
- google
- azure-dns
- digitalocean
- and more...
