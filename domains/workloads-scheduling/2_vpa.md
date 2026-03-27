# VPA

## Purpose

* Automatically **sets CPU / memory requests** for Pods based on real usage.
* Does not change requests/limits in the Deployment manifest.
* Requests are guaranteed resources needed for operation; higher usage is not guaranteed.
* **Does not scale replicas** (unlike HPA).
* Works **only with controllers** (Deployment, StatefulSet, etc.).

## Dependencies

* **Requires `metrics-server`**
* Without metrics, VPA **does not provide recommendations**

---

## Installation (typical for the exam)

Via Helm (quick and sufficient for CKA):

```sh
git clone https://github.com/kubernetes/autoscaler.git --depth=1
cd autoscaler/vertical-pod-autoscaler/charts/vertical-pod-autoscaler
helm install vpa vertical-pod-autoscaler -n vpa --create-namespace
```

---

## Update modes (important for CKA)

> The mode defines **how VPA applies recommendations**

### `Off`

 * ❗ **Only calculates recommendations**
 * Does not modify Pods
 * Used for analysis and debugging

### `Initial`

* Applies requests **only when creating Pods**
* Does not touch already running Pods
* Without eviction → safe mode

### `Recreate`

* Applies recommendations **via Pod eviction**
* The Pod is deleted and recreated with new requests
* Behavior is similar to the old Auto

### `InPlaceOrRecreate`

* 🔹 **Preferred mode**
* Tries to update resources **in-place**
* If it can't → performs eviction
* Minimizes restarts

### `Auto` (**deprecated**)

* Deprecated alias
* Effectively behaves like `Recreate`
* ❌ **Not recommended for new manifests**
* For CKA, it’s better **not to use it**

📌 **CKA recommendation**:

> Use `Initial` or `InPlaceOrRecreate`

---

## `controlledValues`

### `RequestsOnly` ✅ (recommended)

* VPA controls **only requests**
* Limits stay under the user’s control
* **The safest and most expected option for the exam**

### `RequestsAndLimits` ⚠️ (risky)

* VPA changes **both requests and limits**
* Can lead to:

  * CPU throttling
  * OOMKill
  * unstable application behavior
* ❌ Usually **not expected on the CKA**

---

## Example VPA (exam-safe)

```yaml
apiVersion: autoscaling.k8s.io/v1        # VPA API group
kind: VerticalPodAutoscaler              # VPA resource
metadata:
  name: nginx-vpa                        # VPA name
  namespace: stage                       # Namespace target workload
spec:
  targetRef:                             # Applied to which object
    apiVersion: apps/v1                  # API target
    kind: Deployment                     # controller type
    name: nginx                          # Deployment name
  updatePolicy:
    updateMode: Initial                  # Without eviction (safe for CKA)
  resourcePolicy:
    containerPolicies:
    - containerName: nginx               # MUST match the container name
      minAllowed:
        cpu: 100m                        # Minimum CPU request
        memory: 128Mi                    # Minimum memory request
      maxAllowed:
        cpu: "2"                         # Maximum CPU request
        memory: 2Gi                      # Maximum memory request
      controlledResources:
      - cpu                              # Control CPU
      - memory                           # Control memory
      controlledValues: RequestsOnly     # Control only requests
```

---

## Verify it works

```sh
kubectl describe vpa nginx-vpa -n stage
```

* `Status: RecommendationProvided` → metrics are present
* `Events: EvictedPod` → eviction happened
* `status.recommendation` → actual VPA calculations
---

## HPA + VPA

* HPA → scales **replicas**
* VPA → scales **Pod resources (requests/limits)**
* **HPA on CPU + VPA on CPU → conflict**
* Safe:

  * HPA on custom metrics, VPA on CPU/memory
  * Or HPA on CPU, VPA **only on memory**
* VPA mode **Initial / InPlaceOrRecreate**
* `describe` both → check recommendations / events
* Together they provide **dynamic resources + correct replica scaling**
