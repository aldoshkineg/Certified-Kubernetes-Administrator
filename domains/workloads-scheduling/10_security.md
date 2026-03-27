### Pod Security

---

Pod and container level


## SecurityContext (Pod + Container)

```yaml
spec:
  securityContext:
    runAsNonRoot: true # disable root
    runAsUser: 1000 # explicit UID (otherwise taken from the image)
    fsGroup: 2000 # write permissions in volumes (PVC/emptyDir)

  containers:
    - name: app
      image: nginx
      securityContext:
        readOnlyRootFilesystem: true # root FS read-only
        allowPrivilegeEscalation: false # disallow setuid/setgid
        privileged: false # no full host access
        capabilities:
          drop: ["ALL"] # drop all Linux capabilities
          add: ["NET_BIND_SERVICE"] # only if you need port <1024
```

---

## Pod Security Admission (PSA — Namespace)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: secure
  labels:
    pod-security.kubernetes.io/enforce: restricted # strict policy
```

Or:

```bash
kubectl label ns secure pod-security.kubernetes.io/enforce=restricted
```

---

## Host Access (almost always false)

```yaml
spec:
  hostNetwork: false # no host network
  hostPID: false # no host processes
  hostIPC: false # no host IPC
```

Dangerous volume:

```yaml
volumes:
  - name: host
    hostPath:
      path: /var/run # direct node access — avoid
```

---

## Seccomp

```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault # safe default profile
    # Unconfined = protection is disabled (bad)
```

---

## Quick check

```bash
kubectl get pod <pod> -o yaml | grep -A 5 securityContext
```

---

## Red flags (what to fix)

```yaml
privileged: true # full host access
runAsUser: 0 # root
allowPrivilegeEscalation: true # possible escalation
hostNetwork: true # node network
capabilities: ["ALL"] # excessive privileges
seccompProfile: Unconfined # no syscall filtering
```

**Mantra:** `nonRoot + noEscalation + drop ALL + restricted PSA + RuntimeDefault`.
