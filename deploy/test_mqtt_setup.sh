#!/bin/bash

# Script para testar a configuração MQTT após setup
set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Teste de Configuração MQTT AutoCore${NC}"
echo "=========================================="

# Verificar se está no Raspberry Pi
if [ ! -d "/opt/autocore" ]; then
    echo -e "${RED}❌ Este script deve ser executado no Raspberry Pi${NC}"
    exit 1
fi

# Carregar credenciais
if [ -f "/opt/autocore/deploy/.credentials" ]; then
    source /opt/autocore/deploy/.credentials
    echo -e "${GREEN}✅ Credenciais carregadas${NC}"
else
    echo -e "${RED}❌ Arquivo de credenciais não encontrado${NC}"
    exit 1
fi

# Verificar se MQTT_PASS existe
if [ -z "$MQTT_PASS" ]; then
    echo -e "${RED}❌ Senha MQTT não encontrada nas credenciais${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}1. Verificando serviço Mosquitto...${NC}"
if systemctl is-active --quiet mosquitto; then
    echo -e "   ${GREEN}✅ Mosquitto está rodando${NC}"
else
    echo -e "   ${RED}❌ Mosquitto não está rodando${NC}"
    echo "   Execute: sudo systemctl start mosquitto"
    exit 1
fi

echo ""
echo -e "${BLUE}2. Testando conexão MQTT...${NC}"
if timeout 2 mosquitto_sub -h localhost -u autocore -P "$MQTT_PASS" -t test -C 1 >/dev/null 2>&1; then
    echo -e "   ${GREEN}✅ Conexão MQTT funcionando${NC}"
else
    echo -e "   ${RED}❌ Falha na conexão MQTT${NC}"
    echo "   Verifique a senha e configuração"
    exit 1
fi

echo ""
echo -e "${BLUE}3. Verificando arquivos .env...${NC}"

# Verificar backend .env
if [ -f "/opt/autocore/config-app/backend/.env" ]; then
    BACKEND_PASS=$(grep "^MQTT_PASSWORD=" /opt/autocore/config-app/backend/.env | cut -d'=' -f2)
    if [ "$BACKEND_PASS" = "$MQTT_PASS" ]; then
        echo -e "   ${GREEN}✅ Backend .env configurado corretamente${NC}"
    else
        echo -e "   ${YELLOW}⚠️ Backend .env com senha diferente${NC}"
        echo "   Atualizando..."
        sed -i "s/^MQTT_PASSWORD=.*/MQTT_PASSWORD=${MQTT_PASS}/" /opt/autocore/config-app/backend/.env
        echo -e "   ${GREEN}✅ Backend .env atualizado${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️ Backend .env não existe${NC}"
fi

# Verificar gateway .env
if [ -f "/opt/autocore/gateway/.env" ]; then
    GATEWAY_PASS=$(grep "^MQTT_PASSWORD=" /opt/autocore/gateway/.env | cut -d'=' -f2)
    if [ "$GATEWAY_PASS" = "$MQTT_PASS" ]; then
        echo -e "   ${GREEN}✅ Gateway .env configurado corretamente${NC}"
    else
        echo -e "   ${YELLOW}⚠️ Gateway .env com senha diferente${NC}"
        echo "   Atualizando..."
        sed -i "s/^MQTT_PASSWORD=.*/MQTT_PASSWORD=${MQTT_PASS}/" /opt/autocore/gateway/.env
        echo -e "   ${GREEN}✅ Gateway .env atualizado${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️ Gateway .env não existe${NC}"
fi

echo ""
echo -e "${BLUE}4. Testando publicação MQTT...${NC}"
TEST_MSG="test_$(date +%s)"
mosquitto_pub -h localhost -u autocore -P "$MQTT_PASS" -t "autocore/test" -m "$TEST_MSG"
echo -e "   ${GREEN}✅ Mensagem publicada${NC}"

echo ""
echo -e "${BLUE}5. Verificando serviços AutoCore...${NC}"
for service in autocore-config-app autocore-gateway; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        echo -e "   ${GREEN}✅ $service está ativo${NC}"
    else
        echo -e "   ${YELLOW}⚠️ $service não está rodando${NC}"
    fi
done

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Teste concluído!${NC}"
echo ""
echo -e "${BLUE}Informações:${NC}"
echo "  Senha MQTT: ${MQTT_PASS:0:8}..."
echo "  IP do Raspberry: $(hostname -I | awk '{print $1}')"
echo ""
echo -e "${BLUE}Para reiniciar os serviços:${NC}"
echo "  sudo systemctl restart autocore-config-app"
echo "  sudo systemctl restart autocore-gateway"
echo ""