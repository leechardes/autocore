# AutoCore Database - Makefile
# Comandos simplificados para gerenciamento do banco de dados

# Carregar variáveis do .env se existir
ifneq (,$(wildcard .env))
    include .env
    export
endif

# Variáveis
PYTHON = python3
VENV = .venv
VENV_PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip
DB_FILE = autocore.db

# Configurações (com valores padrão se não estiverem no .env)
DATABASE_PATH ?= autocore.db

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.PHONY: help
help: ## Mostra este menu de ajuda
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║       AutoCore Database - Makefile         ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Comandos disponíveis:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BLUE)Exemplos de uso:$(NC)"
	@echo "  make install    # Configura ambiente completo"
	@echo "  make init       # Inicializa banco com seeds"
	@echo "  make test       # Testa repositories"
	@echo "  make clean      # Remove arquivos temporários"

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

.PHONY: install-dev
install-dev: install ## Instala dependências + ferramentas de dev
	@echo "$(GREEN)🔧 Instalando ferramentas de desenvolvimento...$(NC)"
	@$(PIP) install black flake8 pytest ipython
	@echo "✅ Ferramentas de dev instaladas"

# ═══════════════════════════════════════════════════════
# BANCO DE DADOS
# ═══════════════════════════════════════════════════════

.PHONY: init
init: ## Inicializa banco com estrutura e seeds
	@echo "$(GREEN)🚀 Inicializando banco de dados...$(NC)"
	@$(VENV_PYTHON) src/cli/init_database.py --reset --seeds

.PHONY: init-clean
init-clean: ## Inicializa banco vazio (sem seeds)
	@echo "$(GREEN)🗄️ Criando banco vazio...$(NC)"
	@$(VENV_PYTHON) src/cli/init_database.py --reset

.PHONY: seed
seed: ## Aplica seeds de desenvolvimento
	@echo "$(GREEN)🌱 Aplicando seeds...$(NC)"
	@$(VENV_PYTHON) seeds/seed_development.py

.PHONY: migrate
migrate: ## Aplica migrations pendentes
	@echo "$(GREEN)🔄 Aplicando migrations...$(NC)"
	@$(VENV_PYTHON) src/migrations/auto_migrate.py apply

.PHONY: migrate-generate
migrate-generate: ## Gera nova migration baseada nos models
	@echo "$(GREEN)📝 Gerando migration...$(NC)"
	@read -p "Descrição da migration: " desc; \
	$(VENV_PYTHON) src/migrations/auto_migrate.py generate -m "$$desc"

.PHONY: migrate-auto
migrate-auto: ## Gera e aplica migration automaticamente
	@echo "$(GREEN)🔄 Auto-migration...$(NC)"
	@read -p "Descrição da mudança: " desc; \
	$(VENV_PYTHON) src/migrations/auto_migrate.py auto -m "$$desc"

# ═══════════════════════════════════════════════════════
# TESTES E VALIDAÇÃO
# ═══════════════════════════════════════════════════════

.PHONY: test
test: ## Testa todos os repositories
	@echo "$(GREEN)🧪 Testando repositories...$(NC)"
	@$(VENV_PYTHON) scripts/test_repositories.py

.PHONY: check-integrity
check-integrity: ## Verifica integridade do banco
	@echo "$(GREEN)🔍 Verificando integridade...$(NC)"
	@sqlite3 $(DB_FILE) "PRAGMA integrity_check"

.PHONY: status
status: ## Mostra status do banco
	@echo "$(GREEN)📊 Status do banco...$(NC)"
	@$(VENV_PYTHON) src/cli/manage.py status

.PHONY: console
console: ## Abre console SQL interativo
	@echo "$(GREEN)🖥️ Console SQL...$(NC)"
	@sqlite3 $(DB_FILE)

.PHONY: python-console
python-console: ## Abre console Python com repositories
	@echo "$(GREEN)🐍 Console Python interativo...$(NC)"
	@$(VENV_PYTHON) -i -c "from shared.repositories import *; print('📦 Repositories carregados: devices, relays, telemetry, events, config')"

# ═══════════════════════════════════════════════════════
# MANUTENÇÃO
# ═══════════════════════════════════════════════════════

.PHONY: maintenance
maintenance: ## Executa manutenção completa
	@echo "$(GREEN)🧹 Manutenção completa...$(NC)"
	@$(VENV_PYTHON) scripts/maintenance.py full

.PHONY: maintenance-clean
maintenance-clean: ## Limpa dados antigos (7 dias)
	@echo "$(GREEN)🗑️ Limpando dados antigos...$(NC)"
	@$(VENV_PYTHON) scripts/maintenance.py clean

.PHONY: vacuum
vacuum: ## Desfragmenta banco (VACUUM)
	@echo "$(GREEN)📦 Desfragmentando banco...$(NC)"
	@sqlite3 $(DB_FILE) "VACUUM"

