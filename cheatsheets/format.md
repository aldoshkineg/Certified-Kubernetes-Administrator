# 🧠 JSONPath in Kubernetes

## Principle

### 1️⃣ Everything is a tree

Traverse left-to-right using `.field`

```
.metadata.name
.spec.nodeName
.status.phase
```

---

### 2️⃣ One object ≠ list

If `kubectl get pod alpine` →
root is immediately `.`

If `kubectl get pods` →
root is always `.items[]`

```
.items[*].metadata.name
```

---

### 3️⃣ If you see an array → add `[]`

* need one → `[0]`
* need all → `[*]`

```
.spec.containers[0].name
.spec.containers[*].name
```

---

### 4️⃣ Two arrays in a row?

Use `[*]` for each.

```
.items[*].spec.containers[*].name
```

Read it like:
for each Pod → for each container → name

---

### 5️⃣ Filtering works only inside an array

```
.items[?(@.status.phase=="Running")].metadata.name
```

* `@` — the current array element
* `[?()]` — the condition

No array means no filtering.

---

### 6️⃣ JSONPath does not filter at the API level

It filters the JSON after it has been returned.

API-side filtering is done via:

```
-l
--field-selector
```

---

### 7️⃣ custom-columns does not filter

It only formats output nicely:

```
-o custom-columns=NAME:.metadata.name
```

---

### 8️⃣ --sort-by is not a filter

It only sorts:

```
--sort-by=.metadata.name
```

---

### 9️⃣ If you don't understand the path — look at the JSON

```
k get pod alpine -o json
```

Then just follow the structure top-to-bottom.

---


## Basic structures

### 1️⃣ Pod

```jsonc
{
  "Pod": {
    "metadata": {
      "name": "<pod-name>", // Pod name
      "namespace": "<namespace>", // namespace
      "labels": { "<key>": "<value>" }, // labels for selection
    },
    "spec": {
      "containers": [
        {
          "name": "<container-name>", // container name
          "image": "<image-name>", // container image
        },
      ],
      "nodeName": "<node-name>", // node the Pod is running on
    },
    "status": {
      "phase": "Running", // Pod phase: Pending, Running, Succeeded, Failed
      "podIP": "10.1.2.3", // Pod IP
      "conditions": [
        { "type": "Ready", "status": "True" }, // readiness
      ],
    },
  },
}
```

---

### 2️⃣ Deployment

```jsonc
{
  "Deployment": {
    "metadata": {
      "name": "<deployment-name>",
      "namespace": "<namespace>",
      "labels": { "<key>": "<value>" },
    },
    "spec": {
      "replicas": 3, // desired number of replicas
      "template": {
        "spec": {
          "containers": [
            { "name": "<container-name>", "image": "<image-name>" },
          ],
        },
      },
    },
    "status": {
      "replicas": 3, // current number of replicas
      "availableReplicas": 3, // available replicas
    },
  },
}
```

---

### 3️⃣ Service

```jsonc
{
  "Service": {
    "metadata": {
      "name": "<service-name>",
      "namespace": "<namespace>",
      "labels": { "<key>": "<value>" },
    },
    "spec": {
      "type": "ClusterIP", // Service type: ClusterIP, NodePort, LoadBalancer
      "clusterIP": "10.0.0.1",
      "ports": [{ "port": 80, "targetPort": 8080 }],
      "selector": { "<key>": "<value>" }, // selects Pods by labels
    },
    "status": {
      "loadBalancer": {}, // external LB info (if any)
    },
  },
}
```

---

### 4️⃣ Node

```jsonc
{
  "Node": {
    "metadata": {
      "name": "<node-name>",
      "labels": { "<key>": "<value>" },
    },
    "spec": {
      "podCIDR": "10.244.0.0/24", // Pod CIDR
      "providerID": "<cloud-provider-id>", // cloud provider identifier
    },
    "status": {
      "capacity": {
        "cpu": "4",
        "memory": "16Gi",
        "pods": "110",
      },
      "allocatable": {
        "cpu": "4",
        "memory": "15Gi",
        "pods": "100",
      },
      "conditions": [{ "type": "Ready", "status": "True" }],
      "addresses": [
        { "type": "InternalIP", "address": "192.168.1.10" },
        { "type": "Hostname", "address": "<node-hostname>" },
      ],
      "nodeInfo": {
        "kubeletVersion": "v1.28.0",
        "osImage": "Ubuntu 22.04",
        "kernelVersion": "5.15.0-70-generic",
        "containerRuntimeVersion": "docker://24.0.5",
      },
    },
  },
}
```

---

### 5️⃣ PersistentVolume (PV)

```jsonc
{
  "PersistentVolume": {
    "metadata": {
      "name": "<pv-name>",
      "labels": { "<key>": "<value>" },
    },
    "spec": {
      "capacity": { "storage": "10Gi" }, // PV size
      "accessModes": ["ReadWriteOnce"], // access modes
      "persistentVolumeReclaimPolicy": "Retain", // reclaim policy after PVC deletion
      "storageClassName": "<storage-class>",
      "hostPath": { "path": "/mnt/data" }, // example for hostPath
    },
    "status": {
      "phase": "Available", // Available, Bound, Released
    },
  },
}
```
