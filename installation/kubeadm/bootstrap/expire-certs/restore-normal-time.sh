#!/bin/bash
echo "=== Restoring Correct System Time ==="
echo

# 1. Stop services affected by time change
echo "[1/5] Stopping time-sensitive services..."
sudo systemctl stop kubelet docker containerd
echo "Services stopped."

# 2. Enable NTP synchronization
echo "[2/5] Enabling time synchronization..."
sudo timedatectl set-ntp true
sudo systemctl enable systemd-timesyncd
sudo systemctl start systemd-timesyncd

# 3. Force sync from NTP servers
echo "[3/5] Forcing NTP synchronization..."
sudo systemctl restart systemd-timesyncd
sleep 5

# 4. Alternative: Sync from RTC if NTP fails
echo "[4/5] Checking sync status..."
if ! timedatectl status | grep -q "synchronized: yes"; then
    echo "NTP sync failed, syncing from hardware clock..."
    sudo hwclock --hctosys
    echo "Time set from hardware clock."
fi

# 5. Restart services
echo "[5/5] Restarting services..."
sudo systemctl start docker containerd kubelet

# Final verification
echo "=== Verification ==="
timedatectl status
echo "System time should now be correct."
