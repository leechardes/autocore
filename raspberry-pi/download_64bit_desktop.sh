#!/bin/bash

# Script para baixar e gravar Raspberry Pi OS Desktop 64-bit (RECOMENDADO)
set -e

echo "==========================================="
echo "   Raspberry Pi OS Desktop 64-bit"
echo "   VERSÃO RECOMENDADA PARA ZERO 2W"
echo "==========================================="
echo ""

# Versão 64-bit Desktop (recomendada pelo Raspberry Pi Imager)
VERSION="2025-05-13"
BASE_URL="https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-${VERSION}"
IMAGE_NAME="${VERSION}-raspios-bookworm-arm64.img.xz"
IMAGE_URL="${BASE_URL}/${IMAGE_NAME}"
SHA256_URL="${IMAGE_URL}.sha256"

IMAGE_DIR="/Users/leechardes/Projetos/AutoCore/raspberry-pi/images"
mkdir -p "$IMAGE_DIR"
cd "$IMAGE_DIR"

# 1. Download da imagem
echo "📥 Baixando Raspberry Pi OS Desktop 64-bit..."
echo "   ⚠️  Versão RECOMENDADA pelo Raspberry Pi Foundation"
echo "   📦 Tamanho: ~1.1GB comprimido"
echo ""

if [ -f "$IMAGE_NAME" ]; then
    echo "✅ Imagem já existe, verificando integridade..."
else
    echo "Baixando imagem Desktop 64-bit..."
    echo "Isso pode demorar alguns minutos..."
    curl -L -O "$IMAGE_URL" || {
        echo ""
        echo "💡 Download direto falhou. Alternativas:"
        echo ""
        echo "OPÇÃO 1 - Use o Raspberry Pi Imager (RECOMENDADO):"
        echo "  1. Abra o Raspberry Pi Imager"
        echo "  2. Escolha: Raspberry Pi OS (64-bit)"
        echo "  3. Configure WiFi e SSH na engrenagem ⚙️"
        echo ""
        echo "OPÇÃO 2 - Baixe manualmente:"
        echo "  URL: $IMAGE_URL"
        echo "  Salve em: $IMAGE_DIR"
        echo ""
        exit 1
    }
fi

# 2. Verificação SHA256
echo ""
echo "🔒 Verificando integridade..."
curl -s -O "$SHA256_URL" 2>/dev/null || echo "Aviso: Não foi possível baixar SHA256"

if [ -f "${IMAGE_NAME}.sha256" ]; then
    if shasum -a 256 -c "${IMAGE_NAME}.sha256" 2>/dev/null; then
        echo "✅ Imagem verificada com sucesso!"
    else
        echo "⚠️  Verificação SHA256 falhou, mas continuando..."
    fi
fi

# 3. Descomprimir
echo ""
echo "📦 Descomprimindo imagem..."
if [ ! -f "${IMAGE_NAME%.xz}" ]; then
    xz -d -k "$IMAGE_NAME" || {
        echo "❌ Erro ao descomprimir"
        echo "   Tente: xz -d -k $IMAGE_NAME"
        exit 1
    }
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
echo "⚠️  ATENÇÃO: Isso apagará TODO o conteúdo do SD Card!"
read -p "Continuar? (s/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Operação cancelada"
    exit 0
fi

# 5. Gravar imagem
echo ""
echo "💾 Gravando imagem no SD Card..."
echo "   ⏱️  Tempo estimado: 15-20 minutos"
echo "   📊 A imagem Desktop é maior (~2.9GB descomprimida)"

# Desmontar
sudo diskutil unmountDisk $DISK

# Gravar com dd (usando rdisk para maior velocidade)
RDISK="${DISK/disk/rdisk}"
echo "Gravando... (Ctrl+T para ver progresso no macOS)"
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
    echo "   Tente manualmente: diskutil mount ${DISK}s1"
    exit 1
}

BOOT_PATH="/Volumes/bootfs"

if [ ! -d "$BOOT_PATH" ]; then
    BOOT_PATH="/Volumes/boot"
fi

if [ ! -d "$BOOT_PATH" ]; then
    echo "❌ Partição boot não encontrada"
    echo "   Verifique manualmente com: diskutil list $DISK"
    exit 1
fi

# Habilitar SSH
touch "$BOOT_PATH/ssh"
echo "✅ SSH habilitado"

# Configurar WiFi
echo ""
echo "📶 Configuração WiFi"
read -p "Nome da rede WiFi [Lee]: " SSID
SSID=${SSID:-Lee}
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
echo "✅ WiFi configurado para rede: $SSID"

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
echo "🎉 SUCESSO! SD Card preparado!"
echo "==========================================="
echo ""
echo "📝 INSTRUÇÕES:"
echo ""
echo "1️⃣  Insira o SD Card no Raspberry Pi Zero 2W"
echo "    - Empurre firmemente até o fim"
echo ""
echo "2️⃣  Conecte a alimentação na porta PWR"
echo "    - Porta do CANTO (não a do meio)"
echo "    - Use fonte de pelo menos 5V/2A"
echo ""
echo "3️⃣  Observe as luzes:"
echo "    🟢 Verde PISCANDO = Boot normal (aguarde 3-5 min)"
echo "    🟢 Verde FIXA = Problema (reinsira o SD Card)"
echo "    ⚫ Sem luz = Problema de alimentação"
echo ""
echo "4️⃣  Após o boot, conecte via SSH:"
echo "    ssh pi@raspberrypi.local"
echo "    Senha: raspberry"
echo ""
echo "💡 DICAS:"
echo "- Primeira inicialização demora mais (expansão do filesystem)"
echo "- A versão Desktop usa mais recursos mas é mais estável"
echo "- Se não conectar, verifique o IP no roteador"
echo ""