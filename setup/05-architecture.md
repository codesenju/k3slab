# k3s Architecture Deep Dive

## What Makes k3s Different?

### Traditional Kubernetes

Multiple components:
- kube-apiserver
- etcd
- kube-controller-manager
- kube-scheduler
- kubelet
- kube-proxy
- containerd/container runtime
- CNI plugin
- Metrics server

Each can be separately configured and updated.

### k3s: All-in-One

Single binary (~100MB) containing:
- All control plane components
- Embedded SQLite (instead of etcd)
- Container runtime
- CNI (Flannel by default)

## k3s vs k8s Comparison

| Feature | k3s | k8s |
|---------|-----|-----|
| Binary Size | ~100MB | ~1GB+ |
| Memory Usage | ~512MB | ~2GB+ |
| Installation | 1 command | Multiple steps |
| etcd | SQLite (default) | External etcd cluster |
| Default CNI | Flannel | None (you choose) |
| Updates | Simple | Complex |

## Components Explained

### Control Plane

```
┌─────────────────────────────────────┐
│           k3s Binary                │
│  ┌───────────────────────────────┐  │
│  │     API Server (REST)        │  │
│  ├───────────────────────────────┤  │
│  │   Controller Manager         │  │
│  ├───────────────────────────────┤  │
│  │      Scheduler               │  │
│  ├───────────────────────────────┤  │
│  │        etcd/SQLite          │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Data Plane

```
┌─────────────┐   ┌─────────────┐
│   Node 1    │   │   Node 2    │
│ ┌─────────┐ │   │ ┌─────────┐ │
│ │ kubelet │ │   │ │ kubelet │ │
│ ├─────────┤ │   │ ├─────────┤ │
│ │ kube-   │ │   │ │ kube-   │ │
│ │ proxy   │ │   │ │ proxy   │ │
│ └─────────┘ │   └─────────┘ │
└─────────────┘   └─────────────┘
```

## Storage

### Embedded SQLite (Default)

```bash
# Data location
/var/lib/rancher/k3s/server/db/
```

### External Database (Production)

For production, use external etcd:

```bash
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--datastore-endpoint=mysql://user:pass@tcp(host:3306)/k3s" \
  sh -
```

## Networking

### Default CNI: Flannel

- Layer 3 overlay network
- Uses VXLAN by default
- Simple, works out of the box

### Alternative CNIs

- **Cilium** - eBPF-based, advanced features
- **Calico** - Full-featured, policy engine
- **Weave Net** - Simple, encrypted mesh

## High Availability

For HA k3s, you'll need:
- 3+ server nodes
- External database (MySQL/PostgreSQL/etcd)
- Load balancer for API server

```
                    ┌──────────────┐
                    │ Load Balancer│
                    └──────┬───────┘
           ┌──────────────┼──────────────┐
           │              │              │
      ┌────▼────┐   ┌────▼────┐   ┌────▼────┐
      │ Server 1│   │ Server 2│   │ Server 3│
      │   k3s   │   │   k3s   │   │   k3s   │
      └─────────┘   └─────────┘   └─────────┘
           │              │              │
           └──────────────┼──────────────┘
                          │
                    ┌─────▼─────┐
                    │   etcd    │
                    │  Cluster  │
                    └───────────┘
```

## Next Steps

- [Deploy Your First App](./04-first-app.md)
- [Explore Addons](../addons/)
