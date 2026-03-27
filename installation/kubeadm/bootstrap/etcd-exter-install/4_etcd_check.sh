#!/bin/bash

ETCD_PKI_DIR=/etc/kubernetes/pki/etcd

echo "=== Checking Certificate Structure ==="
ls -la $ETCD_PKI_DIR/

echo -e "\n=== Checking Certificate Details ==="
for cert in ca.crt master-1-server.crt healthcheck-client.crt; do
    if [ -f "$ETCD_PKI_DIR/$cert" ]; then
        echo "--- $cert ---"
        openssl x509 -in "$ETCD_PKI_DIR/$cert" -text -noout | grep -E "Subject:|Issuer:|Not Before|Not After"
    fi
done

echo -e "\n=== Checking Certificate SANs ==="
for node in master-1 master-2 master-3; do
    if [ -f "$ETCD_PKI_DIR/${node}-server.crt" ]; then
        echo "--- ${node}-server.crt ---"
        openssl x509 -in "$ETCD_PKI_DIR/${node}-server.crt" -text -noout | grep -A1 "Subject Alternative Name"
    fi
done

echo -e "\n=== Certificate Validity Check ==="
for cert in $ETCD_PKI_DIR/*.crt; do
    echo "$(basename $cert): $(openssl x509 -in $cert -enddate -noout | cut -d= -f2)"
done
