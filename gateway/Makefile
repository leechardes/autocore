# AutoCore Gateway - Makefile
# Automação para setup, desenvolvimento e deploy

.PHONY: help venv install dev test lint clean start stop status logs backup

# Carregar variáveis do .env se existir
ifneq (,$(wildcard .env))
    include .env
    export
endif

# Variáveis
VENV_PATH := .venv
PYTHON := $(VENV_PATH)/bin/python
PIP := $(VENV_PATH)/bin/pip
ACTIVATE := source $(VENV_PATH)/bin/activate

# O Gateway não tem servidor HTTP, apenas cliente MQTT

# Cores para output
GREEN := \033[0;32m
YELLOW := \033[1;33m  
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m # No Color

help: ## Mostra ajuda com comandos disponíveis
	@echo -e "$(GREEN)AutoCore Gateway - Comandos Disponíveis:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(BLUE)  %-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

venv: ## Cria ambiente virtual Python
	@echo -e "$(GREEN)📦 Criando ambiente virtual...$(NC)"
	@python3 -m venv $(VENV_PATH)
	@$(ACTIVATE) && pip install --upgrade pip setuptools wheel
	@echo -e "$(GREEN)✅ Ambiente virtual criado em $(VENV_PATH)$(NC)"

install: venv ## Instala dependências
	@echo -e "$(GREEN)📥 Instalando dependências...$(NC)"
	@$(ACTIVATE) && $(PIP) install -r requirements.txt
	@echo -e "$(GREEN)✅ Dependências instaladas$(NC)"

dev: install ## Setup completo para desenvolvimento
	@echo -e "$(GREEN)🛠️ Configurando ambiente de desenvolvimento...$(NC)"
	@$(ACTIVATE) && $(PIP) install -r requirements.txt
	@if [ ! -f .env ]; then \
		echo -e "$(YELLOW)⚙️ Criando arquivo .env...$(NC)"; \
		cp .env.example .env; \
	fi
	@mkdir -p logs tmp
	@echo -e "$(GREEN)✅ Ambiente de desenvolvimento pronto$(NC)"
	@echo -e "$(BLUE)💡 Para ativar: source $(VENV_PATH)/bin/activate$(NC)"

test: ## Executa testes
	@echo -e "$(GREEN)🧪 Executando testes...$(NC)"
	@$(ACTIVATE) && python -m pytest tests/ -v --tb=short

lint: ## Executa linting e formatação
	@echo -e "$(GREEN)🔍 Executando linting...$(NC)"
	@$(ACTIVATE) && black src/ --check --diff
	@$(ACTIVATE) && pylint src/ --disable=missing-docstring

format: ## Formata código com black
	@echo -e "$(GREEN)✨ Formatando código...$(NC)"
	@$(ACTIVATE) && black src/

check: ## Verifica dependências e configuração
	@echo -e "$(GREEN)🔎 Verificando configuração...$(NC)"
	@echo -n "Python: "
	@python3 --version || echo -e "$(RED)❌ Python não encontrado$(NC)"
	@echo -n "Ambiente virtual: "
	@if [ -d "$(VENV_PATH)" ]; then \
		echo -e "$(GREEN)✅ $(VENV_PATH)$(NC)"; \
	else \
		echo -e "$(RED)❌ Não encontrado$(NC)"; \
	fi
	@echo -n "Database: "
	@if [ -f "../database/autocore.db" ]; then \
		echo -e "$(GREEN)✅ Encontrado$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠️ Não encontrado$(NC)"; \
	fi
	@echo -n "Arquivo .env: "
	@if [ -f ".env" ]; then \
		echo -e "$(GREEN)✅ Configurado$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠️ Não configurado$(NC)"; \
	fi

start: ## Inicia o Gateway
	@echo -e "$(GREEN)🚀 Iniciando AutoCore Gateway...$(NC)"
	@python3 run.py

start-bg: ## Inicia Gateway em background
	@echo -e "$(GREEN)🚀 Iniciando Gateway em background...$(NC)"
	@mkdir -p logs tmp
	@nohup python3 run.py > logs/gateway.log 2>&1 & echo $$! > tmp/gateway.pid
	@echo -e "$(GREEN)✅ Gateway iniciado (PID: $$(cat tmp/gateway.pid))$(NC)"

stop: ## Para o Gateway em background
	@if [ -f tmp/gateway.pid ]; then \
		echo -e "$(GREEN)📴 Parando Gateway...$(NC)"; \
		kill $$(cat tmp/gateway.pid) && rm tmp/gateway.pid; \
		echo -e "$(GREEN)✅ Gateway parado$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠️ Gateway não está rodando em background$(NC)"; \
	fi

status: ## Mostra status do Gateway
	@echo -e "$(GREEN)📊 Status do AutoCore Gateway:$(NC)"
	@if [ -f tmp/gateway.pid ]; then \
		PID=$$(cat tmp/gateway.pid); \
		if kill -0 $$PID 2>/dev/null; then \
			echo -e "$(GREEN)✅ Rodando (PID: $$PID)$(NC)"; \
		else \
			echo -e "$(RED)❌ Processo morto$(NC)"; \
			rm tmp/gateway.pid; \
		fi \
	else \
		echo -e "$(YELLOW)⚠️ Não está rodando em background$(NC)"; \
	fi
	@echo -n "Último log: "
	@if [ -f logs/gateway.log ]; then \
		tail -1 logs/gateway.log; \
	else \
		echo "Nenhum log encontrado"; \
	fi

logs: ## Mostra logs do Gateway
	@echo -e "$(GREEN)📋 Logs do AutoCore Gateway:$(NC)"
	@if [ -f logs/gateway.log ]; then \
		tail -f logs/gateway.log; \
	else \
		echo -e "$(YELLOW)⚠️ Arquivo de log não encontrado$(NC)"; \
	fi

clean: ## Remove arquivos temporários
	@echo -e "$(GREEN)🧹 Limpando arquivos temporários...$(NC)"
	@rm -rf __pycache__ src/__pycache__ src/core/__pycache__ src/services/__pycache__
	@rm -rf .pytest_cache
	@rm -rf tmp/*.pid
	@rm -rf logs/*.log.*
	@echo -e "$(GREEN)✅ Limpeza concluída$(NC)"

clean-all: clean ## Remove tudo (incluindo venv)
	@echo -e "$(YELLOW)⚠️ Removendo ambiente virtual...$(NC)"
	@rm -rf $(VENV_PATH)
	@echo -e "$(GREEN)✅ Limpeza completa$(NC)"

backup: ## Cria backup do Gateway
	@echo -e "$(GREEN)💾 Criando backup...$(NC)"
	@mkdir -p ../backups
	@tar -czf ../backups/gateway-backup-$$(date +%Y%m%d-%H%M%S).tar.gz \
		--exclude='.venv' --exclude='__pycache__' --exclude='logs' --exclude='tmp' \
		.
	@echo -e "$(GREEN)✅ Backup criado em ../backups/$(NC)"

docs: ## Abre documentação
	@echo -e "$(GREEN)📚 Abrindo documentação...$(NC)"
	@if command -v xdg-open > /dev/null; then \
		xdg-open docs/README.md; \
	elif command -v open > /dev/null; then \
		open docs/README.md; \
	else \
		echo -e "$(BLUE)📖 Documentação disponível em: docs/README.md$(NC)"; \
	fi

# Comandos de desenvolvimento
watch: ## Monitora mudanças e reinicia automaticamente
	@echo -e "$(GREEN)👀 Monitorando mudanças...$(NC)"
	@echo -e "$(BLUE)💡 Pressione Ctrl+C para parar$(NC)"
	@$(ACTIVATE) && python -m watchdog.shell-monitor src/ --wait --drop 'code' --command 'make start'

debug: ## Inicia Gateway em modo debug
	@echo -e "$(GREEN)🐛 Iniciando em modo debug...$(NC)"
	@LOG_LEVEL=DEBUG python3 run.py

# Comandos de manutenção
upgrade: ## Atualiza dependências
	@echo -e "$(GREEN)⬆️ Atualizando dependências...$(NC)"
	@$(ACTIVATE) && $(PIP) install --upgrade -r requirements.txt

# Comandos de sistema
install-system: ## Instala dependências do sistema (Ubuntu/Debian)
	@echo -e "$(GREEN)📦 Instalando dependências do sistema...$(NC)"
	@sudo apt-get update
	@sudo apt-get install -y python3-venv python3-pip mosquitto mosquitto-clients

# Default target
all: dev check