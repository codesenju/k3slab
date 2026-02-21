# Portainer - Container Management

## Install Portainer

```bash
kubectl create namespace portainer
helm repo add portainer https://portainer.github.io/k8s
helm install portainer portainer/portainer -n portainer
```

## Access Portainer

```bash
kubectl port-forward -n portainer svc/portainer 9000:9000
```

## Configuration

```yaml
values.yaml:
ingress:
  enabled: true
  hostname: portainer.example.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  tls:
  - secretName: portainer-tls

persistence:
  enabled: true
  size: 10Gi

service:
  type: LoadBalancer
```

## Deploy Agent

```bash
kubectl apply -f https://raw.githubusercontent.com/portainer/agent/master/k8s/agent.yml
```

## Connect to Agent

1. Access Portainer UI
2. Go to "Endpoints"
3. Add "Agent" endpoint
4. Enter agent URL

## Features

- Container management
- Image management
- Stack/Compose support
- User management
- Access control
- Logs viewer
- Terminal access
