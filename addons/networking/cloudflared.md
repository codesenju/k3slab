# Cloudflare Tunnel (cloudflared)

## Install cloudflared

```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared
```

## Authenticate

```bash
cloudflared tunnel login
```

## Create Tunnel

```bash
cloudflared tunnel create my-tunnel
```

## Configure DNS

```bash
cloudflared tunnel route dns my-tunnel myapp.example.com
```

## Deploy in k3s

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudflared-creds
  namespace: default
data:
  credentials.json: <base64-of-credentials-file>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudflared
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloudflared
  template:
    metadata:
      labels:
        app: cloudflared
    spec:
      containers:
      - name: cloudflared
        image: cloudflare/cloudflared:latest
        args:
        - tunnel
        - --config
        - /etc/cloudflared/config.yml
        - run
        volumeMounts:
        - name: config
          mountPath: /etc/cloudflared
        - name: creds
          mountPath: /etc/cloudflared/creds
          readOnly: true
      volumes:
      - name: config
        configMap:
          name: cloudflared-config
      - name: creds
        secret:
          secretName: cloudflared-creds
```

## Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    external-dns.alpha.kubernetes.io/hostname: myapp.example.com
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
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
```
