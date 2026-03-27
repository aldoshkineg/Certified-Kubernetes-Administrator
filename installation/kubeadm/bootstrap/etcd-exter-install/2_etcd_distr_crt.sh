#!/bin/bash
set -e

ETCD_PKI_DIR=/etc/kubernetes/pki/etcd
ROOT_PASSWORD="root"  # Set the root password here

# Node information
NODES=("master-1" "master-2" "master-3")
IPS=("192.168.56.21" "192.168.56.22" "192.168.56.23")

echo "[+] Distributing certificates to all nodes..."

# Helper function to SSH with password
sshpass_ssh() {
    sshpass -p "$ROOT_PASSWORD" ssh -o StrictHostKeyChecking=no root@$1 "$2"
}

# Helper function to SCP with password
sshpass_scp() {
    sshpass -p "$ROOT_PASSWORD" scp -o StrictHostKeyChecking=no "$1" root@$2:"$3"
}

# First, ensure all nodes have the etcd PKI directory
for i in ${!NODES[@]}; do
    NODE=${NODES[$i]}
    IP=${IPS[$i]}

    echo "[+] Creating directories on ${NODE} (${IP})"
    sshpass_ssh "$IP" "mkdir -p /etc/kubernetes/pki/etcd"
done

# Copy CA and healthcheck client cert to all nodes (these are common)
echo "[+] Copying common certificates..."
for i in ${!NODES[@]}; do
    NODE=${NODES[$i]}
    IP=${IPS[$i]}

    echo "  -> Copying to ${NODE}"
    sshpass_scp "$ETCD_PKI_DIR/ca.crt" "$IP" "/etc/kubernetes/pki/etcd/"
    sshpass_scp "$ETCD_PKI_DIR/ca.key" "$IP" "/etc/kubernetes/pki/etcd/"
    sshpass_scp "$ETCD_PKI_DIR/healthcheck-client.crt" "$IP" "/etc/kubernetes/pki/etcd/"
    sshpass_scp "$ETCD_PKI_DIR/healthcheck-client.key" "$IP" "/etc/kubernetes/pki/etcd/"

    # Set proper permissions
    sshpass_ssh "$IP" "chmod 600 /etc/kubernetes/pki/etcd/*.key"
done

# Copy node-specific certificates
echo "[+] Copying node-specific certificates..."
for i in ${!NODES[@]}; do
    NODE=${NODES[$i]}
    IP=${IPS[$i]}

    echo "  -> Copying ${NODE} certificates"
    sshpass_scp "$ETCD_PKI_DIR/${NODE}-server.crt" "$IP" "/etc/kubernetes/pki/etcd/"
    sshpass_scp "$ETCD_PKI_DIR/${NODE}-server.key" "$IP" "/etc/kubernetes/pki/etcd/"
    sshpass_scp "$ETCD_PKI_DIR/${NODE}-peer.crt" "$IP" "/etc/kubernetes/pki/etcd/"
    sshpass_scp "$ETCD_PKI_DIR/${NODE}-peer.key" "$IP" "/etc/kubernetes/pki/etcd/"

    # Create symlinks for easy reference
    sshpass_ssh "$IP" "cd /etc/kubernetes/pki/etcd && \
        ln -sf ${NODE}-server.crt server.crt && \
        ln -sf ${NODE}-server.key server.key && \
        ln -sf ${NODE}-peer.crt peer.crt && \
        ln -sf ${NODE}-peer.key peer.key"

    # Set permissions
    sshpass_ssh "$IP" "chmod 600 /etc/kubernetes/pki/etcd/${NODE}-*.key"
done

# Copy apiserver-etcd-client certs to all nodes (for future kubeadm use)
echo "[+] Copying apiserver-etcd-client certificates..."
for i in ${!NODES[@]}; do
    NODE=${NODES[$i]}
    IP=${IPS[$i]}

    echo "  -> Copying to ${NODE}"
    sshpass_scp "/etc/kubernetes/pki/apiserver-etcd-client.crt" "$IP" "/etc/kubernetes/pki/"
    sshpass_scp "/etc/kubernetes/pki/apiserver-etcd-client.key" "$IP" "/etc/kubernetes/pki/"

    # Set permissions
    sshpass_ssh "$IP" "chmod 600 /etc/kubernetes/pki/apiserver-etcd-client.key"
done

echo "[✓] Certificates distributed successfully!"

