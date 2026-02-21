# ArgoCD - GitOps Deployment Controller

## What is ArgoCD?

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It automates the deployment of applications to your cluster by syncing the desired application state from Git to your Kubernetes cluster.

### Key Features

- **GitOps** - All application definitions live in Git
- **Automated Sync** - Automatically deploys changes from Git
- **Rollback** - Easy rollback to any previous version
- **Multi-tenancy** - Built-in RBAC
- **Visual UI** - Web-based dashboard

## Prerequisites

Before installing ArgoCD, ensure you have:

1. A running k3s cluster
2. `kubectl` configured to access your cluster
3. Helm installed (`helm version`)

## Quick Install

### Option 1: Use Ansible Playbook (Recommended)

```bash
cd ansible
ansible-playbook -i inventory.ini addons/argocd.yaml
```

This will:
- Install ArgoCD via Helm
- Configure RBAC
- Set up the initial admin user

### Option 2: Manual Installation

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for deployment
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

## Access ArgoCD

### Port Forward (Development)

```bash
kubectl port-forward -n argocd svc/argocd-server 8080:80
```

Then open: http://localhost:8080

### Get Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Default username: `admin`

## Using ArgoCD

### 1. Login via CLI

```bash
# Install ArgoCD CLI
brew install argocd

# Login
argocd login localhost:8080 --username admin --password <your-password>
```

### 2. Register Your Cluster

```bash
# Get cluster credentials
argocd cluster add <context-name>

# Or use internal Kubernetes endpoint
argocd cluster add in-cluster --name k3s-cluster
```

### 3. Create an Application

Create `myapp.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myuser/myapp-repo.git
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply:

```bash
kubectl apply -f myapp.yaml
```

### 4. Sync Your Application

```bash
# Sync manually
argocd app sync myapp

# View status
argocd app get myapp

# View logs
argocd app logs myapp
```

## ArgoCD Application Manifests

We provide pre-configured ArgoCD Application manifests for easy deployment:

```bash
# Deploy addons via ArgoCD
kubectl apply -f ansible/manifests/

# Available applications:
# - argocd-longhorn.yaml    (Storage)
# - argocd-prometheus.yaml   (Monitoring)
# - argocd-metallb.yaml     (Load Balancer)
# - argocd-nginx.yaml        (Ingress)
```

## Project Structure for GitOps

```
myapp-repo/
├── k8s/
│   ├── base/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── overlays/
│   │   ├── dev/
│   │   │   └── kustomization.yaml
│   │   ├── staging/
│   │   │   └── kustomization.yaml
│   │   └── prod/
│   │       └── kustomization.yaml
│   └── kustomization.yaml
└── README.md
```

## Common Operations

### Rollback

```bash
# View history
argocd app history myapp

# Rollback to previous version
argocd app rollback myapp <revision>
```

### Sync Options

```bash
# Sync with force refresh
argocd app sync myapp --force

# Sync specific resources
argocd app sync myapp --resources deployments,statefulsets
```

### Webhooks

Set up webhooks to trigger automatic syncs:

```bash
# Create webhook configuration in ArgoCD UI
# Or use ArgoCD CLI
argocd repo add https://github.com/myuser/myapp-repo \
  --type git \
  --project myproject \
  --github-token <token>
```

## Best Practices

1. **Use Git as Single Source of Truth** - All configs in Git
2. **Enable Auto-Sync** - For automated deployments
3. **Use Overlay Patterns** - Dev/Staging/Prod via Kustomize
4. **Set Resource Limits** - Prevent resource exhaustion
5. **Enable Notifications** - Slack/Discord alerts on sync status

## Troubleshooting

### Pod Not Starting

```bash
# Check logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Check events
kubectl events -n argocd --sort-by='.lastTimestamp'
```

### Sync Stuck

```bash
# Force sync
argocd app sync myapp --force

# Restart reconciliation
argocd app actions pause myapp
argocd app actions resume myapp
```

### Permission Issues

```bash
# Check RBAC
kubectl get configmap argocd-rbac-cm -n argocd -o yaml
```

## Next Steps

- [Deploy your first app via ArgoCD](./tutorials/first-app.md)
- [Set up GitOps workflow](./tutorials/gitops.md)
- [Configure monitoring](./observability/prometheus.md)

## Related Addons

- [Prometheus](./observability/prometheus.md) - Metrics for ArgoCD
- [Loki](./observability/loki.md) - Log aggregation
- [Cert-Manager](./security/cert-manager.md) - TLS for ArgoCD
