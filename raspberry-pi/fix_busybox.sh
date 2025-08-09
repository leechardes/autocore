#!/bin/bash

echo "================================================"
echo "   🔧 Fix BusyBox/initramfs - Raspberry Pi"
echo "================================================"
echo ""
echo "PROBLEMA: BusyBox initramfs indica filesystem corrompido"
echo ""

# Opção 1: Verificar o SD Card no Mac
echo "📍 OPÇÃO 1: Verificar e reparar o SD Card"
echo "----------------------------------------"
echo "1. Remova o SD Card do Raspberry Pi"
echo "2. Insira no Mac"
echo ""

# Detectar SD Card
DISK=$(diskutil list | grep -B 2 "external" | grep "/dev/disk" | awk '{print $1}' | head -1)

if [ -n "$DISK" ]; then
    echo "✅ SD Card detectado: $DISK"
    echo ""
    echo "Deseja tentar reparar? (s/n)"
    read -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "🔧 Tentando reparar partições..."
        
        # Tentar reparar com fsck
        sudo fsck_msdos -y ${DISK}s1 2>/dev/null || echo "Partição boot não reparável via Mac"
        
        # Verificar com diskutil
        diskutil verifyDisk $DISK
        diskutil repairDisk $DISK
        
        echo ""
        echo "✅ Tentativa de reparo concluída"
        echo "   Teste novamente no Raspberry Pi"
    fi
else
    echo "❌ Nenhum SD Card detectado"
fi

echo ""
echo "================================================"
echo "📍 OPÇÃO 2: Regravar com imagem LITE (mais leve)"
echo "================================================"
echo ""
echo "A versão Desktop pode ser pesada demais."
echo "Vamos usar a versão LITE que é mais confiável:"
echo ""

cat << 'EOF'
# 1. Baixar Raspberry Pi OS LITE (não Desktop)
curl -L -O https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz

# 2. Descomprimir
xz -d 2024-07-04-raspios-bookworm-arm64-lite.img.xz

# 3. Gravar (substitua diskX pelo seu disco)
sudo dd if=2024-07-04-raspios-bookworm-arm64-lite.img of=/dev/rdiskX bs=4m status=progress

# 4. Configurar WiFi e SSH ANTES de inserir no Pi
EOF

echo ""
echo "================================================"
echo "📍 OPÇÃO 3: Configuração Headless (sem teclado)"
echo "================================================"
echo ""
echo "Após gravar, monte o SD Card e crie estes arquivos:"
echo ""

# Criar arquivo de configuração WiFi exemplo
cat << 'EOF' > wpa_supplicant_example.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=BR

network={
    ssid="Lee"
    psk="lee159753"
    key_mgmt=WPA-PSK
}
EOF

cat << 'EOF' > config_example.txt
# Adicionar ao final do config.txt na partição boot:

# Habilitar UART para debug serial
enable_uart=1

# Forçar HDMI mesmo sem monitor
hdmi_force_hotplug=1

# Resolver problemas de boot
boot_delay=5
boot_delay_ms=5000

# Desabilitar splash screen
disable_splash=1

# Modo de emergência
#init=/bin/sh
EOF

cat << 'EOF' > cmdline_example.txt
# Modificar cmdline.txt para adicionar:
# fsck.repair=yes - repara automaticamente
# rootwait - espera o root estar pronto

console=serial0,115200 console=tty1 root=PARTUUID=xxxxxxxx-02 rootfstype=ext4 fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles
EOF

echo ""
echo "================================================"
echo "📍 OPÇÃO 4: Criar script de auto-reparo"
echo "================================================"
echo ""

cat << 'SCRIPT' > autofix.sh
#!/bin/bash
# Salvar este script na partição boot como autofix.sh

# Este script será executado automaticamente no boot
fsck -y /dev/mmcblk0p2
mount -o remount,rw /
touch /boot/fixed.txt
reboot
SCRIPT

echo "Para executar automaticamente, adicione ao rc.local"
echo ""

echo "================================================"
echo "📍 OPÇÃO 5: Usar Raspberry Pi Imager (RECOMENDADO)"
echo "================================================"
echo ""
echo "1. Abra o Raspberry Pi Imager"
echo "2. Escolha:"
echo "   - Device: Raspberry Pi Zero 2 W"
echo "   - OS: Raspberry Pi OS LITE (64-bit)"
echo "   - Storage: Seu SD Card"
echo ""
echo "3. Clique na engrenagem ⚙️ e configure:"
echo "   - Enable SSH: Yes"
echo "   - Set username: pi"  
echo "   - Set password: raspberry"
echo "   - Configure WiFi:"
echo "     - SSID: Lee"
echo "     - Password: lee159753"
echo "     - Country: BR"
echo ""
echo "4. IMPORTANTE: Use versão LITE, não Desktop!"
echo ""

echo "================================================"
echo "🔍 DIAGNÓSTICO"
echo "================================================"
echo ""
echo "Causas comuns do BusyBox/initramfs:"
echo "1. ❌ SD Card corrompido ou com setores defeituosos"
echo "2. ❌ Imagem mal gravada (erro nos 99%)"
echo "3. ❌ Versão Desktop muito pesada para Zero 2W"
echo "4. ❌ Problema de expansão do filesystem no primeiro boot"
echo "5. ❌ Incompatibilidade da imagem com o hardware"
echo ""
echo "Solução mais confiável:"
echo "✅ Usar Raspberry Pi OS LITE 64-bit"
echo "✅ Gravar com Raspberry Pi Imager oficial"
echo "✅ Configurar WiFi/SSH antes do primeiro boot"
echo "✅ Testar com outro SD Card se possível"
echo ""

echo "================================================"
echo "💡 DICA IMPORTANTE"
echo "================================================"
echo ""
echo "Se continuar com problemas:"
echo "1. Tente outro SD Card (de preferência novo)"
echo "2. Use fonte de alimentação mais potente (2.5A)"
echo "3. Teste a versão 32-bit ao invés de 64-bit"
echo "4. Grave em velocidade mais lenta (bs=1m ao invés de 4m)"
echo ""