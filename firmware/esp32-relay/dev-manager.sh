#!/bin/bash

# AutoCore ESP32 Relay - Development Manager
# Ferramenta completa de desenvolvimento e debug

PROJETO_DIR="/Users/leechardes/Projetos/AutoCore/firmware/esp32-relay"
PORTA_SERIAL="/dev/cu.usbserial-0001"
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
    echo -e "${CYAN}║                    ${WHITE}🚗 AutoCore ESP32 Relay${CYAN}                        ║${NC}"
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

# Função para selecionar porta serial
select_serial_port() {
    echo -e "${CYAN}🔍 Detectando portas seriais disponíveis...${NC}"
    echo ""
    
    # Detectar portas usando PlatformIO
    local ports_output=$(pio device list 2>/dev/null)
    
    # Arrays para armazenar portas
    declare -a port_names
    declare -a port_descriptions
    local port_count=0
    
    # Processar saída e encontrar portas USB/Serial
    while IFS= read -r line; do
        if [[ "$line" =~ ^/dev/cu\. ]]; then
            port_name=$(echo "$line" | cut -d' ' -f1)
            # Pegar apenas portas USB serial relevantes
            if [[ "$port_name" == *"usbserial"* ]] || [[ "$port_name" == *"usbmodem"* ]] || [[ "$port_name" == *"SLAB"* ]]; then
                port_names[$port_count]=$port_name
                # Tentar pegar a descrição na próxima linha
                read -r desc_line
                port_descriptions[$port_count]="$desc_line"
                ((port_count++))
            fi
        fi
    done <<< "$ports_output"
    
    if [ $port_count -eq 0 ]; then
        echo -e "${RED}❌ Nenhuma porta serial USB encontrada!${NC}"
        echo -e "${YELLOW}Conecte seu ESP32 e tente novamente.${NC}"
        echo ""
        read -p "Pressione Enter para continuar..."
        return 1
    fi
    
    echo -e "${GREEN}Portas disponíveis:${NC}"
    echo "----------------------------------------"
    for i in "${!port_names[@]}"; do
        local num=$((i + 1))
        echo -e "${WHITE}$num.${NC} ${CYAN}${port_names[$i]}${NC}"
        if [[ "${port_descriptions[$i]}" == *"ESP"* ]] || [[ "${port_descriptions[$i]}" == *"CP210"* ]] || [[ "${port_descriptions[$i]}" == *"CH340"* ]]; then
            echo -e "   ${GREEN}└─ Provável ESP32${NC}"
        else
            echo -e "   └─ ${port_descriptions[$i]}"
        fi
    done
    echo "----------------------------------------"
    echo -e "${WHITE}0.${NC} Cancelar"
    echo ""
    
    read -p "Selecione o número da porta: " port_choice
    
    if [ "$port_choice" = "0" ]; then
        echo -e "${YELLOW}Operação cancelada${NC}"
        return 1
    fi
    
    local index=$((port_choice - 1))
    if [ $index -ge 0 ] && [ $index -lt $port_count ]; then
        local selected_port="${port_names[$index]}"
        echo ""
        echo -e "${GREEN}✅ Porta selecionada: $selected_port${NC}"
        
        # Atualizar variável global
        PORTA_SERIAL="$selected_port"
        
        # Atualizar platformio.ini
        echo -e "${CYAN}📝 Atualizando platformio.ini...${NC}"
        if [ -f "$PROJETO_DIR/platformio.ini" ]; then
            # Usar sed para atualizar a linha upload_port
            sed -i.bak "s|^upload_port = .*|upload_port = $selected_port|" "$PROJETO_DIR/platformio.ini"
            echo -e "${GREEN}✅ platformio.ini atualizado${NC}"
        fi
        
        # Atualizar o próprio script
        echo -e "${CYAN}📝 Salvando configuração...${NC}"
        sed -i.bak "s|^PORTA_SERIAL=\".*\"|PORTA_SERIAL=\"$selected_port\"|" "$0"
        echo -e "${GREEN}✅ Configuração salva${NC}"
        
        echo ""
        echo -e "${GREEN}🎉 Porta configurada com sucesso!${NC}"
        sleep 2
        return 0
    else
        echo -e "${RED}❌ Opção inválida!${NC}"
        sleep 2
        return 1
    fi
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
        echo -e "${GREEN}1.${NC} Alterar porta serial (com detecção automática)"
        echo -e "${GREEN}2.${NC} Alterar velocidade"
        echo -e "${GREEN}3.${NC} Digitar porta manualmente"
        echo -e "${GREEN}0.${NC} Voltar ao menu principal"
        echo ""
        
        read -p "Escolha uma opção: " config_option
        
        case $config_option in
            1)
                clear_screen
                select_serial_port
                ;;
            2)
                echo ""
                echo -e "${CYAN}Selecione a velocidade:${NC}"
                echo -e "${GREEN}1.${NC} 9600 baud"
                echo -e "${GREEN}2.${NC} 115200 baud (padrão)"
                echo -e "${GREEN}3.${NC} 230400 baud"
                echo -e "${GREEN}4.${NC} 921600 baud (upload rápido)"
                echo -e "${GREEN}5.${NC} Outra velocidade"
                echo ""
                read -p "Escolha: " speed_choice
                
                case $speed_choice in
                    1) VELOCIDADE="9600" ;;
                    2) VELOCIDADE="115200" ;;
                    3) VELOCIDADE="230400" ;;
                    4) VELOCIDADE="921600" ;;
                    5)
                        read -p "Digite a velocidade: " custom_speed
                        if [ -n "$custom_speed" ]; then
                            VELOCIDADE="$custom_speed"
                        fi
                        ;;
                    *)
                        echo -e "${RED}❌ Opção inválida!${NC}"
                        sleep 1
                        continue
                        ;;
                esac
                
                echo -e "${GREEN}✅ Velocidade alterada para: $VELOCIDADE baud${NC}"
                # Salvar no script
                sed -i.bak "s|^VELOCIDADE=\".*\"|VELOCIDADE=\"$VELOCIDADE\"|" "$0"
                sleep 2
                ;;
            3)
                echo ""
                echo -e "${CYAN}Digite a porta serial manualmente:${NC}"
                echo -e "${YELLOW}Exemplos:${NC}"
                echo "  macOS: /dev/cu.usbserial-0001"
                echo "  Linux: /dev/ttyUSB0"
                echo "  Windows: COM3"
                echo ""
                read -p "Porta: " nova_porta
                if [ -n "$nova_porta" ]; then
                    PORTA_SERIAL="$nova_porta"
                    echo -e "${GREEN}✅ Porta alterada para: $PORTA_SERIAL${NC}"
                    
                    # Atualizar platformio.ini
                    if [ -f "$PROJETO_DIR/platformio.ini" ]; then
                        sed -i.bak "s|^upload_port = .*|upload_port = $nova_porta|" "$PROJETO_DIR/platformio.ini"
                    fi
                    
                    # Salvar no script
                    sed -i.bak "s|^PORTA_SERIAL=\".*\"|PORTA_SERIAL=\"$nova_porta\"|" "$0"
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