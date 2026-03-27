# Kubeadm

## Setup cluster

Init single Control-Plane:

```sh
kubeadm init --apiserver-advertise-address=192.168.56.11 --pod-network-cidr=10.244.0.0/16
kubeadm init --kubernetes-version=v1.34.0 # Setting version
```

Init HA cluster:

```sh
kubeadm init --apiserver-advertise-address=192.168.56.21 --control-plane-endpoint=192.168.56.10 --pod-network-cidr=10.
244.0.0/16 --upload-certs
```

Install Flannel:

```sh
wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml # Change CIDR
```

Join Control-Plane:

```sh
kubeadm init phase upload-certs --upload-certs

kubeadm token create --print-join-command

kubeadm join 192.168.56.10:6443 --token m5t146.2n3x7216onk2ch71 \
--discovery-token-ca-cert-hash sha256:3323c5688df4221bc2fe39d4b166d10fe7e954ddd9e7a176810a1c312bc429a9 \
--apiserver-advertise-address=192.168.56.22 \
--certificate-key=5e004720ad46cbbcc40b512f62f78decc7df5e7267eb0ce9638cded6dbb72111 --control-plane
```

Join node:

```sh
kubeadm token create --print-join-command
kubeadm join 192.168.56.11:6443 --token u6u99i.gbe1ao4glkq4spik \
--discovery-token-ca-cert-hash sha256:132add43ecb1197b53a5eba78e55b41bbe8dcabad876b7078c1efc13e7725499
```

Reset node:

```sh
kubeadm reset -f
kubectl delete node master-1 --force --grace-period=0
rm -rf /var/lib/etcd
```

## Update cluster

Update cluster:

```sh
# Search and setup version
apt-cache policy kubelet
apt-get install -y kubelet=1.33.0-00 kubeadm=1.33.0-00 kubectl=1.33.0-00

# Step-by-step 1.33 > 1.34 #
apt upgrade -y kubelet kubeadm kubectl
kubeadm upgrade plan
kubeadm upgrade apply v1.19.0

```

Update Control-Plane:

```sh
kubeadm upgrade node
systemctl restart kubelet
```

Update worker:

```sh
kubectl cordon # Only marks node unscheduled
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data --force
kubeadm upgrade node
systemctl restart kubelet
kubectl uncordon worker-1
```

## Renew certificate

```sh
# Check expiry
kubeadm certs check-expiration
sudo openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -dates

# Renew all certs
kubeadm certs renew all

# Restart all components
kubectl delete pods -n kube-system

# Reload kubelet
cp /etc/kubernetes/admin.conf /etc/kubernetes/bootstrap-kubelet.conf
systemctl restart kubelet

# Worker
kubeadm reset -f && kubeadm join
```

## Regenerate control-plane config

```sh
k get cm -n kube-system kubeadm-config -oyaml >kubeadm.yml
kubeadm init phase etcd local --config=kubeadm.yaml --dry-run
kubeadm init phase control-plane all --dry-run --config=kubeadm.yaml
```

## Regenerate full kubelet config

```sh
kubeadm init phase kubeconfig --config=kubeadm.yml #kubeconfig
kubeadm init phase kubelet-start --config=kubeadm.yml #/var/lib/kubelet
kubeadm init phase kubelet-finalize all --config=kubeadm.yml #kubeconfig+crt
```

## Etcd

Create backup:

```sh
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /tmp/etcd_backup.db
```

Stop services:

```sh
mkdir /etc/kubernetes/backup
mv /etc/kubernetes/manifest/* /etc/kubernetes/backup/
```

Restore backup (etcd>=3.6):

```sh
etcdutl snapshot restore etcd-snap --data-dir=/var/lib/etcd --initial-cluster=master-1=https://192.168.56.21:2380 --initial-advertise-peer-urls=https://192.168.56.21:2380 --name=master-1
```

Start services:

```sh
mv /etc/kubernetes/manifest/* /etc/kubernetes/backup/
```

Check etcd state:

```sh
etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list

ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint status -w table
```

Reset other masters:
```sh
kubeadm init phase upload-certs --upload-certs
kubeadm token create --print-join-command
kubeadm reset -f
kubeadm join
```

Change **ETCD** directory:

```sh
- hostPath:
    path: /var/lib/etcd-restore
```


Restore HA etcd external cluster (for each node)

```bash
# Create snapshot
etcdctl --endpoints 127.0.0.1:2379 --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key  --cacert=/etc/kubernetes/pki/etcd/ca.crt   snapshot save etcd-snap

# Prepare
systemctl stop etcd.service
EDITOR=vim systemctl edit --full etcd.service

# Restore
etcdutl snapshot restore etcd-snap --data-dir=/var/lib/etcd-restore --initial-cluster=master-1=https://192.168.56.21:2380,master-2=https://192.168.56.22:2380,master-3=https://192.168.56.23:2380 --initial-advertise-peer-urls=https://192.168.56.21:2380 --name=master-1

# Run
chown etcd:etcd -R /var/lib/etcd-restore
systemctl daemon-reload
systemctl start etcd.service
```

## Configuration

```sh
kubectl cluster-info # See HA status
kubectl get cm kubeadm-config -n kube-system -o yaml
```

Migrate configuration:
```sh
kubeadm config migrate --old-config kubeadm.yaml
```
