# Crossplane - Infrastructure as Code

## Install Crossplane

```bash
kubectl create namespace crossplane-system
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace
```

## Install Provider

```bash
# AWS Provider
kubectl apply -f https://raw.githubusercontent.com/crossplane/provider-aws/main/examples.yaml

# GCP Provider  
kubectl apply -f https://raw.githubusercontent.com/crossplane/provider-gcp/main/examples.yaml

# Azure Provider
kubectl apply -f https://raw.githubusercontent.com/crossplane/provider-azure/main/examples.yaml
```

## Create Provider Config

```yaml
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: credentials
```

## Create Managed Resource

```yaml
apiVersion: s3.aws.upbound.io/v1beta1
kind: Bucket
metadata:
  name: my-bucket
spec:
  forProvider:
    region: us-east-1
  providerConfigRef:
    name: default
```

## Composites (XR)

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: databases.example.org
spec:
  group: example.org
  names:
    kind: Database
    plural: databases
  versions:
  - name: v1alpha1
    served: true
    referenceable: true
```

## Claim

```yaml
apiVersion: example.org/v1alpha1
kind: Database
metadata:
  name: my-database
  namespace: default
spec:
  parameters:
    size: small
    engine: postgres
  writeConnectionSecretToRef:
    name: db-credentials
```
