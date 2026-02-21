# ArgoCD - GitOps Deployment

## Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Get Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Access ArgoCD UI

```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
```

Open: http://localhost:8080

## CLI Installation

```bash
brew install argocd
argocd login localhost:8080
```

## Deploy Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myuser/myrepo
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

## Sync Commands

```bash
argocd app sync myapp
argocd app rollback myapp 1
argocd app diff myapp
```

## Next: [ArgoCD Deep Dive](../cicd/argocd.md)
