# GitLab CE/EE on k3s

## Install GitLab

```bash
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io
helm install gitlab gitlab/gitlab -n gitlab
```

## Get GitLab Password

```bash
kubectl get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 -d
```

## Access GitLab

```bash
kubectl port-forward -n gitlab svc/gitlab-nginx-ingress-controller 8080:80
```

## Configure

```yaml
values.yaml:
global:
  hosts:
    domain: example.com
  ingress:
    class: nginx
  gitlab:
    hostname: gitlab.example.com

certmanager:
  install: false

postgresql:
  install: true

redis:
  install: true

minio:
  enabled: true
```

## Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gitlab
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: '250m'
spec:
  rules:
  - host: gitlab.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gitlab-webservice-default
            port:
              number: 8080
```
