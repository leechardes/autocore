#!/bin/bash
# Setup all Python environments for AutoCore
# Otimizado para Raspberry Pi Zero 2W

set -e  # Exit on error

echo "🚀 AutoCore Environment Setup"
echo "============================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para criar venv otimizado
setup_venv() {
    local project=$1
    local path=$2
    
    echo -e "\n${YELLOW}📦 Configurando $project...${NC}"
    cd "$path"
    
    # Remove venv antigo se existir
    if [ -d ".venv" ]; then
        echo "  Removendo .venv antigo..."
        rm -rf .venv
    fi
    
    # Cria novo venv com otimizações
    echo "  Criando ambiente virtual..."
    python3 -m venv .venv --system-site-packages  # Usa pacotes do sistema quando possível
    
    # Ativa e instala
    echo "  Instalando dependências..."
    source .venv/bin/activate
    
    # Atualiza pip com cache
    pip install --upgrade pip wheel setuptools -q
    
    # Instala requirements com cache compartilhado
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt --cache-dir /tmp/pip-cache -q
        echo -e "  ${GREEN}✓ Dependências instaladas${NC}"
    else
        echo -e "  ${RED}⚠ requirements.txt não encontrado${NC}"
    fi
    
    deactivate
    
    # Cria arquivo de ativação rápida
    cat > activate.sh << 'EOF'
#!/bin/bash
# Quick activation script
source .venv/bin/activate
echo "🔧 Ambiente $(basename $(pwd)) ativado"
EOF
    chmod +x activate.sh
    
    echo -e "  ${GREEN}✓ $project configurado${NC}"
}

# Limpa cache anterior
echo "🧹 Limpando cache antigo..."
rm -rf /tmp/pip-cache
mkdir -p /tmp/pip-cache

# Setup cada projeto
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_venv "Database" "$BASE_DIR/database"
setup_venv "Gateway" "$BASE_DIR/gateway"
setup_venv "Config-App Backend" "$BASE_DIR/config-app/backend"

# Limpa cache após instalação
echo -e "\n🧹 Limpando cache temporário..."
rm -rf /tmp/pip-cache

# Estatísticas
echo -e "\n${GREEN}✅ Setup Completo!${NC}"
echo "============================="
echo "📊 Espaço usado pelos ambientes:"
du -sh */venv 2>/dev/null || du -sh */.venv 2>/dev/null

echo -e "\n💡 Para ativar um ambiente:"
echo "   cd [projeto] && source .venv/bin/activate"
echo "   ou use: ./activate.sh"

echo -e "\n🚀 Próximos passos:"
echo "   1. cd database && ./activate.sh"
echo "   2. python src/cli/manage.py init"
echo "   3. Configurar systemd services"