# Environment

```yaml
env:
  - name: ENV_VAR_1           # Simple constant
    value: "value1"

  - name: ENV_FROM_CONFIGMAP   # Value from ConfigMap via valueFrom
    valueFrom:
      configMapKeyRef:
        name: app-config      # ConfigMap name
        key: ENV_VAR_1        # key inside ConfigMap

  - name: ENV_FROM_SECRET      # Value from Secret via valueFrom
    valueFrom:
      secretKeyRef:
        name: app-secret      # Secret name
        key: PASSWORD         # key inside Secret

  - name: POD_NAME             # Dynamic Pod field
    valueFrom:
      fieldRef:
        fieldPath: metadata.name

  - name: NODE_NAME            # Dynamic Node field
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName

# Alternative: import all variables from a ConfigMap or Secret at once
envFrom:
  - configMapRef:
      name: app-config        # load all ConfigMap keys as env
  - secretRef:
      name: app-secret        # load all Secret keys as env
```
