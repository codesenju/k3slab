# RBAC in k3s

## Default Roles

k3s comes with built-in roles:

| Role | Access |
|------|--------|
| `view` | Read-only access to most resources |
| `edit` | Can modify most resources, but not roles/bindings |
| `admin` | Full access except managing roles |
| `cluster-admin` | Superuser - can do anything |

## Create a User

### 1. Generate kubeconfig for user

```bash
# On k3s server
openssl genrsa -out user.key 2048
openssl req -new -key user.key -out user.csr -subj "/CN=user/O=developers"
openssl x509 -req -in user.csr -CA /var/lib/rancher/k3s/server/tls/client-ca.crt \
  -CAkey /var/lib/rancher/k3s/server/tls/client-ca.key \
  -CAcreateserial -out user.crt -days 365
```

### 2. Create kubeconfig

```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: <base64 of ca.crt>
    server: https://localhost:6443
  name: k3s-cluster
contexts:
- context:
    cluster: k3s-cluster
    user: user
  name: user@k3s-cluster
current-context: user@k3s-cluster
users:
- name: user
  user:
    client-certificate: user.crt
    client-key: user.key
```

## Create Role and Binding

### Namespace-Scoped Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: developer
rules:
- apiGroups: ["", "apps", "networking.k8s.io"]
  resources: ["deployments", "services", "pods", "ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: dev
subjects:
- kind: User
  name: developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

### Cluster-Scoped Role (ClusterRole)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: devops-engineer
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch", "update"]
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: devops-engineer-binding
subjects:
- kind: User
  name: developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: devops-engineer
  apiGroup: rbac.authorization.k8s.io
```

## ServiceAccount for Applications

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp-sa
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: myapp-role
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["myapp-config"]
  verbs: ["get", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: myapp-binding
subjects:
- kind: ServiceAccount
  name: myapp-sa
  namespace: default
roleRef:
  kind: Role
  name: myapp-role
  apiGroup: rbac.authorization.k8s.io
```

## Check Permissions

```bash
# As the user
kubectl auth can-i get pods
kubectl auth can-i create deployments --as=user@developers
```

## Best Practices

1. **Least privilege** - Give minimum permissions needed
2. **Use groups** - Assign permissions to groups, not users
3. **Audit regularly** - Review who has what access
4. **Use ServiceAccounts** - For applications, not user credentials
