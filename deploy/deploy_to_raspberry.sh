#!/bin/bash

# Deploy AutoCore to Raspberry Pi
set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Diretório do projeto
PROJECT_DIR="$(dirname "$(dirname "$(realpath "$0")")")"

echo -e "${BLUE}🚀 Deploy AutoCore para Raspberry Pi${NC}"
echo "======================================"

# Verificar se existe arquivo de credenciais
if [ -f ".credentials" ]; then
    echo -e "${GREEN}📋 Usando credenciais de .credentials${NC}"
    source .credentials
    
    # Validar que as variáveis necessárias existem
    if [ -z "$RASPBERRY_USER" ]; then
        RASPBERRY_USER="autocore"
    fi
    
    # Usar IP do arquivo ou descobrir
    if [ -z "$RASPBERRY_IP" ] && [ ! -z "$RASPBERRY_HOSTNAME" ]; then
        echo -e "${BLUE}🔍 Resolvendo $RASPBERRY_HOSTNAME...${NC}"
        RASPBERRY_IP=$(dig +short $RASPBERRY_HOSTNAME 2>/dev/null | head -1)
    fi
    
    USE_CREDENTIALS=true
else
    echo -e "${YELLOW}📝 Arquivo .credentials não encontrado, usando modo interativo${NC}"
    USE_CREDENTIALS=false
fi

# Se não tem IP ainda, descobrir ou perguntar
if [ -z "$RASPBERRY_IP" ]; then
    if [ -f ".last_raspberry_ip" ]; then
        LAST_IP=$(cat .last_raspberry_ip)
        echo -e "${YELLOW}📍 Último IP conhecido: $LAST_IP${NC}"
        read -p "Usar este IP? (S/n): " USE_LAST
        if [ "$USE_LAST" != "n" ] && [ "$USE_LAST" != "N" ]; then
            RASPBERRY_IP=$LAST_IP
        else
            source ./find_raspberry.sh 2>/dev/null || {
                echo -e "${YELLOW}Digite o IP do Raspberry Pi:${NC}"
                read RASPBERRY_IP
            }
        fi
    else
        if [ -f "./find_raspberry.sh" ]; then
            source ./find_raspberry.sh 2>/dev/null || {
                echo -e "${YELLOW}Digite o IP do Raspberry Pi:${NC}"
                read RASPBERRY_IP
            }
        else
            echo -e "${YELLOW}Digite o IP do Raspberry Pi:${NC}"
            read RASPBERRY_IP
        fi
    fi
fi

