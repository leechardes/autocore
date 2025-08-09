#!/bin/bash
# Deploy script for AutoCore services
# Permite deploy independente de cada serviço

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função de ajuda
show_help() {
    echo "Usage: $0 [service] [action]"
    echo ""
    echo "Services:"
    echo "  all         - Todos os serviços"
    echo "  gateway     - Apenas Gateway MQTT"
    echo "  config-app  - Apenas Config App"
    echo "  database    - Apenas Database (migrations)"
    echo ""
    echo "Actions:"
    echo "  deploy      - Atualiza e reinicia"
    echo "  update      - Apenas atualiza código"
    echo "  restart     - Apenas reinicia"
    echo "  status      - Mostra status"
    echo ""
    echo "Examples:"
    echo "  $0 gateway deploy    # Deploy apenas do gateway"
    echo "  $0 all status        # Status de todos"
    exit 1
}

# Valida argumentos
if [ $# -lt 2 ]; then
    show_help
fi

SERVICE=$1
ACTION=$2
BASE_DIR="/opt/autocore"

# Função para deploy de um serviço
deploy_service() {
    local service=$1
    local path=$2
    local systemd_service=$3
    
    echo -e "${BLUE}🚀 Deploying $service...${NC}"
    
    # Pull do código
    cd "$path"
    echo "  📥 Atualizando código..."
    git pull origin main
    
    # Atualiza dependências no venv isolado
    echo "  📦 Atualizando dependências..."
    source .venv/bin/activate
    pip install -r requirements.txt --upgrade -q
    deactivate
    
    # Reinicia serviço
    echo "  🔄 Reiniciando serviço..."
    sudo systemctl restart $systemd_service
    
    # Verifica status
    sleep 2
    if sudo systemctl is-active --quiet $systemd_service; then
        echo -e "  ${GREEN}✓ $service rodando${NC}"
    else
        echo -e "  ${RED}✗ $service falhou${NC}"
        sudo systemctl status $systemd_service --no-pager -l
        exit 1
    fi
}

# Função para update sem restart
update_service() {
    local service=$1
    local path=$2
    
    echo -e "${BLUE}🔄 Updating $service...${NC}"
    
    cd "$path"
    git pull origin main
    
    source .venv/bin/activate
    pip install -r requirements.txt --upgrade -q
    deactivate
    
    echo -e "  ${GREEN}✓ $service atualizado (restart manual necessário)${NC}"
}

# Função para mostrar status
show_status() {
    local service=$1
    echo -e "${BLUE}📊 Status: $service${NC}"
    sudo systemctl status $service --no-pager -n 10
    echo ""
}

# Executa ação baseada nos parâmetros
case "$SERVICE" in
    gateway)
        case "$ACTION" in
            deploy)
                deploy_service "Gateway" "$BASE_DIR/gateway" "autocore-gateway"
                ;;
            update)
                update_service "Gateway" "$BASE_DIR/gateway"
                ;;
            restart)
                sudo systemctl restart autocore-gateway
                echo -e "${GREEN}✓ Gateway reiniciado${NC}"
                ;;
            status)
                show_status "autocore-gateway"
                ;;
            *)
                show_help
                ;;
        esac
        ;;
        
    config-app)
        case "$ACTION" in
            deploy)
                deploy_service "Config App" "$BASE_DIR/config-app/backend" "autocore-config-app"
                ;;
            update)
                update_service "Config App" "$BASE_DIR/config-app/backend"
                ;;
            restart)
                sudo systemctl restart autocore-config-app
                echo -e "${GREEN}✓ Config App reiniciado${NC}"
                ;;
            status)
                show_status "autocore-config-app"
                ;;
            *)
                show_help
                ;;
        esac
        ;;
        
    database)
        case "$ACTION" in
            deploy|update)
                echo -e "${BLUE}🗓️ Atualizando Database...${NC}"
                cd "$BASE_DIR/database"
                git pull origin main
                source .venv/bin/activate
                
                # Aplica migrations
                echo "  🔄 Aplicando migrations..."
                python src/cli/manage.py migrate
                
                deactivate
                echo -e "${GREEN}✓ Database atualizado${NC}"
                ;;
            status)
                cd "$BASE_DIR/database"
                source .venv/bin/activate
                python src/cli/manage.py status
                deactivate
                ;;
            *)
                show_help
                ;;
        esac
        ;;
        
    all)
        case "$ACTION" in
            deploy)
                # Deploy em ordem: database -> gateway -> config-app
                $0 database deploy
                $0 gateway deploy
                $0 config-app deploy
                ;;
            status)
                $0 database status
                $0 gateway status
                $0 config-app status
                ;;
            restart)
                sudo systemctl restart autocore-gateway autocore-config-app
                echo -e "${GREEN}✓ Todos os serviços reiniciados${NC}"
                ;;
            *)
                show_help
                ;;
        esac
        ;;
        
    *)
        show_help
        ;;
esac

echo -e "\n${GREEN}✅ Operação completa!${NC}"