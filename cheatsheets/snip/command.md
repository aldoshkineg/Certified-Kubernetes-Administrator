# Container command

## 🔹 Container: entrypoint and command/args

- **ENTRYPOINT → command** (fully replaces the image's entrypoint)
- **CMD → args** (only arguments; if ENTRYPOINT is set, it may not behave as expected)
- **First element of `command`** = binary/executable (`argv[0]`)
- **Don't rely on `args` without `command`** — the image's ENTRYPOINT may override behavior.

## 🔹 Reference command formats

1. Simple array form:

```yaml
command: ["sleep", "60"]
```

2. Line-by-line YAML (equivalent to the array):

```yaml
- command:
    - sleep
    - 1d
```

3. Use `sh` for loops/logic:

```yaml
command: ["sh", "-c", "while true; do echo now; sleep 2; done"]
```

4. CLI/run:

```bash
kubectl run test --image=alpine --command -- sh -c "sleep 1d"
```

5. CLI/run short form with args:

```bash
kubectl run test --image=alpine -- sleep 1d
```