# Validar IP
if [[ ! $RASPBERRY_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ IP inválido: $RASPBERRY_IP${NC}"
    exit 1
fi

# Salvar IP para próxima vez
echo "$RASPBERRY_IP" > .last_raspberry_ip

# Se não tem usuário ainda, perguntar
if [ -z "$RASPBERRY_USER" ]; then
    echo ""
    echo -e "${BLUE}🔐 Credenciais de acesso:${NC}"
    read -p "Usuário SSH [autocore]: " RASPBERRY_USER
    RASPBERRY_USER=${RASPBERRY_USER:-autocore}
fi

# Configurar conexão
echo -e "${BLUE}🔌 Testando conexão SSH...${NC}"

# Se tem credenciais com senha, usar
if [ "$USE_CREDENTIALS" = true ] && [ ! -z "$RASPBERRY_PASS" ]; then
    if ! command -v sshpass &> /dev/null; then
        echo -e "${YELLOW}⚠️ Instalando sshpass...${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install hudochenkov/sshpass/sshpass 2>/dev/null || {
                echo -e "${RED}Instale sshpass: brew install hudochenkov/sshpass/sshpass${NC}"
                exit 1
            }
        fi
    fi
    
    if sshpass -p "$RASPBERRY_PASS" ssh -o StrictHostKeyChecking=no ${RASPBERRY_USER}@${RASPBERRY_IP} "echo 'OK'" 2>/dev/null; then
        echo -e "${GREEN}✅ Conectado com credenciais do arquivo${NC}"
        USE_SSH_KEY=false
        USE_SSHPASS=true
    else
        echo -e "${RED}❌ Credenciais inválidas em .credentials${NC}"
        exit 1
    fi
# Senão, tentar chave SSH ou pedir senha
elif ssh -o ConnectTimeout=3 -o PasswordAuthentication=no ${RASPBERRY_USER}@${RASPBERRY_IP} "echo 'SSH key OK'" 2>/dev/null; then
    echo -e "${GREEN}✅ Conectado com chave SSH${NC}"
    USE_SSH_KEY=true
    USE_SSHPASS=false
else
    echo -e "${YELLOW}📝 Chave SSH não configurada, será necessário usar senha${NC}"
    USE_SSH_KEY=false
    
    # Verificar se sshpass está instalado para usar senha
    if ! command -v sshpass &> /dev/null; then
        echo -e "${YELLOW}⚠️ sshpass não está instalado.${NC}"
        echo -e "${YELLOW}Para instalar no macOS: brew install hudochenkov/sshpass/sshpass${NC}"
        echo -e "${YELLOW}Ou configure chave SSH: ssh-copy-id ${RASPBERRY_USER}@${RASPBERRY_IP}${NC}"
        echo ""
        echo -e "${BLUE}Continuando com SSH padrão (você precisará digitar a senha várias vezes)${NC}"
        echo ""
        USE_SSHPASS=false
    else
        read -s -p "Senha SSH: " RASPBERRY_PASS
        echo ""
        
        # Testar conexão com senha
        if ! sshpass -p "$RASPBERRY_PASS" ssh -o StrictHostKeyChecking=no ${RASPBERRY_USER}@${RASPBERRY_IP} "echo 'Password OK'" 2>/dev/null; then
            echo -e "${RED}❌ Não foi possível conectar. Verifique as credenciais.${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ Conectado com senha${NC}"
        USE_SSHPASS=true
    fi
fi

REMOTE_DIR="/opt/autocore"

echo ""
echo -e "Host: ${YELLOW}${RASPBERRY_IP}${NC}"
echo -e "User: ${YELLOW}${RASPBERRY_USER}${NC}"
echo -e "Path: ${YELLOW}${REMOTE_DIR}${NC}"
echo ""

# Funções para executar comandos e copiar arquivos
if [ "$USE_SSH_KEY" = true ]; then
    # Usar chave SSH
    remote_exec() {
        ssh ${RASPBERRY_USER}@${RASPBERRY_IP} "$1"
    }
    remote_copy() {
        # Separar argumentos e destino
        local args=""
        local dest=""
        for arg in "$@"; do
            if [[ "$arg" == ${REMOTE_DIR}/* ]]; then
                dest="$arg"
            else
                args="$args $arg"
            fi
        done
        rsync -avz $args ${RASPBERRY_USER}@${RASPBERRY_IP}:${dest}
    }
elif [ "$USE_SSHPASS" = true ] && [ ! -z "$RASPBERRY_PASS" ]; then
    # Usar sshpass com senha
    remote_exec() {
        sshpass -p "$RASPBERRY_PASS" ssh -o StrictHostKeyChecking=no ${RASPBERRY_USER}@${RASPBERRY_IP} "$1"
    }
    remote_copy() {
        # Separar argumentos e destino
        local args=""
        local dest=""
        for arg in "$@"; do
            if [[ "$arg" == ${REMOTE_DIR}/* ]]; then
                dest="$arg"
            else
                args="$args $arg"
            fi
        done
        sshpass -p "$RASPBERRY_PASS" rsync -avz -e "ssh -o StrictHostKeyChecking=no" $args ${RASPBERRY_USER}@${RASPBERRY_IP}:${dest}
    }
else
    # Usar SSH padrão (pedirá senha várias vezes)
    remote_exec() {
        ssh ${RASPBERRY_USER}@${RASPBERRY_IP} "$1"
    }
    remote_copy() {
        # Separar argumentos e destino
        local args=""
        local dest=""
        for arg in "$@"; do
            if [[ "$arg" == ${REMOTE_DIR}/* ]]; then
                dest="$arg"
            else
                args="$args $arg"
            fi
        done
        rsync -avz $args ${RASPBERRY_USER}@${RASPBERRY_IP}:${dest}
    }
fi

# Criar estrutura de diretórios no Raspberry
echo -e "${BLUE}📁 Criando estrutura de diretórios...${NC}"
remote_exec "sudo mkdir -p ${REMOTE_DIR}/{database,gateway,config-app,logs,deploy} && sudo chown -R ${RASPBERRY_USER}:${RASPBERRY_USER} ${REMOTE_DIR}"

# Aguardar criação dos diretórios
sleep 2

# Navegar para o diretório do projeto
cd "${PROJECT_DIR}"

# Copiar arquivos do database
echo -e "${BLUE}💾 Copiando database...${NC}"
# Garantir que o diretório de destino existe e tem permissões corretas
remote_exec "sudo mkdir -p ${REMOTE_DIR}/database && sudo chown -R ${RASPBERRY_USER}:${RASPBERRY_USER} ${REMOTE_DIR}/database"
remote_copy --exclude='__pycache__' --exclude='*.pyc' --exclude='.env' --exclude='.venv' \
    database/ ${REMOTE_DIR}/database/

# Copiar arquivos do gateway
echo -e "${BLUE}🌐 Copiando gateway...${NC}"
remote_exec "sudo mkdir -p ${REMOTE_DIR}/gateway && sudo chown -R ${RASPBERRY_USER}:${RASPBERRY_USER} ${REMOTE_DIR}/gateway"
remote_copy --exclude='__pycache__' --exclude='*.pyc' --exclude='.env' --exclude='.venv' --exclude='venv' \
    gateway/ ${REMOTE_DIR}/gateway/

# Copiar arquivos do config-app
echo -e "${BLUE}⚙️ Copiando config-app...${NC}"
remote_exec "sudo mkdir -p ${REMOTE_DIR}/config-app && sudo chown -R ${RASPBERRY_USER}:${RASPBERRY_USER} ${REMOTE_DIR}/config-app"
remote_copy --exclude='__pycache__' --exclude='*.pyc' --exclude='.env' --exclude='node_modules' --exclude='.venv' --exclude='venv' \
    config-app/ ${REMOTE_DIR}/config-app/

# Copiar scripts de deploy
echo -e "${BLUE}📦 Copiando scripts de deploy...${NC}"
remote_copy deploy/*.sh ${REMOTE_DIR}/deploy/
remote_exec "chmod +x ${REMOTE_DIR}/deploy/*.sh"

# Copiar arquivos systemd
echo -e "${BLUE}🔧 Copiando arquivos systemd...${NC}"
remote_exec "mkdir -p ${REMOTE_DIR}/deploy/systemd"
remote_copy deploy/systemd/*.service ${REMOTE_DIR}/deploy/systemd/

# Copiar credenciais se existir
if [ -f "deploy/.credentials" ]; then
    echo -e "${BLUE}🔐 Copiando credenciais...${NC}"
    remote_copy deploy/.credentials ${REMOTE_DIR}/deploy/
    remote_exec "chmod 600 ${REMOTE_DIR}/deploy/.credentials"
fi

# Criar arquivo de configuração .env
echo -e "${BLUE}📝 Criando arquivo .env...${NC}"

# Pegar senha MQTT das credenciais ou usar padrão seguro
if [ -f ".credentials" ]; then
    source .credentials
    MQTT_PASSWORD="${MQTT_PASS:-kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr}"
else
    MQTT_PASSWORD="kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr"
fi

# Verificar se já existe um .env no Raspberry com as chaves
echo -e "${BLUE}🔑 Verificando chaves de segurança...${NC}"
EXISTING_KEYS=$(remote_exec "[ -f ${REMOTE_DIR}/.env ] && grep -E '^(GATEWAY_SECRET_KEY|CONFIG_SECRET_KEY|JWT_SECRET_KEY)=' ${REMOTE_DIR}/.env || echo ''")

if [ ! -z "$EXISTING_KEYS" ]; then
    echo -e "${YELLOW}📋 Usando chaves existentes do servidor${NC}"
    # Extrair chaves existentes
    GATEWAY_SECRET=$(echo "$EXISTING_KEYS" | grep GATEWAY_SECRET_KEY | cut -d'=' -f2)
    CONFIG_SECRET=$(echo "$EXISTING_KEYS" | grep CONFIG_SECRET_KEY | cut -d'=' -f2)
    JWT_SECRET=$(echo "$EXISTING_KEYS" | grep JWT_SECRET_KEY | cut -d'=' -f2)
fi

# Se não existem chaves, gerar novas
if [ -z "$GATEWAY_SECRET" ] || [ -z "$CONFIG_SECRET" ] || [ -z "$JWT_SECRET" ]; then
    echo -e "${GREEN}🔐 Gerando novas chaves de segurança únicas...${NC}"
    
    # Gerar chaves únicas para esta instalação
    GATEWAY_SECRET=$(openssl rand -hex 32)
    CONFIG_SECRET=$(openssl rand -hex 32)
    JWT_SECRET=$(openssl rand -hex 32)
    
    echo -e "  Gateway Secret: ${YELLOW}[GERADA]${NC}"
    echo -e "  Config Secret:  ${YELLOW}[GERADA]${NC}"
    echo -e "  JWT Secret:     ${YELLOW}[GERADA]${NC}"
    
    # Salvar as chaves geradas em um arquivo local para referência
    KEYS_FILE="deploy/.keys_${RASPBERRY_IP}_$(date +%Y%m%d_%H%M%S).txt"
    cat > "$KEYS_FILE" << EOF
# Chaves de Segurança Geradas para ${RASPBERRY_IP}
# Data: $(date)
# ATENÇÃO: Guarde este arquivo em local seguro!

GATEWAY_SECRET_KEY=${GATEWAY_SECRET}
CONFIG_SECRET_KEY=${CONFIG_SECRET}
JWT_SECRET_KEY=${JWT_SECRET}

# Para recuperar estas chaves:
# ssh ${RASPBERRY_USER}@${RASPBERRY_IP} "grep SECRET_KEY ${REMOTE_DIR}/.env"
EOF
    chmod 600 "$KEYS_FILE"
    echo -e "${GREEN}📄 Chaves salvas em: $KEYS_FILE${NC}"
fi

cat > temp.env << EOF
# Database
DATABASE_PATH=/opt/autocore/database/autocore.db

# MQTT Configuration
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_USERNAME=autocore
MQTT_PASSWORD=${MQTT_PASSWORD}

# Security
SECRET_KEY=${GATEWAY_SECRET}
GATEWAY_SECRET_KEY=${GATEWAY_SECRET}
CONFIG_SECRET_KEY=${CONFIG_SECRET}
JWT_SECRET_KEY=${JWT_SECRET}
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRES=3600
ENABLE_AUTH=true

# Config App
CONFIG_APP_PORT=8081
CONFIG_APP_HOST=0.0.0.0

# Gateway
GATEWAY_ID=raspberry-gateway
GATEWAY_NAME=AutoCore Gateway

# Logging
LOG_LEVEL=INFO
LOG_FILE=/opt/autocore/logs/autocore.log

# Environment
ENVIRONMENT=production
EOF

if [ "$USE_SSH_KEY" = true ] || [ -z "$RASPBERRY_PASS" ]; then
    scp temp.env ${RASPBERRY_USER}@${RASPBERRY_IP}:${REMOTE_DIR}/.env
else
    sshpass -p "$RASPBERRY_PASS" scp -o StrictHostKeyChecking=no temp.env ${RASPBERRY_USER}@${RASPBERRY_IP}:${REMOTE_DIR}/.env
fi
rm temp.env

# Criar .env para o frontend
echo -e "${BLUE}📝 Criando .env do frontend...${NC}"
cat > temp-frontend.env << EOF
# Config App Frontend Configuration

# API Backend  
# Frontend port
VITE_PORT=8080

# Backend API
VITE_API_URL=http://${RASPBERRY_IP}:8081
VITE_API_PORT=8081
VITE_API_BASE_URL=http://${RASPBERRY_IP}:8081/api
VITE_WS_URL=ws://${RASPBERRY_IP}:8081

# Environment
VITE_ENV=production
EOF

if [ "$USE_SSH_KEY" = true ] || [ -z "$RASPBERRY_PASS" ]; then
    scp temp-frontend.env ${RASPBERRY_USER}@${RASPBERRY_IP}:${REMOTE_DIR}/config-app/frontend/.env
else
    sshpass -p "$RASPBERRY_PASS" scp -o StrictHostKeyChecking=no temp-frontend.env ${RASPBERRY_USER}@${RASPBERRY_IP}:${REMOTE_DIR}/config-app/frontend/.env
fi
rm temp-frontend.env

echo -e "${GREEN}✅ Deploy concluído!${NC}"
echo ""

# Verificar se é primeira instalação
echo -e "${BLUE}🔍 Verificando se é primeira instalação...${NC}"
FIRST_INSTALL=$(remote_exec "[ ! -f ${REMOTE_DIR}/.installed ] && echo 'yes' || echo 'no'")

if [ "$FIRST_INSTALL" = "yes" ]; then
    echo -e "${YELLOW}📦 Primeira instalação detectada!${NC}"
    echo ""
    read -p "Deseja executar o setup inicial automaticamente? (s/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${BLUE}🚀 Executando setup inicial no Raspberry Pi...${NC}"
        echo -e "${YELLOW}Isso pode demorar alguns minutos...${NC}"
        echo ""
        
        # Executar setup remotamente
        if [ "$USE_SSH_KEY" = true ] || [ -z "$RASPBERRY_PASS" ]; then
            ssh -t ${RASPBERRY_USER}@${RASPBERRY_IP} "cd ${REMOTE_DIR} && bash deploy/raspberry_setup.sh"
        else
            sshpass -p "$RASPBERRY_PASS" ssh -t -o StrictHostKeyChecking=no ${RASPBERRY_USER}@${RASPBERRY_IP} "cd ${REMOTE_DIR} && bash deploy/raspberry_setup.sh"
        fi
        
        # Marcar como instalado
        remote_exec "touch ${REMOTE_DIR}/.installed"
        
        echo ""
        echo -e "${GREEN}✅ Setup inicial concluído!${NC}"
    else
        echo -e "${YELLOW}Para executar o setup manualmente:${NC}"
        echo -e "  ${BLUE}ssh ${RASPBERRY_USER}@${RASPBERRY_IP}${NC}"
        echo -e "  ${BLUE}cd ${REMOTE_DIR}${NC}"
        echo -e "  ${BLUE}bash deploy/raspberry_setup.sh${NC}"
    fi
else
    echo -e "${BLUE}📦 Sistema já instalado. Atualizando...${NC}"
    
    # Verificar se os serviços systemd estão instalados
    echo -e "${BLUE}🔍 Verificando serviços systemd...${NC}"
    SERVICES_INSTALLED=$(remote_exec "systemctl list-unit-files | grep -q 'autocore-gateway' && echo 'yes' || echo 'no'")
    
    if [ "$SERVICES_INSTALLED" = "no" ]; then
        echo -e "${YELLOW}⚠️ Serviços systemd não instalados. Instalando...${NC}"
        
        # Instalar serviços systemd
        remote_exec "sudo cp ${REMOTE_DIR}/deploy/systemd/*.service /etc/systemd/system/ 2>/dev/null || true"
        remote_exec "sudo chmod 644 /etc/systemd/system/autocore-*.service 2>/dev/null || true"
        remote_exec "sudo systemctl daemon-reload"
        
        # Habilitar serviços
        remote_exec "sudo systemctl enable autocore-gateway autocore-config-app autocore-config-frontend 2>/dev/null || true"
        
        echo -e "${GREEN}✅ Serviços systemd instalados!${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Opções disponíveis:${NC}"
    echo "  1) Reiniciar serviços"
    echo "  2) Executar setup completo (reinstalar dependências)"
    echo "  3) Pular"
    echo ""
    read -p "Escolha uma opção (1-3): " -n 1 -r
    echo ""
    
    case $REPLY in
        1)
            echo -e "${BLUE}🔄 Reiniciando serviços...${NC}"
            
            # Verificar e reiniciar cada serviço individualmente
            for service in autocore-gateway autocore-config-app autocore-config-frontend; do
                if remote_exec "systemctl list-unit-files | grep -q '$service'" 2>/dev/null; then
                    remote_exec "sudo systemctl restart $service" 2>/dev/null || echo "  ⚠️ $service não pôde ser reiniciado"
                else
                    echo "  ⚠️ $service não encontrado"
                fi
            done
            
            echo -e "${GREEN}✅ Processo de reinicialização concluído!${NC}"
            ;;
        2)
            echo -e "${BLUE}🚀 Executando setup completo no Raspberry Pi...${NC}"
            echo -e "${YELLOW}Isso pode demorar alguns minutos...${NC}"
            echo ""
            
            # Executar setup remotamente
            if [ "$USE_SSH_KEY" = true ] || [ -z "$RASPBERRY_PASS" ]; then
                ssh -t ${RASPBERRY_USER}@${RASPBERRY_IP} "cd ${REMOTE_DIR} && bash deploy/raspberry_setup.sh"
            else
                sshpass -p "$RASPBERRY_PASS" ssh -t -o StrictHostKeyChecking=no ${RASPBERRY_USER}@${RASPBERRY_IP} "cd ${REMOTE_DIR} && bash deploy/raspberry_setup.sh"
            fi
            
            echo ""
            echo -e "${GREEN}✅ Setup completo concluído!${NC}"
            ;;
        3)
            echo -e "${YELLOW}⏭️ Pulando reinicialização de serviços${NC}"
            ;;
        *)
            echo -e "${YELLOW}⚠️ Opção inválida. Pulando...${NC}"
            ;;
    esac
fi

echo ""
echo -e "${YELLOW}🌐 URLs de acesso:${NC}"
echo "  Frontend: http://${RASPBERRY_IP}:8080 ou http://autocore.local:8080"
echo "  Backend API: http://${RASPBERRY_IP}:8081 ou http://autocore.local:8081"
echo "  MQTT Broker: ${RASPBERRY_IP}:1883 ou autocore.local:1883"
echo ""
echo -e "${YELLOW}📊 Comandos úteis:${NC}"
echo "  Ver status: make status"
echo "  Ver logs: make logs-gateway"
echo "  Reiniciar: make restart"
echo ""
echo -e "${GREEN}💡 Dica: Configure chave SSH para evitar digitar senha:${NC}"
echo "  ssh-copy-id ${RASPBERRY_USER}@${RASPBERRY_IP}"