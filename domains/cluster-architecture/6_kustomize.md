# Kustomize

## Main commands

```bash
kubectl apply -k <dir>          # Apply configuration
kubectl kustomize <dir>         # View the final YAML
kubectl diff -k <dir>           # Show changes
kustomize create --autodetect   # Create kustomization.yaml
kubectl get -k ./overlays/dev   # View created resources
kustomize edit fix              # Fix outdated syntax
kustomize build ./k8s            # Generate manifests
```

## Exam key topics

### 1. Base structure

```
app/
├── base-db/                    # Shared manifests
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── base-dep/                    # Shared manifests
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    └── prod/               # Environment
       ├── kustomization.yaml
       └── patches/
    └── dev/               # Environment
        ├── kustomization.yaml
        └── patches/
```

### 2. Key concepts

- **Deployment selectors are immutable** — don't change them via `commonLabels`
- **Patches**: use `patches:`, not the deprecated `patchesStrategicMerge:`
- **Generators**: `configMapGenerator`/`secretGenerator` add a hash to names for automatic restarts/rollouts

### 3. Safe label additions

```yaml
# patch.yaml (for Deployment)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  template:
    metadata:
      labels:
        env: prod # Add ONLY here
```

### 4. Example kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
patches:
  - path: patch.yaml
commonLabels:
  env: prod
configMapGenerator:
  - name: app-config
    literals: [LOG_LEVEL=INFO]
```


### 5. Set a transformer (value change)

Simply replace:
```yaml
images:
  name: nginx
  newName: haproxy
```

Patch:
```yaml
patches:
  - label-patch.yaml

# Or
patches:
  - target:
      kind: Deployment
      name: api-deployment
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 5
```


## What they test

1. Create base + overlay
2. Patch the Deployment (replicas/image)
3. Add labels without changing the selector
4. Generate ConfigMap/Secret
5. Debug via `kubectl kustomize`



## Manual (bottom-up search)

1. Find `labels` in the first `kustomization.yaml` block
2. Create structure `mkdir -p overlays/dev`
3. Put in your `kustomization.yaml`
4. Add the **patches** block
5. Add the **configMapGenerator** block
6. Minimal configuration
8. Check `kubectl kustomize ../overlays/dev`
9. Apply with `kubectl apply -k ../overlays/dev`
9. Compare with `kubectl diff -k ../overlays/dev`
