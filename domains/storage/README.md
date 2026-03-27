# Storage (10%)

This domain covers persistent storage, volumes, and storage classes.

## Topics Covered

### Storage Classes
- Understand StorageClass resources
- Create StorageClass resources
- Configure provisioner
- Set default storage class
- Understand volume binding modes

### Dynamic Volume Provisioning
- Enable dynamic provisioning
- Configure storage class for PVCs
- Understand provisioner types
- Configure volume expansion

### Volume Types
- Understand volume types (hostPath, emptyDir, NFS, etc.)
- Configure volume access modes
- Understand ReadWriteOnce, ReadOnlyMany, ReadWriteMany
- Choose appropriate volume type

### Reclaim Policies
- Understand Retain policy
- Understand Delete policy
- Understand Recycle policy (deprecated)
- Configure reclaim policy

### Persistent Volumes (PVs)
- Create PersistentVolume resources
- Configure PV capacity
- Set access modes
- Configure storage class
- Understand PV lifecycle

### Persistent Volume Claims (PVCs)
- Create PersistentVolumeClaim resources
- Bind PVCs to PVs
- Mount PVCs in pods
- Understand PVC lifecycle
- Resize PVCs

## Key Concepts

### Access Modes
- **ReadWriteOnce (RWO)**: Single node read-write
- **ReadOnlyMany (ROX)**: Multiple nodes read-only
- **ReadWriteMany (RWX)**: Multiple nodes read-write

### Reclaim Policies
- **Retain**: Manual cleanup required
- **Delete**: Automatically deleted when PVC is deleted

### Volume Types
- **hostPath**: Node filesystem (testing only)
- **emptyDir**: Temporary storage
- **NFS**: Network File System
- **CSI**: Container Storage Interface (production)

## Key Commands

```bash
# Storage Classes
kubectl get storageclass
kubectl create storageclass
kubectl patch storageclass <name> -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Persistent Volumes
kubectl get pv
kubectl describe pv
kubectl create -f pv.yaml

# Persistent Volume Claims
kubectl get pvc
kubectl describe pvc
kubectl create -f pvc.yaml
kubectl delete pvc <name>

# Expand PVC
kubectl patch pvc <name> -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'
```

## Practice Resources

- Exercises: `../../exercises/by-topic/storage/`
- Labs: `../../exercises/labs/tasks/` (Task 1, Task 25)
- Templates: `../../templates/` (Check for PV/PVC templates)

## Study Tips

1. **Understand access modes**: Know when to use each mode
2. **Practice PVC creation**: Common exam task
3. **Learn StorageClass**: Dynamic provisioning is standard
4. **Know reclaim policies**: Understand data retention
5. **Volume mounting**: Practice mounting PVCs in pods

---

**Weight**: 10% of exam - **SMALLEST DOMAIN**
