# **Multi-Container Pods**

## **1. InitContainers**

- Run **before main containers**.
- Sequential execution, pod won’t start main containers until all succeed.
- Use cases:

  - Setup/configuration
  - Pre-populate volumes
  - Wait for external services

```yaml
spec:
  initContainers:
    - name: init-example
      image: busybox
      command: ["sh", "-c", "echo hello > /work-dir/init.txt"]
      volumeMounts:
        - name: work-dir
          mountPath: /work-dir
  containers:
    - name: main-app
      image: nginx
      volumeMounts:
        - name: work-dir
          mountPath: /usr/share/nginx/html
  volumes:
    - name: work-dir
      emptyDir: {}
```

---

## **2. Sidecar Containers**

- Run **concurrently** with main container.
- Provide **supporting functionality**.
- Use cases:

  - Logging (Fluentd, Filebeat)
  - Metrics / Monitoring (Prometheus exporters)
  - Local proxy

```yaml
spec:
  containers:
    - name: main-app
      image: nginx
      volumeMounts:
        - name: shared-data
          mountPath: /usr/share/nginx/html
    - name: log-sidecar
      image: busybox
      command: ["sh", "-c", "tail -f /usr/share/nginx/html/access.log"]
      volumeMounts:
        - name: shared-data
          mountPath: /usr/share/nginx/html
  volumes:
    - name: shared-data
      emptyDir: {}
```

---

## **3. Shared Resources**

- **Volumes**: `emptyDir`, `hostPath`, PVC
- **Network**: Same pod IP → communicate via `localhost`
- **Environment variables**: Each container can access pod-level metadata
