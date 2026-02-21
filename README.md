# k3slab 🧪

Learn and explore Kubernetes addons using k3s - the lightweight Kubernetes.

## What is k3s?

k3s is a fully compliant Kubernetes distribution that is:
- Lightweight (< 512MB RAM)
- Single binary installation
- Perfect for learning, edge, and resource-constrained environments

## Getting Started

1. **Install k3s:** See `/setup/01-installation.md`
2. **Verify your cluster:** `kubectl get nodes`
3. **Explore addons:** Browse the `/addons` directory

## Project Structure

```
k3slab/
├── setup/           # Getting started guides
│   ├── 01-installation.md
│   ├── 02-healthchecks.md
│   └── ...
├── addons/          # Kubernetes addons by category
│   ├── observability/
│   ├── security/
│   ├── networking/
│   ├── storage/
│   └── ...
├── tutorials/       # Step-by-step tutorials
├── projects/        # Real-world projects
└── challenges/      # Hands-on challenges
```

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
- **Best Practices** - Production tips

## Difficulty Levels

- 🟢 **Beginner** - Foundational concepts
- 🟡 **Medium** - Intermediate topics
- 🔴 **Hard** - Advanced configurations

## Daily Learning Path

Follow our 65-day journey from zero to hero!

## Requirements

- A Linux machine (VM, bare metal, or Raspberry Pi)
- 512MB+ RAM
- Root or sudo access

## License

MIT
