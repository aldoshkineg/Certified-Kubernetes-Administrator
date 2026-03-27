# HPA

Documentation:

- HPA
- HPA **Custom metrics**

## 1️⃣ HPA (Horizontal Pod Autoscaler)

### Install Metrics Server (required for CPU/Memory HPA)

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# Edit deployment to add: --kubelet-insecure-tls if needed
```

---

### Create HPA (Imperative, fastest)

```sh
# CPU + Memory autoscaling
kubectl autoscale deployment <name> -n <ns> --cpu=60% --memory=70% --min=2 --max=5

# Dry-run YAML (optional)
kubectl autoscale deployment <name> -n <ns> --cpu=50% --min=1 --max=5 --dry-run=client -o yaml > hpa.yaml
kubectl apply -f hpa.yaml
```

---

### Check HPA

```sh
kubectl get hpa -n <ns>
kubectl describe hpa <name> -n <ns>
```

- `<unknown>` metrics → **missing resource requests** or metrics-server not running
- Events section shows scaling errors

---

### Scale Manually / Disable HPA Temporarily

```sh
kubectl scale deployment <name> -n <ns> --replicas=0  # maintenance
```

---

## 2️⃣ Resource Requests & Limits (Mandatory for HPA)

```yaml
resources:
  requests: # required for CPU/Memory autoscaling
    cpu: 100m
    memory: 50Mi
  limits: # protects pod from OOM or CPU throttling
    cpu: 200m
    memory: 1Gi
```

- **Requests** → baseline for HPA metrics,
- **Limits** → max usage, prevents node overload

- Only `requests` are set — Pod falls into the `Burstable` class.
- `requests == limits` — Pod falls into the `Guaranteed` class (highest priority).
- Nothing is set — Pod falls into the `BestEffort` class (lowest priority).


---

## 3️⃣ Metrics Types

| Type              | default? | Notes                                    |
| ----------------- | -------- | ---------------------------------------- |
| Resource          | ✅ Yes   | CPU / Memory                             |
| Pods (custom)     | ❌ No    | custom.metrics.k8s.io (Prometheus)       |
| Object (custom)   | ❌ No    | external.metrics.k8s.io Requires adapter |
| ContainerResource | Rare     | Advanced, not needed for exam            |

---

## 4️⃣ Autoscaling Behavior (v2)

Control speed / stability:

```yaml
behavior:
  scaleUp:
    tolerance: 0.05 # 5% tolerance
    policies:
      - type: Percent # max % replicas per period
      - type: Pods # max # pods per period
  scaleDown:
    stabilizationWindowSeconds: 300 # prevent flapping
```
