# Tutorial: Deploy a Web Application

In this tutorial, you'll deploy a complete web application with backend and database.

## What You'll Build

```
┌─────────────────────────────────────────────┐
│              Web Application                   │
├─────────────────────────────────────────────┤
│                                              │
│  ┌─────────────┐     ┌─────────────┐        │
│  │  Frontend  │────►│   Backend   │        │
│  │   (Next.js) │     │   (API)     │        │
│  └─────────────┘     └──────┬──────┘        │
│                             │                 │
│                      ┌──────▼──────┐         │
│                      │  Database   │         │
│                      │ (PostgreSQL)│         │
│                      └─────────────┘         │
│                                              │
└─────────────────────────────────────────────┘
```

## Prerequisites

- k3s installed
- kubectl configured
- NFS storage (for persistent data)

## Step 1: Create Namespace

```bash
kubectl create namespace webapp
```

## Step 2: Create Secrets

```bash
# Create database credentials
kubectl create secret generic db-credentials \
  --from-literal=POSTGRES_PASSWORD=changeme \
  --from-literal=POSTGRES_USER=webapp \
  --from-literal=POSTGRES_DB=webapp \
  -n webapp
```

## Step 3: Create Database Deployment

Create `postgres.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: webapp
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-client
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: POSTGRES_PASSWORD
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: POSTGRES_USER
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: POSTGRES_DB
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      volumes:
      - name: postgres-data
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: webapp
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

Apply:

```bash
kubectl apply -f postgres.yaml
```

## Step 4: Create Backend Deployment

Create `backend.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: nginx:alpine
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          value: postgresql://webapp:changeme@postgres.webapp.svc.cluster.local:5432/webapp
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: webapp
spec:
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080
```

Apply:

```bash
kubectl apply -f backend.yaml
```

## Step 5: Create Frontend Deployment

Create `frontend.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
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
  name: frontend
  namespace: webapp
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webapp-ingress
  namespace: webapp
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: webapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
```

Apply:

```bash
kubectl apply -f frontend.yaml
```

## Step 6: Verify Deployment

```bash
# Check all resources
kubectl get all -n webapp

# Check pods
kubectl get pods -n webapp -w

# Wait for all to be Running
```

## Step 7: Access the Application

### Option 1: Port Forward

```bash
# Frontend
kubectl port-forward -n webapp svc/frontend 8080:80

# Backend
kubectl port-forward -n webapp svc/backend 8081:8080
```

### Option 2: Add to /etc/hosts

```bash
echo "127.0.0.1 webapp.local" | sudo tee -a /etc/hosts
```

Then open http://webapp.local in your browser.

## Step 8: Scale the Application

```bash
# Scale frontend
kubectl scale deployment frontend --replicas=5 -n webapp

# Scale backend
kubectl scale deployment backend --replicas=3 -n webapp

# Check
kubectl get pods -n webapp
```

## Step 9: Monitor Resources

```bash
# Check resource usage
kubectl top pods -n webapp

# Check events
kubectl get events -n webapp --sort-by='.lastTimestamp'
```

## Step 10: Clean Up

```bash
# Delete namespace (removes everything)
kubectl delete namespace webapp

# Or delete resources individually
kubectl delete -f frontend.yaml
kubectl delete -f backend.yaml
kubectl delete -f postgres.yaml
```

## What You Learned

- ✅ Create namespaces
- ✅ Manage secrets
- ✅ Deploy databases with persistent storage
- ✅ Deploy backend APIs
- ✅ Deploy frontend applications
- ✅ Expose services with Ingress
- ✅ Scale applications
- ✅ Monitor resources
- ✅ Clean up resources

## Next Steps

- Add health checks to containers
- Set up auto-scaling with HPA
- Add TLS with cert-manager
- Set up monitoring with Prometheus
- Implement CI/CD with ArgoCD
