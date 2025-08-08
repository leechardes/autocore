#!/bin/bash

# ============================================
# Script de Deploy para Raspberry Pi Zero
# AutoCore Gateway System
# ============================================

set -e  # Para em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações
PI_HOST="autocore.local"
PI_USER="leechardes"
PI_PATH="/home/leechardes/AutoCore"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  AutoCore - Deploy para Raspberry Pi${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Verificar conexão com a Pi
echo -e "${YELLOW}📡 Verificando conexão com ${PI_HOST}...${NC}"
if ping -c 1 ${PI_HOST} &> /dev/null; then
    echo -e "${GREEN}✅ Raspberry Pi encontrada!${NC}"
else
    echo -e "${RED}❌ Não foi possível conectar com ${PI_HOST}${NC}"
    echo "Verifique se a Raspberry Pi está ligada e conectada na rede."
    exit 1
fi

# Menu de opções
echo ""
echo "Escolha o que deseja fazer:"
echo "1) Deploy completo (primeira instalação)"
echo "2) Atualizar código apenas"
echo "3) Atualizar e reiniciar serviços"
echo "4) Ver status dos serviços"
echo "5) Ver logs em tempo real"
echo "6) Backup do banco de dados"
echo ""
read -p "Opção: " option

case $option in
    1)
        echo -e "${YELLOW}🚀 Iniciando deploy completo...${NC}"
        
        # Copiar arquivos
        echo -e "${YELLOW}📦 Copiando arquivos...${NC}"
        rsync -avz --exclude '.venv' \
                   --exclude '__pycache__' \
                   --exclude '*.pyc' \
                   --exclude '.git' \
                   --exclude 'node_modules' \
                   --exclude '*.db' \
                   --exclude '.env' \
                   --exclude 'RASPBERRY_PI_CONFIG.md' \
                   ./ ${PI_USER}@${PI_HOST}:${PI_PATH}/
        
        echo -e "${YELLOW}🔧 Executando setup na Raspberry Pi...${NC}"
        ssh ${PI_USER}@${PI_HOST} << 'ENDSSH'
            cd ~/AutoCore
            
            # Database setup
            echo "📊 Configurando database..."
            cd database
            python3 -m venv .venv
            source .venv/bin/activate
            pip install -r requirements.txt
            make reset
            deactivate
            cd ..
            
            # Backend setup
            echo "🔧 Configurando backend..."
            cd config-app/backend
            python3 -m venv .venv
            source .venv/bin/activate
            pip install -r requirements.txt
            cp .env.example .env
            deactivate
            cd ../..
            
            # Gateway setup
            echo "🌉 Configurando gateway..."
            cd gateway
            python3 -m venv .venv
            source .venv/bin/activate
            pip install -r requirements.txt
            deactivate
            cd ..
            
            echo "✅ Setup completo!"
