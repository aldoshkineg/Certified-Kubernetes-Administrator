## Volumes/VolumeMounts


## 📦 volumes (Pod)

```yaml
volumes:
- name: data
  <type>
```

## 🔗 volumeMounts (Container)

```yaml
volumeMounts:
- name: data
  mountPath: /data
```

Main volume types:

* `emptyDir` — temporary
* `persistentVolumeClaim` — persistent
* `configMap` — configs
* `secret` — secrets
* `hostPath` — node directory

---


# Example resource
```yaml
volumes:
  - name: temp-data
    emptyDir: {}               # temporary; cleared when the Pod is deleted

  - name: pvc-data
    persistentVolumeClaim:
      claimName: my-pvc       # persistent storage via PVC

  - name: config
    configMap:
      name: app-config         # configuration files

  - name: secret
    secret:
      secretName: app-secret   # secrets (passwords, tokens)

  - name: host
    hostPath:
      path: /mnt/data          # node directory
      type: Directory
```
