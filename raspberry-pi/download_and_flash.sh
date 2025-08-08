#!/bin/bash

# Script para baixar e gravar Raspberry Pi OS estável
set -e

echo "==========================================="
echo "   Raspberry Pi OS - Download e Gravação"
echo "==========================================="
echo ""

# Versão recomendada e estável
VERSION="2024-07-04"
BASE_URL="https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-${VERSION}"
IMAGE_NAME="${VERSION}-raspios-bookworm-armhf-lite.img.xz"
IMAGE_URL="${BASE_URL}/${IMAGE_NAME}"
SHA256_URL="${IMAGE_URL}.sha256"

IMAGE_DIR="/Users/leechardes/Projetos/AutoCore/raspberry-pi/images"
mkdir -p "$IMAGE_DIR"
cd "$IMAGE_DIR"

# 1. Download da imagem
echo "📥 Baixando Raspberry Pi OS Lite (32-bit) - Versão Estável ${VERSION}..."
echo "   Esta é a versão mais testada e estável para o Zero 2W"
echo ""

if [ -f "$IMAGE_NAME" ]; then
    echo "✅ Imagem já existe, verificando integridade..."
else
    echo "Baixando imagem (cerca de 500MB)..."
    curl -L -O "$IMAGE_URL"
fi

# 2. Verificação SHA256
echo ""
echo "🔒 Verificando integridade..."
curl -s -O "$SHA256_URL"

if shasum -a 256 -c "${IMAGE_NAME}.sha256" 2>/dev/null; then
    echo "✅ Imagem verificada com sucesso!"
else
    echo "❌ Erro na verificação. Baixando novamente..."
    rm -f "$IMAGE_NAME"
    curl -L -O "$IMAGE_URL"
    shasum -a 256 -c "${IMAGE_NAME}.sha256" || exit 1
fi

# 3. Descomprimir
echo ""
echo "📦 Descomprimindo imagem..."
if [ ! -f "${IMAGE_NAME%.xz}" ]; then
    xz -d -k "$IMAGE_NAME"
fi
echo "✅ Imagem pronta: ${IMAGE_NAME%.xz}"

# 4. Encontrar SD Card
echo ""
echo "🔍 Procurando SD Card..."
DISK=$(diskutil list | grep -B 2 "external" | grep "/dev/disk" | awk '{print $1}' | head -1)

if [ -z "$DISK" ]; then
    echo "❌ Nenhum SD Card encontrado!"
    echo "   Insira o cartão e execute novamente"
    exit 1
fi

echo "📱 SD Card encontrado: $DISK"
diskutil info $DISK | grep "Media Name\|Disk Size" | head -2
echo ""
read -p "⚠️  ATENÇÃO: Isso apagará todo o conteúdo! Continuar? (s/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Operação cancelada"
    exit 0
fi

# 5. Gravar imagem
echo ""
echo "💾 Gravando imagem no SD Card..."
echo "   Isso levará cerca de 10-15 minutos..."

# Desmontar
sudo diskutil unmountDisk $DISK

# Gravar com dd (usando rdisk para maior velocidade)
RDISK="${DISK/disk/rdisk}"
sudo dd if="${IMAGE_NAME%.xz}" of="$RDISK" bs=4m status=progress

# Sincronizar
sync

echo ""
echo "✅ Gravação concluída!"

# 6. Configurar WiFi e SSH
echo ""
echo "⚙️  Configurando WiFi e SSH..."

# Aguardar partições aparecerem
sleep 3

# Montar partição boot
diskutil mount "${DISK}s1" || {
    echo "❌ Erro ao montar partição boot"
    echo "   Remova e reinsira o SD Card, depois execute:"
    echo "   diskutil mount ${DISK}s1"
    exit 1
}

BOOT_PATH="/Volumes/bootfs"

# Habilitar SSH
touch "$BOOT_PATH/ssh"
echo "✅ SSH habilitado"

# Configurar WiFi
echo ""
echo "📶 Configuração WiFi"
read -p "Nome da rede WiFi: " SSID
read -s -p "Senha do WiFi: " PSK
echo ""

cat > "$BOOT_PATH/wpa_supplicant.conf" << EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=BR

network={
    ssid="$SSID"
    psk="$PSK"
    key_mgmt=WPA-PSK
}
EOF
echo "✅ WiFi configurado"

# Configurar usuário
echo 'pi:$6$rBoByrWRKMY1EHFy$ho.LISnfm83CLBWBE/yqJ6Lq1TinRa7bqqY0x4mKLNOU0gPJ2tXZHf2C0iSJDYUm/3vxXzK.5bOlz7KrsVEf81' > "$BOOT_PATH/userconf.txt"
echo "✅ Usuário configurado (pi/raspberry)"

# 7. Ejetar
echo ""
echo "🔌 Ejetando SD Card..."
sync
diskutil eject $DISK

echo ""
echo "==========================================="
echo "🎉 CONCLUÍDO COM SUCESSO!"
echo "==========================================="
echo ""
echo "📝 Próximos passos:"
echo "1. Insira o SD Card no Raspberry Pi Zero 2W"
echo "2. Conecte a alimentação na porta PWR (canto)"
echo "3. Aguarde a luz verde PISCAR (boot em progresso)"
echo ""
echo "⏱️  Tempo de boot: 2-3 minutos"
echo ""
echo "🔌 Para conectar após o boot:"
echo "   ssh pi@raspberrypi.local"
echo "   Senha: raspberry"
echo ""
echo "💡 Dicas:"
echo "- Luz verde PISCANDO = boot normal"
echo "- Luz verde FIXA = problema com SD Card"
echo "- Sem luz = problema de alimentação"