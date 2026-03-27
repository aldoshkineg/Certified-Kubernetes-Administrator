# Pod DNS

## DNS Policies

| dnsPolicy               | Description               | When to use                        |
| ----------------------- | ------------------------- | ---------------------------------- |
| Default                 | Use **node DNS**          | Bypass cluster DNS                 |
| ClusterFirst            | Use **CoreDNS** first     | Default for Pods in cluster        |
| ClusterFirstWithHostNet | Cluster DNS + hostNetwork | Host network Pods need cluster DNS |
| None                    | Fully **custom DNS**      | Must define `dnsConfig`            |

---

## Custom DNS (`dnsPolicy: None`)

```yaml
dnsPolicy: None
dnsConfig:
  nameservers:
    - <IP>
  searches:
    - <domain1>
    - <domain2>
  options:
    - name: ndots
      value: "<number>"
    - name: edns0
```

- **nameservers:** Where queries go
- **searches:** Domains appended to short names
- **options:** Resolver behavior (`ndots`, `edns0`)

---

## Quick Rules

1. **`dnsPolicy: None` → must set `dnsConfig`**
2. **`dnsPolicy: Default` → use node DNS**
3. **`hostNetwork: true` → Pod shares node IP/ports, DNS still follows policy**
4. **`ndots`** controls whether short names append search domains
5. **`edns0`** enables modern DNS features

---

**Memory shortcut:**

- Default → node DNS
- ClusterFirst → cluster DNS
- None → custom DNS
- hostNetwork → only affects IP/ports, **not DNS behavior**
