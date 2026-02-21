# OpenSearch - Search & Analytics

## Install OpenSearch

```bash
kubectl create namespace opensearch
helm repo add opensearch https://opensearch-project.github.io/helm-charts
helm install opensearch opensearch/opensearch -n opensearch
```

## Install Dashboards

```bash
helm install opensearch-dashboards opensearch/opensearch-dashboards -n opensearch
```

## Access Dashboards

```bash
kubectl port-forward -n opensearch svc/opensearch-dashboards 5601:5601
```

## Configuration

```yaml
values.yaml:
persistence:
  enabled: true
  size: 50Gi

opensearch-dashboards:
  ingress:
    enabled: true
    hostname: opensearch.example.com
  env:
    OPENSEARCH_HOSTS: https://opensearch:9200

security:
  enabled: true
  admin:
    user: admin
    password: changeme
```

## Security Config

```yaml
plugins:
  security:
    enabled: true
    config:
      securityConfig:
        internalUsers: |
          admin:
            hash: <bcrypt-hash>
            roles:
            - admin
```

## Index Data

```bash
# Create index
curl -X PUT "https://localhost:9200/my-index" -u admin:changeme

# Search
curl -X GET "https://localhost:9200/my-index/_search" -u admin:changeme
```
