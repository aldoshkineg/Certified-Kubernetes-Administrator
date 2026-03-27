# Liveness and Readiness probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-demo
  labels:
    app: probe-demo
spec:
  containers:
    - name: demo-app
      image: busybox
      command: ["sh", "-c", "sleep 3600"] # Container just "lives" for the demo
      # ------------------- Startup Probe -------------------
      startupProbe:
        # Check that the container has fully started (e.g., created /app/started.txt)
        exec:
          command: ["cat", "/app/started.txt"]
        # Number of consecutive failures before the container is restarted
        failureThreshold: 30
        # Interval between checks (seconds)
        periodSeconds: 10
        # StartupProbe ignores LivenessProbe until startup succeeds
        initialDelaySeconds: 0
      # ------------------- Liveness Probe -------------------
      livenessProbe:
        # Check whether the container is "alive" (e.g., responds to HTTP /healthz)
        httpGet:
          path: /healthz
          port: 8080
        # Wait before the first check so the container can start
        initialDelaySeconds: 10
        # Interval between checks
        periodSeconds: 5
        # Number of consecutive failures after which the container is restarted
        failureThreshold: 3
      # ------------------- Readiness Probe -------------------
      readinessProbe:
        # Readiness check: container is ready to accept traffic (TCP / port)
        tcpSocket:
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 5
        failureThreshold: 3
        # If it exceeds the threshold:
        # - Pod is marked NotReady
        # - Traffic via Service does not reach the container
        # - Container is NOT restarted
        # ------------------- Resources -------------------
      # ------------------- Volume Mounts -------------------
      volumeMounts:
        - name: work-dir
          mountPath: /app # Used by startupProbe to check file presence
  # ------------------- Volumes -------------------
  volumes:
    - name: work-dir
      emptyDir: {} # Ephemeral shared volume available to the container for checks and file exchange
```
