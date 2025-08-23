#!/bin/bash

# Script para configurar ambiente Python com autocompletar e Black

echo "🐍 Configurando ambiente Python..."

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Diretório do projeto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo -e "${BLUE}📁 Diretório do projeto: $PROJECT_DIR${NC}"

# Criar ambiente virtual se não existir
if [ ! -d ".venv" ]; then
    echo -e "${YELLOW}🔨 Criando ambiente virtual...${NC}"
    python3 -m venv .venv
    echo -e "${GREEN}✅ Ambiente virtual criado${NC}"
else
    echo -e "${GREEN}✅ Ambiente virtual já existe${NC}"
fi

# Ativar ambiente virtual
echo -e "${YELLOW}🔌 Ativando ambiente virtual...${NC}"
source .venv/bin/activate

# Atualizar pip
echo -e "${YELLOW}📦 Atualizando pip...${NC}"
pip install --upgrade pip

# Instalar dependências de desenvolvimento
if [ -f "requirements-dev.txt" ]; then
    echo -e "${YELLOW}📚 Instalando ferramentas de desenvolvimento...${NC}"
    pip install -r requirements-dev.txt
    echo -e "${GREEN}✅ Ferramentas instaladas${NC}"
fi

# Instalar dependências do projeto (se existir)
if [ -f "requirements.txt" ]; then
    echo -e "${YELLOW}📚 Instalando dependências do projeto...${NC}"
    pip install -r requirements.txt
    echo -e "${GREEN}✅ Dependências instaladas${NC}"
fi

# Criar arquivo de exemplo para testar
echo -e "${YELLOW}📝 Criando arquivo de exemplo...${NC}"
cat > scripts/example_unformatted.py << 'EOF'
import os,sys
from datetime import datetime
import json


def hello_world(  name: str,age:int   ):
    """This is a test function"""
    x=1
    y=2
    if x==1:
        print(f"Hello {name}, you are {age} years old")
        data={'name':name,'age':age,'timestamp':datetime.now().isoformat()}
        return data
    else:
        return None

class   TestClass:
    def __init__(self,value):
        self.value=value
    
    def get_value(self):
        return self.value

if __name__=="__main__":
    result=hello_world("Python",30)
    print(result)
EOF

echo -e "${GREEN}✅ Arquivo exemplo criado: scripts/example_unformatted.py${NC}"

# Demonstrar Black
echo -e "\n${BLUE}🎨 Demonstrando Black formatter...${NC}"
echo -e "${YELLOW}Antes da formatação:${NC}"
head -n 10 scripts/example_unformatted.py

echo -e "\n${YELLOW}Aplicando Black...${NC}"
black scripts/example_unformatted.py

echo -e "\n${GREEN}Depois da formatação:${NC}"
head -n 15 scripts/example_unformatted.py

# Configurar git hooks (opcional)
echo -e "\n${YELLOW}🔧 Configurando git hooks para Black...${NC}"
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Formatar arquivos Python antes do commit

FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep '\.py$')
if [ -n "$FILES" ]; then
    source .venv/bin/activate 2>/dev/null
    black $FILES
    git add $FILES
fi
EOF
chmod +x .git/hooks/pre-commit
echo -e "${GREEN}✅ Git hook configurado${NC}"

echo -e "\n${GREEN}🎉 Configuração concluída!${NC}"
echo -e "\n${BLUE}📚 Comandos úteis:${NC}"
echo -e "  ${YELLOW}black .${NC}              - Formatar todos os arquivos Python"
echo -e "  ${YELLOW}black --check .${NC}      - Verificar formatação sem alterar"
echo -e "  ${YELLOW}pylint scripts/*.py${NC}  - Verificar qualidade do código"
echo -e "  ${YELLOW}isort .${NC}              - Organizar imports"
echo -e "  ${YELLOW}mypy scripts/${NC}        - Verificar tipos"

echo -e "\n${BLUE}💡 Dicas:${NC}"
echo -e "  - O VS Code formatará automaticamente ao salvar"
echo -e "  - Use ${YELLOW}source .venv/bin/activate${NC} para ativar o ambiente"
echo -e "  - Black usa linha de 88 caracteres por padrão"