# Nginx Proxy Manager

## Install Nginx Proxy Manager

```bash
kubectl create namespace npm
helm repo add nginx-proxy-manager https://nginx-proxy-manager.github.io/nginx-proxy-manager-chart
helm install npm nginx-proxy-manager/nginx-proxy-manager -n npm
```

## Access Nginx Proxy Manager

```bash
kubectl port-forward -n npm svc/npm-nginx-proxy-manager 8080:80
```

## Default Credentials

- Email: `admin@example.com`
- Password: `changeme`

## Configuration

```yaml
values.yaml:
persistence:
  enabled: true
  size: 5Gi

ingressClassName: nginx

env:
  DB_SQLITE_FILE: "/data/database.sqlite"

service:
  type: LoadBalancer
```

## Add Proxy Host

1. Login to NPM UI
2. Go to Proxy Hosts
3. Add Proxy Host:
   - Domain Name: myapp.example.com
   - Forward Hostname: myapp-service
   - Forward Port: 80
   - Enable SSL (Let's Encrypt)

## SSL Certificates

NPM automatically manages SSL via Let's Encrypt.

## Docker Integration

Add Docker labels to containers:
```yaml
labels:
  nginx-proxy-manager.enable: "true"
```
