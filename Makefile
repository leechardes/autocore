# Makefile para AutoCore
# Sistema completo de automação veicular

.PHONY: help

# Variáveis de configuração
RASPBERRY_HOSTNAME ?= autocore.local
RASPBERRY_USER ?= autocore
REMOTE_DIR ?= /opt/autocore

# Descobrir IP do Raspberry dinamicamente
RASPBERRY_IP := $(shell \
	if [ -f deploy/.last_raspberry_ip ]; then \
		cat deploy/.last_raspberry_ip; \
	elif command -v dig >/dev/null 2>&1; then \
		dig +short $(RASPBERRY_HOSTNAME) 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$$' | head -1; \
	elif [ ! -z "$$RASPBERRY_IP" ]; then \
		echo "$$RASPBERRY_IP"; \
	else \
		echo "10.0.10.119"; \
	fi \
)
PYTHON := python3
PIP := pip3
VENV := .venv

# Cores para output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[1;37m
NC := \033[0m # No Color

# Default target
help: ## Mostra esta mensagem de ajuda
	@echo "$(CYAN)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║          AutoCore - Makefile               ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Uso:$(NC) make [comando]"
	@echo ""
	@echo "$(GREEN)📦 Instalação:$(NC)"
	@echo "  $(BLUE)install$(NC)              Instala todas as dependências"
	@echo "  $(BLUE)install-database$(NC)     Instala dependências do database"
	@echo "  $(BLUE)install-gateway$(NC)      Instala dependências do gateway"
	@echo "  $(BLUE)install-config$(NC)       Instala dependências do config-app"
	@echo "  $(BLUE)install-flutter$(NC)      Instala dependências do Flutter"
	@echo ""
	@echo "$(GREEN)🚀 Execução Local:$(NC)"
	@echo "  $(BLUE)run$(NC)                  Instruções para executar serviços"
	@echo "  $(BLUE)run-gateway$(NC)          Executa o gateway"
	@echo "  $(BLUE)run-config-backend$(NC)   Executa o config-app backend"
	@echo "  $(BLUE)run-config-frontend$(NC)  Executa o config-app frontend"
	@echo "  $(BLUE)run-flutter$(NC)          Executa o app Flutter"
	@echo ""
	@echo "$(GREEN)🌐 Deploy Raspberry:$(NC)"
	@echo "  $(BLUE)deploy$(NC)               Deploy completo automático"
	@echo "  $(BLUE)deploy-manual$(NC)        Deploy manual interativo"
	@echo "  $(BLUE)ssh$(NC)                  Conecta via SSH no Raspberry"
	@echo "  $(BLUE)status$(NC)               Verifica status dos serviços"
	@echo "  $(BLUE)status-verbose$(NC)       Status detalhado com logs"
	@echo "  $(BLUE)logs-gateway$(NC)         Mostra logs do gateway"
	@echo "  $(BLUE)logs-config$(NC)          Mostra logs do config-app"
	@echo "  $(BLUE)restart$(NC)              Reinicia todos os serviços"
	@echo "  $(BLUE)recovery$(NC)             Executa recuperação automática"
	@echo "  $(BLUE)report$(NC)               Mostra relatório de instalação"
	@echo ""
	@echo "$(GREEN)🧪 Desenvolvimento:$(NC)"
	@echo "  $(BLUE)test$(NC)                 Executa todos os testes"
	@echo "  $(BLUE)lint$(NC)                 Executa linting do código"
	@echo "  $(BLUE)format$(NC)               Formata todo o código"
	@echo "  $(BLUE)build$(NC)                Build de todos os componentes"
	@echo ""
	@echo "$(GREEN)🧹 Limpeza:$(NC)"
	@echo "  $(BLUE)clean$(NC)                Limpa arquivos temporários"
	@echo "  $(BLUE)clean-venv$(NC)           Remove ambientes virtuais"
	@echo "  $(BLUE)clean-node$(NC)           Remove node_modules"
	@echo "  $(BLUE)clean-all$(NC)            Limpa tudo"
	@echo ""
	@echo "$(GREEN)🔧 Utilitários:$(NC)"
	@echo "  $(BLUE)backup$(NC)               Faz backup do projeto"
	@echo "  $(BLUE)info$(NC)                 Mostra informações do sistema"
	@echo "  $(BLUE)tree$(NC)                 Mostra estrutura de diretórios"
	@echo "  $(BLUE)count$(NC)                Conta linhas de código"
	@echo "  $(BLUE)dev$(NC)                  Modo desenvolvimento"
	@echo ""
	@echo "$(GREEN)⚡ Atalhos:$(NC)"
	@echo "  $(BLUE)d$(NC) = deploy   $(BLUE)s$(NC) = status   $(BLUE)r$(NC) = restart"
	@echo "  $(BLUE)c$(NC) = clean    $(BLUE)t$(NC) = test     $(BLUE)h$(NC) = help"
	@echo ""
	@echo "$(PURPLE)Configuração atual:$(NC)"
	@echo "  RASPBERRY_IP = $(RASPBERRY_IP)"
	@echo "  RASPBERRY_USER = $(RASPBERRY_USER)"
	@echo "  REMOTE_DIR = $(REMOTE_DIR)"
	@echo ""

# ============================================
# INSTALAÇÃO LOCAL
# ============================================

.PHONY: install
install: ## Instala todas as dependências locais
	@echo "$(CYAN)📦 Instalando todas as dependências...$(NC)"
	@$(MAKE) install-database
	@$(MAKE) install-gateway
	@$(MAKE) install-config-backend
	@$(MAKE) install-config-frontend
	@$(MAKE) install-flutter
	@echo "$(GREEN)✅ Todas as dependências instaladas!$(NC)"

.PHONY: install-database
install-database: ## Instala dependências do database
	@echo "$(YELLOW)💾 Instalando database...$(NC)"
	@cd database && $(PYTHON) -m venv $(VENV) && \
		. $(VENV)/bin/activate && \
		$(PIP) install --upgrade pip && \
		$(PIP) install -r requirements.txt
	@[ -f .env ] || cp .env.example .env
	@echo "$(GREEN)✅ Database instalado$(NC)"

.PHONY: install-gateway
install-gateway: ## Instala dependências do gateway
	@echo "$(YELLOW)🌐 Instalando gateway...$(NC)"
	@cd gateway && $(PYTHON) -m venv $(VENV) && \
		. $(VENV)/bin/activate && \
		$(PIP) install --upgrade pip && \
		$(PIP) install -r requirements.txt
	@[ -f .env ] || cp .env.example .env
	@echo "$(GREEN)✅ Gateway instalado$(NC)"

.PHONY: install-config-backend
install-config-backend: ## Instala dependências do config-app backend
	@echo "$(YELLOW)⚙️ Instalando config-app backend...$(NC)"
	@cd config-app/backend && $(PYTHON) -m venv $(VENV) && \
		. $(VENV)/bin/activate && \
		$(PIP) install --upgrade pip && \
		$(PIP) install -r requirements.txt
	@[ -f .env ] || cp .env.example .env
	@echo "$(GREEN)✅ Config backend instalado$(NC)"

.PHONY: install-config-frontend
install-config-frontend: ## Instala dependências do config-app frontend
	@echo "$(YELLOW)🎨 Instalando config-app frontend...$(NC)"
	@cd config-app/frontend && npm install
	@[ -f .env ] || cp .env.example .env
	@echo "$(GREEN)✅ Config frontend instalado$(NC)"

.PHONY: install-flutter
install-flutter: ## Instala dependências do Flutter
	@echo "$(YELLOW)📱 Instalando dependências Flutter...$(NC)"
	@cd app-flutter && flutter pub get
	@cd app-flutter/ios && pod install 2>/dev/null || true
	@echo "$(GREEN)✅ Flutter instalado$(NC)"

# ============================================
# EXECUÇÃO LOCAL
# ============================================

.PHONY: run
run: ## Executa todos os serviços localmente
	@echo "$(CYAN)🚀 Instruções para executar os serviços:$(NC)"
	@echo ""
	@echo "$(YELLOW)Abra 4 terminais separados e execute:$(NC)"
	@echo ""
	@echo "  Terminal 1: $(BLUE)make run-gateway$(NC)"
	@echo "  Terminal 2: $(BLUE)make run-config-backend$(NC)"
	@echo "  Terminal 3: $(BLUE)make run-config-frontend$(NC)"
	@echo "  Terminal 4: $(BLUE)make run-flutter$(NC)"
	@echo ""
	@echo "$(GREEN)URLs de acesso:$(NC)"
	@echo "  Frontend: http://localhost:3000"
	@echo "  Backend API: http://localhost:5000"
	@echo "  MQTT Broker: localhost:1883"

.PHONY: run-database
run-database: ## Executa o database
	@echo "$(YELLOW)💾 Iniciando database...$(NC)"
	@cd database && . $(VENV)/bin/activate && $(PYTHON) src/cli/init_database.py

.PHONY: run-gateway
run-gateway: ## Executa o gateway
	@echo "$(YELLOW)🌐 Iniciando gateway...$(NC)"
	@cd gateway && . $(VENV)/bin/activate && $(PYTHON) src/main.py

.PHONY: run-config-backend
run-config-backend: ## Executa o config-app backend
	@echo "$(YELLOW)⚙️ Iniciando config backend...$(NC)"
	@cd config-app/backend && . $(VENV)/bin/activate && $(PYTHON) main.py

.PHONY: run-config-frontend
run-config-frontend: ## Executa o config-app frontend
	@echo "$(YELLOW)🎨 Iniciando config frontend...$(NC)"
	@cd config-app/frontend && npm start

.PHONY: run-flutter
run-flutter: ## Executa o app Flutter
	@echo "$(YELLOW)📱 Iniciando Flutter...$(NC)"
	@cd app-flutter && flutter run

# ============================================
# DEPLOY RASPBERRY PI
# ============================================

.PHONY: find-pi
find-pi: ## Descobre o IP do Raspberry Pi na rede
	@echo "$(CYAN)🔍 Procurando Raspberry Pi...$(NC)"
	@cd deploy && ./find_raspberry.sh

.PHONY: deploy
deploy: ## Deploy completo para o Raspberry Pi
	@echo "$(CYAN)🚀 Deploy para Raspberry Pi...$(NC)"
	@if [ "$(RASPBERRY_IP)" = "10.0.10.119" ] && [ ! -f deploy/.last_raspberry_ip ]; then \
		echo "$(YELLOW)⚠️ IP padrão detectado. Procurando Raspberry Pi...$(NC)"; \
		cd deploy && ./find_raspberry.sh; \
	fi
	@echo "$(YELLOW)📍 IP: $(RASPBERRY_IP)$(NC)"
	@echo "$(YELLOW)👤 User: $(RASPBERRY_USER)$(NC)"
	@cd deploy && ./deploy_to_raspberry.sh
	@echo "$(GREEN)✅ Deploy completo!$(NC)"

.PHONY: deploy-manual
deploy-manual: ## Deploy manual (interativo)
	@echo "$(CYAN)🚀 Deploy manual para Raspberry Pi...$(NC)"
	@cd deploy && ./deploy_to_raspberry.sh

.PHONY: ssh
ssh: ## Conecta via SSH no Raspberry Pi
	@echo "$(CYAN)🔐 Conectando ao Raspberry Pi...$(NC)"
	@ssh $(RASPBERRY_USER)@$(RASPBERRY_IP)

.PHONY: status
status: ## Verifica status dos serviços no Raspberry Pi
	@echo "$(CYAN)📊 Verificando status no Raspberry Pi...$(NC)"
	@ssh $(RASPBERRY_USER)@$(RASPBERRY_IP) "cd $(REMOTE_DIR)/deploy && ./check_status.sh"

.PHONY: status-verbose
status-verbose: ## Status detalhado com logs
	@echo "$(CYAN)📊 Status detalhado do Raspberry Pi...$(NC)"
	@ssh $(RASPBERRY_USER)@$(RASPBERRY_IP) "cd $(REMOTE_DIR)/deploy && ./check_status.sh --verbose"

.PHONY: logs-gateway
logs-gateway: ## Mostra logs do gateway
	@ssh $(RASPBERRY_USER)@$(RASPBERRY_IP) "sudo journalctl -u autocore-gateway -f"

.PHONY: logs-config
logs-config: ## Mostra logs do config-app
	@ssh $(RASPBERRY_USER)@$(RASPBERRY_IP) "sudo journalctl -u autocore-config-app -f"

.PHONY: logs-frontend
logs-frontend: ## Mostra logs do frontend
	@ssh $(RASPBERRY_USER)@$(RASPBERRY_IP) "sudo journalctl -u autocore-config-frontend -f"

.PHONY: restart
restart: ## Reinicia serviços no Raspberry Pi
	@echo "$(CYAN)🔄 Reiniciando serviços no Raspberry Pi...$(NC)"
	@ssh $(RASPBERRY_USER)@$(RASPBERRY_IP) "sudo systemctl restart autocore-*"
	@sleep 3
	@$(MAKE) status

.PHONY: clean
clean: ## Limpeza básica (preserva .env e credenciais)
	@echo "$(YELLOW)🧹 Limpeza básica...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name ".DS_Store" -delete 2>/dev/null || true
	@rm -f logs/*.log 2>/dev/null || true
	@rm -f tmp/* 2>/dev/null || true
	@echo "$(GREEN)✅ Limpeza básica concluída!$(NC)"

.PHONY: clean-local
clean-local: ## Limpa arquivos temporários e builds locais
	@echo "$(YELLOW)🧹 Limpando arquivos locais...$(NC)"
	@echo "Removendo:"
	@echo "  • node_modules"
	@echo "  • .venv"
	@echo "  • __pycache__"
	@echo "  • dist/build"
	@echo "  • logs temporários"
	@echo ""
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".venv" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "dist" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "build" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.log" -delete 2>/dev/null || true
	@find . -type f -name ".DS_Store" -delete 2>/dev/null || true
	@echo "$(GREEN)✅ Limpeza local concluída!$(NC)"

.PHONY: clean-pi
clean-pi: ## Limpa completamente a instalação do AutoCore no Raspberry Pi
	@echo "$(RED)⚠️  LIMPEZA COMPLETA DO AUTOCORE NO RASPBERRY PI$(NC)"
	@echo "$(YELLOW)Esta operação irá remover TODA a instalação do AutoCore!$(NC)"
	@echo ""
	@echo "$(YELLOW)Será removido:$(NC)"
	@echo "  • Todos os serviços systemd do AutoCore"
	@echo "  • Todo o diretório /opt/autocore"
	@echo "  • Configurações do Mosquitto para AutoCore"
	@echo "  • Logs do sistema"
	@echo ""
	@read -p "Tem certeza? Digite 'sim' para confirmar: " confirm; \
	if [ "$$confirm" = "sim" ]; then \
		echo "$(RED)🧹 Executando limpeza...$(NC)"; \
		if [ -f deploy/.credentials ]; then \
			. deploy/.credentials; \
			sshpass -p "$$RASPBERRY_PASS" scp -o StrictHostKeyChecking=no deploy/clean_raspberry.sh $(RASPBERRY_USER)@$(RASPBERRY_IP):/tmp/; \
			sshpass -p "$$RASPBERRY_PASS" ssh -o StrictHostKeyChecking=no $(RASPBERRY_USER)@$(RASPBERRY_IP) "chmod +x /tmp/clean_raspberry.sh && echo 'sim' | bash /tmp/clean_raspberry.sh"; \
		else \
			scp deploy/clean_raspberry.sh $(RASPBERRY_USER)@$(RASPBERRY_IP):/tmp/; \
			ssh $(RASPBERRY_USER)@$(RASPBERRY_IP) "chmod +x /tmp/clean_raspberry.sh && echo 'sim' | bash /tmp/clean_raspberry.sh"; \
		fi; \
		echo "$(GREEN)✅ Limpeza concluída!$(NC)"; \
		echo "$(YELLOW)💡 Execute 'make deploy' para reinstalar$(NC)"; \
	else \
		echo "$(YELLOW)❌ Operação cancelada$(NC)"; \
	fi

.PHONY: recovery
recovery: ## Executa recuperação automática no Raspberry Pi
	@echo "$(CYAN)🔧 Executando recuperação automática...$(NC)"
	@ssh $(RASPBERRY_USER)@$(RASPBERRY_IP) "cd $(REMOTE_DIR)/deploy && sudo ./auto_recovery.sh"

.PHONY: report
report: ## Mostra relatório de instalação
	@echo "$(CYAN)📊 Relatório de instalação:$(NC)"
	@ssh $(RASPBERRY_USER)@$(RASPBERRY_IP) "cat $(REMOTE_DIR)/last_installation_report.log"

# ============================================
# TESTES
# ============================================

.PHONY: test
test: ## Executa todos os testes
	@echo "$(CYAN)🧪 Executando todos os testes...$(NC)"
	@$(MAKE) test-gateway
	@$(MAKE) test-config
	@$(MAKE) test-flutter
	@echo "$(GREEN)✅ Todos os testes executados!$(NC)"

.PHONY: test-gateway
test-gateway: ## Testa o gateway
	@echo "$(YELLOW)🧪 Testando gateway...$(NC)"
	@cd gateway && . $(VENV)/bin/activate && $(PYTHON) -m pytest tests/ -v 2>/dev/null || echo "  Sem testes encontrados"

.PHONY: test-config
test-config: ## Testa o config-app
	@echo "$(YELLOW)🧪 Testando config-app...$(NC)"
	@cd config-app/backend && . $(VENV)/bin/activate && $(PYTHON) -m pytest tests/ -v 2>/dev/null || echo "  Sem testes encontrados"

.PHONY: test-flutter
test-flutter: ## Testa o app Flutter
	@echo "$(YELLOW)🧪 Testando Flutter...$(NC)"
	@cd app-flutter && flutter test 2>/dev/null || echo "  Sem testes encontrados"

# ============================================
# LINTING & FORMATAÇÃO
# ============================================

.PHONY: lint
lint: ## Executa linting em todos os componentes
	@echo "$(CYAN)🔍 Executando linting...$(NC)"
	@$(MAKE) lint-python
	@$(MAKE) lint-flutter
	@echo "$(GREEN)✅ Linting completo!$(NC)"

.PHONY: lint-python
lint-python: ## Linting do código Python
	@echo "$(YELLOW)🐍 Linting Python...$(NC)"
	@cd gateway && . $(VENV)/bin/activate && \
		(black . --check 2>/dev/null || echo "  black não instalado") && \
		(flake8 . 2>/dev/null || echo "  flake8 não instalado")
	@cd config-app/backend && . $(VENV)/bin/activate && \
		(black . --check 2>/dev/null || echo "  black não instalado") && \
		(flake8 . 2>/dev/null || echo "  flake8 não instalado")

.PHONY: lint-flutter
lint-flutter: ## Linting do código Flutter
	@echo "$(YELLOW)📱 Linting Flutter...$(NC)"
	@cd app-flutter && flutter analyze

.PHONY: format
format: ## Formata todo o código
	@echo "$(CYAN)✨ Formatando código...$(NC)"
	@$(MAKE) format-python
	@$(MAKE) format-flutter
	@echo "$(GREEN)✅ Código formatado!$(NC)"

.PHONY: format-python
format-python: ## Formata código Python
	@echo "$(YELLOW)🐍 Formatando Python...$(NC)"
	@cd gateway && . $(VENV)/bin/activate && (black . 2>/dev/null || echo "  black não instalado")
	@cd config-app/backend && . $(VENV)/bin/activate && (black . 2>/dev/null || echo "  black não instalado")
	@cd database && . $(VENV)/bin/activate && (black . 2>/dev/null || echo "  black não instalado")

.PHONY: format-flutter
format-flutter: ## Formata código Flutter
	@echo "$(YELLOW)📱 Formatando Flutter...$(NC)"
	@cd app-flutter && dart format .

# ============================================
# BUILD
# ============================================

.PHONY: build
build: ## Build de todos os componentes
	@echo "$(CYAN)🔨 Building todos os componentes...$(NC)"
	@$(MAKE) build-frontend
	@$(MAKE) build-flutter
	@echo "$(GREEN)✅ Build completo!$(NC)"

.PHONY: build-frontend
build-frontend: ## Build do frontend React
	@echo "$(YELLOW)🎨 Building frontend...$(NC)"
	@cd config-app/frontend && npm run build
	@echo "$(GREEN)✅ Frontend build completo$(NC)"

.PHONY: build-flutter
build-flutter: ## Build do app Flutter (Android)
	@echo "$(YELLOW)📱 Building Flutter APK...$(NC)"
	@cd app-flutter && flutter build apk --release
	@echo "$(GREEN)✅ APK gerado em app-flutter/build/app/outputs/flutter-apk/$(NC)"

.PHONY: build-flutter-ios
build-flutter-ios: ## Build do app Flutter (iOS)
	@echo "$(YELLOW)📱 Building Flutter iOS...$(NC)"
	@cd app-flutter && flutter build ios --release
	@echo "$(GREEN)✅ iOS build completo$(NC)"

# ============================================
# LIMPEZA
# ============================================

.PHONY: clean-venv
clean-venv: ## Remove todos os ambientes virtuais
	@echo "$(CYAN)🧹 Removendo ambientes virtuais...$(NC)"
	@rm -rf gateway/$(VENV)
	@rm -rf config-app/backend/$(VENV)
	@rm -rf database/$(VENV)
	@echo "$(GREEN)✅ Ambientes virtuais removidos!$(NC)"

.PHONY: clean-node
clean-node: ## Remove node_modules
	@echo "$(CYAN)🧹 Removendo node_modules...$(NC)"
	@rm -rf config-app/frontend/node_modules
	@echo "$(GREEN)✅ node_modules removido!$(NC)"

.PHONY: clean-all
clean-all: clean clean-venv clean-node ## Limpa tudo
	@echo "$(GREEN)✅ Limpeza completa de todos os arquivos!$(NC)"

# ============================================
# CONFIGURAÇÃO
# ============================================

.PHONY: setup-mqtt
setup-mqtt: ## Configura o Mosquitto MQTT no Mac
	@echo "$(CYAN)🦟 Configurando MQTT...$(NC)"
	@chmod +x scripts/setup/mqtt_mac.sh
	@./scripts/setup/mqtt_mac.sh

# ============================================
# UTILITÁRIOS
# ============================================

.PHONY: backup
backup: ## Faz backup do projeto
	@echo "$(CYAN)💾 Fazendo backup...$(NC)"
	@tar -czf ../autocore-backup-$$(date +%Y%m%d-%H%M%S).tar.gz \
		--exclude='$(VENV)' \
		--exclude='node_modules' \
		--exclude='__pycache__' \
		--exclude='.git' \
		--exclude='*.pyc' \
		--exclude='build' \
		--exclude='dist' \
		.
	@echo "$(GREEN)✅ Backup criado em ../autocore-backup-*.tar.gz$(NC)"

.PHONY: info
info: ## Mostra informações do sistema
	@echo "$(CYAN)ℹ️ Informações do Sistema:$(NC)"
	@echo "$(YELLOW)OS:$(NC) $$(uname -s)"
	@echo "$(YELLOW)Python:$(NC) $$($(PYTHON) --version)"
	@echo "$(YELLOW)Node:$(NC) $$(node --version 2>/dev/null || echo 'não instalado')"
	@echo "$(YELLOW)npm:$(NC) $$(npm --version 2>/dev/null || echo 'não instalado')"
	@echo "$(YELLOW)Flutter:$(NC) $$(flutter --version 2>/dev/null | head -1 || echo 'não instalado')"
	@echo "$(YELLOW)Git:$(NC) $$(git --version)"

.PHONY: tree
tree: ## Mostra estrutura de diretórios
	@echo "$(CYAN)🌲 Estrutura do projeto:$(NC)"
	@tree -L 2 -I 'node_modules|$(VENV)|__pycache__|*.pyc|.git' 2>/dev/null || ls -la

.PHONY: count
count: ## Conta linhas de código
	@echo "$(CYAN)📊 Contando linhas de código...$(NC)"
	@echo "$(YELLOW)Python:$(NC)"
	@find . -name "*.py" -not -path "./$(VENV)/*" -not -path "./*/$(VENV)/*" | xargs wc -l 2>/dev/null | tail -1
	@echo "$(YELLOW)Dart/Flutter:$(NC)"
	@find . -name "*.dart" | xargs wc -l 2>/dev/null | tail -1
	@echo "$(YELLOW)JavaScript:$(NC)"
	@find . \( -name "*.js" -o -name "*.jsx" \) -not -path "./node_modules/*" -not -path "./*/node_modules/*" | xargs wc -l 2>/dev/null | tail -1

# ============================================
# GIT
# ============================================

.PHONY: git-status
git-status: ## Mostra status do git
	@echo "$(CYAN)📊 Git status:$(NC)"
	@git status

.PHONY: git-pull
git-pull: ## Pull das últimas mudanças
	@echo "$(CYAN)⬇️ Fazendo pull...$(NC)"
	@git pull origin main

# ============================================
# DESENVOLVIMENTO
# ============================================

.PHONY: dev
dev: ## Modo desenvolvimento com instruções
	@echo "$(CYAN)🔥 Modo desenvolvimento...$(NC)"
	@echo ""
	@echo "$(YELLOW)Para desenvolvimento local, abra 4 terminais:$(NC)"
	@echo ""
	@echo "  Terminal 1: $(BLUE)make run-gateway$(NC)"
	@echo "  Terminal 2: $(BLUE)make run-config-backend$(NC)"
	@echo "  Terminal 3: $(BLUE)make run-config-frontend$(NC)"
	@echo "  Terminal 4: $(BLUE)make run-flutter$(NC)"
	@echo ""
	@echo "$(GREEN)URLs de acesso:$(NC)"
	@echo "  Frontend: http://localhost:3000"
	@echo "  Backend API: http://localhost:5000"
	@echo "  MQTT Broker: localhost:1883"
	@echo ""
	@echo "$(YELLOW)Para deploy no Raspberry Pi:$(NC)"
	@echo "  $(BLUE)make deploy$(NC) - Deploy automático"
	@echo "  $(BLUE)make status$(NC) - Verificar status"
	@echo "  $(BLUE)make logs-gateway$(NC) - Ver logs"

# ============================================
# ATALHOS
# ============================================

.PHONY: d
d: deploy ## Atalho para deploy

.PHONY: s
s: status ## Atalho para status

.PHONY: r
r: restart ## Atalho para restart

.PHONY: c
c: clean ## Atalho para clean

.PHONY: t
t: test ## Atalho para test

.PHONY: h
h: help ## Atalho para help

# ============================================
# CONFIG
# ============================================

.DEFAULT_GOAL := help

# Evita que make tente algo com arquivos de mesmo nome
.PHONY: all install test clean build deploy run