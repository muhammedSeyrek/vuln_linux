#!/bin/bash
# attack_simulation.sh
# Tum kurban makinelerde zafiyetleri tetikler, Wazuh alarmlarini test eder.
# Wazuh makinesinde /vagrant/ansible dizininde calistirilir.

cd /vagrant/ansible || exit 1
INV="hosts.ini"

echo "=========================================="
echo " SALDIRI SIMULASYONU BASLIYOR"
echo " Her makinede zafiyet tetiklenecek."
echo " Wazuh Dashboard'da Security Events'i izleyin."
echo "=========================================="
sleep 2

echo ""
echo "[1/5] CAPS (Muhammed) - setcap yetki yukseltme..."
ansible -i $INV 'target-caps' -b -m shell -a \
  "cp /usr/bin/python3 /tmp/python-backdoor 2>/dev/null; setcap cap_setuid+ep /tmp/python-backdoor"
sleep 3

echo ""
echo "[2/5] NFS/SUID (Bedirhan) - find ile root komut..."
ansible -i $INV 'target-nfs' -b -m shell -a \
  "find /etc/passwd -exec /bin/sh -c 'id' \;"
sleep 3

echo ""
echo "[3/5] PAM (Emirhan) - PAM dosyasi manipulasyonu..."
ansible -i $INV 'target-pam' -b -m shell -a \
  "echo '# simulated change' >> /etc/pam.d/sudo"
sleep 3

echo ""
echo "[4/5] SYSTEMD (Ahmet) - servis betigi manipulasyonu..."
ansible -i $INV 'target-systemd' -b -m shell -a \
  "echo '# malicious edit' >> /opt/system_backup.sh"
sleep 3

echo ""
echo "[5/5] LD_PRELOAD (Ahmet) - sudoers env_keep tetikleme..."
ansible -i $INV 'target-ld' -b -m shell -a \
  "su - ld_user -c 'sudo -n -l' 2>/dev/null || echo 'ld_user sudo denemesi yapildi'"
sleep 3

echo ""
echo "=========================================="
echo " SIMULASYON BITTI."
echo " Wazuh Dashboard -> Security Events ac."
echo " Level 12 kirmizi alarmlari gor:"
echo "   110101 (caps), 110202 (nfs), 110301 (pam),"
echo "   110401 (systemd), 110403 (ld)"
echo "=========================================="