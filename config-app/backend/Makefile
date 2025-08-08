# Config-App Backend - Makefile
# API FastAPI para configuração do AutoCore

# Variáveis
PYTHON = python3
VENV = .venv
VENV_PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip
UVICORN = $(VENV)/bin/uvicorn

# Configurações da API
HOST = 0.0.0.0
PORT = 8000
WORKERS = 1

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.PHONY: help
help: ## Mostra este menu de ajuda
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     Config-App Backend - Makefile          ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Comandos disponíveis:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BLUE)Exemplos de uso:$(NC)"
	@echo "  make install    # Configura ambiente completo"
	@echo "  make run        # Executa API em modo desenvolvimento"
	@echo "  make test       # Roda testes"

# ═══════════════════════════════════════════════════════
# SETUP E INSTALAÇÃO
# ═══════════════════════════════════════════════════════

.PHONY: venv
venv: ## Cria ambiente virtual Python
	@echo "$(GREEN)🐍 Criando ambiente virtual...$(NC)"
	@$(PYTHON) -m venv $(VENV)
	@echo "✅ Ambiente virtual criado em $(VENV)"

.PHONY: install
install: venv ## Instala todas as dependências
	@echo "$(GREEN)📦 Instalando dependências...$(NC)"
	@$(PIP) install --upgrade pip
	@$(PIP) install -r requirements.txt
	@echo "✅ Dependências instaladas"
	@echo ""
	@echo "$(GREEN)📝 Configurando ambiente...$(NC)"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✅ Arquivo .env criado (edite conforme necessário)"; \
	else \
		echo "ℹ️  Arquivo .env já existe"; \
	fi

.PHONY: install-dev
install-dev: install ## Instala dependências + ferramentas de dev
	@echo "$(GREEN)🔧 Instalando ferramentas de desenvolvimento...$(NC)"
	@$(PIP) install black flake8 pytest-cov ipython
	@echo "✅ Ferramentas de dev instaladas"

# ═══════════════════════════════════════════════════════
# EXECUÇÃO
# ═══════════════════════════════════════════════════════

.PHONY: run
run: ## Executa API em modo desenvolvimento (com reload)
	@echo "$(GREEN)🚀 Iniciando API em modo desenvolvimento...$(NC)"
	@echo "📡 API disponível em: http://$(HOST):$(PORT)"
	@echo "📚 Documentação em: http://$(HOST):$(PORT)/docs"
	@echo ""
	@$(VENV_PYTHON) main.py

.PHONY: run-prod
run-prod: ## Executa API em modo produção (sem reload)
	@echo "$(GREEN)🚀 Iniciando API em modo produção...$(NC)"
	@$(UVICORN) main:app --host $(HOST) --port $(PORT) --workers $(WORKERS)

.PHONY: run-debug
run-debug: ## Executa API com debug habilitado
	@echo "$(GREEN)🐛 Iniciando API em modo debug...$(NC)"
	@$(UVICORN) main:app --host $(HOST) --port $(PORT) --reload --log-level debug

# ═══════════════════════════════════════════════════════
# TESTES
# ═══════════════════════════════════════════════════════

.PHONY: test
test: ## Roda todos os testes
	@echo "$(GREEN)🧪 Rodando testes...$(NC)"
	@$(VENV_PYTHON) -m pytest tests/ -v

.PHONY: test-coverage
test-coverage: ## Roda testes com cobertura
	@echo "$(GREEN)📊 Rodando testes com cobertura...$(NC)"
	@$(VENV_PYTHON) -m pytest tests/ --cov=. --cov-report=html --cov-report=term

.PHONY: test-api
test-api: ## Testa endpoints da API manualmente
	@echo "$(GREEN)🔍 Testando endpoints...$(NC)"
	@echo "\n$(YELLOW)GET /$(NC)"
	@curl -s http://localhost:$(PORT)/ | python -m json.tool
	@echo "\n$(YELLOW)GET /api/status$(NC)"
	@curl -s http://localhost:$(PORT)/api/status | python -m json.tool
	@echo "\n$(YELLOW)GET /api/devices$(NC)"
	@curl -s http://localhost:$(PORT)/api/devices | python -m json.tool | head -20

# ═══════════════════════════════════════════════════════
# QUALIDADE DE CÓDIGO
# ═══════════════════════════════════════════════════════

.PHONY: format
format: ## Formata código com Black
	@echo "$(GREEN)🎨 Formatando código...$(NC)"
	@$(VENV)/bin/black . --exclude $(VENV)

.PHONY: lint
lint: ## Verifica código com Flake8
	@echo "$(GREEN)🔍 Verificando código...$(NC)"
	@$(VENV)/bin/flake8 . --exclude=$(VENV) --max-line-length=120

.PHONY: type-check
type-check: ## Verifica tipos com mypy
	@echo "$(GREEN)🔍 Verificando tipos...$(NC)"
	@$(VENV)/bin/mypy main.py --ignore-missing-imports

# ═══════════════════════════════════════════════════════
# DATABASE
# ═══════════════════════════════════════════════════════

.PHONY: db-check
db-check: ## Verifica conexão com database
	@echo "$(GREEN)🗄️ Verificando database...$(NC)"
	@$(VENV_PYTHON) -c "import sys; sys.path.append('../../database'); from shared.repositories import devices; print('✅ Database conectado'); print(f'📊 Dispositivos: {len(devices.get_all())}')"

