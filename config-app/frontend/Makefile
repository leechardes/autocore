# Config-App Frontend - Makefile
# React + Vite + shadcn/ui

# Variáveis
NODE = node
NPM = npm
VITE = npx vite
SHADCN = npx shadcn@latest

# Diretórios
DIST_DIR = dist
SRC_DIR = src
PUBLIC_DIR = public

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.PHONY: help
help: ## Mostra este menu de ajuda
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     Config-App Frontend - Makefile        ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Comandos disponíveis:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BLUE)Exemplos de uso:$(NC)"
	@echo "  make install    # Configura ambiente completo"
	@echo "  make dev        # Executa em modo desenvolvimento"
	@echo "  make build      # Build para produção"

# ═══════════════════════════════════════════════════════
# SETUP E INSTALAÇÃO
# ═══════════════════════════════════════════════════════

.PHONY: check-node
check-node: ## Verifica se Node.js está instalado
	@echo "$(GREEN)🔍 Verificando Node.js...$(NC)"
	@$(NODE) --version || (echo "$(RED)❌ Node.js não encontrado. Instale Node.js 16+$(NC)" && exit 1)
	@echo "✅ Node.js OK"

.PHONY: install
install: check-node ## Instala todas as dependências
	@echo "$(GREEN)📦 Instalando dependências...$(NC)"
	@$(NPM) install
	@echo "✅ Dependências instaladas"
	@echo ""
	@echo "$(GREEN)📝 Configurando ambiente...$(NC)"
	@if [ ! -f .env ]; then \
		echo "VITE_API_BASE_URL=http://localhost:8000" > .env; \
		echo "✅ Arquivo .env criado"; \
	else \
		echo "ℹ️  Arquivo .env já existe"; \
	fi

.PHONY: install-dev
install-dev: install ## Instala dependências + ferramentas de dev
	@echo "$(GREEN)🔧 Instalando ferramentas de desenvolvimento...$(NC)"
	@$(NPM) install --save-dev prettier eslint
	@echo "✅ Ferramentas de dev instaladas"

# ═══════════════════════════════════════════════════════
# EXECUÇÃO
# ═══════════════════════════════════════════════════════

.PHONY: dev
dev: ## Executa em modo desenvolvimento (com HMR)
	@echo "$(GREEN)🚀 Iniciando servidor de desenvolvimento...$(NC)"
	@echo "📡 Aplicação disponível em: http://localhost:3000"
	@echo "🔄 Hot Module Reload habilitado"
	@echo ""
	@$(NPM) run dev

.PHONY: build
build: ## Build para produção
	@echo "$(GREEN)🏗️ Gerando build de produção...$(NC)"
	@$(NPM) run build
	@echo "✅ Build gerado em $(DIST_DIR)/"
	@echo ""
	@echo "$(GREEN)📊 Estatísticas do bundle:$(NC)"
	@ls -lh $(DIST_DIR)/ || echo "Diretório $(DIST_DIR)/ não encontrado"

.PHONY: preview
preview: ## Preview do build de produção
	@echo "$(GREEN)👁️ Preview do build de produção...$(NC)"
	@echo "📡 Preview disponível em: http://localhost:3000"
	@$(NPM) run preview

.PHONY: serve
serve: build ## Build e servir localmente
	@echo "$(GREEN)🌐 Servindo build de produção...$(NC)"
	@$(NPM) run preview

# ═══════════════════════════════════════════════════════
# QUALIDADE DE CÓDIGO
# ═══════════════════════════════════════════════════════

.PHONY: lint
lint: ## Verifica código com ESLint
	@echo "$(GREEN)🔍 Verificando código com ESLint...$(NC)"
	@$(NPM) run lint

.PHONY: format
format: ## Formata código com Prettier
	@echo "$(GREEN)🎨 Formatando código...$(NC)"
	@$(NPM) run format

.PHONY: check
check: lint ## Verifica qualidade do código
	@echo "$(GREEN)✅ Verificação de qualidade concluída$(NC)"

