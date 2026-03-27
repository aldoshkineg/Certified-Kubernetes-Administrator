# Need memory

- NIKI
- 10.244.0.0/16 - pod-network
- ephemeral-storage
- etcd cluster restore (needs headers)
- Events -w (see what’s happening)
- OOM - 2x

---
- --as=system:serviceaccount:ns:sa | --serviceaccount=cka-q3:cka-sa
- nodeName, nodeSelector, NodeAffinity (NSA)
- pv:sach, pvc:sarv, sc:pv
- netpool (OR | AND rules)
- custom-resources (for ...)
- Ingress - example 2 lines from the bottom (k create ingress)
- kubeadm init phase control-plane all --dry-run | kubelet-start | etcd local
- app=web, run=web - default labels when creating via `create`
- limits (pods) | quota (ns)
- Gateway - Guides: TLS, Splitting
- CoreDNS: RNSNO rewrite name substring (new) (old) | Hosts {fallthrough} | Redirect
- (Allocatable - Requests - 10% System) ÷ Pods Request × 1.2 (or 20% higher) Limit
- readOnly: true (search volume readonly)
- api/v1/secrets (curl api) | jq
- k config view --flatten
- Besteffort
- Affinity (constraint)
- iptables-save | grep service-name
- k explain resources
