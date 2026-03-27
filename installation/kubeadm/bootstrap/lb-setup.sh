#!/bin/bash
echo "=== Setting up HAProxy Load Balancer ==="

LB_IP=192.168.56.10

# Set timezone
timedatectl set-timezone Europe/Moscow

# Set conf repository
sed -i 's/mirrors.edge.kernel.org/mirror.yandex.ru/g' /etc/apt/sources.list

apt-get update
apt-get install -y haproxy

# Configure HAProxy for Kubernetes API (port 6443)
cat <<EOF >/etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon
    maxconn 4096
    user haproxy
    group haproxy

defaults
    log global
    mode tcp
    option tcplog
    option dontlognull
    timeout connect 5000ms
    timeout client 50000ms
      timeout server 50000ms
    retries 3

frontend kubernetes-api
    bind $LB_IP:6443
    default_backend kubernetes-masters

backend kubernetes-masters
    balance roundrobin
    option tcp-check
    # Master 1
    server k8s-master-1 192.168.56.21:6443 check fall 3 rise 2
    # Master 2
    server k8s-master-2 192.168.56.22:6443 check fall 3 rise 2
    # Master 3
    server k8s-master-3 192.168.56.23:6443 check fall 3 rise 2

# Optional: Stats page for monitoring
listen stats
    bind :9000
    mode http
    stats enable
    stats uri /
    stats refresh 5s
    stats show-legends
    stats show-node
EOF

systemctl restart haproxy
systemctl enable haproxy

echo "=== HAProxy Load Balancer configured ==="
echo "API Load Balancer: $LB_IP:6443"
echo "HAProxy Stats: http://$LB_IP:9000"
