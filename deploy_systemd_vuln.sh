#!/bin/bash

echo "[*] Systemd Zafiyeti Kurulumu Başlıyor..."

# 1. Test için düşük yetkili bir kullanıcı oluşturalım
useradd -m systemd_user -s /bin/bash

# 2. Çalıştırılacak küçük scripti oluşturalım ve yetkilerini zayıf bırakalım
cat <<EOF > /opt/system_backup.sh
#!/bin/bash
# hostname dosyasını kullanıcının ev dizinine yedekler
cp /etc/hostname /home/systemd_user/hostname_backup.txt
chown systemd_user:systemd_user /home/systemd_user/hostname_backup.txt
EOF

# ZAFİYET: Herkesin bu scripti değiştirebilmesini sağlıyoruz
chmod 777 /opt/system_backup.sh

# 3. Root yetkisiyle çalışacak servisi oluşturalım
cat <<EOF > /etc/systemd/system/vuln-backup.service
[Unit]
Description=Zafiyetli Yedekleme Servisi

[Service]
Type=simple
User=root
ExecStart=/opt/system_backup.sh
EOF

# 4. Timer'ı oluşturalım (Her dakika çalışır)
cat <<EOF > /etc/systemd/system/vuln-backup.timer
[Unit]
Description=Zafiyetli Yedekleme Servisi Zamanlayıcısı

[Timer]
OnCalendar=*:*
Persistent=true

[Install]
WantedBy=timers.target
EOF

# 5. Yeniden yükleyip aktif edelim
systemctl daemon-reload
systemctl enable --now vuln-backup.timer

echo "[+] Başarılı! Yeni hafif senaryo hazır."
echo "    - Kullanıcı: systemd_user"
echo "    - Hedef Dosya: /opt/system_backup.sh"
echo "    - Çıktı Dizini: /home/systemd_user/hostname_backup.txt"