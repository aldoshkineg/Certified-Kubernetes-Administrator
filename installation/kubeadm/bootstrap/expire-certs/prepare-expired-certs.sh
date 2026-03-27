#!/bin/bash
echo "=== Preparing k8s cluster for certificate expiration practice ==="
echo "WARNING: This will disrupt time-sensitive services and applications!"
echo "Run only on isolated practice clusters."
echo

# 1. Stop kubelet and other critical services
echo "[1/5] Stopping Kubernetes services..."
sudo systemctl stop kubelet docker containerd
echo "Services stopped."

# 2. Disable time synchronization
echo "[2/5] Disabling time synchronization..."
sudo timedatectl set-ntp false
sudo systemctl stop systemd-timesyncd
sudo systemctl disable systemd-timesyncd
echo "Time synchronization disabled."

# # 3. Set date to 1 year ago
# echo "[3/5] Setting system date 1 year back..."
# OLD_DATE=$(date -d "1 year ago" "+%Y-%m-%d %H:%M:%S")
# echo "Setting date to: $OLD_DATE"
# sudo date --set "$OLD_DATE"
# echo "Date set successfully."

# 3. Set date to 1 year FORWARD
echo "[3/6] Setting system date 1 year FORWARD..."
FUTURE_DATE=$(date -d "1 year" "+%Y-%m-%d %H:%M:%S")
echo "Setting date to: $FUTURE_DATE"
sudo date --set "$FUTURE_DATE"
echo "Date set successfully."

# 4. Verify the change
echo "[4/5] Verifying new system time..."
timedatectl status
echo "Current date: $(date)"

# 5. Optional: Prevent auto time sync on reboot
echo "[5/5] Preventing time sync on future reboots..."
sudo timedatectl set-ntp false
echo "Done! System is now set to 1 year in the past."
echo "You can now start kubelet: sudo systemctl start kubelet"
echo "Certificates should appear expired or near expiry."
