#!/bin/bash
set -e

# Configuration - CHANGE THESE FOR EACH NODE
NODE_NAME="master-1"  # Change to: master-1, master-2, or master-3
NODE_IP="192.168.56.21"  # Change to node's IP
ETCD_VERSION="3.6.6"  # Can be 3.4.x, 3.5.x, or 3.6.x
CLUSTER_NAME="etcd-cluster"

# Directories
ETCD_PKI_DIR="/etc/kubernetes/pki/etcd"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_CONF_DIR="/etc/etcd"

# Cluster members
INITIAL_CLUSTER="master-1=https://192.168.56.21:2380,master-2=https://192.168.56.22:2380,master-3=https://192.168.56.23:2380"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[+]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root"
    exit 1
fi

print_status "Starting etcd installation on $NODE_NAME ($NODE_IP)"
print_status "Using kubeadm-generated certificates from $ETCD_PKI_DIR"

# Validate certificates exist
required_certs=("ca.crt" "${NODE_NAME}-server.crt" "${NODE_NAME}-server.key" "${NODE_NAME}-peer.crt" "${NODE_NAME}-peer.key" "healthcheck-client.crt" "healthcheck-client.key")
for cert in "${required_certs[@]}"; do
    if [ ! -f "$ETCD_PKI_DIR/$cert" ]; then
        print_error "Missing certificate: $ETCD_PKI_DIR/$cert"
        print_error "Please run certificate distribution script first"
        exit 1
    fi
done

# Update system
print_status "Updating system packages..."
apt-get update
apt-get install -y wget curl

# Create etcd user and group
if ! id "etcd" &>/dev/null; then
    print_status "Creating etcd user and group..."
    groupadd --system etcd 2>/dev/null || true
    useradd --system --home /var/lib/etcd --shell /sbin/nologin --comment "etcd user" --gid etcd etcd 2>/dev/null || true
fi

# Download etcd
print_status "Downloading etcd v$ETCD_VERSION..."
cd /tmp
ETCD_TAR="etcd-v${ETCD_VERSION}-linux-amd64.tar.gz"
wget -q "https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/${ETCD_TAR}"

if [ ! -f "$ETCD_TAR" ]; then
    print_error "Failed to download etcd"
    exit 1
fi

# Extract and install
print_status "Installing etcd binaries..."
tar xzf "$ETCD_TAR"
cd "etcd-v${ETCD_VERSION}-linux-amd64"
cp etcd etcdctl etcdutl /usr/local/bin/
chmod +x /usr/local/bin/etcd /usr/local/bin/etcdctl /usr/local/bin/etcdutl

# Create directories
print_status "Creating directories..."
mkdir -p $ETCD_DATA_DIR $ETCD_CONF_DIR
chown -R etcd:etcd $ETCD_DATA_DIR
chmod 700 $ETCD_DATA_DIR

# Create symbolic links for certificates (use generic names)
print_status "Creating certificate symlinks..."
cd $ETCD_PKI_DIR
ln -sf ${NODE_NAME}-server.crt server.crt
ln -sf ${NODE_NAME}-server.key server.key
ln -sf ${NODE_NAME}-peer.crt peer.crt
ln -sf ${NODE_NAME}-peer.key peer.key

# Set proper permissions for etcd user
print_status "Setting certificate permissions..."
# Make sure etcd user can read the certificates
chown root:etcd $ETCD_PKI_DIR/ca.crt
chown root:etcd $ETCD_PKI_DIR/server.crt
chown root:etcd $ETCD_PKI_DIR/peer.crt
chown etcd:etcd $ETCD_PKI_DIR/server.key
chown etcd:etcd $ETCD_PKI_DIR/peer.key
chown root:root $ETCD_PKI_DIR/ca.key
chown root:root $ETCD_PKI_DIR/healthcheck-client.crt
chown root:root $ETCD_PKI_DIR/healthcheck-client.key

# Set file permissions
chmod 644 $ETCD_PKI_DIR/ca.crt
chmod 644 $ETCD_PKI_DIR/server.crt
chmod 644 $ETCD_PKI_DIR/peer.crt
chmod 600 $ETCD_PKI_DIR/server.key
chmod 600 $ETCD_PKI_DIR/peer.key
chmod 600 $ETCD_PKI_DIR/ca.key
chmod 600 $ETCD_PKI_DIR/healthcheck-client.crt
chmod 600 $ETCD_PKI_DIR/healthcheck-client.key

# Create etcd systemd service
print_status "Creating etcd systemd service..."
cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd - highly-available key value store
Documentation=https://github.com/etcd-io/etcd
Documentation=man:etcd
After=network.target
Wants=network-online.target

