# Affinity

```yaml
# NodeSelector – simple matching of labels
spec:
  nodeSelector:
    disktype: ssd        # selects the node with label disktype=ssd

# NodeName – hard pinning to a specific node
spec:
  nodeName: worker-node-1  # Pod will run only on this node

# Tolerations – allow Pods to schedule on tainted nodes
spec:
  tolerations:
    - key: "key1"
      operator: "Equal"      # possible operators: Equal, Exists
      value: "value1"
      effect: "NoSchedule"   # taint types: NoSchedule, PreferNoSchedule, NoExecute
```

# 1️⃣ Node Affinity (preferred / required)

```yaml id="j1k2ad"
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-example
  labels:
    app: web
spec:
  containers:
    - name: nginx
      image: nginx
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: disktype
                operator: In
                values:
                  - ssd
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          preference:
            matchExpressions:
              - key: region
                operator: In
                values:
                  - us-east-1
```
---

# 2️⃣ Pod Affinity (schedule near other pods)

```yaml id="k3m9fv"
apiVersion: v1
kind: Pod
metadata:
  name: pod-affinity-example
  labels:
    app: frontend
spec:
  containers:
    - name: nginx
      image: nginx
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app: backend
          topologyKey: kubernetes.io/hostname
```

Maximum pod spread:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: spread-example
  labels:
    app: foo  # Label used to select pods for spreading
spec:
  containers:
    - name: nginx
      image: nginx  # Container image
  # Topology spread constraints to evenly distribute pods
  topologySpreadConstraints:
    - maxSkew: 1  # Maximum allowed difference in pod count across nodes
      topologyKey: kubernetes.io/hostname  # Spread across nodes
      whenUnsatisfiable: DoNotSchedule  # Don’t schedule if constraint can't be satisfied
      labelSelector:
        matchLabels:
          app: foo  # Only count pods with this label for spreading
```
