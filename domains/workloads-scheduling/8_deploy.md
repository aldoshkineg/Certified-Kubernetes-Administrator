# Manage version

Deployment operations:

```sh
kubectl rollout status deployment/myapp
kubectl rollout history deployment/myaoo
kubectl rollout history deployment --revision=3
kubectl rollout undo deployment/myapp --to-revision=1

# Running
kubectl scale deployment wordpress --replicas=0
kubectl -n kube-system rollout restart deployment coredns
```



## Deployment Strategies

| Strategy       | Native in K8s? | Downtime | Rollback Speed | Tools/Notes                      |
|----------------|----------------|----------|----------------|----------------------------------|
| Recreate       | Yes            | Yes      | Slow           | Simple, all-at-once switch       |
| RollingUpdate  | Yes (default)  | No       | Fast           | Gradual, zero downtime           |
| Blue-Green     | No             | No       | Instant        | Argo Rollouts, Istio             |
| Canary         | No             | No       | Fast           | Argo Rollouts, Istio             |
| A/B Testing    | No             | No       | Fast           | Istio, NGINX Ingress             |
| Shadow         | No             | No       | N/A            | Istio, Linkerd                   |


```yaml
type: Recreate | RollingUpdate
rollingUpdate:
  maxSurge: 35%         # Up to 7 pods total (5 + 2)
  maxUnavailable: 25%   # For 4 replicas, 1 pod can be unavailable
```
