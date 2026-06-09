#!/bin/bash

echo "[*] LD_PRELOAD Zafiyeti Kurulumu Başlıyor..."

# Düşük yetkili bir kullanıcı oluşturalım
useradd -m ld_user -s /bin/bash

# Sömürü testi için gcc kurulu değilse kuralım
if ! command -v gcc &> /dev/null; then
    echo "[*] gcc bulunamadı, yükleniyor..."
    apt-get update && apt-get install -y gcc
fi

# Kullanıcının LD_PRELOAD değişkenini korumasına izin veriyoruz ve parola kullanmadan find komutunu çalıştırma yetkisi veriyoruz
cat <<EOF > /etc/sudoers.d/ldpreload_vuln
Defaults:ld_user env_keep += LD_PRELOAD
ld_user ALL=(root) NOPASSWD: /usr/bin/find
EOF

# Sudoers dosyası izinlerinin güvenliği için 0440 yapılması şarttır.
chmod 0440 /etc/sudoers.d/ldpreload_vuln

echo "[+] Başarılı! LD_PRELOAD zafiyeti oluşturuldu."
echo "    - Kullanıcı: ld_user"
echo "    - Sudo yetkisi: /usr/bin/find"
echo "    - Zafiyet: 'sudo -l' ile env_keep += LD_PRELOAD görünür."
