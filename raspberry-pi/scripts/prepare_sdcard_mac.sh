#!/bin/bash

#############################################
# Script para Preparar SD Card no macOS
# Para Raspberry Pi Zero 2W
#############################################

echo "========================================"
echo "   PREPARAÇÃO DE SD CARD - macOS"
echo "   Raspberry Pi Zero 2W"
echo "========================================"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Verificar se está rodando no macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Este script é para macOS apenas!${NC}"
    exit 1
fi

echo -e "${BLUE}1. LISTANDO DISCOS${NC}"
echo "------------------------"
diskutil list

echo ""
echo -e "${YELLOW}IMPORTANTE: Identifique seu SD Card acima (geralmente /dev/disk4 ou similar)${NC}"
echo -e "${YELLOW}NÃO use /dev/disk0 ou /dev/disk1 (são seus discos internos!)${NC}"
echo ""

read -p "Digite o número do disco do SD Card (ex: 4 para /dev/disk4): " DISK_NUM

# Validar entrada
if [[ ! "$DISK_NUM" =~ ^[2-9]$ ]]; then
    echo -e "${RED}Número de disco inválido! Use apenas números de 2-9${NC}"
    exit 1
fi

DISK="/dev/disk${DISK_NUM}"
RDISK="/dev/rdisk${DISK_NUM}"

echo ""
echo -e "${BLUE}Você selecionou: $DISK${NC}"
diskutil list $DISK

echo ""
read -p "Confirma que este é o SD Card correto? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Operação cancelada."
    exit 1
fi

echo ""
echo -e "${BLUE}2. DESMONTANDO SD CARD${NC}"
echo "------------------------"
diskutil unmountDisk $DISK
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ SD Card desmontado${NC}"
else
    echo -e "${RED}✗ Erro ao desmontar${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}3. FORMATANDO SD CARD${NC}"
echo "------------------------"
echo "Isso vai APAGAR TUDO no SD Card!"
read -p "Continuar? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "Formatando..."
    # Formatar como FAT32 com MBR
    sudo diskutil eraseDisk FAT32 RASPBERRYPI MBRFormat $DISK
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ SD Card formatado${NC}"
    else
        echo -e "${RED}✗ Erro ao formatar${NC}"
        exit 1
    fi
else
    echo "Formatação pulada."
fi

echo ""
echo -e "${BLUE}4. BAIXANDO IMAGEM DO RASPBERRY PI OS${NC}"
echo "------------------------"

IMAGE_DIR="$HOME/Downloads"
IMAGE_FILE="2025-05-13-raspios-bookworm-armhf-lite.img"
IMAGE_XZ="${IMAGE_FILE}.xz"

if [ -f "../images/${IMAGE_FILE}" ]; then
    echo -e "${GREEN}✓ Imagem encontrada localmente${NC}"
    IMAGE_PATH="../images/${IMAGE_FILE}"
elif [ -f "../images/${IMAGE_XZ}" ]; then
    echo -e "${YELLOW}Descompactando imagem...${NC}"
    xz -dk "../images/${IMAGE_XZ}"
    IMAGE_PATH="../images/${IMAGE_FILE}"
elif [ -f "$IMAGE_DIR/${IMAGE_FILE}" ]; then
    echo -e "${GREEN}✓ Imagem encontrada em Downloads${NC}"
    IMAGE_PATH="$IMAGE_DIR/${IMAGE_FILE}"
else
    echo -e "${YELLOW}Imagem não encontrada. Baixando...${NC}"
    echo "Isso pode demorar alguns minutos..."
    
    URL="https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2025-05-13/${IMAGE_XZ}"
    curl -L -o "$IMAGE_DIR/${IMAGE_XZ}" "$URL"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Download concluído${NC}"
        echo "Descompactando..."
        xz -d "$IMAGE_DIR/${IMAGE_XZ}"
        IMAGE_PATH="$IMAGE_DIR/${IMAGE_FILE}"
    else
        echo -e "${RED}✗ Erro no download${NC}"
        echo "Baixe manualmente de:"
        echo "https://www.raspberrypi.com/software/operating-systems/"
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}5. GRAVANDO IMAGEM NO SD CARD${NC}"
echo "------------------------"
echo -e "${YELLOW}Isso vai demorar 5-10 minutos...${NC}"
echo "Gravando de: $IMAGE_PATH"
echo "Para: $RDISK"

# Desmontar novamente antes de gravar
diskutil unmountDisk $DISK

