# ESP32 Relay ESP-IDF - Makefile
# Build, flash e monitoramento para projeto ESP-IDF

# Configurações
PORT ?= /dev/cu.usbserial-0001
BAUD_RATE ?= 115200
IDF_PATH ?= $(HOME)/esp/esp-idf
PROJECT_NAME = esp32-relay
CHIP ?= esp32

# Detecta se ESP-IDF está ativo
ifdef IDF_PYTHON_ENV_PATH
    # Usa Python do ESP-IDF se estiver ativo
    PYTHON = $(IDF_PYTHON_ENV_PATH)/bin/python
    PIP = $(IDF_PYTHON_ENV_PATH)/bin/pip
    IDF_ACTIVE = true
else
    # Usa Python do sistema se ESP-IDF não estiver ativo
    PYTHON = python3
    PIP = pip3
    IDF_ACTIVE = false
endif

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
CYAN = \033[0;36m
NC = \033[0m # No Color

# Detectar sistema operacional
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    MONITOR_FILTER = --filter esp32_exception_decoder
endif

.PHONY: help install setup build flash monitor clean fullclean menuconfig size ota status test

help: ## Mostra todos os comandos disponíveis
	@echo "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
	@echo "${CYAN}║          ESP32 Relay ESP-IDF - Build System             ║${NC}"
	@echo "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
	@echo ""
	@echo "${YELLOW}Comandos disponíveis:${NC}"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-20s${NC} %s\n", $$1, $$2}'
	@echo ""
	@echo "${YELLOW}Variáveis de ambiente:${NC}"
	@echo "  PORT=${PORT}"
	@echo "  BAUD_RATE=${BAUD_RATE}"
	@echo "  CHIP=${CHIP}"
	@echo "  IDF_PATH=${IDF_PATH}"

# ============================================================================
# VERIFICAÇÃO DO AMBIENTE
# ============================================================================

check-idf: ## Verifica se ESP-IDF está ativo
	@if [ "$(IDF_ACTIVE)" = "false" ]; then \
		echo "${RED}❌ ESP-IDF não está ativo!${NC}"; \
		echo "${YELLOW}Execute primeiro:${NC}"; \
		echo "${GREEN}  source ~/esp/esp-idf/export.sh${NC}"; \
		echo ""; \
		echo "${YELLOW}Ou use o script de ativação:${NC}"; \
		echo "${GREEN}  source activate.sh${NC}"; \
		exit 1; \
	else \
		echo "${GREEN}✅ ESP-IDF ativo${NC}"; \
		echo "  IDF_PATH: $(IDF_PATH)"; \
		echo "  Python: $(PYTHON)"; \
	fi

# ============================================================================
# SETUP E INSTALAÇÃO
# ============================================================================

install: ## Instala ESP-IDF e dependências
	@echo "${BLUE}📦 Instalando ESP-IDF e dependências...${NC}"
	@$(PYTHON) scripts/install_esp_idf.py
	@echo "${GREEN}✅ ESP-IDF instalado com sucesso!${NC}"

setup: ## Configura ambiente ESP-IDF
	@echo "${BLUE}🔧 Configurando ambiente ESP-IDF...${NC}"
	@if [ ! -d "$(IDF_PATH)" ]; then \
		echo "${RED}❌ ESP-IDF não encontrado em $(IDF_PATH)${NC}"; \
		echo "${YELLOW}Execute 'make install' primeiro${NC}"; \
		exit 1; \
	fi
	@echo "source $(IDF_PATH)/export.sh" >> ~/.bashrc 2>/dev/null || true
	@echo "source $(IDF_PATH)/export.sh" >> ~/.zshrc 2>/dev/null || true
	@echo "${GREEN}✅ Ambiente configurado!${NC}"
	@echo "${YELLOW}ℹ️  Execute 'source $(IDF_PATH)/export.sh' no terminal atual${NC}"

check-env: check-idf ## Verifica se o ambiente está configurado
	@$(PYTHON) scripts/check_environment.py

# ============================================================================
# BUILD E COMPILAÇÃO
# ============================================================================

build: check-idf ## Compila o projeto
	@echo "${BLUE}🔨 Compilando projeto ESP32 Relay...${NC}"
	@$(PYTHON) scripts/pre_build.py
	idf.py build
	@$(PYTHON) scripts/post_build.py
	@echo "${GREEN}✅ Build concluído com sucesso!${NC}"

rebuild: clean build ## Limpa e recompila o projeto

build-verbose: check-env ## Build com output detalhado
	@echo "${BLUE}🔨 Build verbose...${NC}"
	idf.py -v build

# ============================================================================
# FLASH E MONITORAMENTO
# ============================================================================

flash: ## Grava firmware no ESP32
	@echo "${BLUE}📤 Gravando firmware no ESP32...${NC}"
	@$(PYTHON) scripts/check_port.py $(PORT)
	idf.py -p $(PORT) -b $(BAUD_RATE) flash
	@echo "${GREEN}✅ Firmware gravado com sucesso!${NC}"

monitor: ## Monitor serial do ESP32
	@echo "${CYAN}📺 Monitor Serial ESP32${NC}"
	@echo "${YELLOW}Pressione Ctrl+] para sair${NC}"
	@echo "────────────────────────────────────────────"
	idf.py -p $(PORT) monitor

flash-monitor: flash monitor ## Flash + Monitor em sequência

dev: rebuild flash-monitor ## Rebuild + Flash + Monitor (desenvolvimento)

# ============================================================================
# CONFIGURAÇÃO
# ============================================================================

menuconfig: ## Abre menu de configuração do ESP-IDF
	@echo "${BLUE}⚙️  Configuração do projeto...${NC}"
	idf.py menuconfig

config: menuconfig ## Alias para menuconfig

defconfig: ## Restaura configuração padrão
	@echo "${YELLOW}⚠️  Restaurando configuração padrão...${NC}"
	@cp sdkconfig.defaults sdkconfig
	@echo "${GREEN}✅ Configuração restaurada!${NC}"

saveconfig: ## Salva configuração atual como padrão
	@echo "${BLUE}💾 Salvando configuração atual...${NC}"
	@cp sdkconfig sdkconfig.defaults
	@echo "${GREEN}✅ Configuração salva!${NC}"

# ============================================================================
# LIMPEZA
# ============================================================================

clean: ## Limpa arquivos de build
	@echo "${YELLOW}🧹 Limpando build...${NC}"
	idf.py clean
	@echo "${GREEN}✅ Build limpo!${NC}"

fullclean: ## Limpa tudo (build + config)
	@echo "${RED}🗑️  Limpeza completa...${NC}"
	idf.py fullclean
	@rm -f sdkconfig sdkconfig.old
	@echo "${GREEN}✅ Limpeza completa!${NC}"

distclean: fullclean ## Limpa tudo incluindo downloads
	@echo "${RED}🗑️  Removendo componentes baixados...${NC}"
	@rm -rf managed_components
	@rm -rf .espressif
	@echo "${GREEN}✅ Distclean completo!${NC}"

# ============================================================================
# ANÁLISE E DEBUG
# ============================================================================

size: ## Analisa tamanho do firmware
	@echo "${BLUE}📊 Análise de tamanho do firmware:${NC}"
	idf.py size
	@echo ""
	@echo "${CYAN}Componentes por tamanho:${NC}"
	idf.py size-components

size-files: ## Mostra tamanho detalhado por arquivo
	@echo "${BLUE}📊 Tamanho por arquivo:${NC}"
	idf.py size-files

partition-table: ## Mostra tabela de partições
	@echo "${BLUE}💾 Tabela de partições:${NC}"
	idf.py partition-table

# ============================================================================
# OTA (Over-The-Air Update)
# ============================================================================

ota: ## Atualização OTA via rede
	@echo "${BLUE}📡 Iniciando atualização OTA...${NC}"
	@$(PYTHON) scripts/ota_update.py
	@echo "${GREEN}✅ OTA concluído!${NC}"

ota-server: ## Inicia servidor OTA local
	@echo "${BLUE}🌐 Servidor OTA na porta 8070...${NC}"
	@$(PYTHON) scripts/ota_server.py

# ============================================================================
# TESTES E VALIDAÇÃO
# ============================================================================

test: ## Executa testes unitários
	@echo "${BLUE}🧪 Executando testes...${NC}"
	@$(PYTHON) scripts/run_tests.py
	@echo "${GREEN}✅ Testes concluídos!${NC}"

test-mqtt: ## Testa conexão MQTT
	@echo "${BLUE}📡 Testando MQTT...${NC}"
	@$(PYTHON) scripts/test_mqtt.py
	
test-http: ## Testa endpoints HTTP
	@echo "${BLUE}🌐 Testando HTTP...${NC}"
	@$(PYTHON) scripts/test_http.py

validate: ## Valida configuração e código
	@echo "${BLUE}✔️  Validando projeto...${NC}"
	@$(PYTHON) scripts/validate_project.py

# ============================================================================
# FERRAMENTAS E UTILIDADES
# ============================================================================

list-ports: ## Lista todas as portas USB/Serial disponíveis
	@$(PYTHON) scripts/list_ports.py || { \
		echo "${CYAN}🔌 Portas USB/Serial disponíveis (fallback):${NC}"; \
		echo "────────────────────────────────────────────"; \
		if [ "$(UNAME_S)" = "Darwin" ]; then \
			ls -la /dev/cu.* 2>/dev/null | awk '{print NR". " $$9}' | grep -E "usb|serial" || echo "Nenhuma porta USB encontrada"; \
		else \
			ls -la /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | awk '{print NR". " $$9}' || echo "Nenhuma porta USB encontrada"; \
		fi; \
		echo "────────────────────────────────────────────"; \
	}
	@echo ""
	@echo "${YELLOW}Porta atual configurada: ${GREEN}$(PORT)${NC}"

ports: list-ports ## Alias para list-ports

select-port: ## Seleciona porta USB interativamente
	@echo "${CYAN}🔌 Seleção de Porta USB/Serial${NC}"
	@echo "────────────────────────────────────────────"
	@if [ "$(UNAME_S)" = "Darwin" ]; then \
		ports=$$(ls /dev/cu.* 2>/dev/null | grep -E "usb|serial"); \
	else \
		ports=$$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null); \
	fi; \
	if [ -z "$$ports" ]; then \
		echo "${RED}❌ Nenhuma porta USB encontrada${NC}"; \
		exit 1; \
	fi; \
	echo "Portas disponíveis:"; \
	echo "$$ports" | nl; \
	echo ""; \
	read -p "Digite o número da porta desejada: " port_num; \
	selected=$$(echo "$$ports" | sed -n "$${port_num}p"); \
	if [ -n "$$selected" ]; then \
		echo "${GREEN}✅ Porta selecionada: $$selected${NC}"; \
		echo ""; \
		echo "${YELLOW}Para tornar permanente, adicione ao Makefile:${NC}"; \
		echo "${CYAN}PORT = $$selected${NC}"; \
		echo ""; \
		echo "${YELLOW}Ou exporte a variável:${NC}"; \
		echo "${CYAN}export PORT=$$selected${NC}"; \
		echo ""; \
		read -p "Deseja usar esta porta agora? (s/N): " use_now; \
		if [ "$$use_now" = "s" ]; then \
			$(MAKE) PORT=$$selected monitor; \
		fi; \
	else \
		echo "${RED}❌ Seleção inválida${NC}"; \
	fi

configure: ## Configura porta e outras opções interativamente
	@echo "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
	@echo "${CYAN}║            Configuração Interativa ESP32-Relay          ║${NC}"
	@echo "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
	@echo ""
	@echo "${YELLOW}1. Configuração de Porta${NC}"
	@echo "────────────────────────────────────────────"
	@if [ "$(UNAME_S)" = "Darwin" ]; then \
		ports=$$(ls /dev/cu.* 2>/dev/null | grep -E "usb|serial"); \
	else \
		ports=$$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null); \
	fi; \
	if [ -z "$$ports" ]; then \
		echo "${RED}❌ Nenhuma porta USB encontrada${NC}"; \
		selected_port="$(PORT)"; \
	else \
		echo "Portas disponíveis:"; \
		echo "$$ports" | nl; \
		echo "0. Manter atual ($(PORT))"; \
		echo ""; \
		read -p "Digite o número da porta (0 para manter): " port_num; \
		if [ "$$port_num" = "0" ] || [ -z "$$port_num" ]; then \
			selected_port="$(PORT)"; \
		else \
			selected_port=$$(echo "$$ports" | sed -n "$${port_num}p"); \
		fi; \
	fi; \
	echo "${GREEN}✅ Porta: $$selected_port${NC}"; \
	echo ""; \
	echo "${YELLOW}2. Configuração de Baud Rate${NC}"; \
	echo "────────────────────────────────────────────"
	echo "1. 115200 (padrão)"
	echo "2. 230400"
	echo "3. 460800"
	echo "4. 921600"
	echo "0. Manter atual ($(BAUD_RATE))"
	echo ""
	read -p "Digite o número do baud rate (0 para manter): " baud_num
	case "$$baud_num" in \
		1) selected_baud="115200" ;; \
		2) selected_baud="230400" ;; \
		3) selected_baud="460800" ;; \
		4) selected_baud="921600" ;; \
		*) selected_baud="$(BAUD_RATE)" ;; \
	esac
	echo "${GREEN}✅ Baud Rate: $$selected_baud${NC}"
	echo ""
	echo "${YELLOW}3. Ação a executar${NC}"
	echo "────────────────────────────────────────────"
	echo "1. Monitor Serial"
	echo "2. Build"
	echo "3. Flash"
	echo "4. Flash + Monitor"
	echo "5. Build + Flash + Monitor"
	echo "6. Menuconfig"
	echo "7. Erase Flash"
	echo "0. Apenas salvar configuração"
	echo ""
	read -p "Digite o número da ação: " action_num
	echo ""
	echo "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
	echo "${CYAN}║                    Configuração Final                    ║${NC}"
	echo "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
	echo "  Porta: $$selected_port"
	echo "  Baud Rate: $$selected_baud"
	echo ""
	echo "${YELLOW}Para tornar permanente, edite o Makefile:${NC}"
	echo "${CYAN}PORT = $$selected_port${NC}"
	echo "${CYAN}BAUD_RATE = $$selected_baud${NC}"
	echo ""
	echo "${YELLOW}Ou exporte as variáveis:${NC}"
	echo "${CYAN}export PORT=$$selected_port${NC}"
	echo "${CYAN}export BAUD_RATE=$$selected_baud${NC}"
	echo ""
	case "$$action_num" in \
		1) $(MAKE) PORT=$$selected_port BAUD_RATE=$$selected_baud monitor ;; \
		2) $(MAKE) build ;; \
		3) $(MAKE) PORT=$$selected_port BAUD_RATE=$$selected_baud flash ;; \
		4) $(MAKE) PORT=$$selected_port BAUD_RATE=$$selected_baud flash-monitor ;; \
		5) $(MAKE) PORT=$$selected_port BAUD_RATE=$$selected_baud dev ;; \
		6) $(MAKE) menuconfig ;; \
		7) $(MAKE) PORT=$$selected_port erase ;; \
		*) echo "${GREEN}✅ Configuração salva (use as variáveis acima)${NC}" ;; \
	esac

