#!/bin/bash

# setup_env.sh - Configura o ambiente Python para os scripts
# O .venv deve estar na raiz do projeto AutoCore

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
VENV_PATH="$PROJECT_ROOT/.venv"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}AutoCore - Setup Python Environment${NC}"
echo "Project root: $PROJECT_ROOT"
echo "Virtual env: $VENV_PATH"

# Verifica se o .venv existe na raiz do projeto
if [ ! -d "$VENV_PATH" ]; then
    echo -e "${YELLOW}Virtual environment não encontrado em $VENV_PATH${NC}"
    echo "Criando ambiente virtual..."
    python3 -m venv "$VENV_PATH"
    echo -e "${GREEN}✓ Ambiente virtual criado${NC}"
fi

# Ativa o ambiente virtual
echo "Ativando ambiente virtual..."
source "$VENV_PATH/bin/activate"

# Atualiza pip
echo "Atualizando pip..."
pip install --upgrade pip --quiet

# Instala dependências
echo "Instalando dependências..."
pip install -r "$SCRIPT_DIR/requirements.txt" --quiet

echo -e "${GREEN}✓ Ambiente configurado com sucesso!${NC}"
echo ""
echo "Para usar os scripts Python:"
echo "  1. Ative o ambiente: source $VENV_PATH/bin/activate"
echo "  2. Execute o script: python <script>.py"
echo ""
echo "Ou execute diretamente:"
echo "  $VENV_PATH/bin/python <script>.py"