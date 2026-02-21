# MetalLB - Load Balancer for Bare Metal Kubernetes

## What is MetalLB?

MetalLB is a load balancer designed for bare metal Kubernetes clusters. In cloud environments, load balancers are provided by the cloud provider. On bare metal (or when running k3s on VMs), you need MetalLB to provide LoadBalancer services.

### Why MetalLB?

```
┌─────────────────────────────────────────────────────────┐
│                    Cloud Environment                      │
│  ┌─────────────┐    ┌─────────────┐                     │
│  │   Ingress   │───▶│ LoadBalancer│───▶ Cloud LB       │
│  │   Controller│    │   Service   │    (AWS/GCP/Azure) │
│  └─────────────┘    └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                   Bare Metal / k3s                       │
│  ┌─────────────┐    ┌─────────────┐                     │
│  │   Ingress   │───▶│ LoadBalancer│───▶ MetalLB       │
│  │   Controller│    │   Service   │    (Your Network)  │
│  └─────────────┘    └─────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

### Key Features

- **Layer 2 Mode** - Uses ARP to announce IPs (simple)
- **BGP Mode** - For advanced routing (more scalable)
- **IP Address Pool** - Define ranges to assign
- **Kubernetes Native** - Standard LoadBalancer service

## Prerequisites

- k3s cluster
- Network connectivity to your cluster nodes
- Available IP addresses for MetalLB to use

## Quick Install

### Option 1: Use Ansible Playbook (Recommended)

```bash
cd ansible
ansible-playbook -i inventory.ini addons/metallb.yaml
```

This will:
- Install MetalLB via manifest
- Configure IP address pool (192.168.1.100-192.168.1.200)
- Set up Layer 2 advertisement

### Option 2: Manual Installation

```bash
# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Verify installation
kubectl get pods -n metallb-system
```

## Configuration

### Create IP Address Pool

Create `metallb-config.yaml`:

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.100-192.168.1.200
  - 10.0.0.100-10.0.0.200
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
```

Apply:

```bash
kubectl apply -f metallb-config.yaml
```

## Using MetalLB

### 1. Create a LoadBalancer Service

Create `nginx-service.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-lb
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  # Optionally specify the IP (must be in the pool)
  # loadBalancerIP: 192.168.1.100
```

Apply:

```bash
kubectl apply -f nginx-service.yaml
```

### 2. Check the Assigned IP

```bash
kubectl get svc nginx-lb

# Output:
# NAME       TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
# nginx-lb   LoadBalancer   10.43.0.123   192.168.1.100   80:31234/TCP   30s
```

### 3. Access Your Service

Now you can access your service at `http://192.168.1.100:80`

## Layer 2 vs BGP Mode

### Layer 2 Mode (Default)

Simpler setup - one node responds to ARP requests:

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advertisement
spec:
  ipAddressPools:
  - default-pool
```

**Pros:**
- Simple setup
- Works with any network switch
- No router configuration needed

**Cons:**
- Single point of failure (one node handles traffic)
- No true load balancing

### BGP Mode (Advanced)

For true load balancing with router:

```yaml
apiVersion: metallb.io/v1beta1
kind: BGPPeer
metadata:
  name: peer-1
spec:
  peerAddress: 192.168.1.1
  peerASN: 65001
  myASN: 65000
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: bgp-advertisement
spec:
  ipAddressPools:
  - default-pool
  peers:
  - peer-1
```

**Pros:**
- True load balancing
- Multiple nodes can announce IPs
- Better scalability

**Cons:**
- Requires BGP-capable router
- More complex setup

## Using with Ingress

MetalLB works great with Ingress controllers:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 80
---
apiVersion: v1
kind: Service
metadata:
  name: traefik
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: traefik
  ports:
  - port: 80
    targetPort: 80
  - port: 443
    targetPort: 443
```

Now Traefik will get an external IP from MetalLB!

## Troubleshooting

### Service Stuck in Pending

```bash
# Check MetalLB logs
kubectl logs -n metallb-system -l component=speaker

# Check events
kubectl describe svc my-service
```

### IP Not Assigned

1. Verify IP pool is configured correctly
2. Check if IPs are in use by other services
3. Ensure network allows ARP

### Check MetalLB Status

```bash
# Verify all pods are running
kubectl get pods -n metallb-system

# Check address pool
kubectl get ipaddresspools.metallb.io -n metallb-system

# Check L2 advertisement
kubectl get l2advertisement.metallb.io -n metallb-system
```

## Example: Multiple Services

```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress
spec:
  type: LoadBalancer
  selector:
    app: wordpress
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: wordpress-db
spec:
  type: LoadBalancer
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

## Best Practices

1. **Use separate IP ranges** for different environments
2. **Reserve IPs** for critical services
3. **Use Ingress** instead of multiple LoadBalancers when possible
4. **Monitor** MetalLB logs in production
5. **Consider BGP** for high availability

## Uninstall

```bash
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
kubectl delete ipaddresspools.metallb.io default-pool -n metallb-system
kubectl delete l2advertisement.metallb.io default -n metallb-system
```

## Related Addons

- [Traefik](./networking/traefik.md) - Ingress controller
- [Ingress-Nginx](./networking/ingress-nginx.md) - Alternative ingress
- [ArgoCD](./observability/argocd.md) - Deploy via GitOps