status: ## Mostra status do ESP32 conectado
	@echo "${CYAN}📊 Status do ESP32${NC}"
	@$(PYTHON) scripts/device_status.py $(PORT)

info: ## Informações do chip ESP32
	@echo "${CYAN}ℹ️  Informações do ESP32${NC}"
	esptool.py --chip $(CHIP) --port $(PORT) chip_id
	esptool.py --chip $(CHIP) --port $(PORT) flash_id

reset: ## Reset do ESP32 via serial
	@echo "${YELLOW}🔄 Resetando ESP32...${NC}"
	@$(PYTHON) scripts/reset_device.py $(PORT)
	@echo "${GREEN}✅ Reset enviado!${NC}"

erase: ## Apaga toda a flash do ESP32
	@echo "${RED}⚠️  ATENÇÃO: Isso apagará TODA a flash do ESP32!${NC}"
	@read -p "Tem certeza? (s/N): " confirm && [ "$$confirm" = "s" ] || exit 1
	esptool.py --chip $(CHIP) --port $(PORT) erase_flash
	@echo "${GREEN}✅ Flash apagada!${NC}"

backup: ## Faz backup da flash atual
	@echo "${BLUE}💾 Fazendo backup da flash...${NC}"
	@mkdir -p backups
	esptool.py --chip $(CHIP) --port $(PORT) read_flash 0x0 0x400000 backups/backup_$$(date +%Y%m%d_%H%M%S).bin
	@echo "${GREEN}✅ Backup salvo em backups/${NC}"