.PHONY: analyze
analyze: ## Analisa e otimiza índices
	@echo "$(GREEN)📈 Analisando banco...$(NC)"
	@sqlite3 $(DB_FILE) "ANALYZE"

.PHONY: stats
stats: ## Mostra estatísticas detalhadas
	@echo "$(GREEN)📊 Estatísticas...$(NC)"
	@$(VENV_PYTHON) scripts/maintenance.py stats

# ═══════════════════════════════════════════════════════
# BACKUP E RESTORE
# ═══════════════════════════════════════════════════════

.PHONY: backup
backup: ## Cria backup do banco
	@echo "$(GREEN)💾 Criando backup...$(NC)"
	@mkdir -p backups
	@cp $(DB_FILE) backups/autocore_$$(date +%Y%m%d_%H%M%S).db
	@gzip backups/autocore_$$(date +%Y%m%d_%H%M%S).db
	@echo "✅ Backup criado em backups/"

.PHONY: restore
restore: ## Restaura último backup
	@echo "$(YELLOW)⚠️ Restaurando backup...$(NC)"
	@echo "Backups disponíveis:"
	@ls -la backups/*.gz 2>/dev/null || echo "Nenhum backup encontrado"
	@read -p "Nome do arquivo (sem path): " file; \
	gunzip -c backups/$$file > $(DB_FILE).tmp && \
	mv $(DB_FILE).tmp $(DB_FILE) && \
	echo "✅ Backup restaurado"

# ═══════════════════════════════════════════════════════
# DESENVOLVIMENTO
# ═══════════════════════════════════════════════════════

.PHONY: format
format: ## Formata código com Black
	@echo "$(GREEN)🎨 Formatando código...$(NC)"
	@$(VENV)/bin/black src/ shared/ scripts/ seeds/

.PHONY: lint
lint: ## Verifica código com Flake8
	@echo "$(GREEN)🔍 Verificando código...$(NC)"
	@$(VENV)/bin/flake8 src/ shared/ scripts/ seeds/ --max-line-length=120

.PHONY: watch
watch: ## Monitora mudanças no banco (tail logs)
	@echo "$(GREEN)👁️ Monitorando eventos...$(NC)"
	@watch -n 1 "sqlite3 $(DB_FILE) 'SELECT * FROM event_logs ORDER BY timestamp DESC LIMIT 10'"

# ═══════════════════════════════════════════════════════
# LIMPEZA
# ═══════════════════════════════════════════════════════

.PHONY: clean
clean: ## Remove arquivos temporários
	@echo "$(GREEN)🧹 Limpando arquivos temporários...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete
	@find . -type f -name ".DS_Store" -delete
	@echo "✅ Arquivos temporários removidos"

.PHONY: clean-db
clean-db: ## Remove banco de dados
	@echo "$(RED)⚠️ Removendo banco de dados...$(NC)"
	@read -p "Tem certeza? (y/N): " confirm; \
	if [ "$$confirm" = "y" ]; then \
		rm -f $(DB_FILE) $(DB_FILE)-journal $(DB_FILE)-wal $(DB_FILE)-shm; \
		echo "✅ Banco removido"; \
	else \
		echo "❌ Cancelado"; \
	fi

.PHONY: clean-all
clean-all: clean ## Remove tudo (venv, banco, temps)
	@echo "$(RED)⚠️ Limpeza completa...$(NC)"
	@read -p "Remove venv e banco? (y/N): " confirm; \
	if [ "$$confirm" = "y" ]; then \
		rm -rf $(VENV); \
		rm -f $(DB_FILE) $(DB_FILE)-journal $(DB_FILE)-wal $(DB_FILE)-shm; \
		echo "✅ Limpeza completa"; \
	else \
		echo "❌ Cancelado"; \
	fi

# ═══════════════════════════════════════════════════════
# ATALHOS ÚTEIS
# ═══════════════════════════════════════════════════════

.PHONY: quick-start
quick-start: install init test ## Setup completo rápido
	@echo "$(GREEN)✅ Setup completo finalizado!$(NC)"

.PHONY: reset
reset: clean-db init ## Reset completo do banco
	@echo "$(GREEN)✅ Banco resetado com sucesso!$(NC)"

.PHONY: dev
dev: install-dev format lint test ## Ambiente de desenvolvimento
	@echo "$(GREEN)✅ Ambiente de desenvolvimento pronto!$(NC)"

# ═══════════════════════════════════════════════════════
# DOCKER (futuro)
# ═══════════════════════════════════════════════════════

.PHONY: docker-build
docker-build: ## Build imagem Docker (futuro)
	@echo "$(YELLOW)🐳 Docker support em breve...$(NC)"

.PHONY: docker-run
docker-run: ## Roda container Docker (futuro)
	@echo "$(YELLOW)🐳 Docker support em breve...$(NC)"

# Default target
.DEFAULT_GOAL := help