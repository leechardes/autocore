#!/bin/bash

# AutoTech HMI Display ESP32 - Development Manager
# Ferramenta completa de desenvolvimento e debug

PROJETO_DIR="/Users/leechardes/Projetos/autocore/firmware/autotech_hmi_display_v2"
PORTA_SERIAL="/dev/cu.usbserial-2110"
VELOCIDADE="115200"

# Cores para interface
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Função para limpar tela
clear_screen() {
    clear
}

# Função para mostrar cabeçalho
show_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    ${WHITE}🚗 AutoTech HMI Display ESP32${CYAN}                    ║${NC}"
    echo -e "${CYAN}║                        ${YELLOW}Development Manager${CYAN}                          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📂 Projeto: ${WHITE}$PROJETO_DIR${NC}"
    echo -e "${BLUE}📡 Porta: ${WHITE}$PORTA_SERIAL${NC}"
    echo -e "${BLUE}⚡ Velocidade: ${WHITE}$VELOCIDADE baud${NC}"
    echo ""
}

# Função para mostrar menu principal
show_menu() {
    echo -e "${GREEN}┌─────────────────────── Opções Disponíveis ───────────────────────┐${NC}"
    echo -e "${GREEN}│${NC}  ${WHITE}1.${NC} 📊 ${CYAN}Monitor Serial${NC} (Ver logs em tempo real)              ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${WHITE}2.${NC} ⬆️  ${CYAN}Upload Firmware${NC} (Compilar e enviar)                 ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${WHITE}3.${NC} 🔄 ${CYAN}Upload + Monitor${NC} (Upload e iniciar monitor)          ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${WHITE}4.${NC} 🔧 ${CYAN}Apenas Compilar${NC} (Build sem upload)                  ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${WHITE}5.${NC} 🧹 ${CYAN}Limpar Build${NC} (Clean do projeto)                     ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${WHITE}6.${NC} ℹ️  ${CYAN}Info do Sistema${NC} (Status do ESP32)                   ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${WHITE}7.${NC} 🔍 ${CYAN}Listar Portas${NC} (Ver portas disponíveis)              ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${WHITE}8.${NC} ⚙️  ${CYAN}Configurações${NC} (Alterar porta/velocidade)           ${GREEN}│${NC}"
    echo -e "${GREEN}│${NC}  ${WHITE}0.${NC} 🚪 ${RED}Sair${NC}                                                 ${GREEN}│${NC}"
    echo -e "${GREEN}└───────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Função para verificar se está no diretório correto
check_directory() {
    if [ ! -f "platformio.ini" ]; then
        echo -e "${RED}❌ Erro: platformio.ini não encontrado!${NC}"
        echo -e "${YELLOW}   Navegando para o diretório do projeto...${NC}"
        cd "$PROJETO_DIR" || {
            echo -e "${RED}❌ Erro: Diretório do projeto não encontrado!${NC}"
            exit 1
        }
    fi
}

# Função para verificar se a porta existe
check_port() {
    if [ ! -e "$PORTA_SERIAL" ]; then
        echo -e "${RED}❌ Erro: Porta $PORTA_SERIAL não encontrada!${NC}"
        echo -e "${YELLOW}💡 Dica: Use a opção 7 para listar portas disponíveis${NC}"
        return 1
    fi
    return 0
}

# Função para monitor serial
start_monitor() {
    echo -e "${CYAN}🖥️  Iniciando Monitor Serial...${NC}"
    echo -e "${YELLOW}📍 Porta: $PORTA_SERIAL${NC}"
    echo -e "${YELLOW}⚡ Velocidade: $VELOCIDADE baud${NC}"
    echo -e "${YELLOW}🔄 Pressione Ctrl+C para parar${NC}"
    echo ""
    
    if ! check_port; then
        read -p "Pressione Enter para continuar..."
        return
    fi
    
    echo -e "${GREEN}▶️  Monitor iniciado:${NC}"
    echo "========================================"
    
    pio device monitor --port "$PORTA_SERIAL" --baud "$VELOCIDADE" || {
        echo -e "${RED}❌ Erro ao iniciar monitor serial${NC}"
        read -p "Pressione Enter para continuar..."
    }
}

# Função para upload
do_upload() {
    echo -e "${CYAN}⬆️  Iniciando Upload...${NC}"
    
    # Reset do ESP32
    echo -e "${YELLOW}🔄 Resetando ESP32...${NC}"
    if command -v esptool.py >/dev/null 2>&1; then
        esptool.py --port "$PORTA_SERIAL" --baud "$VELOCIDADE" run >/dev/null 2>&1
        sleep 2
    fi
    
    echo -e "${YELLOW}🔨 Compilando e fazendo upload...${NC}"
    echo ""
    
    if pio run -t upload; then
        echo ""
        echo -e "${GREEN}✅ Upload realizado com sucesso!${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}❌ Erro durante o upload!${NC}"
        return 1
    fi
}

# Função para upload + monitor
upload_and_monitor() {
    if do_upload; then
        echo ""
        echo -e "${CYAN}🔄 Aguardando 3 segundos antes de iniciar monitor...${NC}"
        sleep 3
        start_monitor
    else
        read -p "Pressione Enter para continuar..."
    fi
}

# Função para apenas compilar
compile_only() {
    echo -e "${CYAN}🔧 Compilando projeto...${NC}"
    echo ""
    
    if pio run; then
        echo ""
        echo -e "${GREEN}✅ Compilação realizada com sucesso!${NC}"
    else
        echo ""
        echo -e "${RED}❌ Erro durante a compilação!${NC}"
    fi
    
    read -p "Pressione Enter para continuar..."
}

# Função para limpar build
clean_build() {
    echo -e "${CYAN}🧹 Limpando arquivos de build...${NC}"
    
    if pio run -t clean; then
        echo -e "${GREEN}✅ Build limpo com sucesso!${NC}"
    else
        echo -e "${RED}❌ Erro ao limpar build!${NC}"
    fi
    
    read -p "Pressione Enter para continuar..."
}

# Função para mostrar info do sistema
show_system_info() {
    echo -e "${CYAN}ℹ️  Informações do Sistema${NC}"
    echo "========================================"
    
    echo -e "${YELLOW}PlatformIO:${NC}"
    pio --version 2>/dev/null || echo "  ❌ PlatformIO não encontrado"
    
    echo ""
    echo -e "${YELLOW}Porta Serial:${NC}"
    if [ -e "$PORTA_SERIAL" ]; then
        echo -e "  ✅ $PORTA_SERIAL (disponível)"
    else
        echo -e "  ❌ $PORTA_SERIAL (não encontrado)"
    fi
    
    echo ""
    echo -e "${YELLOW}Projeto:${NC}"
    if [ -f "platformio.ini" ]; then
        echo "  ✅ platformio.ini encontrado"
        echo "  📋 Configuração:"
        grep -E "board|platform|framework" platformio.ini | head -3 | sed 's/^/    /'
    else
        echo "  ❌ platformio.ini não encontrado"
    fi
    
    echo ""
    echo -e "${YELLOW}Espaço em disco:${NC}"
    df -h . | tail -1 | awk '{print "  💾 Disponível: " $4 " de " $2}'
    
    echo ""
    read -p "Pressione Enter para continuar..."
}

# Função para listar portas
list_ports() {
    echo -e "${CYAN}🔍 Portas Seriais Disponíveis${NC}"
    echo "========================================"
    
    echo -e "${YELLOW}Portas USB/Serial encontradas:${NC}"
    
    # macOS
    if ls /dev/cu.* 2>/dev/null; then
        echo ""
        echo -e "${YELLOW}Detalhes das portas:${NC}"
        for port in /dev/cu.*; do
            if [[ "$port" == *"usbserial"* ]] || [[ "$port" == *"usbmodem"* ]]; then
                echo -e "  📡 $port ${GREEN}(possível ESP32)${NC}"
            else
                echo -e "  📡 $port"
            fi
        done
    else
        echo -e "${RED}  ❌ Nenhuma porta serial encontrada${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Porta atual configurada:${NC} $PORTA_SERIAL"
    
    echo ""
    read -p "Pressione Enter para continuar..."
}

# Função para configurações
configure_settings() {
    while true; do
        clear_screen
        echo -e "${CYAN}⚙️  Configurações${NC}"
        echo "========================================"
        echo -e "${YELLOW}Configurações atuais:${NC}"
        echo -e "  📡 Porta: ${WHITE}$PORTA_SERIAL${NC}"
        echo -e "  ⚡ Velocidade: ${WHITE}$VELOCIDADE baud${NC}"
        echo ""
        echo -e "${GREEN}1.${NC} Alterar porta serial"
        echo -e "${GREEN}2.${NC} Alterar velocidade"
        echo -e "${GREEN}0.${NC} Voltar ao menu principal"
        echo ""
        
        read -p "Escolha uma opção: " config_option
        
        case $config_option in
            1)
                echo ""
                echo -e "${CYAN}Digite a nova porta serial:${NC}"
                read -p "Porta (ex: /dev/cu.usbserial-210): " nova_porta
                if [ -n "$nova_porta" ]; then
                    PORTA_SERIAL="$nova_porta"
                    echo -e "${GREEN}✅ Porta alterada para: $PORTA_SERIAL${NC}"
                fi
                sleep 2
                ;;
            2)
                echo ""
                echo -e "${CYAN}Digite a nova velocidade:${NC}"
                echo -e "${YELLOW}Opções comuns: 9600, 115200, 230400${NC}"
                read -p "Velocidade: " nova_velocidade
                if [ -n "$nova_velocidade" ]; then
                    VELOCIDADE="$nova_velocidade"
                    echo -e "${GREEN}✅ Velocidade alterada para: $VELOCIDADE baud${NC}"
                fi
                sleep 2
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}❌ Opção inválida!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Função principal
main() {
    # Verificar se está no diretório correto
    check_directory
    
    while true; do
        clear_screen
        show_header
        show_menu
        
        read -p "Escolha uma opção: " opcao
        
        case $opcao in
            1)
                clear_screen
                start_monitor
                ;;
            2)
                clear_screen
                do_upload
                read -p "Pressione Enter para continuar..."
                ;;
            3)
                clear_screen
                upload_and_monitor
                ;;
            4)
                clear_screen
                compile_only
                ;;
            5)
                clear_screen
                clean_build
                ;;
            6)
                clear_screen
                show_system_info
                ;;
            7)
                clear_screen
                list_ports
                ;;
            8)
                configure_settings
                ;;
            0)
                echo -e "${GREEN}👋 Até logo!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opção inválida! Tente novamente.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Executar função principal
main