# Custom Scheduler

[Docs link](https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/)


Assign to pod:

```yaml
spec:
  schedulerName: my-scheduler
  containers:
  - name: pod-with-second-annotation-container
    image: registry.k8s.io/pause:3.8
```
