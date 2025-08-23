# AutoCore Flutter Makefile
# Automatiza tarefas comuns do projeto

# Variáveis
PROJECT_ROOT := $(shell pwd)/../..
VENV_PATH := $(PROJECT_ROOT)/.venv
PYTHON := $(VENV_PATH)/bin/python
PIP := $(VENV_PATH)/bin/pip
SCRIPTS_DIR := scripts
BUILD_DIR := build
FLUTTER := flutter

# Cores para output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Phony targets
.PHONY: help clean analyze test build-debug build-release format fix \
        pub-get pub-upgrade run run-release devices logs install \
        venv pip-install adb-manager analyze-apk build-apk-versioned \
        qa check-todos check-imports check-const \
        all ci release doctor gradle-clean

# Help automático
help: ## Mostra este help
	@echo "$(GREEN)AutoCore Flutter - Makefile$(NC)"
	@echo ""
	@echo "Uso: make [target]"
	@echo ""
	@echo "Targets disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2}'

# Flutter Targets
analyze: ## Executa análise estática do código
	@echo "$(YELLOW)Analisando código Flutter...$(NC)"
	@$(FLUTTER) analyze
	@echo "$(GREEN)✓ Análise concluída$(NC)"

test: ## Executa testes
	@echo "$(YELLOW)Executando testes...$(NC)"
	@$(FLUTTER) test
	@echo "$(GREEN)✓ Testes concluídos$(NC)"

build-debug: ## Compila APK em modo debug
	@echo "$(YELLOW)Compilando APK debug...$(NC)"
	@$(FLUTTER) build apk --debug
	@echo "$(GREEN)✓ APK debug gerado em build/app/outputs/flutter-apk/$(NC)"

build-release: ## Compila APK em modo release
	@echo "$(YELLOW)Compilando APK release...$(NC)"
	@$(FLUTTER) build apk --release
	@echo "$(GREEN)✓ APK release gerado em build/app/outputs/apk/release/$(NC)"

clean: ## Limpa arquivos de build e cache
	@echo "$(YELLOW)Limpando projeto...$(NC)"
	@$(FLUTTER) clean
	@rm -rf $(BUILD_DIR)
	@echo "$(GREEN)✓ Projeto limpo$(NC)"

pub-get: ## Baixa dependências do pubspec.yaml
	@echo "$(YELLOW)Baixando dependências...$(NC)"
	@$(FLUTTER) pub get
	@echo "$(GREEN)✓ Dependências instaladas$(NC)"

pub-upgrade: ## Atualiza dependências para últimas versões
	@echo "$(YELLOW)Atualizando dependências...$(NC)"
	@$(FLUTTER) pub upgrade
	@echo "$(GREEN)✓ Dependências atualizadas$(NC)"

format: ## Formata código Dart
	@echo "$(YELLOW)Formatando código...$(NC)"
	@dart format lib test
	@echo "$(GREEN)✓ Código formatado$(NC)"

fix: ## Aplica correções automáticas
	@echo "$(YELLOW)Aplicando correções...$(NC)"
	@dart fix --apply
	@echo "$(GREEN)✓ Correções aplicadas$(NC)"

# Desenvolvimento
run: ## Executa app em modo debug
	@echo "$(YELLOW)Executando app...$(NC)"
	@$(FLUTTER) run

run-release: ## Executa app em modo release
	@echo "$(YELLOW)Executando app em release...$(NC)"
	@$(FLUTTER) run --release

devices: ## Lista dispositivos conectados
	@echo "$(YELLOW)Dispositivos disponíveis:$(NC)"
	@$(FLUTTER) devices

logs: ## Mostra logs do dispositivo
	@$(FLUTTER) logs

install: build-debug ## Instala APK debug no dispositivo
	@echo "$(YELLOW)Instalando APK...$(NC)"
	@adb install -r build/app/outputs/flutter-apk/app-debug.apk
	@echo "$(GREEN)✓ APK instalado$(NC)"