# ═══════════════════════════════════════════════════════
# SHADCN/UI
# ═══════════════════════════════════════════════════════

.PHONY: ui-add
ui-add: ## Adiciona componente shadcn/ui (uso: make ui-add COMPONENT=button)
	@if [ -z "$(COMPONENT)" ]; then \
		echo "$(RED)❌ Especifique o componente: make ui-add COMPONENT=button$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)📦 Adicionando componente: $(COMPONENT)$(NC)"
	@$(SHADCN) add $(COMPONENT)
	@echo "✅ Componente $(COMPONENT) adicionado"

.PHONY: ui-update
ui-update: ## Atualiza todos os componentes shadcn/ui
	@echo "$(GREEN)🔄 Atualizando componentes shadcn/ui...$(NC)"
	@$(SHADCN) update
	@echo "✅ Componentes atualizados"

.PHONY: ui-list
ui-list: ## Lista componentes shadcn/ui disponíveis
	@echo "$(GREEN)📝 Componentes shadcn/ui disponíveis:$(NC)"
	@echo ""
	@echo "$(YELLOW)Básicos:$(NC) button, input, label, textarea, select"
	@echo "$(YELLOW)Layout:$(NC) card, separator, sheet, dialog, drawer"
	@echo "$(YELLOW)Navegação:$(NC) tabs, breadcrumb, pagination"
	@echo "$(YELLOW)Feedback:$(NC) alert, badge, progress, toast"
	@echo "$(YELLOW)Forms:$(NC) checkbox, radio-group, switch, slider"
	@echo "$(YELLOW)Avançados:$(NC) table, calendar, popover, tooltip"
	@echo ""
	@echo "Uso: $(BLUE)make ui-add COMPONENT=button$(NC)"

# ═══════════════════════════════════════════════════════
# TESTES
# ═══════════════════════════════════════════════════════

.PHONY: test-build
test-build: ## Testa se build funciona corretamente
	@echo "$(GREEN)🧪 Testando build...$(NC)"
	@$(NPM) run build
	@echo "✅ Build OK"

.PHONY: test-api
test-api: ## Testa conexão com API
	@echo "$(GREEN)🔍 Testando API...$(NC)"
	@echo "$(YELLOW)GET /api/status$(NC)"
	@curl -s http://localhost:8000/api/status | python3 -c "import sys, json; print(json.dumps(json.load(sys.stdin), indent=2))" || echo "❌ API não disponível"

.PHONY: test-responsiveness
test-responsiveness: ## Lista breakpoints para testar responsividade
	@echo "$(GREEN)📱 Breakpoints para testes:$(NC)"
	@echo ""
	@echo "$(YELLOW)Mobile:$(NC)     320px, 375px, 414px"
	@echo "$(YELLOW)Tablet:$(NC)     768px, 1024px"
	@echo "$(YELLOW)Desktop:$(NC)    1280px, 1440px, 1920px"
	@echo ""
	@echo "Use DevTools para testar cada breakpoint"

# ═══════════════════════════════════════════════════════
# DEPLOY
# ═══════════════════════════════════════════════════════

.PHONY: deploy-check
deploy-check: ## Verifica se está pronto para deploy
	@echo "$(GREEN)🚀 Verificando deploy readiness...$(NC)"
	@echo -n "✓ Package.json existe: "; test -f package.json && echo "OK" || echo "FALHOU"
	@echo -n "✓ Vite config existe: "; test -f vite.config.js && echo "OK" || echo "FALHOU"
	@echo -n "✓ Tailwind config existe: "; test -f tailwind.config.js && echo "OK" || echo "FALHOU"
	@echo -n "✓ shadcn/ui config existe: "; test -f components.json && echo "OK" || echo "FALHOU"
	@echo -n "✓ Build funciona: "; $(NPM) run build >/dev/null 2>&1 && echo "OK" || echo "FALHOU"

