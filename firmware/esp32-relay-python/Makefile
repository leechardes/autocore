# ESP32 Relay Controller - Makefile Simplificado
# Comandos essenciais para deploy e monitoramento

# Configurações
PORT ?= /dev/cu.usbserial-0001
BAUD_RATE = 115200

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.PHONY: help deploy restart format clean logs monitor flash install-tools

help: ## Mostra todos os comandos disponíveis
	@echo "${BLUE}ESP32 Relay Controller - Comandos${NC}"
	@echo "================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-15s${NC} %s\n", $$1, $$2}'

install-tools: ## Instala ampy e ferramentas necessárias
	@echo "${BLUE}Instalando ferramentas...${NC}"
	pip3 install adafruit-ampy esptool pyserial
	@echo "${GREEN}✅ Ferramentas instaladas!${NC}"

flash: ## Instala firmware MicroPython no ESP32
	@echo "${BLUE}Instalando firmware MicroPython...${NC}"
	@if [ ! -f "firmware/esp32-micropython.bin" ]; then \
		echo "${RED}❌ Firmware não encontrado em firmware/esp32-micropython.bin${NC}"; \
		exit 1; \
	fi
	esptool.py --chip esp32 --port $(PORT) --baud $(BAUD_RATE) write_flash -z 0x1000 firmware/esp32-micropython.bin
	@echo "${GREEN}✅ Firmware instalado! Aguarde 5 segundos para boot...${NC}"
	@sleep 5

deploy: ## Envia main.py para ESP32 usando ampy
	@echo "${BLUE}Fazendo deploy do main.py...${NC}"
	@if [ ! -f "main.py" ]; then \
		echo "${RED}❌ Arquivo main.py não encontrado${NC}"; \
		exit 1; \
	fi
	python3 -m ampy.cli --port $(PORT) --baud $(BAUD_RATE) put main.py
	@echo "${GREEN}✅ Deploy concluído!${NC}"

restart: ## Reinicia ESP32 via software reset
	@echo "${BLUE}Reiniciando ESP32...${NC}"
	python3 scripts/restart.py
	@echo "${GREEN}✅ ESP32 reiniciado!${NC}"

format: ## Formata ESP32 (apaga todos os arquivos)
	@echo "${RED}⚠️  ATENÇÃO: Isso apagará TODOS os arquivos do ESP32!${NC}"
	@read -p "Tem certeza? (s/N): " confirm && [ "$$confirm" = "s" ] || exit 1
	@echo "${BLUE}Formatando ESP32...${NC}"
	python3 -m ampy.cli --port $(PORT) --baud $(BAUD_RATE) rmdir /
	@echo "${GREEN}✅ ESP32 formatado!${NC}"

clean: ## Limpa arquivos temporários locais
	@echo "${BLUE}Limpando arquivos temporários...${NC}"
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "${GREEN}✅ Limpeza concluída!${NC}"

logs: ## Mostra logs do ESP32 em tempo real
	@echo "${BLUE}Conectando ao monitor serial...${NC}"
	@echo "${YELLOW}Pressione Ctrl+C para sair${NC}"
	python3 -m serial.tools.miniterm $(PORT) $(BAUD_RATE)

monitor: ## Monitor completo com logs e informações
	@echo "${BLUE}Iniciando monitor completo...${NC}"
	python3 scripts/monitor.py

# Comandos de desenvolvimento
dev: deploy monitor ## Deploy + Monitor (desenvolvimento rápido)

check: ## Verifica se ESP32 está conectado
	@echo "${BLUE}Verificando conexão...${NC}"
	python3 -m ampy.cli --port $(PORT) --baud $(BAUD_RATE) ls
	@echo "${GREEN}✅ ESP32 conectado!${NC}"

list-files: ## Lista arquivos no ESP32
	@echo "${BLUE}Arquivos no ESP32:${NC}"
	python3 -m ampy.cli --port $(PORT) --baud $(BAUD_RATE) ls

get-config: ## Baixa config.json do ESP32
	@echo "${BLUE}Baixando configuração...${NC}"
	python3 -m ampy.cli --port $(PORT) --baud $(BAUD_RATE) get config.json || echo "${YELLOW}Config não encontrada${NC}"

# Comandos de produção
production-deploy: clean deploy restart ## Deploy completo para produção

# Info
info: ## Informações do projeto
	@echo "${BLUE}ESP32 Relay Controller${NC}"
	@echo "======================"
	@echo "Porta: $(PORT)"
	@echo "Baud Rate: $(BAUD_RATE)"
	@echo "Firmware: firmware/esp32-micropython.bin"
	@echo "Código: main.py"