# Gravar imagem com dd
sudo dd if="$IMAGE_PATH" of=$RDISK bs=1m status=progress

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Imagem gravada com sucesso!${NC}"
else
    echo -e "${RED}✗ Erro ao gravar imagem${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}6. CONFIGURANDO BOOT${NC}"
echo "------------------------"

# Aguardar montagem automática
sleep 5

# Verificar se a partição boot foi montada
if [ -d "/Volumes/bootfs" ]; then
    BOOT_PATH="/Volumes/bootfs"
elif [ -d "/Volumes/boot" ]; then
    BOOT_PATH="/Volumes/boot"
else
    echo -e "${YELLOW}Partição boot não montada automaticamente${NC}"
    echo "Tentando montar manualmente..."
    diskutil mount "${DISK}s1"
    sleep 2
    BOOT_PATH="/Volumes/bootfs"
fi

if [ -d "$BOOT_PATH" ]; then
    echo -e "${GREEN}✓ Partição boot montada em $BOOT_PATH${NC}"
    
    # Habilitar SSH
    echo -e "${BLUE}Habilitando SSH...${NC}"
    touch "$BOOT_PATH/ssh"
    echo -e "${GREEN}✓ SSH habilitado${NC}"
    
    # Configurar WiFi
    read -p "Deseja configurar WiFi agora? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo ""
        read -p "Nome da rede WiFi (SSID): " WIFI_SSID
        read -s -p "Senha do WiFi: " WIFI_PASS
        echo ""
        
        # Criar arquivo de configuração WiFi
        cat > "$BOOT_PATH/wpa_supplicant.conf" << EOF
country=BR
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="$WIFI_SSID"
    psk="$WIFI_PASS"
    key_mgmt=WPA-PSK
}
EOF
        echo -e "${GREEN}✓ WiFi configurado${NC}"
    fi
    
    # Configurar usuário
    read -p "Deseja configurar usuário pi? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo ""
        read -s -p "Digite a senha para o usuário pi: " USER_PASS
        echo ""
        
        # Gerar hash da senha
        HASH=$(echo "$USER_PASS" | openssl passwd -6 -stdin)
        
        # Criar arquivo userconf
        echo "pi:$HASH" > "$BOOT_PATH/userconf.txt"
        echo -e "${GREEN}✓ Usuário configurado${NC}"
    fi
    
    # Configurar config.txt para otimizações
    echo "" >> "$BOOT_PATH/config.txt"
    echo "# Otimizações para Pi Zero 2W" >> "$BOOT_PATH/config.txt"
    echo "arm_freq=1000" >> "$BOOT_PATH/config.txt"
    echo "gpu_mem=64" >> "$BOOT_PATH/config.txt"
    echo "dtoverlay=disable-bt" >> "$BOOT_PATH/config.txt"
    
    echo -e "${GREEN}✓ Configurações aplicadas${NC}"
else
    echo -e "${YELLOW}⚠ Não foi possível acessar a partição boot${NC}"
    echo "Você precisará configurar manualmente após o primeiro boot"
fi

echo ""
echo -e "${BLUE}7. FINALIZANDO${NC}"
echo "------------------------"

# Ejetar SD Card
diskutil eject $DISK

echo ""
echo "========================================"
echo -e "${GREEN}    SD CARD PRONTO!${NC}"
echo "========================================"
echo ""
echo "✅ Raspberry Pi OS Lite (Bookworm) gravado"
echo "✅ SSH habilitado"
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "✅ WiFi configurado"
    echo "✅ Usuário pi configurado"
fi
echo ""
echo -e "${BLUE}PRÓXIMOS PASSOS:${NC}"
echo "1. Insira o SD Card no Raspberry Pi Zero 2W"
echo "2. Conecte a alimentação"
echo "3. Aguarde ~2 minutos para o primeiro boot"
echo "4. Conecte via SSH:"
echo "   ssh pi@raspberrypi.local"
echo ""
echo "5. No primeiro login, execute:"
echo "   sudo raspi-config --expand-rootfs"
echo "   sudo apt update && sudo apt upgrade -y"
echo "   sudo reboot"
echo ""
echo -e "${YELLOW}DICA: Se o Pi não inicializar:${NC}"
echo "• Verifique a fonte de alimentação (mínimo 2.5A)"
echo "• Tente outro SD Card"
echo "• Conecte um monitor HDMI para ver mensagens de erro"
echo ""