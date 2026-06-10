Vagrant.configure("2") do |config|
  # Ortak İşletim Sistemi Kalıbı
  config.vm.box = "bento/ubuntu-22.04"

  # ==========================================
  # FAZ 1: ZAFİYETLİ HEDEF MAKİNELER (4 ADET)
  # ==========================================

  # 1. Muhammed Seyrek: Linux Capabilities Suistimali
  config.vm.define "vuln-caps" do |caps|
    caps.vm.network "private_network", ip: "192.168.56.11"
    caps.vm.hostname = "target-caps"
    caps.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "Vuln1_Capabilities"
      v.vmx["memsize"] = "1024"
    end
    # Yeni değişiklik, otomatize etmek için.
    caps.vm.provision "shell", path: "deploy_linux_capabilities.sh"
  end

  # 2. Bedirhan İhtiyar: NFS Misconfiguration & SUID
  config.vm.define "vuln-nfs" do |nfs|
    nfs.vm.network "private_network", ip: "192.168.56.12"
    nfs.vm.hostname = "target-nfs"
    nfs.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "Vuln2_NFS"
      v.vmx["memsize"] = "1024"
    end
    nfs.vm.provision "shell", path: "deploy_nfs_suid.sh"
  end

  # 3. Emrihan Özgen: PAM Backdoor
  config.vm.define "vuln-pam" do |pam|
    pam.vm.network "private_network", ip: "192.168.56.13"
    pam.vm.hostname = "target-pam"
    pam.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "Vuln3_PAM"
      v.vmx["memsize"] = "1024"
    end
    # Otomasyon için betik çalıştırma talimatı eklendi
    pam.vm.provision "shell", path: "deploy_pam_vuln.sh"
  end

  # 4. Ahmet Faruk: Systemd
  config.vm.define "vuln-systemd" do |sys|
    sys.vm.network "private_network", ip: "192.168.56.14"
    sys.vm.hostname = "target-systemd"
    sys.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "Vuln4_Systemd"
      v.vmx["memsize"] = "1024"
    end
    sys.vm.provision "shell", path: "deploy_systemd_vuln.sh"
  end

  # 5.Ahmet Faruk: LD_PRELOAD
  config.vm.define "vuln-ld" do |ld|
    ld.vm.network "private_network", ip: "192.168.56.15"
    ld.vm.hostname = "target-ld"
    ld.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "Vuln5_ld"
      v.vmx["memsize"] = "1024"
    end
    ld.vm.provision "shell", path: "deploy_ld_preload_vuln.sh"
  end


  # ==========================================
  # FAZ 3: MERKEZİ İZLEME VE ALARM MAKİNESİ
  # ==========================================

  # 5. Wazuh Manager (SIEM)
  config.vm.define "wazuh" do |w|
    w.vm.network "private_network", ip: "192.168.56.20"
    w.vm.hostname = "wazuh-manager"
    w.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "Wazuh_Server"
      v.vmx["memsize"] = "4096" # Wazuh log işleyeceği için daha fazla RAM gerektirir
      v.vmx["numvcpus"] = "2"
    end
  end

end