# Troubleshooting Domain (30%)

This domain covers troubleshooting clusters, nodes, components, and applications.

## Topics Covered

### Cluster & Node Troubleshooting
- Diagnose cluster issues
- Troubleshoot node problems
- Identify and fix node connectivity issues
- Resolve node resource problems

### Cluster Components Troubleshooting
- Troubleshoot kubelet issues
- Fix API server problems
- Resolve etcd issues
- Debug scheduler problems
- Fix controller manager issues

### Monitoring & Resource Usage
- Monitor cluster resource usage
- Monitor application resource usage
- Use kubectl top commands
- Analyze resource metrics

### Container Output Streams
- View container logs
- Stream container output
- Debug container issues
- Use kubectl logs effectively

### Services & Networking Troubleshooting
- Troubleshoot service connectivity
- Debug network policies
- Fix DNS issues
- Resolve ingress problems
- Diagnose pod-to-pod communication

## Key Commands

```bash
# View logs
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container>
kubectl logs <pod-name> -f

# Describe resources
kubectl describe pod <pod-name>
kubectl describe node <node-name>
kubectl describe service <svc-name>

# Get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n <namespace>

# Check resource usage
kubectl top nodes
kubectl top pods
kubectl top pods --containers

# Debugging
kubectl exec -it <pod-name> -- /bin/sh
kubectl get pods -o wide
kubectl get nodes -o wide
```

## Practice Resources

- Exercises: `../../exercises/by-topic/troubleshooting/`
- Labs: `../../exercises/labs/tasks/` (Tasks 6-15 focus on troubleshooting)
- Examples: `../../examples/troubleshooting/`

## Study Tips

1. **Practice common scenarios**: CrashLoopBackOff, ImagePullError, resource limits
2. **Learn to read logs**: Understanding log output is crucial
3. **Use describe command**: Often provides the diagnosis
4. **Check events**: Events show what happened
5. **Time yourself**: Troubleshooting should be quick during exam

---

**Weight**: 30% of exam - **HIGHEST PRIORITY**