restore: ## Restaura backup da flash
	@echo "${BLUE}📥 Restaurando backup...${NC}"
	@echo "Backups disponíveis:"
	@ls -la backups/*.bin 2>/dev/null || echo "Nenhum backup encontrado"
	@read -p "Digite o nome do arquivo: " backup; \
	if [ -f "backups/$$backup" ]; then \
		esptool.py --chip $(CHIP) --port $(PORT) write_flash 0x0 backups/$$backup; \
		echo "${GREEN}✅ Backup restaurado!${NC}"; \
	else \
		echo "${RED}❌ Arquivo não encontrado${NC}"; \
	fi

# ============================================================================
# COMANDOS RÁPIDOS
# ============================================================================

f: flash ## Atalho para flash
m: monitor ## Atalho para monitor
b: build ## Atalho para build
c: clean ## Atalho para clean
fm: flash-monitor ## Atalho para flash-monitor

# ============================================================================
# PRODUÇÃO
# ============================================================================

production: ## Build otimizado para produção
	@echo "${BLUE}🏭 Build de produção...${NC}"
	@$(PYTHON) scripts/production_build.py
	idf.py build
	@echo "${GREEN}✅ Build de produção concluído!${NC}"

release: ## Cria release com versionamento
	@echo "${BLUE}📦 Criando release...${NC}"
	@$(PYTHON) scripts/create_release.py
	@echo "${GREEN}✅ Release criada!${NC}"

# ============================================================================
# DOCUMENTAÇÃO
# ============================================================================

docs: ## Gera documentação do código
	@echo "${BLUE}📚 Gerando documentação...${NC}"
	@$(PYTHON) scripts/generate_docs.py
	@echo "${GREEN}✅ Documentação gerada em docs/html${NC}"

api-docs: ## Gera documentação da API
	@echo "${BLUE}📖 Gerando documentação da API...${NC}"
	@$(PYTHON) scripts/generate_api_docs.py
	@echo "${GREEN}✅ API docs em docs/api.md${NC}"

# ============================================================================
# DESENVOLVIMENTO AVANÇADO
# ============================================================================

gdb: ## Debug com GDB
	@echo "${CYAN}🐛 Iniciando GDB debug...${NC}"
	idf.py gdb

openocd: ## Inicia OpenOCD para debug
	@echo "${CYAN}🔌 Iniciando OpenOCD...${NC}"
	idf.py openocd

coredump: ## Analisa coredump
	@echo "${CYAN}💥 Analisando coredump...${NC}"
	idf.py coredump-info -p $(PORT)

# Comando padrão
.DEFAULT_GOAL := help