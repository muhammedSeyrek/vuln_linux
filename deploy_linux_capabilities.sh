#!/bin/bash

# 1. Team2 kullanıcısını oluştur ve ona klasör tahsis et
echo "[*] 'team2' kullanicisi sisteme ekleniyor..."
sudo useradd -m -s /bin/bash team2

echo "[*] Linux Capabilities Zafiyeti Kuruluyor..."

# 2. Klasik python3 aracını team2'nin ev dizinine kopyala
sudo cp /usr/bin/python3 /home/team2/python-backdoor

# 3. Dosyanın sahibini team2 kullanıcısı yap (ÖNCE SAHİPLİK)
sudo chown team2:team2 /home/team2/python-backdoor

# 4. Dosyaya 'setuid' (root olma) kapasitesi ekle (SONRA YETKİ)
sudo setcap cap_setuid+ep /home/team2/python-backdoor

echo "[+] Zafiyet Enjekte Edildi! /home/team2/python-backdoor hazir."
