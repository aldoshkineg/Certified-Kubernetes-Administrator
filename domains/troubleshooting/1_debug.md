# Troubleshooting

## Short check

### **Troubleshooting App in k8s**

```bash
kubectl get pods
kubectl describe pod
kubectl logs
kubectl describe deploy
kubectl describe svc
kubectl get events
kubectl exec -it  # ping, shell, etc.
kubectl get netpol
```
---

### **Troubleshooting Cluster**

```bash
kubectl cluster-info
kubectl get cs
kubectl get nodes -o wide
kubectl get pods -n kube-system
kubectl get events -n kube-system
kubectl logs <pod-name> -n kube-system
kubectl top nodes
kubectl exec -it  # dns, ping
```

### **On nodes**

```bash
systemctl status kubelet
journalctl -u kubelet
crictl ps
crictl logs <container-id>
ss -ntlp
ps aux | grep kube
kubeadm init phase control-plane all --dry-run   # with diff to check
```


## 0. Cluster state

```bash
kubectl cluster-info                        # Control plane status
kubectl get cs                              # Component status
kubectl get nodes -A -owide                 # Status of all nodes (detailed)
kubectl cluster-info dump | grep -i error   # Search for errors in the dump
```

---

## 1. Check context and kubeconfig

**Current context and user**

```bash
kubectl config current-context
kubectl --kubeconfig <file> auth whoami          # Who am I in this kubeconfig
kubectl auth can-i --list --kubeconfig=<file>    # List permissions for the user
```

**Verify certificates in kubeconfig**

```bash
# Extract and decode the client certificate from kubeconfig, then print full details
kubectl --kubeconfig kubelet.conf config view --raw \
  -o jsonpath='{.users[0].user.client-certificate-data}' \
  | base64 -d | openssl x509 -noout -subject -text
```

---

## 2. Check sequence (API → Kubelet → etcd → CRI)

- **API Server**: is it reachable? (`kubectl get pods`)
- **Kubelet**: is it working on nodes? (`systemctl status kubelet`, logs)
- **etcd**: is it healthy? (`etcdctl endpoint health`)
- **CRI**: are containers ok? (`crictl ps`, `crictl logs`)

---

## 3. Pod problems

| State / Error               | Typical causes                                    |
| --------------------------- | ------------------------------------------------- |
| `Pending`                   | Insufficient resources, taints, PVC, node selectors |
| `CrashLoopBackOff`          | App error, probes, memory limits                |
| `ImagePullBackOff`          | Wrong image, no access to registry              |
| `OOMKilled`                 | Memory limit exceeded                             |
| `CreateContainerConfigError` | Missing ConfigMap/Secret, env var mistakes    |
| `FailedScheduling`          | Taints, selectors, insufficient resources        |

**Core commands**

```bash
kubectl get pods -o wide                     # Status + nodes
kubectl describe pod <pod>                    # Events and details
kubectl logs <pod> [--previous]               # Logs (previous)
kubectl exec -it <pod> -- sh                   # Access the container
kubectl debug pod/<pod> -it --image=busybox --target=<container>  # Temporary debug container
kubectl top pod                                # Pod resource usage
```

---

## 4. Service and networking problems

1. **Check the Service and endpoints**

   ```bash
   kubectl get svc, endpointslices
   ```

2. **Run a test Pod**

   ```bash
   kubectl run debug --image=busybox -it --rm -- sh
   ```

3. **Inside the debug Pod, check DNS and connectivity**

   ```bash
   nslookup <service-name>.<namespace>.svc.cluster.local
   wget -qO- <service-ip>:<port>
   ```

4. **Check `kube-proxy`**

   ```bash
   kubectl logs -n kube-system -l k8s-app=kube-proxy
   # On the node: iptables -L -t nat | grep <service>
   ```

5. **Consider NetworkPolicy** — if present, make sure they allow the traffic.

---

## 5. Node problems (Nodes)

**Status check**

```bash
kubectl get nodes -A -owide
kubectl describe node <node>
kubectl top nodes                              # Node load monitoring
```

**Node conditions**: `Ready`, `MemoryPressure`, `DiskPressure`, `PIDPressure`, `KubeletNotReady`.

**Diagnose directly on the node**

```bash
systemctl status kubelet               # Is kubelet running?
journalctl -u kubelet -f                # kubelet logs
crictl ps                                # Containers running via CRI
crictl logs <container-id>               # Logs of the specific container
systemctl restart kubelet                # Restart if needed
```

---

## 6. Control plane problems (Control Plane)

**Component check**

```bash
kubectl get pods -n kube-system          # Are they all running?
kubectl logs -n kube-system <pod>         # Logs (api-server, scheduler, controller-manager)
```

**etcd**

```bash
# If etcd is running as a Pod:
kubectl exec -n kube-system etcd-pod -- etcdctl endpoint health
etcdctl endpoint health
```

---

## 7. Certificate and quota checks

**Certificate expiration (kubeadm)**

```bash
kubeadm certs check-expiration            # Certificate expiration
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text | grep Not
```

**Quotas and limits**

```bash
kubectl get resourcequota,limitrange -A
kubectl describe pod <pod> | grep -A5 Requests
```

---

## 8. Additional useful commands

```bash
kubectl events -A --watch                  # Real-time events (alternative to deprecated `get events`)
kubectl get all -A                          # All resources across all namespaces
kubectl api-resources                        # List available resources
kubectl explain <resource>                  # Help for resource fields
```

---

## 9. System troubleshooting flow

```
Problem
   |
   v
Type: ──┬──> Pods ──> kubectl get pods, describe, logs, events
       ├──> Services ──> Check svc, endpoints, DNS, kube-proxy
       ├──> Nodes ──> Node status, kubelet, crictl, top nodes
       └──> Control Plane ──> Check kube-system components, etcd
                |
                v
         Error analysis and fixes
```
