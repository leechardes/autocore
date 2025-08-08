#!/bin/bash

# ============================================================================
# Script de Setup Automático para Raspberry Pi Zero 2W
# Autor: AutoCore System
# Descrição: Automatiza a gravação e configuração do SD Card
# ============================================================================

set -e  # Sair em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações padrão
DEFAULT_USER="pi"
DEFAULT_PASSWORD="raspberry"
DEFAULT_HOSTNAME="raspberrypi"
COUNTRY="BR"

# Função para exibir mensagens
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Banner
clear
echo -e "${GREEN}"
echo "=============================================="
echo "   Raspberry Pi Zero 2W - Setup Automático"
echo "=============================================="
echo -e "${NC}"

# Verificar se está rodando no macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "Este script foi desenvolvido para macOS"
fi

# Verificar se está rodando como sudo quando necessário
check_sudo() {
    if [ "$EUID" -ne 0 ]; then 
        error "Por favor, execute com sudo: sudo $0"
    fi
}

# Função para baixar a imagem
download_image() {
    local IMAGE_DIR="$HOME/Projetos/AutoCore/raspberry-pi/images"
    local IMAGE_URL="https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2025-05-13/2025-05-13-raspios-bookworm-armhf-lite.img.xz"
    local IMAGE_FILE="$IMAGE_DIR/2025-05-13-raspios-bookworm-armhf-lite.img.xz"
    local IMAGE_SHA256_URL="${IMAGE_URL}.sha256"
    
    mkdir -p "$IMAGE_DIR"
    
    if [ -f "$IMAGE_FILE" ]; then
        info "Imagem já existe em $IMAGE_FILE"
        
        # Verificar integridade
        log "Verificando integridade da imagem..."
        cd "$IMAGE_DIR"
        
        if [ ! -f "${IMAGE_FILE}.sha256" ]; then
            curl -L -o "${IMAGE_FILE}.sha256" "$IMAGE_SHA256_URL"
        fi
        
        if shasum -a 256 -c "${IMAGE_FILE}.sha256" > /dev/null 2>&1; then
            log "✅ Imagem verificada com sucesso!"
        else
            warning "Imagem corrompida, baixando novamente..."
            rm -f "$IMAGE_FILE"
            curl -L -o "$IMAGE_FILE" "$IMAGE_URL"
        fi
    else
        log "Baixando imagem do Raspberry Pi OS..."
        curl -L -o "$IMAGE_FILE" "$IMAGE_URL"
        curl -L -o "${IMAGE_FILE}.sha256" "$IMAGE_SHA256_URL"
        
        cd "$IMAGE_DIR"
        shasum -a 256 -c "${IMAGE_FILE}.sha256" || error "Falha na verificação SHA256"
    fi
    
    # Descomprimir se necessário
    if [ ! -f "${IMAGE_FILE%.xz}" ]; then
        log "Descomprimindo imagem..."
        xz -d -k "$IMAGE_FILE"
    fi
    
    echo "${IMAGE_FILE%.xz}"
}

# Função para encontrar o SD Card
find_sd_card() {
    log "Procurando SD Card..."
    
    # Listar discos externos
    local DISK=$(diskutil list | grep -B 2 "external" | grep "/dev/disk" | awk '{print $1}' | head -1)
    
    if [ -z "$DISK" ]; then
        error "Nenhum SD Card encontrado. Insira o cartão e tente novamente."
    fi
    
    # Confirmar com o usuário
    info "SD Card encontrado: $DISK"
    diskutil info $DISK | grep "Media Name\|Disk Size" | head -2
    
    read -p "Este é o SD Card correto? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        error "Operação cancelada pelo usuário"
    fi
    
    echo "${DISK}"
}

# Função para gravar a imagem
write_image() {
    local IMAGE_PATH="$1"
    local DISK="$2"
    
    log "Desmontando SD Card..."
    diskutil unmountDisk "$DISK" || true
    
    log "Gravando imagem no SD Card (isso pode levar 10-15 minutos)..."
    log "Por favor, aguarde..."
    
    # Usar rdisk para melhor performance
    local RDISK="${DISK/disk/rdisk}"
    
    # Gravar com dd
    sudo dd if="$IMAGE_PATH" of="$RDISK" bs=4m status=progress
    
    # Sincronizar
    sync
    
    log "✅ Gravação concluída!"
}

