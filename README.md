# k3slab 🧪

Learn and explore Kubernetes addons using k3s - the lightweight Kubernetes.

## What is k3s?

k3s is a fully compliant Kubernetes distribution that is:
- Lightweight (< 512MB RAM)
- Single binary installation
- Perfect for learning, edge, and resource-constrained environments

## Quick Start

### 1. Install k3s

```bash
# Manual installation
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

# Or use Ansible (recommended)
cd ansible
ansible-playbook -i inventory.ini install-k3s.yaml
```

### 2. Deploy Addons with ArgoCD

```bash
# Install ArgoCD and addons via Ansible
cd ansible
ansible-playbook -i inventory.ini addons.yaml

# Or manually
kubectl create namespace argocd
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Deploy addons via GitOps
kubectl apply -f docs/manifests/
```

### 3. Verify

```bash
kubectl get nodes
kubectl get pods -A
```

## Project Structure

```
k3slab/
├── setup/           # Getting started guides
│   ├── 01-installation.md
│   ├── 02-healthchecks.md
│   ├── 03-remote-access.md
│   └── 05-architecture.md
├── addons/         # Kubernetes addons by category
│   ├── observability/    (Prometheus, Grafana, Loki, ArgoCD, etc.)
│   ├── security/        (RBAC, Network Policies, Cert-Manager)
│   ├── networking/      (Traefik, MetalLB, Cilium, etc.)
│   ├── storage/         (Longhorn, MinIO, NFS)
│   ├── autoscaling/     (HPA, KEDA)
│   ├── automation/      (GitLab, Harbor, n8n, Portainer)
│   ├── database/        (PostgreSQL, Redis, MongoDB)
│   └── servicemesh/    (Istio)
├── docs/         # Ansible playbooks for deployment
│   ├── install-k3s.yaml      # Install k3s cluster
│   ├── addons.yaml          # Deploy all addons
│   ├── addons/              # Individual addon playbooks
│   └── manifests/           # ArgoCD Application manifests
├── manifests/      # Sample Kubernetes manifests
│   ├── nginx-deployment.yaml
│   ├── postgres-deployment.yaml
│   ├── nginx-hpa.yaml
│   └── network-policies.yaml
├── tutorials/      # Step-by-step tutorials
├── projects/       # Real-world projects
└── challenges/    # Hands-on challenges
```

## Deploy Addons via Ansible (Recommended)

### Install k3s + Addons

```bash
cd ansible

# Edit inventory.ini with your hosts
nano inventory.ini

# Install k3s
ansible-playbook -i inventory.ini install-k3s.yaml

# Deploy ArgoCD + All Addons
ansible-playbook -i inventory.ini addons.yaml
```

### Deploy Individual Addons

```bash
# ArgoCD (GitOps)
ansible-playbook -i inventory.ini addons/argocd.yaml

# Longhorn (Storage)
ansible-playbook -i inventory.ini addons/longhorn.yaml

# MetalLB (Load Balancer)
ansible-playbook -i inventory.ini addons/metallb.yaml

# Prometheus + Grafana
ansible-playbook -i inventory.ini addons/prometheus.yaml
```

## GitOps with ArgoCD

All addons can be deployed via ArgoCD for automatic sync from Git:

```bash
# After installing ArgoCD
kubectl apply -f docs/manifests/

# Check sync status
argocd app list
argocd app sync <app-name>
```

### Available ArgoCD Applications

| Application | Description |
|-------------|-------------|
| `argocd-longhorn.yaml` | Longhorn storage |
| `argocd-prometheus.yaml` | Prometheus + Grafana |
| `argocd-metallb.yaml` | MetalLB load balancer |
| `argocd-nginx.yaml` | Nginx ingress |

## Categories

- **Setup** - Installing and configuring k3s
- **Observability** - Monitoring, logging, tracing
- **Security** - RBAC, secrets, network policies
- **Networking** - Ingress, service mesh, DNS
- **Storage** - Persistent volumes, CSI drivers
- **Auto-scaling** - HPA, VPA, KEDA
- **CI/CD** - GitOps, ArgoCD, Tekton
- **Databases** - PostgreSQL, Redis, MongoDB
- **Service Mesh** - Istio, Linkerd
- **Automation** - GitLab, Harbor, n8n

## Difficulty Levels

- 🟢 **Beginner** - Foundational concepts
- 🟡 **Medium** - Intermediate topics
- 🔴 **Hard** - Advanced configurations

## Daily Learning Path

Follow our 65-day journey from zero to hero! See the LinkedIn content sheet for daily topics.

## Requirements

- A Linux machine (VM, bare metal, or Raspberry Pi)
- 512MB+ RAM
- Root or sudo access
- For Ansible: SSH access to target machines

## Learning Resources

- [Setup Guides](./setup/)
- [Addon Documentation](./addons/)
- [Ansible Playbooks](./docs/)
- [Sample Manifests](./manifests/)

## License

MIT
