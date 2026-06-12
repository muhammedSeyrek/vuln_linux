#!/bin/bash

echo "Wazuh (SIEM) Kurulumu Basliyor..."
echo "NOT: Bu islem bilesenlerin (Indexer, Manager, Dashboard) indirilmesi sebebiyle internet hizina bagli olarak 5-15 dakika surebilir."

# Wazuh 4.7 Quickstart (Otomatik Tümleşik Kurulum)
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.7/config.yml
bash ./wazuh-install.sh -a

echo "Ana kurulum tamamlandi! Parolalar çikartiliyor..."

# Kurulum sonrası oluşturulan şifreleri vagrant kullanıcısının ev dizinine kolay erişim için kopyalayalım
tar -O -xf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt > /home/vagrant/wazuh_passwords.txt

echo "GitHub reposundan ozel kurallar (Rulesets) Wazuh'a aktariliyor..."
# Eğer host makineden paylaşılan '/vagrant/wazuh_rules' klasöründe kural dosyaları varsa onları Wazuh'un içine kopyala
if [ -d "/vagrant/wazuh_rules" ]; then
    cp /vagrant/wazuh_rules/*.xml /var/ossec/etc/rules/ 2>/dev/null
    chown wazuh:wazuh /var/ossec/etc/rules/*.xml
    chmod 660 /var/ossec/etc/rules/*.xml
    # Kuralların aktif olması için Wazuh servisini yeniden başlat
    systemctl restart wazuh-manager
    echo "Özel kurallar başariyla eklendi ve servis yeniden başlatildi."
fi

echo "Kurulum tamamen bitti. Wazuh Dashboard'a https://192.168.56.20 adresinden erisebilirsiniz."