#!/bin/bash
set -e

ETCD_PKI_DIR=/etc/kubernetes/pki/etcd

NODES=("master-1" "master-2" "master-3")
IPS=("192.168.56.21" "192.168.56.22" "192.168.56.23")

mkdir -p ${ETCD_PKI_DIR}

echo "[+] Generate ETCD CA"
kubeadm init phase certs etcd-ca

echo "[+] Generate API Server → ETCD client cert"
kubeadm init phase certs apiserver-etcd-client

for i in ${!NODES[@]}; do
  NODE=${NODES[$i]}
  IP=${IPS[$i]}

  echo "[+] Generating certs for ${NODE} (${IP})"

  cat <<EOF > /tmp/etcd-${NODE}.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
etcd:
  local:
    serverCertSANs:
      - ${NODE}
      - ${IP}
      - 127.0.0.1
    peerCertSANs:
      - ${NODE}
      - ${IP}
      - 127.0.0.1
EOF

  kubeadm init phase certs etcd-server --config /tmp/etcd-${NODE}.yaml
  kubeadm init phase certs etcd-peer   --config /tmp/etcd-${NODE}.yaml
  kubeadm init phase certs etcd-healthcheck-client

  mv ${ETCD_PKI_DIR}/server.crt ${ETCD_PKI_DIR}/${NODE}-server.crt
  mv ${ETCD_PKI_DIR}/server.key ${ETCD_PKI_DIR}/${NODE}-server.key
  mv ${ETCD_PKI_DIR}/peer.crt   ${ETCD_PKI_DIR}/${NODE}-peer.crt
  mv ${ETCD_PKI_DIR}/peer.key   ${ETCD_PKI_DIR}/${NODE}-peer.key
done

echo "[✓] ETCD certificates generated successfully"
