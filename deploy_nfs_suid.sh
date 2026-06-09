#!/bin/bash

# 1. NFS Misconfiguration (no_root_squash Zafiyeti) zafiyet kurulumu
echo "NFS servisi kuruluyor"
apt-get update
apt-get install -y nfs-kernel-server

mkdir -p /mnt/vuln_nfs_share
chown nobody:nogroup /mnt/vuln_nfs_share
chmod 777 /mnt/vuln_nfs_share

echo "/mnt/vuln_nfs_share *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports

systemctl restart nfs-kernel-server
echo "NFS zafiyeti eklendi"

# 2. SUID Injection zafiyet kurulumu
echo "SUID zafiyeti ekleniyor"

chmod u+s /usr/bin/find

echo "SUID zafiyeti eklendi, işlem tamamlandı"