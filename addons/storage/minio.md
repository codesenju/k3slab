# MinIO - S3-Compatible Storage

## Install MinIO

```bash
kubectl create namespace minio
helm repo add minio https://charts.min.io/
helm install minio minio/minio -n minio
```

## Access MinIO Console

```bash
kubectl port-forward -n minio svc/minio 9000:9000
```

## Credentials

- Access Key: `minioadmin`
- Secret Key: `minioadmin`

## Configuration

```yaml
values.yaml:
persistence:
  enabled: true
  size: 100Gi

service:
  type: LoadBalancer

consoleService:
  type: LoadBalancer

rootUser: minioadmin
rootPassword: minioadmin

ingress:
  enabled: true
  hostname: minio.example.com
```

## Deploy with Operator

```bash
kubectl apply -f https://operator.min.io/thanos/minio-operator.yaml
kubectl apply -f https://operator.min.io/thanos/tenant.yaml
```

## Use as S3 Backend

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: minio-creds
type: Opaque
stringData:
  accesskey: minioadmin
  secretkey: minioadmin
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-using-s3
spec:
  containers:
  - name: app
    env:
    - name: S3_ENDPOINT
      value: http://minio.minio.svc:9000
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: minio-creds
          key: accesskey
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: minio-creds
          key: secretkey
```
