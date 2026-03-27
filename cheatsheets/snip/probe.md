# Probes

```yaml
# Liveness Probe – checks if the container is alive; restarts on failure
livenessProbe:
  httpGet:
    path: /health
    port: 8080
# Liveness settings:
  initialDelaySeconds: 5 # wait after container start
  periodSeconds: 10 # interval between checks
  timeoutSeconds: 2 # how long to wait for a response
  failureThreshold: 3 # consecutive failures -> restart
  successThreshold: 1 # 1 successful check to be considered healthy

# Readiness Probe – checks if the container is ready to accept traffic
readinessProbe:
  tcpSocket:
    port: 5432

# Startup Probe – for slow container startup; blocks liveness until startup succeeds
startupProbe:
  exec:
    command: ["cat", "/tmp/healthy"] # command inside the container; must return 0
```
