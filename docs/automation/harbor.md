# Harbor - Container Registry

## Install Harbor

```bash
kubectl create namespace harbor
helm repo add harbor https://helm.goharbor.io
helm install harbor harbor/harbor -n harbor
```

## Access Harbor

```bash
kubectl port-forward -n harbor svc/harbor 8080:80
```

## Default Credentials

- Username: `admin`
- Password: `Harbor12345`

## Configuration

```yaml
values.yaml:
expose:
  type: ingress
  ingress:
    hostname: harbor.example.com
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod

persistence:
  enabled: true
  size: 100Gi

harborAdminPassword: changeme

 notary:
   enabled: true

trivy:
   enabled: true
```

## Push Image

```bash
docker login harbor.example.com
docker tag myapp:latest harbor.example.com/library/myapp:latest
docker push harbor.example.com/library/myapp:latest
```

## Pull in k3s

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: harbor-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-config>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    spec:
      imagePullSecrets:
      - name: harbor-secret
      containers:
      - name: myapp
        image: harbor.example.com/library/myapp:latest
```
