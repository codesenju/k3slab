# Kubernetes Addons for k3s

This directory contains guides and manifests for deploying various Kubernetes addons on k3s.

## Categories

### Observability
- [Prometheus](./observability/prometheus.md) - Metrics collection
- [Grafana](./observability/grafana.md) - Dashboards and visualization
- [Loki](./observability/loki.md) - Log aggregation
- [Promtail](./observability/promtail.md) - Log collection
- [Alertmanager](./observability/alertmanager.md) - Alert routing

### Security
](./security/rbac- [RBAC.md) - Role-based access control
- [Network Policies](./security/network-policies.md) - Pod-to-pod security
- [Secrets Management](./security/secrets.md) - Using Vault or Sealed Secrets

### Networking
- [Traefik](./networking/traefik.md) - Built-in ingress (included with k3s)
- [MetalLB](./networking/metallb.md) - Load balancer for bare metal
- [Cilium](./networking/cilium.md) - eBPF networking and security

### Storage
- [Local Path Provisioner](./storage/local-path-provisioner.md) - Built-in with k3s
- [Longhorn](./storage/longhorn.md) - Cloud-native block storage
- [NFS Client](./storage/nfs-client.md) - NFS storage support

### Auto-scaling
- [Metrics Server](./autoscaling/metrics-server.md) - Built-in with k3s
- [Horizontal Pod Autoscaler](./autoscaling/hpa.md) - Pod scaling
- [KEDA](./autoscaling/keda.md) - Event-driven autoscaling

### CI/CD
- [ArgoCD](./cicd/argocd.md) - GitOps deployment
- [Tekton](./cicd/tekton.md) - Kubernetes-native pipelines
- [Jenkins](./cicd/jenkins.md) - Classic CI/CD

### Databases
- [PostgreSQL](./database/postgresql.md) - Using CloudNativePG
- [Redis](./database/redis.md) - Caching and message queues
- [MySQL](./database/mysql.md) - Using Operator

### Service Mesh
- [Istio](./servicemesh/istio.md) - Complete service mesh
- [Linkerd](./servicemesh/linkerd.md) - Lightweight service mesh

### Advanced
- [Knative](./advanced/knative.md) - Serverless on k3s
- [KubeVirt](./advanced/kubevirt.md) - Virtual machines in k3s
- [Krustlet](./advanced/krustlet.md) - WebAssembly runtime

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
1. **Monitoring** - Prometheus + Grafana (day 1)
2. **Logging** - Loki (after monitoring)
3. **Ingress** - Traefik (already included!)
4. **Storage** - Longhorn (when needed)

## Verify Installations

```bash
kubectl get pods -A
kubectl get storageclass
kubectl get ingressclass
```
