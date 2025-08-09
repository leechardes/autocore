#!/bin/bash

# Script para recuperar as SECRET_KEYs de uma instalação AutoCore

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔑 Recuperar Chaves de Segurança do AutoCore${NC}"
echo "============================================="
echo ""

# Verificar se existe arquivo de credenciais
if [ -f ".credentials" ]; then
    source .credentials
else
    # Solicitar informações de conexão
    echo -e "${YELLOW}Digite as informações de conexão:${NC}"
    read -p "IP do Raspberry Pi: " RASPBERRY_IP
    read -p "Usuário SSH [autocore]: " RASPBERRY_USER
    RASPBERRY_USER=${RASPBERRY_USER:-autocore}
fi

# Validar IP
if [[ ! $RASPBERRY_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ IP inválido: $RASPBERRY_IP${NC}"
    exit 1
fi

REMOTE_DIR="/opt/autocore"

echo ""
echo -e "${BLUE}🔌 Conectando a ${RASPBERRY_USER}@${RASPBERRY_IP}...${NC}"

# Função para executar comando remoto
remote_exec() {
    ssh ${RASPBERRY_USER}@${RASPBERRY_IP} "$1" 2>/dev/null
}

# Verificar se consegue conectar
if ! remote_exec "echo 'Conectado'" > /dev/null; then
    echo -e "${RED}❌ Não foi possível conectar${NC}"
    echo "   Verifique as credenciais e tente novamente"
    exit 1
fi

# Verificar se existe .env no servidor
if ! remote_exec "[ -f ${REMOTE_DIR}/.env ]"; then
    echo -e "${RED}❌ Arquivo .env não encontrado em ${REMOTE_DIR}${NC}"
    echo "   O sistema pode não estar instalado ainda"
    exit 1
fi

echo -e "${GREEN}✅ Conectado com sucesso${NC}"
echo ""

# Recuperar as chaves
echo -e "${BLUE}📋 Chaves de Segurança Encontradas:${NC}"
echo "======================================"
echo ""

# Gateway Secret Key
GATEWAY_KEY=$(remote_exec "grep '^GATEWAY_SECRET_KEY=' ${REMOTE_DIR}/.env | cut -d'=' -f2")
if [ ! -z "$GATEWAY_KEY" ]; then
    echo -e "${YELLOW}GATEWAY_SECRET_KEY:${NC}"
    echo "$GATEWAY_KEY"
    echo ""
fi

# Config Secret Key
CONFIG_KEY=$(remote_exec "grep '^CONFIG_SECRET_KEY=' ${REMOTE_DIR}/.env | cut -d'=' -f2")
if [ ! -z "$CONFIG_KEY" ]; then
    echo -e "${YELLOW}CONFIG_SECRET_KEY:${NC}"
    echo "$CONFIG_KEY"
    echo ""
fi

# JWT Secret Key
JWT_KEY=$(remote_exec "grep '^JWT_SECRET_KEY=' ${REMOTE_DIR}/.env | cut -d'=' -f2")
if [ ! -z "$JWT_KEY" ]; then
    echo -e "${YELLOW}JWT_SECRET_KEY:${NC}"
    echo "$JWT_KEY"
    echo ""
fi

# Secret Key genérica
SECRET_KEY=$(remote_exec "grep '^SECRET_KEY=' ${REMOTE_DIR}/.env | cut -d'=' -f2")
if [ ! -z "$SECRET_KEY" ] && [ "$SECRET_KEY" != "$GATEWAY_KEY" ]; then
    echo -e "${YELLOW}SECRET_KEY:${NC}"
    echo "$SECRET_KEY"
    echo ""
fi

# MQTT Password
MQTT_PASS=$(remote_exec "grep '^MQTT_PASSWORD=' ${REMOTE_DIR}/.env | cut -d'=' -f2")
if [ ! -z "$MQTT_PASS" ]; then
    echo -e "${YELLOW}MQTT_PASSWORD:${NC}"
    echo "$MQTT_PASS"
    echo ""
fi

# Salvar em arquivo?
echo "======================================"
echo ""
read -p "Deseja salvar estas chaves em um arquivo local? (s/N): " SAVE

if [[ $SAVE =~ ^[Ss]$ ]]; then
    KEYS_FILE="deploy/.keys_${RASPBERRY_IP}_recovered_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$KEYS_FILE" << EOF
# Chaves de Segurança Recuperadas de ${RASPBERRY_IP}
# Data: $(date)
# ATENÇÃO: Guarde este arquivo em local seguro!

GATEWAY_SECRET_KEY=${GATEWAY_KEY}
CONFIG_SECRET_KEY=${CONFIG_KEY}
JWT_SECRET_KEY=${JWT_KEY}
SECRET_KEY=${SECRET_KEY}
MQTT_PASSWORD=${MQTT_PASS}

# Servidor de origem
RASPBERRY_IP=${RASPBERRY_IP}
RASPBERRY_USER=${RASPBERRY_USER}
REMOTE_DIR=${REMOTE_DIR}
EOF
    
    chmod 600 "$KEYS_FILE"
    echo ""
    echo -e "${GREEN}✅ Chaves salvas em: $KEYS_FILE${NC}"
    echo -e "${YELLOW}⚠️ IMPORTANTE: Guarde este arquivo em local seguro!${NC}"
fi

echo ""
echo -e "${GREEN}✅ Recuperação concluída${NC}"