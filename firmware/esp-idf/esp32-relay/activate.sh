#!/bin/bash
# Script para ativar ambiente de desenvolvimento ESP-IDF

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    ESP32 Relay ESP-IDF Environment   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# Remove venv antigo se existir
if [ -d ".venv" ]; then
    echo -e "${YELLOW}🗑️  Removendo ambiente virtual antigo...${NC}"
    rm -rf .venv
fi

# Verifica ESP-IDF
if [ -z "$IDF_PATH" ]; then
    if [ -d "$HOME/esp/esp-idf" ]; then
        echo -e "${BLUE}🔧 Configurando ESP-IDF...${NC}"
        source $HOME/esp/esp-idf/export.sh
        echo -e "${GREEN}✅ ESP-IDF configurado!${NC}"
    else
        echo -e "${YELLOW}⚠️  ESP-IDF não encontrado${NC}"
        echo -e "${YELLOW}Execute: make install${NC}"
    fi
else
    echo -e "${GREEN}✅ ESP-IDF já configurado${NC}"
fi

echo ""
echo -e "${GREEN}🚀 Ambiente pronto!${NC}"
echo ""
echo -e "${CYAN}Comandos disponíveis:${NC}"
echo -e "  ${GREEN}make help${NC}     - Ver todos os comandos"
echo -e "  ${GREEN}make build${NC}    - Compilar projeto"
echo -e "  ${GREEN}make flash${NC}    - Gravar no ESP32"
echo -e "  ${GREEN}make monitor${NC}  - Monitor serial"
echo -e "  ${GREEN}make dev${NC}      - Build + Flash + Monitor"
echo ""