.PHONY: db-init
db-init: ## Inicializa database (se necessário)
	@echo "$(GREEN)🗄️ Inicializando database...$(NC)"
	@cd ../../database && make init

# ═══════════════════════════════════════════════════════
# DOCUMENTAÇÃO
# ═══════════════════════════════════════════════════════

.PHONY: docs
docs: ## Abre documentação da API no browser
	@echo "$(GREEN)📚 Abrindo documentação...$(NC)"
	@open http://localhost:$(PORT)/docs || xdg-open http://localhost:$(PORT)/docs

.PHONY: redoc
redoc: ## Abre ReDoc da API no browser
	@echo "$(GREEN)📚 Abrindo ReDoc...$(NC)"
	@open http://localhost:$(PORT)/redoc || xdg-open http://localhost:$(PORT)/redoc

# ═══════════════════════════════════════════════════════
# DESENVOLVIMENTO
# ═══════════════════════════════════════════════════════

.PHONY: shell
shell: ## Abre shell Python com contexto da aplicação
	@echo "$(GREEN)🐍 Shell Python interativo...$(NC)"
	@$(VENV_PYTHON) -i -c "from main import *; import sys; sys.path.append('../../database'); from shared.repositories import *; print('📦 Contexto carregado: app, devices, relays, telemetry, events, config')"

.PHONY: watch
watch: ## Monitora logs em tempo real
	@echo "$(GREEN)👁️ Monitorando logs...$(NC)"
	@tail -f logs/*.log 2>/dev/null || echo "Nenhum log encontrado"

# ═══════════════════════════════════════════════════════
# LIMPEZA
# ═══════════════════════════════════════════════════════

.PHONY: clean
clean: ## Remove arquivos temporários
	@echo "$(GREEN)🧹 Limpando arquivos temporários...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete
	@find . -type f -name ".DS_Store" -delete
	@rm -rf .pytest_cache htmlcov .coverage
	@echo "✅ Arquivos temporários removidos"

.PHONY: clean-venv
clean-venv: ## Remove ambiente virtual
	@echo "$(RED)⚠️ Removendo ambiente virtual...$(NC)"
	@rm -rf $(VENV)
	@echo "✅ Ambiente virtual removido"

.PHONY: clean-all
clean-all: clean clean-venv ## Remove tudo (venv e temporários)
	@echo "$(GREEN)✅ Limpeza completa realizada$(NC)"

# ═══════════════════════════════════════════════════════
# DEPLOY
# ═══════════════════════════════════════════════════════

.PHONY: deploy-check
deploy-check: ## Verifica se está pronto para deploy
	@echo "$(GREEN)🚀 Verificando deploy readiness...$(NC)"
	@echo -n "✓ Requirements.txt existe: "; test -f requirements.txt && echo "OK" || echo "FALHOU"
	@echo -n "✓ .env.example existe: "; test -f .env.example && echo "OK" || echo "FALHOU"
	@echo -n "✓ main.py existe: "; test -f main.py && echo "OK" || echo "FALHOU"
	@echo -n "✓ Database acessível: "; $(VENV_PYTHON) -c "import sys; sys.path.append('../../database'); from shared.repositories import devices" 2>/dev/null && echo "OK" || echo "FALHOU"

.PHONY: deploy-systemd
deploy-systemd: ## Gera arquivo systemd service
	@echo "$(GREEN)📝 Gerando arquivo systemd...$(NC)"
	@echo "[Unit]" > config-app-backend.service
	@echo "Description=AutoCore Config API" >> config-app-backend.service
	@echo "After=network.target" >> config-app-backend.service
	@echo "" >> config-app-backend.service
	@echo "[Service]" >> config-app-backend.service
	@echo "Type=simple" >> config-app-backend.service
	@echo "User=pi" >> config-app-backend.service
	@echo "WorkingDirectory=$$(pwd)" >> config-app-backend.service
	@echo "Environment=\"PATH=$$(pwd)/$(VENV)/bin\"" >> config-app-backend.service
	@echo "ExecStart=$$(pwd)/$(VENV)/bin/uvicorn main:app --host 0.0.0.0 --port 8000" >> config-app-backend.service
	@echo "Restart=on-failure" >> config-app-backend.service
	@echo "" >> config-app-backend.service
	@echo "[Install]" >> config-app-backend.service
	@echo "WantedBy=multi-user.target" >> config-app-backend.service
	@echo "✅ Arquivo config-app-backend.service criado"
	@echo "   Para instalar: sudo cp config-app-backend.service /etc/systemd/system/"
	@echo "   Para habilitar: sudo systemctl enable config-app-backend"
	@echo "   Para iniciar: sudo systemctl start config-app-backend"

# ═══════════════════════════════════════════════════════
# ATALHOS ÚTEIS
# ═══════════════════════════════════════════════════════

.PHONY: dev
dev: install run ## Setup e executa em modo dev

.PHONY: prod
prod: install run-prod ## Setup e executa em modo produção

.PHONY: reset
reset: clean-all install ## Reset completo do ambiente

.PHONY: check
check: lint test ## Verifica qualidade (lint + test)

# Default target
.DEFAULT_GOAL := help