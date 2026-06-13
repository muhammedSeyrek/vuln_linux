#!/bin/bash

echo "Wazuh (SIEM) Kurulumu Basliyor..."
echo "NOT: Bu islem bilesenlerin (Indexer, Manager, Dashboard) indirilmesi sebebiyle internet hizina bagli olarak 5-15 dakika surebilir."

# Wazuh 4.7 Quickstart (Otomatik Tümleşik Kurulum)
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.7/config.yml
bash ./wazuh-install.sh -a

echo "Ana kurulum tamamlandi! Parolalar cikartiliyor..."

# Kurulum sonrasi olusturulan sifreleri vagrant kullanicisinin ev dizinine kopyala
tar -O -xf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt > /home/vagrant/wazuh_passwords.txt

echo "Manager'in etc/rules klasorunu okudugundan emin olunuyor..."
# KRITIK: Default ossec.conf bazen etc/rules klasorunu okumaz, ozel kurallar tetiklenmez.
# Bu satir, ruleset blogunun icine etc/rules'u ekleyerek ozel kurallarin okunmasini garantiler.
if ! grep -q "<rule_dir>etc/rules</rule_dir>" /var/ossec/etc/ossec.conf; then
    sed -i 's#</ruleset>#  <rule_dir>etc/rules</rule_dir>\n  </ruleset>#' /var/ossec/etc/ossec.conf
    echo "ossec.conf ruleset blogu guncellendi (etc/rules eklendi)."
fi

echo "GitHub reposundan ozel kurallar (Rulesets) Wazuh'a aktariliyor..."
# Host makineden paylasilan '/vagrant/wazuh_rules' klasorundeki kurallari Wazuh'a kopyala
if [ -d "/vagrant/wazuh_rules" ]; then
    cp /vagrant/wazuh_rules/*.xml /var/ossec/etc/rules/ 2>/dev/null
    chown wazuh:wazuh /var/ossec/etc/rules/*.xml
    chmod 660 /var/ossec/etc/rules/*.xml
    echo "Ozel kurallar kopyalandi."
fi

# Kurallarin ve ruleset degisikliginin aktif olmasi icin servisi yeniden baslat
systemctl restart wazuh-manager
echo "Wazuh manager yeniden baslatildi."

echo "Kurulum tamamen bitti. Wazuh Dashboard'a https://192.168.56.20 adresinden erisebilirsiniz."