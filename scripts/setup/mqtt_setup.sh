#!/bin/bash

# Script para configurar autenticação no Mosquitto
# Usa credenciais do arquivo .env

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔐 Configuração de Autenticação MQTT${NC}"
echo "======================================="
echo ""

# Procurar arquivo .env
ENV_FILE=""
if [ -f ".env" ]; then
    ENV_FILE=".env"
elif [ -f "deploy/.credentials" ]; then
    ENV_FILE="deploy/.credentials"
elif [ -f "gateway/.env" ]; then
    ENV_FILE="gateway/.env"
else
    echo -e "${RED}❌ Arquivo .env não encontrado${NC}"
    echo "Crie um arquivo .env com MQTT_USERNAME e MQTT_PASSWORD"
    exit 1
fi

echo -e "${GREEN}✅ Usando configuração de: $ENV_FILE${NC}"

# Carregar variáveis
source $ENV_FILE

if [ -z "$MQTT_USERNAME" ] || [ -z "$MQTT_PASSWORD" ]; then
    echo -e "${RED}❌ MQTT_USERNAME ou MQTT_PASSWORD não definidos${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📝 Configurando Mosquitto...${NC}"

# Detectar sistema operacional
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux (incluindo Raspberry Pi)
    MOSQUITTO_DIR="/etc/mosquitto"
    MOSQUITTO_CONF="$MOSQUITTO_DIR/mosquitto.conf"
    PASSWORD_FILE="$MOSQUITTO_DIR/passwd"
    
    # Criar arquivo de senha
    echo -e "${YELLOW}→ Criando arquivo de senha...${NC}"
    sudo mosquitto_passwd -c -b $PASSWORD_FILE $MQTT_USERNAME "$MQTT_PASSWORD"
    
    # Configurar mosquitto.conf
    echo -e "${YELLOW}→ Atualizando configuração...${NC}"
    
    # Backup da configuração original
    if [ ! -f "$MOSQUITTO_CONF.backup" ]; then
        sudo cp $MOSQUITTO_CONF $MOSQUITTO_CONF.backup
    fi
    
    # Adicionar configuração de autenticação se não existir
    if ! grep -q "password_file" $MOSQUITTO_CONF; then
        echo "" | sudo tee -a $MOSQUITTO_CONF
        echo "# Autenticação AutoCore" | sudo tee -a $MOSQUITTO_CONF
        echo "allow_anonymous false" | sudo tee -a $MOSQUITTO_CONF
        echo "password_file $PASSWORD_FILE" | sudo tee -a $MOSQUITTO_CONF
    fi
    
    # Reiniciar Mosquitto
    echo -e "${YELLOW}→ Reiniciando Mosquitto...${NC}"
    sudo systemctl restart mosquitto
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    MOSQUITTO_DIR="/opt/homebrew/etc/mosquitto"
    if [ ! -d "$MOSQUITTO_DIR" ]; then
        MOSQUITTO_DIR="/usr/local/etc/mosquitto"
    fi
    
    MOSQUITTO_CONF="$MOSQUITTO_DIR/mosquitto.conf"
    PASSWORD_FILE="$MOSQUITTO_DIR/passwd"
    
    # Criar arquivo de senha
    echo -e "${YELLOW}→ Criando arquivo de senha...${NC}"
    mosquitto_passwd -c -b $PASSWORD_FILE $MQTT_USERNAME "$MQTT_PASSWORD"
    
    # Configurar mosquitto.conf
    echo -e "${YELLOW}→ Atualizando configuração...${NC}"
    
    # Backup da configuração original
    if [ ! -f "$MOSQUITTO_CONF.backup" ]; then
        cp $MOSQUITTO_CONF $MOSQUITTO_CONF.backup
    fi
    
    # Adicionar configuração de autenticação se não existir
    if ! grep -q "password_file" $MOSQUITTO_CONF; then
        echo "" >> $MOSQUITTO_CONF
        echo "# Autenticação AutoCore" >> $MOSQUITTO_CONF
        echo "allow_anonymous false" >> $MOSQUITTO_CONF
        echo "password_file $PASSWORD_FILE" >> $MOSQUITTO_CONF
    fi
    
    # Reiniciar Mosquitto
    echo -e "${YELLOW}→ Reiniciando Mosquitto...${NC}"
    brew services restart mosquitto
else
    echo -e "${RED}❌ Sistema operacional não suportado${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Mosquitto configurado com sucesso!${NC}"
echo ""
echo "Credenciais configuradas:"
echo -e "  Usuário: ${YELLOW}$MQTT_USERNAME${NC}"
echo -e "  Senha: ${YELLOW}[PROTEGIDA]${NC}"
echo ""
echo -e "${BLUE}📋 Teste a conexão com:${NC}"
echo "mosquitto_sub -h localhost -u $MQTT_USERNAME -P '\$MQTT_PASSWORD' -t 'test/#'"
echo ""
echo -e "${YELLOW}⚠️ Lembre-se de configurar o .env em todos os componentes:${NC}"
echo "  - gateway/.env"
echo "  - config-app/backend/.env"
echo "  - Dispositivos ESP32"