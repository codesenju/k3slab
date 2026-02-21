# Kubernetes Addons for k3s

This directory contains guides and manifests for deploying various Kubernetes addons on k3s.

## Quick Deploy via Ansible (Recommended)

The fastest way to deploy addons is using our Ansible playbooks:

```bash
# Install k3s first
ansible-playbook -i inventory.ini install-k3s.yaml

# Deploy all addons via ArgoCD
ansible-playbook -i inventory.ini addons.yaml

# Or deploy specific addon
ansible-playbook -i inventory.ini addons/argocd.yaml
```

## Manual Installation

### Observability
- [Prometheus](./observability/prometheus.md) - Metrics collection
- [Grafana](./observability/grafana.md) - Dashboards and visualization
- [Loki](./observability/loki.md) - Log aggregation
- [Promtail](./observability/promtail.md) - Log collection
- [Alertmanager](./observability/alertmanager.md) - Alert routing
- [Argocd](./observability/argocd.md) - GitOps deployment
- [Headlamp](./observability/headlamp.md) - Kubernetes Dashboard
- [Goldilocks](./observability/goldilocks.md) - Resource recommendations
- [Alloy](./observability/alloy.md) - Grafana Alloy (formerly Agent)
- [Mimir](./observability/mimir.md) - Metrics storage
- [Tempo](./observability/tempo.md) - Distributed tracing
- [OpenSearch](./observability/opensearch.md) - Search & analytics
- [OpenTelemetry](./observability/opentelemetry.md) - Observability framework

### Security
- [RBAC](./security/rbac.md) - Role-based access control
- [Network Policies](./security/network-policies.md) - Pod-to-pod security
- [Cert-Manager](./security/cert-manager.md) - TLS certificates

### Networking
- [Traefik](./networking/traefik.md) - Built-in ingress (included with k3s)
- [Ingress-Nginx](./networking/ingress-nginx.md) - Nginx ingress controller
- [MetalLB](./networking/metallb.md) - Load balancer for bare metal
- [Cilium](./networking/cilium.md) - eBPF networking and security
- [Cloudflared](./networking/cloudflared.md) - Cloudflare Tunnel
- [External DNS](./networking/external-dns.md) - Automatic DNS records
- [Nginx Proxy Manager](./networking/nginx-proxy-manager.md) - Reverse proxy

### Storage
- [Local Path Provisioner](./storage/local-path-provisioner.md) - Built-in with k3s
- [Longhorn](./storage/longhorn.md) - Cloud-native block storage
- [NFS Client](./storage/nfs-client.md) - NFS storage support
- [MinIO](./storage/minio.md) - S3-compatible storage

### Auto-scaling
- [Metrics Server](./autoscaling/metrics-server.md) - Built-in with k3s
- [Horizontal Pod Autoscaler](./autoscaling/hpa.md) - Pod scaling
- [KEDA](./autoscaling/keda.md) - Event-driven autoscaling

### CI/CD
- [ArgoCD](./cicd/argocd.md) - GitOps deployment
- [Tekton](./cicd/tekton.md) - Kubernetes-native pipelines
- [Jenkins](./cicd/jenkins.md) - Classic CI/CD

### Automation
- [GitLab](./automation/gitlab.md) - Self-hosted Git repository
- [Gitea](./automation/gitea.md) - Lightweight Git service
- [Harbor](./automation/harbor.md) - Container registry
- [Portainer](./automation/portainer.md) - Container management
- [n8n](./automation/n8n.md) - Workflow automation

### Databases
- [PostgreSQL](./database/postgresql.md) - Using CloudNativePG
- [Redis](./database/redis.md) - Caching and message queues
- [MongoDB](./database/mongodb.md) - Using Operator

### Service Mesh
- [Istio](./servicemesh/istio.md) - Complete service mesh

### Advanced
- [Crossplane](./advanced/crossplane.md) - Infrastructure as Code
- [Homarr](./advanced/homarr.md) - Dashboard
- [Immich](./advanced/immich.md) - Photo management
- [Ntfy](./advanced/ntfy.md) - Notifications

### Identity
- [Authentik](./identity/authentik.md) - Identity Provider

## GitOps with ArgoCD (Recommended)

All addons can be deployed via ArgoCD for GitOps-style management:

```bash
# Install ArgoCD
ansible-playbook -i inventory.ini addons/argocd.yaml

# Deploy addons
kubectl apply -f ansible/manifests/argocd-longhorn.yaml
kubectl apply -f ansible/manifests/argocd-prometheus.yaml
kubectl apply -f ansible/manifests/argocd-metallb.yaml
```

## Quick Install Examples

### Prometheus + Grafana (Monitoring Stack)

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

### MetalLB (Load Balancer)

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
```

### Longhorn (Storage)

```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/deploy/longhorn.yaml
```

## Choosing Addons

Start with:
1. **ArgoCD** - GitOps deployment (install first!)
2. **Monitoring** - Prometheus + Grafana
3. **Logging** - Loki (after monitoring)
4. **Ingress** - Traefik (already included!)
5. **Storage** - Longhorn (when needed)

## Verify Installations

```bash
kubectl get pods -A
kubectl get storageclass
kubectl get ingressclass
```
