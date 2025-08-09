#!/bin/bash

# Script para limpar completamente a instalação do AutoCore no Raspberry Pi
# ATENÇÃO: Este script remove TUDO relacionado ao AutoCore!

set -e

# Cores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}⚠️  LIMPEZA COMPLETA DO AUTOCORE${NC}"
echo "======================================"
echo ""
echo -e "${YELLOW}Este script irá remover:${NC}"
echo "  - Todos os serviços systemd do AutoCore"
echo "  - Todo o diretório /opt/autocore"
echo "  - Configurações do Mosquitto para AutoCore"
echo "  - Arquivo .installed"
echo ""
read -p "Tem certeza que deseja continuar? (digite 'sim' para confirmar): " CONFIRM

if [ "$CONFIRM" != "sim" ]; then
    echo -e "${YELLOW}Operação cancelada.${NC}"
    exit 0
fi

echo ""
echo -e "${RED}🧹 Iniciando limpeza...${NC}"
echo ""

# 1. Parar e desabilitar serviços
echo "📛 Parando serviços..."
sudo systemctl stop autocore-gateway autocore-config-app autocore-config-frontend 2>/dev/null || true
sudo systemctl disable autocore-gateway autocore-config-app autocore-config-frontend 2>/dev/null || true

# 2. Remover arquivos de serviço
echo "🗑️  Removendo serviços systemd..."
sudo rm -f /etc/systemd/system/autocore-*.service
sudo systemctl daemon-reload

# 3. Limpar configuração do Mosquitto
echo "🦟 Limpando configuração do Mosquitto..."
sudo rm -f /etc/mosquitto/conf.d/autocore.conf
sudo rm -f /etc/mosquitto/passwd
sudo systemctl restart mosquitto 2>/dev/null || true

# 4. Remover diretório do AutoCore
echo "📁 Removendo /opt/autocore..."
sudo rm -rf /opt/autocore

# 5. Limpar logs
echo "📝 Limpando logs..."
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s

echo ""
echo -e "${GREEN}✅ Limpeza concluída!${NC}"
echo ""
echo "O sistema está pronto para uma nova instalação."
echo "Execute o deploy_to_raspberry.sh para reinstalar."