# Python/Scripts
venv: ## Cria/verifica ambiente virtual Python
	@if [ ! -d "$(VENV_PATH)" ]; then \
		echo "$(YELLOW)Criando ambiente virtual...$(NC)"; \
		python3 -m venv $(VENV_PATH); \
		echo "$(GREEN)✓ Ambiente virtual criado$(NC)"; \
	else \
		echo "$(GREEN)✓ Ambiente virtual já existe$(NC)"; \
	fi

pip-install: venv ## Instala dependências Python
	@echo "$(YELLOW)Instalando dependências Python...$(NC)"
	@$(PIP) install --upgrade pip
	@$(PIP) install -r $(SCRIPTS_DIR)/requirements.txt
	@echo "$(GREEN)✓ Dependências Python instaladas$(NC)"

adb-manager: pip-install ## Executa ADB Device Manager
	@echo "$(YELLOW)Iniciando ADB Device Manager...$(NC)"
	@$(PYTHON) $(SCRIPTS_DIR)/adb_device_manager.py

analyze-apk: pip-install ## Analisa APK com Androguard
	@echo "$(YELLOW)Analisando APK...$(NC)"
	@$(PYTHON) $(SCRIPTS_DIR)/analyze_apk.py

build-apk-versioned: pip-install ## Build APK com versionamento automático
	@echo "$(YELLOW)Build com versionamento...$(NC)"
	@cd .. && $(PYTHON) $(SCRIPTS_DIR)/build_apk.py

# Quality Assurance
qa: analyze test ## Executa suite completa de QA
	@echo "$(GREEN)✓ Quality Assurance completo$(NC)"

check-todos: ## Lista todos os TODOs no código
	@echo "$(YELLOW)TODOs encontrados:$(NC)"
	@grep -r "TODO\|FIXME\|HACK" lib/ --include="*.dart" || echo "Nenhum TODO encontrado"

check-imports: ## Verifica imports relativos
	@echo "$(YELLOW)Verificando imports...$(NC)"
	@! grep -r "import '\.\." lib/ --include="*.dart" || \
		(echo "$(RED)✗ Imports relativos encontrados$(NC)" && exit 1)
	@echo "$(GREEN)✓ Todos os imports estão corretos$(NC)"

check-const: ## Verifica uso de const constructors
	@echo "$(YELLOW)Verificando const constructors...$(NC)"
	@$(FLUTTER) analyze | grep "prefer_const" || echo "$(GREEN)✓ Uso de const está correto$(NC)"

# Targets Compostos
all: clean pub-get analyze test build-release ## Build completo do projeto
	@echo "$(GREEN)✓ Build completo finalizado$(NC)"

ci: clean pub-get analyze test ## Pipeline CI/CD
	@echo "$(GREEN)✓ CI pipeline concluído$(NC)"

release: qa build-release ## Prepara release do app
	@echo "$(GREEN)✓ Release preparado$(NC)"
	@ls -lh build/app/outputs/apk/release/app-release.apk

doctor: ## Verifica ambiente de desenvolvimento
	@echo "$(YELLOW)Verificando ambiente...$(NC)"
	@$(FLUTTER) doctor -v
	@echo ""
	@echo "$(YELLOW)Python:$(NC)"
	@python3 --version
	@echo ""
	@echo "$(YELLOW)Ambiente virtual:$(NC)"
	@if [ -d "$(VENV_PATH)" ]; then \
		echo "$(GREEN)✓ Configurado em $(VENV_PATH)$(NC)"; \
	else \
		echo "$(RED)✗ Não configurado$(NC)"; \
	fi

# Gradle cache fix
gradle-clean: ## Limpa cache do Gradle
	@echo "$(YELLOW)Limpando cache do Gradle...$(NC)"
	@cd android && ./gradlew clean
	@rm -rf ~/.gradle/caches/
	@echo "$(GREEN)✓ Cache do Gradle limpo$(NC)"