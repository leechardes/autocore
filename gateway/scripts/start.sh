#!/bin/bash
# Script para inicializar o AutoCore Gateway

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Iniciando AutoCore Gateway...${NC}"

# Verificar se está no ambiente virtual
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo -e "${GREEN}✅ Ambiente virtual ativo: $VIRTUAL_ENV${NC}"
else
    echo -e "${YELLOW}⚠️ Nenhum ambiente virtual detectado${NC}"
    echo -e "${YELLOW}   Recomendado: source .venv/bin/activate${NC}"
fi

# Verificar dependências
echo -e "${GREEN}📦 Verificando dependências...${NC}"
python3 -c "import paho.mqtt.client; print('✅ paho-mqtt')" 2>/dev/null || echo -e "${RED}❌ paho-mqtt não encontrado${NC}"
python3 -c "import asyncio; print('✅ asyncio')" 2>/dev/null || echo -e "${RED}❌ asyncio não encontrado${NC}"
python3 -c "import psutil; print('✅ psutil')" 2>/dev/null || echo -e "${RED}❌ psutil não encontrado${NC}"

# Verificar database
if [ -f "../database/autocore.db" ]; then
    echo -e "${GREEN}✅ Database encontrado${NC}"
else
    echo -e "${YELLOW}⚠️ Database não encontrado${NC}"
    echo -e "${YELLOW}   Execute: cd ../database && python src/cli/manage.py init${NC}"
fi

# Verificar arquivo de configuração
if [ -f ".env" ]; then
    echo -e "${GREEN}✅ Arquivo .env encontrado${NC}"
else
    echo -e "${YELLOW}⚠️ Arquivo .env não encontrado${NC}"
    echo -e "${YELLOW}   Criando .env baseado no .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ Arquivo .env criado${NC}"
fi

echo -e "${GREEN}🚀 Iniciando Gateway...${NC}"
cd "$(dirname "$0")/.."  # Voltar para raiz do gateway
python3 -m src.main