# Linux

## Prepare


- Setup hostname
- Setting `ip route add `

Disable swap:

```sh
swapoff -a
sed -i '/swap/d' /etc/fstab
```

Disable firewall (for learning environment):

```sh
ufw disable
```

Load kernel modules:

```sh
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOFmodprobe overlay

modprobe overlay
modprobe br_netfilter
```

Sysctl params:

```sh
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system
```

Configure containerd:

```sh
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd
```

Install kubeadm, kubelet, kubectl:

```sh
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet
```

CRICTL - universal working with CRI
Use critcl/ctr/nerdctl
```sh
crictl --runtime-endpoint
crictl pods
crictl pods –label app=nginx
crictl images
crictl ps -a
crictl ps
crictl exec -it <containerid> <command>
crictl logs <containerid>
crictl pull busybox
ctr images
```
