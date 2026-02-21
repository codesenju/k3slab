# Your First Kubernetes Application

In this guide, you'll deploy your first application to k3s and learn the fundamental Kubernetes concepts.

## What You'll Learn

- ✅ Deploy an application to Kubernetes
- ✅ Expose it via a Service
- ✅ Scale the application
- ✅ Update the application
- ✅ Clean up

## Prerequisites

- k3s installed and running
- kubectl configured

Verify your cluster:
```bash
kubectl get nodes
```

Expected output:
```
NAME          STATUS   ROLES           AGE   VERSION
workstation   Ready    control-plane   5m    v1.34.4+k3s1
```

## Step 1: Create a Deployment

A **Deployment** tells Kubernetes how to run your application.

```bash
kubectl create deployment nginx --image=nginx:latest
```

Let's break this down:
- `kubectl create deployment` - Create a deployment
- `nginx` - Name of your deployment
- `--image=nginx:latest` - Container image to use

### Verify the Deployment

```bash
kubectl get deployments
kubectl get pods
```

Expected output:
```
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           30s
```

## Step 2: Expose the Service

A **Service** exposes your application to the network.

```bash
kubectl expose deployment nginx --port=80 --type=ClusterIP
```

### Service Types

| Type | Description |
|------|-------------|
| ClusterIP | Internal only (default) |
| NodePort | Exposes on each node's IP |
| LoadBalancer | External load balancer |
| ExternalName | DNS CNAME alias |

### Verify the Service

```bash
kubectl get services
```

Expected output:
```
NAME         TYPE        CLUSTER-IP      PORT(S)   AGE
nginx        ClusterIP   10.43.120.15   80/TCP    5m
```

## Step 3: Access Your App

### Option 1: From Within the Cluster

```bash
# Create a test pod
kubectl run test --rm -it --image=busybox -- sh

# Inside the pod, run:
wget -qO- http://nginx
```

### Option 2: Port Forward (Recommended for Dev)

```bash
kubectl port-forward deployment/nginx 8080:80

# Now open http://localhost:8080 in your browser
```

## Step 4: Scale Your Application

Kubernetes makes it easy to scale:

```bash
# Scale to 3 replicas
kubectl scale deployment nginx --replicas=3

# Verify
kubectl get pods -l app=nginx
```

You should see 3 nginx pods running:
```
NAME                    READY   STATUS    AGE
nginx-8f6d9d7d9-abcde   1/1     Running   1m
nginx-8f6d9d7d9-fghij   1/1     Running   1m
nginx-8f6d9d7d7-klmno   1/1     Running   1m
```

## Step 5: Update Your Application

### Update the Image

```bash
# Update to a specific version
kubectl set image deployment/nginx nginx=nginx:1.25-alpine

# Watch the rollout
kubectl rollout status deployment/nginx
```

### Check Rollout History

```bash
kubectl rollout history deployment/nginx
```

### Rollback if Needed

```bash
kubectl rollout undo deployment/nginx
```

## Step 6: View Logs

```bash
# View logs from a pod
kubectl logs deployment/nginx

# Follow logs in real-time
kubectl logs -f deployment/nginx
```

## Step 7: Clean Up

When you're done, clean up:

```bash
# Delete the deployment (removes pods and replicaset)
kubectl delete deployment nginx

# Delete the service
kubectl delete service nginx

# Verify cleanup
kubectl get all
```

## Key Concepts Summary

### Pod
- Smallest deployable unit
- Contains one or more containers
- Ephemeral (can be killed/restarted)

### Deployment
- Manages Pods
- Provides declarative updates
- Handles scaling and rollbacks

### Service
- Stable network endpoint
- Load balances across Pods
- Types: ClusterIP, NodePort, LoadBalancer

### ReplicaSet
- Ensures N replicas are running
- Managed by Deployment

## Challenge

Try deploying a different application:
- WordPress
- Ghost (blog)
- Prometheus

Example:
```bash
kubectl create deployment ghost --image=ghost
kubectl expose deployment ghost --port=2368
```

## Next Steps

- [Learn about Kubernetes Architecture](./05-architecture.md)
- [Set up persistent storage](./06-nfs-server.md)
- [Deploy with ArgoCD](../ansible/addons/argocd.yaml)
