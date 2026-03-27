# Service (External)

`externalIPs` — the node IP (under our control) that receives inbound traffic for the Service,
implemented via kube-proxy DNAT rules in iptables.

`ExternalName` — create a redirect (DNS alias) to ya.ru:
`k create svc externalname --external-name=ya.ru my-ya`


Create the endpoint:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ya-service
spec:
  ports:
  - port: 80
    targetPort: 80
  clusterIP: None

---
apiVersion: v1
kind: Endpoints
metadata:
  name: ya-service
subsets:
  - addresses:
      - ip: 1.1.1.1
    ports:
      - port: 80
```

Endpoint Slice:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: external-service
  namespace: default
spec:
  ports:
    - name: http   # Important field
      protocol: TCP
      port: 80
      targetPort: 80

---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: external-service
  namespace: default
  labels:
    kubernetes.io/service-name: external-service
addressType: IPv4
ports:
  - name: http
    protocol: TCP
    port: 80
endpoints:
  - addresses:
      - "1.1.1.1"
```
