# Ingress


Quick generation:
```sh
kubectl create ingress hello-world --rule="example.com/=hello-world:80" -oyaml --dry-run=client
kubectl create ingress simple --rule="foo.com/bar=svc1:8080,tls=my-cert"
```

### 1️⃣ Check Ingress / TLS / Events

```bash
kubectl describe ingress <ingress-name> -n <namespace>
# check:
# - TLS Secret
# - Endpoints
# - Events
```

---

### 2️⃣ Important annotations (NGINX)

```yaml
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"       # HTTP → HTTPS
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true" # forced redirect
    nginx.ingress.kubernetes.io/backend-protocol: https    # backend HTTPS
    nginx.ingress.kubernetes.io/rewrite-target: /          # path rewrite
    nginx.ingress.kubernetes.io/use-regex: "true"          # regex support in path
    nginx.ingress.kubernetes.io/canary: "true"            # enable canary
    nginx.ingress.kubernetes.io/canary-weight: "10"       # % traffic for canary
```

> For CKA you usually need: **ssl-redirect / force-ssl-redirect / rewrite-target / use-regex**
> Example: path: /v1/app → Service expects / → rewrite-target: /.

User:        /appA
Ingress:     path: /appA      ← rule
Rewrite:     /
Service expects: /

---

### 3️⃣ Ingress Class

```bash
kubectl get ingressclass -A
```

```yaml
spec:
  ingressClassName: nginx  # specify the controller
```

* Without ingressClassName → Ingress may be ignored by the controller
* Allows multiple controllers in the cluster

---

### 4️⃣ Path types (`pathType`)

| Type    | Description                     |
| ------- | ----------------------------- |
| Prefix  | Prefix match                  |
| Exact   | Exact path match             |

> Classic trap: `/app` + `Exact` will not match `/app/`

---

### 5️⃣ Disable HTTP (only HTTPS)

```yaml
metadata:
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true" # HTTP -> HTTPS redirect
```

* To fully disable HTTP (port 80) → configure the **Ingress Controller**:

  * NGINX: `--http-port=0 --https-port=443`
* Kubernetes Ingress YAML itself does not disable port 80

---


### Check the host header


### 6️⃣ Quick tips / tricks for CKA

* Ingress → Service.port, **not targetPort**
* TLS Secret must be in the **same namespace**
* Multi-host Ingress → check **host header** `curl -k -H "Host: k8s.dev" https://host`
* 404 usually means: **host/path mismatch** or **missing ingressClass**
* Always specify `pathType` for predictable behavior

