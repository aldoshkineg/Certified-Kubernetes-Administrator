
# 🔐 Gateway (HTTPS + TLS)

```yaml id="g0x9ke"
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gw
spec:
  gatewayClassName: nginx
  listeners:
    - name: https
      protocol: HTTPS
      port: 443
      hostname: example.com
      tls:
        mode: Terminate
        certificateRefs:
          - name: tls-secret
```
---

# 🔀 Traffic Split (90/10)

```yaml id="o4s7u1"
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app
spec:
  parentRefs:
    - name: gw
  hostnames:
    - example.com
  rules:
    - backendRefs:
        - name: app-stable
          port: 80
          weight: 90
        - name: app-canary
          port: 80
          weight: 10
```

---

# 🎯 Header-based Canary

```yaml id="z9k2lm"
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-header
spec:
  parentRefs:
    - name: gw
  hostnames:
    - example.com
  rules:
    - matches:
        - headers:
            - name: x-canary
              value: "true"
      backendRefs:
        - name: app-canary
          port: 80
    - backendRefs:
        - name: app-stable
          port: 80
```


```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: multi-app
spec:
  parentRefs:
    - name: gw
  hostnames:
    - example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /auto
      backendRefs:
        - name: auto-svc
          port: 80

    - matches:
        - path:
            type: PathPrefix
            value: /current
      backendRefs:
        - name: current-svc
          port: 80

    - matches:
        - path:
            type: PathPrefix
            value: /next
      backendRefs:
        - name: next-svc
          port: 80
```
