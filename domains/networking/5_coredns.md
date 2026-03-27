# CoreDNS (CKA)

[Custom DNS](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)

**Ports:** 53/UDP, 53/TCP (DNS), 9153/TCP (Prometheus)

**What to restore the DNS name**
cat /etc/resolv.con | grep cluster.local

**Access a Service within the same namespace**
- `ping api`
- `dig` doesn't work with short names — use the full name, `hosts`, or `nslookup`

**Access a Service in another namespace**
- `ping api.namespace.svc.cluster.local` ## Not recommended; use the full FQDN
- `ping api.namespace` ## Not recommended; use the full FQDN
- 10-244-0-138.dns.pod

**Service check:**
kubectl -n kube-system get svc kube-dns
# ClusterIP is usually 10.96.0.10

**Install test tools:**
apk add bind-tools  # alpine

**Restart CoreDNS:**
kubectl -n kube-system rollout restart deployment coredns

## Main Corefile sections

- `kubernetes {}` — plugin for resolving Service and Pod names in cluster.local
- `log`, `errors` — request/error logging
- `hosts {}` — static hosts (aka_/etc/hosts); use `fallthrough` for other queries
- `forward . 1.1.1.1` — forward all external requests to the specified DNS
- extra block: consul.local:53 {forward . 10.150.0.1} — forward all *.cluster.local queries
- `rewrite name substring svc.cka.example.com svc.cluster.local` - rewrite to svc.cluster.local
