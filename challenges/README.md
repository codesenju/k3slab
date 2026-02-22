# Kubernetes Challenges

Test your Kubernetes skills with these hands-on exercises!

## Challenge Levels

- 🟢 **Beginner** - Basic concepts
- 🟡 **Medium** - Intermediate topics
- 🔴 **Advanced** - Production scenarios

---

## Beginner Challenges

### Challenge 1: Deploy Your First App ⭐

**Objective:** Deploy a simple nginx web server

**Steps:**
1. Create a deployment with 2 replicas
2. Expose it via ClusterIP service
3. Verify pods are running

**Solution:**
```bash
# Create deployment
kubectl create deployment nginx --image=nginx --replicas=2

# Expose service
kubectl expose deployment nginx --port=80

# Verify
kubectl get pods
kubectl get svc
```

---

### Challenge 2: Scale Your App ⭐

**Objective:** Practice scaling

**Steps:**
1. Scale deployment to 5 replicas
2. Observe pods being created
3. Scale down to 3

**Solution:**
```bash
kubectl scale deployment nginx --replicas=5
kubectl get pods -w
kubectl scale deployment nginx --replicas=3
```

---

### Challenge 3: Update Your App ⭐

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

---

### Challenge 4: Create a ConfigMap ⭐

**Objective:** Manage configuration

**Steps:**
1. Create a ConfigMap with app config
2. Mount it in a pod

**Solution:**
```bash
# Create ConfigMap
kubectl create configmap app-config --from-literal=DB_HOST=localhost --from-literal=LOG_LEVEL=info

# View it
kubectl get configmap app-config -o yaml
```

---

### Challenge 5: Use Secrets ⭐

**Objective:** Securely store sensitive data

**Steps:**
1. Create a generic secret
2. Use it in environment variable

**Solution:**
```bash
kubectl create secret generic db-creds \
  --from-literal=username=admin \
  --from-literal=password=secret123

# Use in pod
kubectl set env deployment/nginx DB_PASSWORD=secret(db-creds.password)
```

---

## Medium Challenges

### Challenge 6: Set Up Monitoring ⭐⭐

**Objective:** Install Prometheus + Grafana

**Steps:**
1. Install kube-prometheus-stack via Helm
2. Access Grafana dashboard
3. Explore default metrics

**Solution:**
```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

---

### Challenge 7: Configure Ingress ⭐⭐

**Objective:** Expose app to outside world

**Steps:**
1. Create Ingress resource
2. Add path-based routing
3. Test from browser

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
            name: nginx
            port:
              number: 80
```

---

### Challenge 8: Persistent Storage ⭐⭐

**Objective:** Deploy with persistent data

**Steps:**
1. Create PVC with NFS storage
2. Deploy with volume mount
3. Write data
4. Delete and recreate pod

**Solution:**
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-data
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-client
  resources:
    requests:
      storage: 1Gi
EOF
```

---

### Challenge 9: Auto-scaling ⭐⭐

**Objective:** Scale based on CPU

**Steps:**
1. Create HPA
2. Generate load
3. Observe scaling

**Solution:**
```bash
kubectl autoscale deployment nginx --min=1 --max=10 --cpu-percent=80
kubectl get hpa

# Generate load (in another terminal)
kubectl run -it load-generator --image=busybox -- /bin/sh
# Then run:
while true; do wget -q -O- http://nginx; done
```

---

### Challenge 10: Network Policies ⭐⭐

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

---

## Advanced Challenges

### Challenge 11: GitOps with ArgoCD ⭐⭐⭐

**Objective:** Implement GitOps

**Steps:**
1. Install ArgoCD
2. Create application from Git
3. Sync changes automatically

**Solution:**
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

---

### Challenge 12: Service Mesh ⭐⭐⭐

**Objective:** Implement mTLS

**Steps:**
1. Install Istio
2. Enable sidecar injection
3. Configure mTLS

**Solution:**
```bash
curl -L https://istio.io/downloadIstio | sh -
istioctl install --set profile=demo
kubectl label namespace default istio-injection=enabled
```

---

### Challenge 13: Custom Resources ⭐⭐⭐

**Objective:** Create and use CRDs

**Steps:**
1. Create a custom resource definition
2. Deploy a custom resource
3. Write a controller (optional)

**Solution:**
```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.example.com
spec:
  group: example.com
  names:
    kind: Backup
    plural: backups
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
```

---

### Challenge 15: Production Cluster ⭐⭐⭐

**Objective:** Build a production-ready cluster

**Steps:**
1. Multiple master nodes
2. External etcd
3. Load balancer
4. Worker nodes

This requires:
- 3+ VMs
- External database
- Proper networking

---

## How to Use These Challenges

1. **Start with Beginner** - Complete challenges 1-5
2. **Move to Medium** - Complete challenges 6-10
3. **Advance to Hard** - Complete challenges 11-15

## Tips

- Use `kubectl explain` to learn about resources
- Use `kubectl --dry-run=client -o yaml` to generate manifests
- Use `kubectl get events --sort-by='.lastTimestamp'` to debug
- Use `kubectl top pods` to check resource usage

## Next Steps

- [Deploy real projects](../projects/)
- [Learn about addons](../ansible/)
- [Build your home lab](../setup/06-nfs-server.md)
