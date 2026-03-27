# Cluster Architecture, Installation & Configuration (25%)

This domain covers cluster setup, configuration, and management.

## Topics Covered

### RBAC (Role-Based Access Control)
- Create and manage Roles
- Create and manage ClusterRoles
- Create and manage RoleBindings
- Create and manage ClusterRoleBindings
- Understand ServiceAccounts
- Configure authentication and authorization

### Infrastructure Preparation
- Prepare nodes for Kubernetes installation
- Configure container runtime (containerd, CRI-O)
- Set up networking prerequisites
- Configure kernel parameters
- Disable swap

### kubeadm Cluster Management
- Initialize cluster with kubeadm
- Join nodes to cluster
- Upgrade cluster with kubeadm
- Backup and restore etcd
- Understand kubeadm configuration

### Cluster Lifecycle Management
- Upgrade cluster components
- Upgrade worker nodes
- Drain and cordon nodes
- Backup cluster state
- Restore cluster from backup

### High Availability Control Plane
- Set up HA etcd cluster
- Configure multiple API servers
- Implement load balancing for API servers
- Understand control plane components

### Helm and Kustomize
- Install applications with Helm
- Create and manage Helm charts
- Use Kustomize for configuration management
- Understand Helm vs Kustomize

### Extension Interfaces
- CNI (Container Network Interface)
- CSI (Container Storage Interface)
- CRI (Container Runtime Interface)
- Understand plugin architecture

### CRDs and Operators
- Understand CustomResourceDefinitions
- Install operators
- Configure operators
- Manage custom resources

## Key Documentation

- `kubeadm_doc.md` - kubeadm installation and configuration guide

## Key Commands

```bash
# kubeadm
kubeadm init
kubeadm join
kubeadm upgrade
kubeadm reset

# RBAC
kubectl create role
kubectl create clusterrole
kubectl create rolebinding
kubectl create clusterrolebinding

# Node management
kubectl drain <node>
kubectl cordon <node>
kubectl uncordon <node>

# ServiceAccount
kubectl create serviceaccount
kubectl get serviceaccount
```

## Practice Resources

- Exercises: `../../exercises/by-topic/cluster-architecture/`
- Labs: `../../exercises/labs/tasks/` (Tasks 16-20)
- Templates: `../../templates/` (RBAC templates)

## Study Tips

1. **Practice kubeadm**: Set up clusters multiple times
2. **Understand RBAC**: Know the difference between Role and ClusterRole
3. **Learn etcd**: Backup/restore is commonly tested
4. **Study operators**: CRDs are increasingly important
5. **Time management**: Installation tasks can be time-consuming

---

**Weight**: 25% of exam - **SECOND HIGHEST PRIORITY**
