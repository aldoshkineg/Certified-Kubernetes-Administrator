# PriorityClass

Create a PriorityClass:

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000 # Higher number = higher priority
globalDefault: false
description: "High priority class for critical workloads"
```

Assign Priority to a Pod:

````yaml
apiVersion: v1
kind: Pod
metadata:
name: important-pod
spec:
containers:
- name: nginx
  image: nginx
  priorityClassName: high-priority # Reference the PriorityClass
```
