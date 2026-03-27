# 🎯 Affinity | Anti-Affinity

Kubernetes provides several mechanisms to bind Pods to Nodes and to each other:

| Mechanism                         | Rule type             | Description                                                                  | Notes                                                                               |
| :-------------------------------- | :-------------------- | :---------------------------------------------------------------------------- | :-------------------------------------------------------------------------------- |
| **nodeName**                     | Direct assignment     | Hard pinning to a specific node via `spec.nodeName`. Taints still apply. | Bypasses the scheduler; not an affinity mechanism; does not balance load.    |
| **nodeSelector**                 | Hard (Node)           | Simple node selection by labels in `spec.nodeSelector`.                     | Basic filter; part of NodeAffinity.                                              |
| **Node Affinity**                | Hard/Soft (Node)     | Advanced node selection via `matchExpressions` (`In`, `Exists`, `Gt`, etc.). | `requiredDuringScheduling...` is hard; `preferredDuringScheduling...` is soft. |
| **Pod Affinity / Anti-Affinity** | Hard/Soft (Pod)      | Schedule Pods near or far from other Pods using labels and `topologyKey`. | Works via `labelSelector` and `topologyKey` (node/zone).                          |
| **Taints & Tolerations**         | Hard (Node)           | A node repels Pods (taint); tolerations allow scheduling.                   | Effects: `NoSchedule`, `PreferNoSchedule`, `NoExecute`.                          |
| **Topology Spread Constraints**  | Constraint (Pod)     | Control even Pod distribution across topologyKey with `maxSkew`.             | Declared in `spec.topologySpreadConstraints`; good for uniform distribution.   |

---

## 📌 Key differences

- **Pod Anti-Affinity vs Taints**: Anti-Affinity makes a Pod avoid other **Pods**; Taints make the node repel all **Pods**.
- **Pod Anti-Affinity vs Topology Spread Constraints**: Anti-Affinity answers _whether_ a Pod can be placed; Spread Constraints describe _how evenly_ Pods are distributed.

---

## YAML examples with comments

### 1. nodeName

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  nodeName: kube-01 # force-run Pod on a specific node
  containers:
    - name: nginx
      image: nginx
```

---

### 2. nodeSelector

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  # Hard requirement: run only on nodes with label disktype=ssd
  nodeSelector:
    disktype: ssd
  containers:
    - name: nginx
      image: nginx
```

---

### 3. Node Affinity

**Kubernetes operators**

- **In** — label exists **and equals one of values**
- **NotIn** — label **not equal** to values _(or missing)_
- **Exists** — label **present** ()
- **DoesNotExist** — label **absent**
- **Gt** — label **number > value**
- **Lt** — label **number < value**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  affinity:
    nodeAffinity:
      # Hard requirement: only nodes in zone europe-west1-a
      #
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: topology.kubernetes.io/zone
                operator: In
                values: [europe-west1-a]
      # Preferred option: nodes with GPU
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          preference:
            matchExpressions:
              - key: gpu
                operator: Exists
  containers:
    - name: nginx
      image: nginx
```

---

### 4. Pod Affinity / Anti-Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  labels:
    app: web
spec:
  affinity:
    podAffinity:
      # Hard: schedule on the same node as the Pod with label app=cache
      requiredDuringSchedulingIgnoredDuringExecution:
        - topologyKey: kubernetes.io/hostname
          labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values: [cache]
    podAntiAffinity:
      # Preferred: don't run in the same zone as the load-balancer
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            topologyKey: topology.kubernetes.io/zone
            labelSelector:
              matchExpressions:
                - key: app
                  operator: In
                  values: [load-balancer]
  containers:
    - name: web
      image: nginx
```

---

### 5. Taints & Tolerations

```yaml
# Apply taint on the node:
# "NoSchedule" — blocks all Pods without the matching toleration
kubectl taint nodes node1 key=value:NoSchedule

# In the Pod, set toleration so it can run on such a node
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  tolerations:
  - key: "key"
    operator: "Equal"     # Exists - value does not matter
    value: "value"
    effect: "NoSchedule"  # must match the taint; does not affect already running Pods
                          # PreferNoSchedule schedules if there is no alternative
                          # NoExecute eviction with tolerationSeconds timer
  containers:
  - name: nginx
    image: nginx
```

---

### 6. Topology Spread Constraints

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  topologySpreadConstraints:
    - maxSkew: 1 # maximum allowed difference in Pod count between topology domains
      # Example: if zone A has 2 Pods and zone B has 1 Pod, difference = 1 -> allowed
      topologyKey: topology.kubernetes.io/zone
      # Distribution domain: scheduler looks at the node label
      # Possible options:
      #   - kubernetes.io/hostname → balance across nodes
      #   - topology.kubernetes.io/zone → balance across zones
      #   - topology.kubernetes.io/region → balance across regions
      whenUnsatisfiable: DoNotSchedule
      # Action if the rule is not satisfied:
      #   - DoNotSchedule → Pod remains Pending when maxSkew is violated
      #   - ScheduleAnyway → Pod will be scheduled even if balancing is violated
      labelSelector:
        matchLabels:
          app: nginx
          # With labelSelector, the scheduler counts only Pods with this label
          # You can use:
          #   - matchLabels → simple key=value match
          #   - matchExpressions → complex conditions (In, NotIn, Exists, DoesNotExist)
  containers:
    - name: nginx
      image: nginx
```

---

## 📝 Interaction scheme between mechanisms (ASCII / Markdown)

```markdown
                  +---------------------+
                  |       Node 1        |  <-- Labels: zone=us-east-1a, disktype=ssd
                  |   Taints: gpu=Yes   |      (repels Pods without toleration)
                  +----------+----------+
                             |
           +-----------------+-----------------+
           |                                   |
     Pod A: nginx                        Pod B: web
     nodeSelector: disktype=ssd          podAffinity: near Pod C(cache)
     tolerations: none                   podAntiAffinity: avoid Pod D(load-balancer)
     NodeAffinity: prefer GPU

                  +---------------------+
                  |       Node 2        |  <-- Labels: zone=us-east-1b
                  +---------------------+
                             |
                           Pod C: cache
                           NodeAffinity: zone=us-east-1b

                  +---------------------+
                  |       Node 3        |  <-- Labels: zone=us-east-1a
                  +---------------------+
                             |
                           Pod D: load-balancer
```

**Legend:**

- **NodeSelector / NodeAffinity** → filter nodes by labels.
- **Taints/Tolerations** → node repels Pods without toleration.
- **PodAffinity / PodAntiAffinity** → Pods try to be near/away from other Pods.
- **Topology Spread Constraints** → control even Pod distribution across topology.
