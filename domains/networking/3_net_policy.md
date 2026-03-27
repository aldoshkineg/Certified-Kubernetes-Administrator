# 🟢 NetworkPolicy

## 1. Usage

- Policy applies to Pods via `podSelector`.
- Anything not explicitly allowed is blocked (implicit deny).
- It isolates only the Pods selected by `podSelector`; other Pods are unaffected.
- Applied **within the namespace**
- For the whole namespace → `podSelector: {}`.
- **OR** | **AND** conditions (see example)
- When creating Egress rules, allow DNS queries

## 2. Traffic types

- `Ingress` — incoming
- `Egress` — outgoing
- Can be combined (`policyTypes: Ingress, Egress`)

## 3. Conditions (Selectors)

- `from` / `to` → multiple entries = **OR**
- Can combine:

  - `podSelector`
  - `namespaceSelector`
  - `ipBlock` (with `except` for exclusions)

## 4. Ports

- Not required → all ports/protocols are allowed
- You can specify `protocol: TCP|UDP` + `port`

## 5. Notes / Features

- DNS is blocked via Egress → allow it explicitly (`namespace: kube-system`, Pod: `k8s-app=kube-dns`)
- Cannot match by Service names
- Default policy allows all traffic → to fully deny, specify it explicitly
- To access an entire namespace, you need a label (unless explicitly requested)

## 6. ipBlock

- Allows allow/deny IP ranges (`cidr`)
- `except` → exclusions from the range

---

## Commands

```bash
# View all NetworkPolicies
kubectl describe netpol

# View a specific policy
kubectl describe netpol <name> -n <namespace>

# Find PodCIDR
kubectl describe nodes <node> | grep Cidr
```

---

## 🔹 Base template

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-policy
  namespace: secure
spec:
  podSelector:
    matchLabels:
      app: web # Applies to Pods with label app=web; everything else is blocked (for the label!)
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: ingress-nginx # Allow from Pods with app=ingress-nginx
        - podSelector:
            matchLabels:
              app: ingress-traeffic # Or from Pods in the local namespace (OR)
      ports:
        - protocol: TCP
          port: 443 # Allow only TCP 443; otherwise all ports are allowed
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system # Allow only Pods in kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns # Only Pods with k8s-app=kube-dns in kube-system (AND)
      ports:
        - protocol: UDP
          port: 53 # Allow DNS only over UDP 53; everything else is denied
```
