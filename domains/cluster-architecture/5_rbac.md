# RBAC

## Main RBAC resources

- Role
- ClusterRole
- RoleBinding
- ClusterRoleBinding

**Verbs:** get, list, watch, create, update, patch, delete, deletecollection, bind, escalate, impersonate
**Resources**: **ns**: pods, pods/exec, deployments, services, configmaps, secrets, **cluster**: namespaces, nodes, pv, crd, sc

## Traps

- **RoleBinding can reference Role or ClusterRole** within `ns`
- (aka sudo) To create Role/RoleBinding with elevated permissions you need: `bind`, `escalate`. Create a ClusterRole for yourself.
- Use Group: `system:authenticated` — grant permissions to all users and ServiceAccounts.

## Built-in (Basic) ClusterRole

| ClusterRole Name          | Purpose                                                               |
| ------------------------- | --------------------------------------------------------------------- |
| cluster-admin             | Super-user access (full control over all resources in the cluster)    |
| admin                     | Admin access within a namespace (most resources, except RBAC)         |
| edit                      | Allows read/write access to most resources in a namespace             |
| view                      | Read-only access to most resources in a namespace                     |
| system:auth-delegator     | Used for delegated authentication/authorization checks                |
| system:basic-user         | Minimal access for authenticated users (e.g., discover API endpoints) |
| system:discovery          | Access to API discovery endpoints                                     |
| system:public-info-viewer | Read access to non-sensitive cluster info (e.g., nodes, namespaces)   |
| system:node               | Access for kubelets (node management)                                 |

It’s convenient to check:
```sh
 k describe clusterrole cluster-admin
```

## User vs ServiceAccount

- User is created using a certificate (not stored in the cluster) or OIDC.
- User from the certificate: `"/CN=jane/O=developers"`
- `--resource-name=readablepod` — the rule applies only to the specified resource

## Commands

**View the current kubeconfig:**

```bash
kubectl config view
```

**See who I am:**

```bash
k auth whoami
```

List all permissions for the user:

```sh
kubectl auth can-i --list --as=system:serviceaccount:admin-tools:kubectl-view-sa

```

**Check an action as the user:**

```bash
# Remember impersonate
kubectl auth can-i get pods --as=serviceaccount:default:my-sa
```

**Create a ServiceAccount:**

```bash
k create serviceaccount my-sa -oyaml --dry-run=client
```

**Create a Role:**

```bash
k create role pod-read --verb=get,list,watch --resource=pods -oyaml --dry-run=client
```

**Role for all resources and all actions:**

```bash
k create role namespace-admin --verb="*" --resource="*" --dry-run=client -oyaml
```

**Create a RoleBinding:**

```bash
k create rolebinding my-sa-pod-read --role=pod-read --serviceaccount=default:my-sa -oyaml --dry-run=client
```

Find an aggregated ClusterRole (aggregated rules):

```sh
kubectl get clusterrole -l rbac.authorization.k8s.io/aggregate-to-view=true
```

Can I check and impersonate as other users:

```sh
kubectl auth can-i impersonate users

```

## Using ServiceAccount

### In-cluster (curl)

Pod that uses curl to call the Kubernetes API:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-client-pod
spec:
  serviceAccountName: api-access-sa
  containers:
    - name: curl-client
      image: curlimages/curl:latest
      command: ["sh", "-c"]
      args:
        - |
          TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
          CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

          # Call Kubernetes API
          while true; do
            echo "=== Getting nodes ==="
            curl -s -H "Authorization: Bearer $TOKEN" \
              --cacert $CACERT \
              https://kubernetes.default.svc/api/v1/nodes

            sleep 60
          done
```

### Outside the cluster (kubectl)

**Generate a token:**

```bash
TOKEN=$(kubectl create token -n admin-tools kubectl-view-sa)
```

**Quick check:**

```bash
k get pods -A --token $TOKEN --server https://192.168.122.234:8443 --insecure-skip-tls-verify=true
```

**Create kubeconfig:**

```bash

# Create cluster
kubectl config set-cluster my-cluster \
  --server=https://192.168.122.234:8443 \
  --certificate-authority=/mnt/data/vm/minikube/.minikube/ca.crt \
  --embed-certs=true \
  --kubeconfig=kubeconfig

# Create user
kubectl config set-credentials kubectl-view-sa --token=$TOKEN --kubeconfig=kubeconfig

# Create context
kubectl config set-context view-context \
  --cluster=my-cluster \
  --user=kubectl-view-sa \
  --namespace=admin-tools --kubeconfig=kubeconfig

# Set default context
kubectl config use-context view-context --kubeconfig=kubeconfig
```

Do not mount the ServiceAccount into the Pod:
```yaml
automountServiceAccountToken: false
```

## Kubeconfig

Set the context via kubectl:

```sh
kubectl --context
```

Work with kubeconfig:

```sh
k config get-contexts
k config set-context minikube --user=minikube --namespace=default
k config use-context minikube
```
