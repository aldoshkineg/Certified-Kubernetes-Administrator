#!/bin/bash

# Kubernetes Bootstrap Script for Ubuntu 22.04
# Usage: ./bootstrap.sh [pure|base|full]
#
# Modes:
#   pure - basic system preparation (timezone, repo, essential packages)
#   base - pure + system configuration (swap off, modules, sysctl) and containerd installation
#   full - base + containerd configuration and kubeadm/kubelet/kubectl installation

set -e

MODE=${1:-full}   # default to full if not specified

# Validate mode
if [[ ! "$MODE" =~ ^(pure|base|full)$ ]]; then
    echo "Invalid mode: $MODE. Usage: $0 [pure|base|full]"
    exit 1
fi

echo "=== Starting Kubernetes bootstrap in $MODE mode ==="

# ----------------------------------------------------------------------
# pure steps (always run)
# ----------------------------------------------------------------------
echo ">>> [pure] Setting timezone, repository, and installing basic packages..."
timedatectl set-timezone Europe/Moscow
sed -i 's/mirrors.edge.kernel.org/mirror.yandex.ru/g' /etc/apt/sources.list

apt update -y
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  software-properties-common

# If mode is pure, we stop here
if [ "$MODE" = "pure" ]; then
    echo "=== Pure mode completed ==="
    exit 0
fi

# ----------------------------------------------------------------------
# base steps (pure + base)
# ----------------------------------------------------------------------
echo ">>> [base] Disabling swap, loading kernel modules, and applying sysctl settings..."
swapoff -a
sed -i '/swap/d' /etc/fstab
ufw disable

# Load kernel modules
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# Sysctl params
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# Install containerd (container runtime)
echo ">>> [base] Installing containerd..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y containerd.io

# If mode is base, we stop here
if [ "$MODE" = "base" ]; then
    echo "=== Base mode completed ==="
    exit 0
fi

# ----------------------------------------------------------------------
# full steps (base + full)
# ----------------------------------------------------------------------
echo ">>> [full] Configuring containerd and installing Kubernetes components..."

# Configure containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Install kubeadm, kubelet, kubectl
K8S_VERSION="1.35"
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v$K8S_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$K8S_VERSION/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Enable kubelet
systemctl enable --now kubelet

# Pull control plane images
if [[ "$(hostname)" =~ [Mm]aster ]]; then
    echo ">>>  Pulling Kubernetes control plane images..."
    kubeadm config images pull
fi

echo "=== Full mode completed ==="
