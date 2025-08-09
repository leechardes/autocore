#!/bin/bash

# Setup do Mosquitto MQTT Broker no macOS com senha segura

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🦟 Configuração do Mosquitto MQTT no macOS${NC}"
echo "==========================================="

# Verificar se Mosquitto está instalado
if ! command -v mosquitto &> /dev/null; then
    echo -e "${YELLOW}📦 Mosquitto não está instalado. Instalando...${NC}"
    
    if command -v brew &> /dev/null; then
        brew install mosquitto
    else
        echo -e "${RED}❌ Homebrew não está instalado.${NC}"
        echo "   Instale o Homebrew primeiro: https://brew.sh"
        exit 1
    fi
fi

# Carregar configurações do .env ou credenciais
if [ -f ".env" ]; then
    source .env
elif [ -f "deploy/.credentials" ]; then
    source deploy/.credentials
fi

MQTT_USER="${MQTT_USERNAME:-autocore}"
MQTT_PASS="${MQTT_PASSWORD}"

if [ -z "$MQTT_PASS" ]; then
    echo -e "${RED}❌ MQTT_PASSWORD não definido no .env${NC}"
    echo "Configure a senha no arquivo .env ou deploy/.credentials"
    exit 1
fi

# Diretórios de configuração do Mosquitto no Mac
if [ -d "/usr/local/etc/mosquitto" ]; then
    MOSQUITTO_DIR="/usr/local/etc/mosquitto"
elif [ -d "/opt/homebrew/etc/mosquitto" ]; then
    MOSQUITTO_DIR="/opt/homebrew/etc/mosquitto"
else
    echo -e "${RED}❌ Diretório de configuração do Mosquitto não encontrado${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Diretório de configuração: $MOSQUITTO_DIR${NC}"

# Criar arquivo de configuração
echo -e "${BLUE}📝 Criando configuração do Mosquitto...${NC}"
cat > /tmp/mosquitto_autocore.conf << EOF
# Configuração do Mosquitto para AutoCore
listener 1883
protocol mqtt

# Autenticação
allow_anonymous false
password_file $MOSQUITTO_DIR/passwd

# Logging
log_type all
log_dest stdout
log_dest file /usr/local/var/log/mosquitto.log

# Persistência
persistence true
persistence_location /usr/local/var/lib/mosquitto/
EOF

# Copiar configuração
sudo cp /tmp/mosquitto_autocore.conf $MOSQUITTO_DIR/mosquitto.conf
rm /tmp/mosquitto_autocore.conf

# Criar arquivo de senha
echo -e "${BLUE}🔐 Configurando autenticação...${NC}"
echo "$MQTT_USER:$MQTT_PASS" > /tmp/passwd.txt

# Criptografar senha
if command -v mosquitto_passwd &> /dev/null; then
    mosquitto_passwd -U /tmp/passwd.txt
    sudo mv /tmp/passwd.txt $MOSQUITTO_DIR/passwd
    sudo chmod 600 $MOSQUITTO_DIR/passwd
else
    echo -e "${RED}❌ mosquitto_passwd não encontrado${NC}"
    rm /tmp/passwd.txt
    exit 1
fi

# Criar diretórios necessários
echo -e "${BLUE}📁 Criando diretórios...${NC}"
sudo mkdir -p /usr/local/var/lib/mosquitto
sudo mkdir -p /usr/local/var/log

# Verificar se Mosquitto está rodando
if pgrep -x "mosquitto" > /dev/null; then
    echo -e "${YELLOW}🔄 Reiniciando Mosquitto...${NC}"
    
    # Tentar parar via brew services primeiro
    if brew services list | grep mosquitto > /dev/null; then
        brew services restart mosquitto
    else
        # Parar processo manualmente
        sudo pkill mosquitto
        sleep 2
        # Iniciar novamente
        mosquitto -c $MOSQUITTO_DIR/mosquitto.conf -d
    fi
else
    echo -e "${GREEN}🚀 Iniciando Mosquitto...${NC}"
    
    # Tentar iniciar via brew services
    if command -v brew &> /dev/null; then
        brew services start mosquitto
    else
        # Iniciar manualmente
        mosquitto -c $MOSQUITTO_DIR/mosquitto.conf -d
    fi
fi

sleep 2

# Testar conexão
echo -e "${BLUE}🧪 Testando conexão MQTT...${NC}"
if timeout 2 mosquitto_sub -h localhost -u "$MQTT_USER" -P "$MQTT_PASS" -t test -C 1 2>/dev/null; then
    echo -e "${GREEN}✅ MQTT configurado com sucesso!${NC}"
else
    echo -e "${YELLOW}⚠️ Não foi possível testar a conexão${NC}"
    echo "   O broker pode levar alguns segundos para iniciar"
fi

echo ""
echo -e "${GREEN}📋 Configuração concluída!${NC}"
echo ""
echo -e "${YELLOW}Informações de conexão:${NC}"
echo "  Host: localhost"
echo "  Porta: 1883"
echo "  Usuário: $MQTT_USER"
echo "  Senha: (configurada no .env)"
echo ""
echo -e "${YELLOW}Comandos úteis:${NC}"
echo "  Verificar status: brew services list | grep mosquitto"
echo "  Ver logs: tail -f /usr/local/var/log/mosquitto.log"
echo "  Reiniciar: brew services restart mosquitto"
echo "  Parar: brew services stop mosquitto"
echo ""
echo -e "${YELLOW}Testar conexão:${NC}"
echo "  mosquitto_sub -h localhost -u $MQTT_USER -P '***' -t test"
echo "  mosquitto_pub -h localhost -u $MQTT_USER -P '***' -t test -m 'Hello'"
echo ""

# Adicionar ao Makefile
echo -e "${BLUE}💡 Dica: Execute 'make setup-mqtt' para configurar o MQTT${NC}"