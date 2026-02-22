# k3s Architecture Deep Dive

In this guide, you'll understand how k3s works under the hood and why it's different from traditional Kubernetes.

## What You'll Learn

- ✅ How k3s is structured
- ✅ What's embedded in the single binary
- ✅ How networking works
- ✅ When to use external databases

## What Makes k3s Different?

### Traditional Kubernetes

A typical Kubernetes cluster has many separate components:

```
┌─────────────────────────────────────────────────────────┐
│              Traditional Kubernetes                       │
├─────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │ API      │  │Scheduler │  │ Controller       │   │
│  │ Server   │  │          │  │ Manager         │   │
│  └──────────┘  └──────────┘  └──────────────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │  etcd    │  │ kubelet  │  │ kube-proxy      │   │
│  │          │  │          │  │                  │   │
│  └──────────┘  └──────────┘  └──────────────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │containerd│  │CNI Plugin│  │ Metrics Server   │   │
│  └──────────┘  └──────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────┘
  Each component runs as a separate process
  Total: 100+ processes, 2GB+ RAM
```

### k3s: All-in-One

k3s combines everything into a single binary:

```
┌─────────────────────────────────────────────────────────┐
│                      k3s Binary                          │
│                    (~100MB total)                        │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐  │
│  │           All-in-One Binary                      │  │
│  │  • API Server    • Scheduler                   │  │
│  │  • Controller    • etcd (SQLite)              │  │
│  │  • kubelet       • Containerd                   │  │
│  │  • kube-proxy   • CNI (Flannel)               │  │
│  │  • Metrics Server                              │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
  Single process, ~512MB RAM
```

## k3s vs Kubernetes Comparison

| Feature | k3s | Kubernetes |
|---------|-----|------------|
| Binary Size | ~100MB | ~1GB+ |
| RAM Usage | ~512MB | ~2GB+ |
| Installation | 1 command | Multiple steps |
| Startup Time | ~30 seconds | ~5 minutes |
| Dependencies | None | Many |
| Default Storage | SQLite | etcd |
| Default CNI | Flannel | None |
| Updates | Simple | Complex |

## Components Explained

### Control Plane (Master)

The control plane manages the cluster:

| Component | What it does |
|----------|-------------|
| **API Server** | REST API for all cluster operations |
| **Scheduler** | Decides where pods run |
| **Controller Manager** | Ensures desired state |
| **etcd/SQLite** | Cluster database |

### Data Plane (Worker)

Worker nodes run your workloads:

| Component | What it does |
|----------|-------------|
| **kubelet** | Manages containers on the node |
| **kube-proxy** | Network proxy/load balancer |
| **Container Runtime** | Runs containers (containerd) |
| **CNI** | Pod networking (Flannel) |

## How Pods Communicate

```
┌─────────────────────────────────────────────────────────┐
│                  Pod Networking                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Pod A              Pod B              Pod C            │
│  ┌────────┐        ┌────────┐        ┌────────┐    │
│  │nginx   │        │app     │        │db      │    │
│  │10.42.0.2│◄────►│10.42.0.3│◄────►│10.42.0.4│    │
│  └────────┘        └────────┘        └────────┘    │
│       │                                    │          │
│       └──────────┬──────────────────────┘          │
│                  ▼                                    │
│         ┌────────────────┐                          │
│         │   Service     │                          │
│         │  10.43.0.1    │  (Stable IP)           │
│         └────────────────┘                          │
│                  │                                    │
│                  ▼                                    │
│         ┌────────────────┐                          │
│         │  CNI (Flannel) │                         │
│         │  VXLAN Overlay │                         │
│         └────────────────┘                          │
└─────────────────────────────────────────────────────────┘
```

## Storage Options

### Embedded SQLite (Default)

For learning and development:

```bash
# Data location
/var/lib/rancher/k3s/server/db/

# Simple, no setup needed
```

### External Database (Production)

For production, use an external database:

```bash
# MySQL
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--datastore-endpoint=mysql://user:pass@tcp(mysql:3306)/k3s" \
  sh -

# PostgreSQL  
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--datastore-endpoint=postgresql://user:pass@pg:5432/k3s" \
  sh -

# etcd cluster
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--datastore-endpoint=https://etcd:2379" \
  sh -
```

## Networking

### Default: Flannel

k3s uses Flannel by default:

- **Type**: VXLAN overlay network
- **Pod Network**: 10.42.0.0/16 (default)
- **Service Network**: 10.43.0.0/16 (default)

### Alternative CNIs

| CNI | Use Case |
|-----|----------|
| **Flannel** | Simple, default |
| **Calico** | Policy, BGP |
| **Cilium** | eBPF, performance |
| **Weave** | Encryption |

To use a different CNI:

```bash
# Disable default CNI
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --disable=klipper-lb" sh -

# Then install your CNI
kubectl apply -f <cni-manifest.yaml>
```

## High Availability

### Single Node (Learning)

```
┌─────────────────────┐
│   k3s Server        │
│  ┌───────────────┐  │
│  │ Control Plane│  │
│  │ + Worker     │  │
│  └───────────────┘  │
└─────────────────────┘
```

### High Availability (Production)

```
┌─────────────────────────────────────────────────────┐
│                   Load Balancer                       │
└──────────────────────┬──────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   ┌────────┐   ┌────────┐   ┌────────┐
   │Server 1│   │Server 2│   │Server 3│
   │  k3s   │   │  k3s   │   │  k3s   │
   └────────┘   └────────┘   └────────┘
        │              │              │
        └──────────────┼──────────────┘
                       ▼
               ┌─────────────┐
               │  External   │
               │   etcd     │
               │  Cluster    │
               └─────────────┘
```

For HA, you need:
- 3+ server nodes
- External database
- Load balancer

## Key Files and Directories

| Path | Purpose |
|------|---------|
| `/etc/rancher/k3s/k3s.yaml` | kubeconfig |
| `/var/lib/rancher/k3s/` | Data directory |
| `/var/lib/rancher/k3s/server/db/` | SQLite database |
| `/var/lib/rancher/k3s/agent/` | Agent data |
| `/usr/local/bin/k3s` | Binary |

## Next Steps

- [Deploy your first app](./04-first-app.md)
- [Set up NFS storage](./06-nfs-server.md)
- [Learn about Kubernetes objects](https://kubernetes.io/docs/concepts/)
