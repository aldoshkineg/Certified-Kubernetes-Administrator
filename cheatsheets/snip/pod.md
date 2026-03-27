# Pod snip

```yaml
spec:
  containers:
    - name: app
      ports:
        - containerPort: 80    # port inside the container
          protocol: TCP        # TCP (default?)
          name: http           # port name (optional, convenient)
```
