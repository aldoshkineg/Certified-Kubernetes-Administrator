# Workloads & Scheduling (15%)

This domain covers application deployments, configuration, and scheduling.

## Topics Covered

### Application Deployments
- Create and manage Deployments
- Perform rolling updates
- Perform rollbacks
- Understand deployment strategies
- Configure deployment replicas

### ConfigMaps and Secrets
- Create ConfigMaps
- Use ConfigMaps in pods
- Create Secrets
- Use Secrets in pods
- Understand envFrom
- Mount ConfigMaps and Secrets as volumes

### Workload Autoscaling
- Configure HorizontalPodAutoscaler (HPA)
- Configure VerticalPodAutoscaler (VPA)
- Understand autoscaling metrics
- Set up autoscaling policies

### Self-Healing Deployments
- Understand ReplicaSets
- Understand Deployments
- Understand StatefulSets
- Understand DaemonSets
- Configure liveness and readiness probes

### Pod Scheduling
- Configure resource limits and requests
- Set up node affinity
- Configure pod affinity/anti-affinity
- Use node selectors
- Configure taints and tolerations
- Understand pod priority

## Key Concepts

### Core Components
- **Pods**: Minimal deployable unit
- **ReplicaSet**: Maintains pod replicas
- **Deployment**: Manages ReplicaSets with rollout capabilities
- **StatefulSet**: Stateful applications with stable identities
- **DaemonSet**: One pod per node
- **Job**: Run to completion
- **CronJob**: Scheduled jobs

### Scheduling
- **Scheduler**: Assigns pods to nodes
- **Node Affinity**: Prefer certain nodes
- **Pod Affinity**: Co-locate pods
- **Taints/Tolerations**: Prevent/allow pod scheduling
- **Resource Requests/Limits**: CPU and memory constraints

## Key Commands

```bash
# Deployments
kubectl create deployment <name> --image=<image>
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>
kubectl set image deployment/<name> <container>=<new-image>

# ConfigMaps
kubectl create configmap <name> --from-literal=key=value
kubectl create configmap <name> --from-file=<file>
kubectl get configmap
kubectl describe configmap

# Secrets
kubectl create secret generic <name> --from-literal=key=value
kubectl create secret tls <name> --cert=<cert> --key=<key>
kubectl get secrets

# Autoscaling
kubectl autoscale deployment <name> --min=2 --max=10 --cpu-percent=80
kubectl get hpa
```

## Practice Resources

- Exercises: `../../exercises/by-topic/workloads-scheduling/`
- Labs: `../../exercises/labs/tasks/` (Tasks 1-3, 23-24)
- Templates: `../../templates/` (deploy.yml, configmap.yml, secret.yml)

## Study Tips

1. **Master Deployments**: Most common workload type
2. **Understand rolling updates**: Know how to update and rollback
3. **Practice ConfigMaps/Secrets**: Frequently tested
4. **Learn scheduling**: Affinity, taints, tolerations
5. **Resource management**: Requests vs limits

---

**Weight**: 15% of exam
