# k3slab 🧪

Learn and explore Kubernetes addons using k3s - the lightweight Kubernetes.

## What is k3s?

k3s is a fully compliant Kubernetes distribution that is:
- **Lightweight** (< 512MB RAM)
- **Single binary** installation
- **Perfect for learning**, edge computing, and resource-constrained environments

## Why Learn k3s?

| Feature | k3s | Traditional k8s |
|---------|-----|-----------------|
| RAM Usage | ~512MB | ~2GB+ |
| Binary Size | ~100MB | ~1GB+ |
| Install Time | < 5 minutes | 30+ minutes |
| Dependencies | Embedded | Multiple |

## Course Structure

This course is structured for **self-paced learning** over 65 days:

### 🟢 Beginner (Days 1-20)
- k3s installation and basics
- kubectl fundamentals
- Your first deployment
- Core concepts (Pods, Services, Deployments)

### 🟡 Medium (Days 21-45)
- Storage (NFS, Longhorn)
- Networking (Ingress, Load Balancers)
- Monitoring (Prometheus, Grafana)
- Security (RBAC, Network Policies)
- Auto-scaling (HPA, KEDA)

### 🔴 Advanced (Days 46-65)
- Service Mesh (Istio)
- GitOps (ArgoCD)
- Complex applications
- Production best practices

## Quick Start

### Step 1: Install k3s

```bash
# One-line installation
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

# Verify installation
sudo k3s kubectl get nodes
```

### Step 2: Configure kubectl

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
export KUBECONFIG=~/.kube/config
kubectl get nodes
```

### Step 3: Deploy Your First App

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=ClusterIP
kubectl get pods
```

## Project Structure

```
k3slab/
├── setup/              # Step-by-step setup guides
│   ├── 01-installation.md
│   ├── 02-healthchecks.md
│   ├── 03-remote-access.md
│   ├── 04-first-app.md
│   ├── 05-architecture.md
│   └── 06-nfs-server.md
│
├── ansible/            # Ansible playbooks for deployment
│   ├── addons/        # Individual addon playbooks
│   ├── addons.yaml    # Deploy all addons
│   └── inventory.ini
│
├── kustomize/         # Kubernetes app configurations
│   ├── n8n/
│   ├── minio/
│   └── ...
│
├── challenges/         # Hands-on exercises
└── tutorials/         # In-depth tutorials
```

## Learning Path

### Week 1-2: Foundations
1. Install k3s ✓
2. Verify cluster health
3. Deploy first app
4. Understand k3s architecture
5. Learn kubectl basics

### Week 3-4: Core Addons
1. Set up NFS for storage
2. Install ArgoCD
3. Deploy monitoring (Prometheus + Grafana)
4. Configure ingress (Traefik)

### Week 5-8: Advanced Addons
1. Longhorn for persistent storage
2. MetalLB for load balancing
3. Security (RBAC, Network Policies)
4. Auto-scaling (HPA, KEDA)

### Week 9-13: Production Ready
1. Service Mesh (Istio)
2. GitOps best practices
3. Backup and disaster recovery
4. Multi-cluster management

## Deploy Addons

### Using Ansible (Recommended)

```bash
cd ansible
ansible-playbook -i inventory.ini addons.yaml
```

### Deploy Specific Addons

```bash
# Storage
ansible-playbook -i inventory.ini addons/longhorn.yaml

# Monitoring
ansible-playbook -i inventory.ini addons/prometheus.yaml

# Automation
ansible-playbook -i inventory.ini addons/n8n.yaml
```

## Available Addons

| Category | Addons |
|----------|--------|
| **Storage** | Longhorn, NFS, MinIO |
| **Networking** | Traefik, MetalLB, Ingress-Nginx |
| **Observability** | Prometheus, Grafana, Loki, Tempo |
| **CI/CD** | ArgoCD, GitLab |
| **Automation** | n8n, Portainer |
| **Databases** | PostgreSQL, Redis |

## Requirements

- **Hardware**: 2+ CPU cores, 2GB+ RAM
- **OS**: Ubuntu 20.04+, Debian 11+, or RHEL 8+
- **Access**: Root/sudo privileges

## Daily Learning

Follow our 65-day journey! Each day covers a specific topic with:
- **Theory** - What and why
- **Practice** - Hands-on exercises
- **Challenge** - Test your knowledge

## Next Steps

1. Start with [Setup Guide](./setup/01-installation.md)
2. Complete the [Challenges](./challenges/)
3. Deploy [Real Projects](./projects/)

## Links

- [k3s Official Docs](https://docs.k3s.io)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Ansible Docs](https://docs.ansible.com/)

---

**License**: MIT