[Service]
Type=notify
User=etcd
Group=etcd
Environment=ETCD_NAME=${NODE_NAME}
Environment=ETCD_DATA_DIR=${ETCD_DATA_DIR}
Environment=ETCD_LISTEN_PEER_URLS=https://${NODE_IP}:2380
Environment=ETCD_LISTEN_CLIENT_URLS=https://${NODE_IP}:2379,https://127.0.0.1:2379
Environment=ETCD_INITIAL_ADVERTISE_PEER_URLS=https://${NODE_IP}:2380
Environment=ETCD_ADVERTISE_CLIENT_URLS=https://${NODE_IP}:2379
Environment=ETCD_INITIAL_CLUSTER=${INITIAL_CLUSTER}
Environment=ETCD_INITIAL_CLUSTER_TOKEN=${CLUSTER_NAME}
Environment=ETCD_INITIAL_CLUSTER_STATE=new
Environment=ETCD_CERT_FILE=${ETCD_PKI_DIR}/server.crt
Environment=ETCD_KEY_FILE=${ETCD_PKI_DIR}/server.key
Environment=ETCD_PEER_CERT_FILE=${ETCD_PKI_DIR}/peer.crt
Environment=ETCD_PEER_KEY_FILE=${ETCD_PKI_DIR}/peer.key
Environment=ETCD_TRUSTED_CA_FILE=${ETCD_PKI_DIR}/ca.crt
Environment=ETCD_PEER_TRUSTED_CA_FILE=${ETCD_PKI_DIR}/ca.crt
Environment=ETCD_CLIENT_CERT_AUTH=true
Environment=ETCD_PEER_CLIENT_CERT_AUTH=true
Environment=ETCD_AUTO_COMPACTION_RETENTION=1
Environment=ETCD_SNAPSHOT_COUNT=10000
ExecStart=/usr/local/bin/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Create etcdctl wrapper script
print_status "Creating etcdctl wrapper script..."
cat > /usr/local/bin/etcdctl-wrapper <<EOF
#!/bin/bash
export ETCDCTL_API=3
/usr/local/bin/etcdctl \\
    --endpoints=https://192.168.56.21:2379,https://192.168.56.22:2379,https://192.168.56.23:2379 \\
    --cacert=${ETCD_PKI_DIR}/ca.crt \\
    --cert=${ETCD_PKI_DIR}/healthcheck-client.crt \\
    --key=${ETCD_PKI_DIR}/healthcheck-client.key \\
    "\$@"
EOF

chmod +x /usr/local/bin/etcdctl-wrapper

# Create alias for root user
echo 'alias etcdctl-cluster="etcdctl-wrapper"' >> /root/.bashrc

# Check if etcd is already running and stop it
if systemctl is-active --quiet etcd; then
    print_status "Stopping existing etcd service..."
    systemctl stop etcd
fi

# Reload systemd and start etcd
print_status "Starting etcd service..."
systemctl daemon-reload
systemctl enable etcd
systemctl start etcd

# Wait for etcd to start
print_status "Waiting for etcd to start..."
sleep 8

# Check service status
if systemctl is-active --quiet etcd; then
    print_status "etcd service is running"

    # Check logs for any errors
    print_status "Checking etcd logs..."
    journalctl -u etcd --no-pager -n 10

    # Check local endpoint health
    print_status "Checking local endpoint health..."
    ETCDCTL_API=3 etcdctl \
        --endpoints=https://${NODE_IP}:2379 \
        --cacert=${ETCD_PKI_DIR}/ca.crt \
        --cert=${ETCD_PKI_DIR}/healthcheck-client.crt \
        --key=${ETCD_PKI_DIR}/healthcheck-client.key \
        endpoint health --dial-timeout=5s 2>/dev/null || print_warning "Local endpoint health check failed (may be normal during cluster formation)"

else
    print_error "etcd service failed to start"
    print_status "Checking systemd status..."
    systemctl status etcd --no-pager

    print_status "Checking journal logs..."
    journalctl -u etcd --no-pager -n 30

    # Check certificate permissions
    print_status "Checking certificate permissions..."
    ls -la $ETCD_PKI_DIR/ | grep -E "\.(crt|key)$"

    exit 1
fi

print_status "Installation completed on $NODE_NAME!"
print_status "ETCD endpoint: https://$NODE_IP:2379"
print_status "Use 'etcdctl-wrapper' to interact with the cluster"
print_status "Service management:"
print_status "  systemctl status etcd"
print_status "  journalctl -u etcd -f"
print_status "  systemctl restart etcd"
