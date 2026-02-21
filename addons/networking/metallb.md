# MetalLB - Load Balancer for Bare Metal k3s

MetalLB brings load balancer functionality to bare metal Kubernetes clusters.

## Install MetalLB

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
```

## Configure IP Address Pool

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
kubectl apply -f ip-pool.yaml
```

## Layer 2 vs BGP

### Layer 2 (ARP/NDP)

Simplest setup - one node responds to ARP requests.

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
```

### BGP (For Multiple Routers)

```yaml
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
  name: bgp-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
  peers:
  - my-bgp-peer
```

## Example: Deploy a Service with LoadBalancer

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
        image: nginx
        ports:
        - containerPort: 80
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
```

Get the external IP:
```bash
kubectl get svc nginx-lb
```

## Troubleshooting

### Check MetalLB Logs

```bash
kubectl logs -n metallb-system -l component=controller
kubectl logs -n metallb-system -l component=speaker
```

### Check Speaker Pod

```bash
kubectl get pods -n metallb-system -o wide
```

### Common Issues

1. **No IP assigned** - Check address pool configuration
2. **ARP not working** - Verify network switch allows ARP
3. **Service stuck** - Check MetalLB pods are running