.PHONY: deploy-pi
deploy-pi: build ## Deploy para Raspberry Pi (uso: make deploy-pi PI_HOST=pi@raspberrypi.local)
	@if [ -z "$(PI_HOST)" ]; then \
		echo "$(RED)❌ Especifique o host: make deploy-pi PI_HOST=pi@raspberrypi.local$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)🚀 Deploy para Raspberry Pi...$(NC)"
	@echo "📡 Host: $(PI_HOST)"
	@scp -r $(DIST_DIR)/* $(PI_HOST):/var/www/autocore/ || \
		(echo "$(RED)❌ Falha no deploy. Verifique SSH e diretório$(NC)" && exit 1)
	@echo "✅ Deploy concluído"
	@echo "🌐 Acesse: http://$(shell echo $(PI_HOST) | cut -d@ -f2)"

.PHONY: deploy-local
deploy-local: build ## Deploy local (copia para diretório específico)
	@echo "$(GREEN)📁 Deploy local...$(NC)"
	@read -p "Diretório de destino: " DEST_DIR; \
	if [ -n "$$DEST_DIR" ]; then \
		cp -r $(DIST_DIR)/* "$$DEST_DIR/"; \
		echo "✅ Arquivos copiados para $$DEST_DIR"; \
	else \
		echo "$(RED)❌ Diretório não especificado$(NC)"; \
	fi

# ═══════════════════════════════════════════════════════
# LIMPEZA
# ═══════════════════════════════════════════════════════

.PHONY: clean
clean: ## Remove arquivos temporários e builds
	@echo "$(GREEN)🧹 Limpando arquivos temporários...$(NC)"
	@rm -rf $(DIST_DIR)
	@rm -rf node_modules/.vite
	@rm -rf .eslintcache
	@echo "✅ Arquivos temporários removidos"

.PHONY: clean-deps
clean-deps: ## Remove node_modules
	@echo "$(RED)⚠️ Removendo dependências...$(NC)"
	@rm -rf node_modules
	@rm -f package-lock.json
	@echo "✅ Dependências removidas"

.PHONY: clean-all
clean-all: clean clean-deps ## Remove tudo (deps e temporários)
	@echo "$(GREEN)✅ Limpeza completa realizada$(NC)"

# ═══════════════════════════════════════════════════════
# DESENVOLVIMENTO
# ═══════════════════════════════════════════════════════

.PHONY: deps-update
deps-update: ## Atualiza dependências
	@echo "$(GREEN)🔄 Atualizando dependências...$(NC)"
	@$(NPM) update
	@echo "✅ Dependências atualizadas"

.PHONY: deps-check
deps-check: ## Verifica dependências desatualizadas
	@echo "$(GREEN)🔍 Verificando dependências...$(NC)"
	@$(NPM) outdated

.PHONY: info
info: ## Mostra informações do ambiente
	@echo "$(BLUE)╔════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║         Informações do Ambiente            ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Versões:$(NC)"
	@echo "  Node.js: $$($(NODE) --version)"
	@echo "  NPM:     $$($(NPM) --version)"
	@echo ""
	@echo "$(GREEN)Diretórios:$(NC)"
	@echo "  Source:  $(SRC_DIR)/"
	@echo "  Build:   $(DIST_DIR)/"
	@echo "  Public:  $(PUBLIC_DIR)/"
	@echo ""
	@echo "$(GREEN)Scripts disponíveis:$(NC)"
	@$(NPM) run | grep -E "^  " | head -10

# ═══════════════════════════════════════════════════════
# ATALHOS ÚTEIS
# ═══════════════════════════════════════════════════════

.PHONY: start
start: install dev ## Setup e executa (alias para install + dev)

.PHONY: fresh
fresh: clean-all install ## Reset completo do ambiente

.PHONY: prod
prod: build preview ## Build e preview de produção

.PHONY: ship
ship: clean build deploy-check ## Preparar para produção

# Default target
.DEFAULT_GOAL := help