# Service

```yaml
spec:
  type: NodePort       # service types: ClusterIP (default), NodePort, LoadBalancer, ExternalName
  selector:
    name: MyApp        # connects Service to Pods via labels
  ports:
    - port: 80         # Service port
      targetPort: 80   # container port
      nodePort: 30007  # only for NodePort
      protocol: TCP    # TCP (default)
  clusterIP: None      # makes Service headless (no ClusterIP)
```
