# Gateway API

Next-generation ingress

- Can handle L4
- Universal annotations
- Blue-green deployments
- HTTP header processing
- Cross-namespace interaction

**Gateway API Controller** — component that configures routes

## Nginx Gateway Fabric

- Control Plane Controller — watches CRDs
- Data plane — configures traffic

Installation:

CRD:

```sh
# Maybe conflict with Controller version
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml

```

NGF:

```sh
helm show values oci://ghcr.io/nginx/charts/nginx-gateway-fabric > ngf.yaml
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric -f ngf.yaml --create-namespace -n nginx-gateway
```

Check resources:

```sh
kubectl api-resources --api-group=gateway.networking.k8s.io
```

## Gateway Resources

- GatewayClass — choose the right controller
- Gateway — where traffic enters the cluster
- HTTPRoute — route HTTP traffic to a Service
- gRPCRoute — gRPC to a Service
- ReferenceGrants — configure how different namespaces can reference traffic

Verify resources after creation:

```sh
k -n webserver get gateway  # Attached Routes: 1
k -n webserver describe httproute # Backend service | Message
k -n webserver exec -it <CONTROLLER POD NAME> -- nginx -T # Pod IPs
```

Migration from Ingress → Gateway + HttpRoute, etc.