# Função para configurar WiFi e SSH
configure_boot() {
    local DISK="$1"
    
    log "Configurando WiFi e SSH..."
    
    # Aguardar o sistema reconhecer as partições
    sleep 2
    
    # Montar partição boot
    diskutil mount "${DISK}s1" || error "Falha ao montar partição boot"
    
    local BOOT_PATH="/Volumes/bootfs"
    
    if [ ! -d "$BOOT_PATH" ]; then
        error "Partição boot não encontrada em $BOOT_PATH"
    fi
    
    # Solicitar credenciais WiFi
    echo
    read -p "Nome da rede WiFi: " WIFI_SSID
    read -s -p "Senha do WiFi: " WIFI_PASSWORD
    echo
    
    # Criar arquivo de configuração WiFi
    cat > "$BOOT_PATH/wpa_supplicant.conf" << EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$COUNTRY

network={
    ssid="$WIFI_SSID"
    psk="$WIFI_PASSWORD"
    key_mgmt=WPA-PSK
}
EOF
    
    # Habilitar SSH
    touch "$BOOT_PATH/ssh"
    
    # Configurar usuário (pi/raspberry)
    echo 'pi:$6$rBoByrWRKMY1EHFy$ho.LISnfm83CLBWBE/yqJ6Lq1TinRa7bqqY0x4mKLNOU0gPJ2tXZHf2C0iSJDYUm/3vxXzK.5bOlz7KrsVEf81' > "$BOOT_PATH/userconf.txt"
    
    log "✅ Configuração aplicada!"
}

# Função para ejetar o SD Card
eject_sd_card() {
    local DISK="$1"
    
    log "Ejetando SD Card..."
    sync
    diskutil eject "$DISK"
    log "✅ SD Card ejetado com segurança!"
}

# Função para aguardar e testar conexão
test_connection() {
    echo
    log "🔌 Insira o SD Card no Raspberry Pi e conecte a alimentação"
    log "⏳ Aguardando 2 minutos para o boot inicial..."
    
    # Barra de progresso
    for i in {1..120}; do
        printf "\r[%-60s] %d%%" $(printf '#%.0s' $(seq 1 $((i/2)))) $((i*100/120))
        sleep 1
    done
    echo
    
    log "Testando conexão..."
    
    # Tentar ping por hostname
    if ping -c 1 raspberrypi.local > /dev/null 2>&1; then
        log "✅ Raspberry Pi encontrado!"
        info "Hostname: raspberrypi.local"
        
        # Obter IP
        local IP=$(ping -c 1 raspberrypi.local | grep "PING" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
        info "IP: $IP"
        
        echo
        log "🎉 Setup concluído com sucesso!"
        echo
        info "Para conectar via SSH:"
        echo "  ssh pi@raspberrypi.local"
        echo "  ou"
        echo "  ssh pi@$IP"
        echo
        info "Credenciais:"
        echo "  Usuário: pi"
        echo "  Senha: raspberry"
        
    else
        warning "Não foi possível encontrar o Raspberry Pi na rede"
        echo
        info "Possíveis soluções:"
        echo "  1. Verifique se o Pi está ligado (LED verde piscando)"
        echo "  2. Verifique as credenciais WiFi"
        echo "  3. Procure o IP no roteador"
        echo "  4. Aguarde mais alguns minutos e tente:"
        echo "     ping raspberrypi.local"
    fi
}

# Menu principal
main_menu() {
    echo "Escolha uma opção:"
    echo "  1) Setup completo (download + gravação + configuração)"
    echo "  2) Apenas gravar imagem existente"
    echo "  3) Apenas configurar SD Card já gravado"
    echo "  4) Testar conexão com Raspberry Pi"
    echo "  5) Sair"
    echo
    read -p "Opção: " -n 1 -r
    echo
    
    case $REPLY in
        1)
            check_sudo
            IMAGE_PATH=$(download_image)
            DISK=$(find_sd_card)
            write_image "$IMAGE_PATH" "$DISK"
            configure_boot "$DISK"
            eject_sd_card "$DISK"
            test_connection
            ;;
        2)
            check_sudo
            IMAGE_PATH=$(download_image)
            DISK=$(find_sd_card)
            write_image "$IMAGE_PATH" "$DISK"
            configure_boot "$DISK"
            eject_sd_card "$DISK"
            ;;
        3)
            DISK=$(find_sd_card)
            configure_boot "$DISK"
            eject_sd_card "$DISK"
            ;;
        4)
            test_connection
            ;;
        5)
            exit 0
            ;;
        *)
            error "Opção inválida"
            ;;
    esac
}

# Executar menu principal
main_menu