ENDSSH
        
        echo -e "${GREEN}✅ Deploy completo realizado com sucesso!${NC}"
        echo ""
        echo "Próximos passos:"
        echo "1. SSH na Pi: ssh ${PI_USER}@${PI_HOST}"
        echo "2. Configure os arquivos .env conforme necessário"
        echo "3. Configure os serviços systemd (veja RASPBERRY_PI_CONFIG.md)"
        ;;
        
    2)
        echo -e "${YELLOW}📦 Atualizando código...${NC}"
        rsync -avz --exclude '.venv' \
                   --exclude '__pycache__' \
                   --exclude '*.pyc' \
                   --exclude '.git' \
                   --exclude 'node_modules' \
                   --exclude '*.db' \
                   --exclude '.env' \
                   --exclude 'RASPBERRY_PI_CONFIG.md' \
                   --exclude 'logs/' \
                   --exclude 'backups/' \
                   ./ ${PI_USER}@${PI_HOST}:${PI_PATH}/
        
        echo -e "${GREEN}✅ Código atualizado!${NC}"
        ;;
        
    3)
        echo -e "${YELLOW}📦 Atualizando código e reiniciando serviços...${NC}"
        
        # Atualizar código
        rsync -avz --exclude '.venv' \
                   --exclude '__pycache__' \
                   --exclude '*.pyc' \
                   --exclude '.git' \
                   --exclude 'node_modules' \
                   --exclude '*.db' \
                   --exclude '.env' \
                   --exclude 'RASPBERRY_PI_CONFIG.md' \
                   --exclude 'logs/' \
                   --exclude 'backups/' \
                   ./ ${PI_USER}@${PI_HOST}:${PI_PATH}/
        
        # Reiniciar serviços
        echo -e "${YELLOW}🔄 Reiniciando serviços...${NC}"
        ssh ${PI_USER}@${PI_HOST} << 'ENDSSH'
            sudo systemctl restart autocore-config 2>/dev/null || echo "Config service not found"
            sudo systemctl restart autocore-gateway 2>/dev/null || echo "Gateway service not found"
            sudo systemctl restart mosquitto
            
            echo ""
            echo "Status dos serviços:"
            sudo systemctl status autocore-config --no-pager 2>/dev/null || echo "Config: not installed"
            echo ""
            sudo systemctl status autocore-gateway --no-pager 2>/dev/null || echo "Gateway: not installed"
            echo ""
            sudo systemctl status mosquitto --no-pager
ENDSSH
        
        echo -e "${GREEN}✅ Atualização completa!${NC}"
        ;;
        
    4)
        echo -e "${YELLOW}📊 Verificando status dos serviços...${NC}"
        ssh ${PI_USER}@${PI_HOST} << 'ENDSSH'
            echo "=== AutoCore Config ==="
            sudo systemctl status autocore-config --no-pager 2>/dev/null || echo "Not installed"
            echo ""
            echo "=== AutoCore Gateway ==="
            sudo systemctl status autocore-gateway --no-pager 2>/dev/null || echo "Not installed"
            echo ""
            echo "=== Mosquitto MQTT ==="
            sudo systemctl status mosquitto --no-pager
            echo ""
            echo "=== Recursos do Sistema ==="
            echo "Memória:"
            free -h
            echo ""
            echo "Temperatura:"
            vcgencmd measure_temp
            echo ""
            echo "Espaço em disco:"
            df -h /
ENDSSH
        ;;
        
    5)
        echo -e "${YELLOW}📝 Logs em tempo real (Ctrl+C para sair)...${NC}"
        echo "Escolha o serviço:"
        echo "1) Config App"
        echo "2) Gateway"
        echo "3) Mosquitto"
        echo "4) Todos"
        read -p "Opção: " log_option
        
        case $log_option in
            1)
                ssh ${PI_USER}@${PI_HOST} "sudo journalctl -u autocore-config -f"
                ;;
            2)
                ssh ${PI_USER}@${PI_HOST} "sudo journalctl -u autocore-gateway -f"
                ;;
            3)
                ssh ${PI_USER}@${PI_HOST} "sudo journalctl -u mosquitto -f"
                ;;
            4)
                ssh ${PI_USER}@${PI_HOST} "sudo journalctl -f"
                ;;
        esac
        ;;
        
    6)
        echo -e "${YELLOW}💾 Fazendo backup do banco de dados...${NC}"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="autocore_backup_${TIMESTAMP}.db"
        
        # Fazer backup
        scp ${PI_USER}@${PI_HOST}:${PI_PATH}/database/autocore.db ./backups/${BACKUP_FILE}
        
        if [ -f "./backups/${BACKUP_FILE}" ]; then
            echo -e "${GREEN}✅ Backup salvo em: ./backups/${BACKUP_FILE}${NC}"
            ls -lh ./backups/${BACKUP_FILE}
        else
            echo -e "${RED}❌ Erro ao fazer backup${NC}"
        fi
        ;;
        
    *)
        echo -e "${RED}Opção inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}         Operação Concluída!         ${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Acesso Web:"
echo "  Config App: http://${PI_HOST}:8000"
echo "  Frontend: http://${PI_HOST}:3000"
echo ""
echo "SSH: ssh ${PI_USER}@${PI_HOST}"