# Limits & Requests

## **Requests**

- Minimum resources guaranteed by the **Scheduler**
- Try to set values needed for normal operation
- Define the **QoS class** (BestEffort, Burstable, Guaranteed)
- Under load:

  - Pod gets **minimum (requests)** guaranteed
  - If the Node is overloaded → a Pod with small requests **may be evicted first**

- VPA adjusts requests; Deployment stays the baseline

## **Limits**

- Maximum resources a Pod can use
- CPU → **throttling** when exceeded
- Memory → **OOMKill** when exceeded

## **QoS classes**

| Class      | Req/Lim | Behavior under load                                                                   |
| ---------- | ------- | ------------------------------------------------------------------------------------- |
| BestEffort | none    | gets resources only if available, evicted first                                   |
| Burstable  | <       | gets requests guaranteed, can use up to limits, evicted after BestEffort     |
| Guaranteed | =       | gets exactly requests/limits, evicted last                                       |

- LimitRange — limits for containers
- ResourceQuota — namespace limit

---

✅ **CKA key points**

- Requests = Pod protection and a signal to the cluster
- Limits = protection against excessive consumption
- VPA manages **requests**, Deployment stays baseline

## Pod termination order

- **Killed first:**

  1. BestEffort pods (no requests or limits)
  2. Burstable pods with low priority and exceeding requests

- **Killed last:**

  1. Guaranteed pods (requests = limits)
  2. Pod with high `priorityClass` and memory within limits

Fields to check:

* **QoS Class** – shows the class
* **Priority** – numeric Pod priority; higher means **less chance of being killed**.
* **Requests / Limits** – memory requests/limits; affect QoS and **immediate OOMKilled**


Optimized for the article: **put all key explanations directly in code comments** so the text stays compact and the meaning is obvious.

---

## 🔹 LimitRange — limits for containers / Pods

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limits-example
  namespace: dev
spec:
  limits:
  - type: Container

# Short summary:
# - min/max → only validate limits/requests
# - default → sets both requests and limits
# - defaultRequest → sets only requests

    # Minimum allowed values (validated for both requests and limits)
    # If requests.cpu < 100m or limits.memory < 128Mi → Pod will NOT be created
    min:
      cpu: "100m"
      memory: "128Mi"

    # Maximum allowed values (validated for both requests and limits)
    # If requests.cpu > 1 or limits.memory > 512Mi → Pod will NOT be created
    max:
      cpu: "1"
      memory: "512Mi"

    # If the Pod did not specify resources at all:
    # requests and limits will be set to these values
    # => Pod becomes Guaranteed (requests = limits)
    default:
      cpu: "250m"
      memory: "256Mi"

    # If the Pod set limits but did NOT set requests:
    # requests will be set from defaultRequest
    # => most often Pod becomes Burstable (requests < limits)
    defaultRequest:
      cpu: "200m"
      memory: "200Mi"

    # Limits the limit/request ratio (limit cannot be > 4x request)
    # Violation → Pod will not be created
    maxLimitRequestRatio:
      cpu: "4"
      memory: "4"

```

### Traps / pitfalls
- Pod with requests < min will not be created (Admission Controller returns an error)
- If default = limits = requests → Pod becomes Guaranteed

## 🔹 ResourceQuota — limits for Namespace

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-example
  namespace: dev
spec:
  hard:
    # Total number of Pods in the namespace
    pods: "10"
    # Total requests and limits for CPU and memory
    requests.cpu: "2"        # maximum 2 CPU on the namespace
    requests.memory: "2Gi"   # maximum 2 GiB RAM on the namespace
    limits.cpu: "4"          # maximum 4 CPU on the namespace
    limits.memory: "4Gi"     # maximum 4 GiB RAM on the namespace
    # Number of PVCs
    persistentvolumeclaims: "5"
```

### Traps / pitfalls
 - Only hard limits exist (hard) — exceeding them → Pod is not created
 - Does not affect QoS for a single Pod; it only limits total consumption
 - The Scheduler may refuse to create a Pod even if nodes are free
