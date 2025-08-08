# Makefile para AutoCore - Gerenciamento de múltiplos venvs
# Facilita operações comuns mantendo isolamento

.PHONY: help setup clean test deploy status backup dev-gateway dev-config

# Variáveis
PYTHON := python3
PIP := pip3
VENV := .venv
PROJECTS := database gateway config-app/backend

# Cores para output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

## help: Mostra este menu de ajuda
help:
	@echo "AutoCore - Comandos Disponíveis"
	@echo "================================"
	@echo ""
	@grep -E '^##' Makefile | sed 's/## //' | column -t -s ':'
	@echo ""

## setup: Configura todos os ambientes virtuais
setup:
	@echo "$${BLUE}🚀 Configurando ambientes...$${NC}"
	@chmod +x setup_environments.sh
	@./setup_environments.sh

## setup-database: Configura apenas database
setup-database:
	@echo "$${YELLOW}📦 Configurando Database...$${NC}"
	@cd database && \
		$(PYTHON) -m venv $(VENV) --system-site-packages && \
		. $(VENV)/bin/activate && \
		$(PIP) install -r requirements.txt && \
		echo "$${GREEN}✓ Database configurado$${NC}"

## setup-gateway: Configura apenas gateway
setup-gateway:
	@echo "$${YELLOW}📦 Configurando Gateway...$${NC}"
	@cd gateway && \
		$(PYTHON) -m venv $(VENV) --system-site-packages && \
		. $(VENV)/bin/activate && \
		$(PIP) install -r requirements.txt && \
		echo "$${GREEN}✓ Gateway configurado$${NC}"

## setup-config: Configura apenas config-app
setup-config:
	@echo "$${YELLOW}📦 Configurando Config-App...$${NC}"
	@cd config-app/backend && \
		$(PYTHON) -m venv $(VENV) --system-site-packages && \
		. $(VENV)/bin/activate && \
		$(PIP) install -r requirements.txt && \
		echo "$${GREEN}✓ Config-App configurado$${NC}"

## init-db: Inicializa o banco de dados
init-db:
	@echo "$${BLUE}🗛️ Inicializando banco...$${NC}"
	@cd database && \
		. $(VENV)/bin/activate && \
		$(PYTHON) src/cli/manage.py init

## dev-gateway: Roda gateway em modo desenvolvimento
dev-gateway:
	@echo "$${BLUE}🚀 Iniciando Gateway (dev)...$${NC}"
	@cd gateway && \
		. $(VENV)/bin/activate && \
		$(PYTHON) main.py

## dev-config: Roda config-app em modo desenvolvimento
dev-config:
	@echo "$${BLUE}🌐 Iniciando Config-App (dev)...$${NC}"
	@cd config-app/backend && \
		. $(VENV)/bin/activate && \
		uvicorn main:app --reload --host 0.0.0.0 --port 8000

## test: Roda testes de todos os projetos
test:
	@echo "$${YELLOW}🧪 Rodando testes...$${NC}"
	@for proj in $(PROJECTS); do \
		echo "Testing $$proj..."; \
		cd $$proj && \
		if [ -f "$(VENV)/bin/activate" ]; then \
			. $(VENV)/bin/activate && \
			if [ -f "tests.py" ] || [ -d "tests" ]; then \
				$(PYTHON) -m pytest tests/ || true; \
			else \
				echo "  Sem testes encontrados"; \
			fi; \
		fi; \
		cd - > /dev/null; \
	done

## status: Mostra status dos serviços
status:
	@echo "$${BLUE}📊 Status dos Serviços$${NC}"
	@echo "====================="
	@echo ""
	@echo "Database:"
	@cd database && \
		if [ -f "$(VENV)/bin/activate" ]; then \
			. $(VENV)/bin/activate && \
			$(PYTHON) src/cli/manage.py status 2>/dev/null || echo "  Não inicializado"; \
		else \
			echo "  Venv não configurado"; \
		fi
	@echo ""
	@echo "Gateway:"
	@systemctl is-active autocore-gateway 2>/dev/null || echo "  Não rodando"
	@echo ""
	@echo "Config-App:"
	@systemctl is-active autocore-config-app 2>/dev/null || echo "  Não rodando"

## clean: Limpa arquivos temporários e caches
clean:
	@echo "$${YELLOW}🧹 Limpando arquivos temporários...$${NC}"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name ".DS_Store" -delete 2>/dev/null || true
	@echo "$${GREEN}✓ Limpeza completa$${NC}"

## clean-venv: Remove todos os ambientes virtuais
clean-venv:
	@echo "$${RED}⚠️  Removendo todos os venvs...$${NC}"
	@read -p "Tem certeza? (y/N) " confirm && \
	if [ "$$confirm" = "y" ]; then \
		for proj in $(PROJECTS); do \
			rm -rf $$proj/$(VENV); \
		done; \
		echo "$${GREEN}✓ Venvs removidos$${NC}"; \
	else \
		echo "Cancelado"; \
	fi

## backup: Faz backup do banco de dados
backup:
	@echo "$${BLUE}💾 Criando backup...$${NC}"
	@cd database && \
		if [ -f "$(VENV)/bin/activate" ]; then \
			. $(VENV)/bin/activate && \
			$(PYTHON) src/cli/manage.py backup; \
		else \
			echo "$${RED}Erro: Database venv não configurado$${NC}"; \
		fi

## deploy: Deploy de todos os serviços
deploy:
	@echo "$${BLUE}🚀 Deploy completo...$${NC}"
	@chmod +x deploy/deploy.sh
	@deploy/deploy.sh all deploy

## deploy-gateway: Deploy apenas do gateway
deploy-gateway:
	@chmod +x deploy/deploy.sh
	@deploy/deploy.sh gateway deploy

## deploy-config: Deploy apenas do config-app
deploy-config:
	@chmod +x deploy/deploy.sh
	@deploy/deploy.sh config-app deploy

## install-services: Instala serviços systemd
install-services:
	@echo "$${BLUE}🔧 Instalando serviços systemd...$${NC}"
	@sudo cp deploy/systemd/*.service /etc/systemd/system/
	@sudo systemctl daemon-reload
	@sudo systemctl enable autocore-gateway autocore-config-app
	@echo "$${GREEN}✓ Serviços instalados$${NC}"

## logs-gateway: Mostra logs do gateway
logs-gateway:
	@journalctl -u autocore-gateway -f

## logs-config: Mostra logs do config-app
logs-config:
	@journalctl -u autocore-config-app -f

## disk-usage: Mostra uso de disco dos venvs
disk-usage:
	@echo "$${BLUE}📊 Uso de disco dos ambientes:$${NC}"
	@echo "============================="
	@for proj in $(PROJECTS); do \
		if [ -d "$$proj/$(VENV)" ]; then \
			size=$$(du -sh $$proj/$(VENV) | cut -f1); \
			echo "$$proj: $$size"; \
		fi; \
	done
	@echo ""
	@echo "Total:" $$(du -sh */$(VENV) */*/$(VENV) 2>/dev/null | tail -1 | cut -f1)

## update-deps: Atualiza dependências de todos os projetos
update-deps:
	@echo "$${YELLOW}🔄 Atualizando dependências...$${NC}"
	@for proj in $(PROJECTS); do \
		echo "Atualizando $$proj..."; \
		cd $$proj && \
		if [ -f "$(VENV)/bin/activate" ]; then \
			. $(VENV)/bin/activate && \
			$(PIP) install -r requirements.txt --upgrade; \
		fi; \
		cd - > /dev/null; \
	done
	@echo "$${GREEN}✓ Dependências atualizadas$${NC}"