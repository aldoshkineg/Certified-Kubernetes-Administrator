# Services & Networking (20%)

This domain covers Kubernetes networking, services, and ingress.

## Topics Covered

### Pod Connectivity
- Understand pod-to-pod communication
- Understand pod networking model
- Configure pod network policies
- Debug pod connectivity issues

### Network Policies
- Create NetworkPolicy resources
- Define ingress rules
- Define egress rules
- Apply network policies to namespaces
- Understand default deny policies

### Service Types
- ClusterIP services
- NodePort services
- LoadBalancer services
- Headless services: None (only pod ips)
- Understand service endpoints
- Configure service selectors

### Gateway API
- Understand Gateway API concepts
- Configure Gateway resources
- Set up HTTPRoute
- Manage traffic routing

### Ingress Controllers & Resources
- Install ingress controllers
- Create Ingress resources
- Configure ingress rules
- Set up TLS/SSL
- Understand ingress annotations

### CoreDNS
- Understand CoreDNS configuration
- Modify CoreDNS ConfigMap
- Debug DNS issues
- Configure custom DNS entries

## Key Commands

```bash
# Services
kubectl create service clusterip <name> --tcp=80:8080
kubectl create service nodeport <name> --tcp=80:8080
kubectl create service loadbalancer <name> --tcp=80:8080
kubectl expose deployment <name> --port=80 --target-port=8080

# Network Policies
kubectl create networkpolicy
kubectl get networkpolicy
kubectl describe networkpolicy

# Ingress
kubectl create ingress
kubectl get ingress
kubectl describe ingress

# DNS
kubectl get configmap -n kube-system coredns -o yaml
kubectl exec -it <pod> -- nslookup <service>
```

## Practice Resources

- Exercises: `../../exercises/by-topic/networking/`
- Labs: `../../exercises/labs/tasks/` (Tasks 4-5, 21-22)
- Templates: `../../templates/svc.yml`

## Study Tips

1. **Understand service types**: Know when to use each type
2. **Practice Network Policies**: They're commonly tested
3. **Learn Ingress**: Ingress configuration is frequently asked
4. **DNS debugging**: Know how to troubleshoot DNS issues
5. **Gateway API**: Newer topic, understand basics

---

**Weight**: 20% of exam
