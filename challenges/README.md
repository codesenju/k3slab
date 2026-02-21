# k3s Challenges

Hands-on challenges to test your k3s skills. Complete them in order!

## Beginner Challenges

### Challenge 1: Deploy Your First App

**Objective:** Deploy a simple nginx web server

**Steps:**
1. Create a deployment with 2 replicas
2. Expose it via ClusterIP service
3. Verify pods are running
4. Test internal connectivity

**Solution:**
```bash
kubectl create deployment nginx --image=nginx --replicas=2
kubectl expose deployment nginx --port=80
kubectl get pods -l app=nginx
kubectl exec -it nginx-xxxxx -- /bin/bash
```

### Challenge 2: Scale Your Application

**Objective:** Practice scaling

**Steps:**
1. Scale deployment to 5 replicas
2. Observe pods being created
3. Scale down to 3
4. Check pod distribution

**Solution:**
```bash
kubectl scale deployment nginx --replicas=5
kubectl get pods -l app=nginx -w
kubectl scale deployment nginx --replicas=3
```

### Challenge 3: Update Your App

**Objective:** Perform a rolling update

**Steps:**
1. Change nginx image version
2. Watch the rollout
3. Rollback if needed

**Solution:**
```bash
kubectl set image deployment/nginx nginx=nginx:1.25
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx
kubectl rollout undo deployment/nginx
```

### Challenge 4: Create a ConfigMap

**Objective:** Manage configuration

**Steps:**
1. Create a ConfigMap with app config
2. Mount it as a volume in the pod
3. Verify the app reads it

**Solution:**
```bash
kubectl create configmap app-config --from-literal=DB_HOST=localhost
kubectl get configmap app-config -o yaml
```

### Challenge 5: Use Secrets

**Objective:** Securely store sensitive data

**Steps:**
1. Create a generic secret
2. Use it in environment variable
3. Verify it's available in pod

**Solution:**
```bash
kubectl create secret generic db-creds --from-literal=username=admin --from-literal=password=secret
kubectl get secret db-creds -o yaml
```

## Medium Challenges

### Challenge 6: Set Up Monitoring

**Objective:** Install Prometheus + Grafana

**Steps:**
1. Install kube-prometheus-stack via Helm
2. Access Grafana dashboard
3. Explore default metrics
4. Create a custom dashboard

**Solution:**
```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

### Challenge 7: Configure Ingress

**Objective:** Expose app to outside world

**Steps:**
1. Install ingress controller
2. Create Ingress resource
3. Add path-based routing

**Solution:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: nginx.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-svc
            port:
              number: 80
```

### Challenge 8: Set Up Persistent Storage

**Objective:** Deploy with persistent data

**Steps:**
1. Create PVC
2. Deploy with volume mount
3. Write data
4. Delete and recreate pod
5. Verify data persists

**Solution:**
```bash
kubectl apply -f pvc.yaml
kubectl apply -f deployment-with-pvc.yaml
```

### Challenge 9: Implement Auto-scaling

**Objective:** Scale based on CPU

**Steps:**
1. Create HPA
2. Generate load
3. Observe scaling

**Solution:**
```bash
kubectl autoscale deployment nginx --min=1 --max=10 --cpu-percent=80
kubectl get hpa
```

### Challenge 10: Use Network Policies

**Objective:** Secure pod communication

**Steps:**
1. Create default deny policy
2. Allow specific traffic
3. Test isolation

**Solution:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## Hard Challenges

### Challenge 11: GitOps with ArgoCD

**Objective:** Implement GitOps

**Steps:**
1. Install ArgoCD
2. Create application from Git
3. Sync changes automatically
4. Rollback via Git

**Solution:**
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Challenge 12: Service Mesh with Istio

**Objective:** Implement mTLS

**Steps:**
1. Install Istio
2. Enable sidecar injection
3. Configure mTLS
4. Visualize traffic

**Solution:**
```bash
istioctl install --set profile=demo
kubectl label namespace default istio-injection=enabled
```

### Challenge 13: Build a CI/CD Pipeline

**Objective:** Deploy via Tekton

**Steps:**
1. Install Tekton
2. Create pipeline
3. Build and deploy
4. Run tests

### Challenge 14: Multi-Cluster Management

**Objective:** Manage multiple k3s clusters

**Steps:**
1. Set up 2 k3s clusters
2. Install ArgoCD with external cluster
3. Deploy to both from single Git repo

### Challenge 15: Build a Production Cluster

**Objective:** HA k3s setup

**Steps:**
1. 3 master nodes
2. External etcd
3. Load balancer
4. HAProxy or MetalLB
5. Worker nodes

## Submit Your Solutions

Share your solutions on LinkedIn and tag the post!

#k3slab #kubernetes #devops #challenge
