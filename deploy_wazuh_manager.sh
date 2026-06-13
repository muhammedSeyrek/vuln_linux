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
# KRITIK 1: Default ossec.conf bazen etc/rules klasorunu okumaz, ozel kurallar tetiklenmez.
# Bu satir, ruleset blogunun icine etc/rules'u ekleyerek ozel kurallarin okunmasini garantiler.
if ! grep -q "<rule_dir>etc/rules</rule_dir>" /var/ossec/etc/ossec.conf; then
    sed -i 's#</ruleset>#  <rule_dir>etc/rules</rule_dir>\n  </ruleset>#' /var/ossec/etc/ossec.conf
    echo "ossec.conf ruleset blogu guncellendi (etc/rules eklendi)."
fi

echo "Manager auth (ajan kayit) blogu sikilastiriliyor..."
# KRITIK 2: Ajanlar yeniden kaydolurken 'Duplicate agent name' hatasi almasin diye
# auth blogina purge + force ekliyoruz. Ayni isimde gelen ajan eski kaydi ezer.
if ! grep -q "<force>" /var/ossec/etc/ossec.conf; then
    if grep -q "</auth>" /var/ossec/etc/ossec.conf; then
        # auth blogu varsa, icine force ekle
        sed -i 's#</auth>#    <purge>yes</purge>\n    <force>\n      <enabled>yes</enabled>\n      <key_mismatch>yes</key_mismatch>\n      <disconnected_time enabled="yes">0</disconnected_time>\n      <after_registration_time>0</after_registration_time>\n    </force>\n  </auth>#' /var/ossec/etc/ossec.conf
    else
        # auth blogu hic yoksa, </ossec_config> oncesine komple ekle
        sed -i 's#</ossec_config>#  <auth>\n    <disabled>no</disabled>\n    <port>1515</port>\n    <use_source_ip>no</use_source_ip>\n    <purge>yes</purge>\n    <use_password>no</use_password>\n    <force>\n      <enabled>yes</enabled>\n      <key_mismatch>yes</key_mismatch>\n      <disconnected_time enabled="yes">0</disconnected_time>\n      <after_registration_time>0</after_registration_time>\n    </force>\n  </auth>\n</ossec_config>#' /var/ossec/etc/ossec.conf
    fi
    echo "Auth force blogu eklendi (duplicate agent name sorunu onlendi)."
fi

echo "GitHub reposundan ozel kurallar (Rulesets) Wazuh'a aktariliyor..."
# Host makineden paylasilan '/vagrant/wazuh_rules' klasorundeki kurallari Wazuh'a kopyala
if [ -d "/vagrant/wazuh_rules" ]; then
    cp /vagrant/wazuh_rules/*.xml /var/ossec/etc/rules/ 2>/dev/null
    chown wazuh:wazuh /var/ossec/etc/rules/*.xml
    chmod 660 /var/ossec/etc/rules/*.xml
    echo "Ozel kurallar kopyalandi."
fi

# Kurallarin, ruleset ve auth degisikliklerinin aktif olmasi icin servisi yeniden baslat
systemctl restart wazuh-manager
echo "Wazuh manager yeniden baslatildi."

echo "Kurulum tamamen bitti. Wazuh Dashboard'a https://192.168.56.20 adresinden erisebilirsiniz."