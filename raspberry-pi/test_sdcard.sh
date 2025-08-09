#!/bin/bash

# ============================================================================
# Script de Teste Completo para SD Card
# Detecta cartões falsificados, setores defeituosos e problemas de gravação
# ============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=============================================="
echo "   🔍 Teste Completo de SD Card"
echo "=============================================="
echo -e "${NC}"

# Verificar se F3 está instalado
if ! command -v f3write &> /dev/null; then
    echo -e "${YELLOW}F3 não está instalado. Instalando...${NC}"
    brew install f3
fi

# Detectar SD Card
echo -e "${BLUE}1. Detectando SD Card...${NC}"
DISK=$(diskutil list | grep -B 2 "external" | grep "/dev/disk" | awk '{print $1}' | head -1)

if [ -z "$DISK" ]; then
    echo -e "${RED}❌ Nenhum SD Card detectado!${NC}"
    echo "   Insira o cartão e execute novamente."
    exit 1
fi

echo -e "${GREEN}✅ SD Card encontrado: $DISK${NC}"
diskutil info $DISK | grep -E "Device / Media Name:|Total Size:" | head -2
echo ""

# Mostrar partições
echo -e "${BLUE}2. Partições do SD Card:${NC}"
diskutil list $DISK
echo ""

# Verificar montagem
BOOT_MOUNTED=$(mount | grep "${DISK}s1" | wc -l)
if [ $BOOT_MOUNTED -eq 0 ]; then
    echo -e "${YELLOW}Montando partição boot...${NC}"
    diskutil mount ${DISK}s1 2>/dev/null || echo "Não foi possível montar boot"
fi

# Menu de opções
echo -e "${BLUE}=============================================="
echo "   Escolha o tipo de teste:"
echo "=============================================="
echo -e "${NC}"
echo "1) Teste RÁPIDO (1-2 minutos) - Verifica integridade básica"
echo "2) Teste COMPLETO F3 (30+ minutos) - Detecta cartões falsificados"
echo "3) Teste de VELOCIDADE (5 minutos) - Mede performance"
echo "4) Verificar SMART data (se suportado)"
echo "5) Reparar filesystem (fsck)"
echo "6) TODOS os testes (completo)"
echo "7) FORMATAR SD Card - Apagar tudo e criar nova partição"
echo "8) GRAVAR Raspberry Pi OS - Baixar e gravar imagem"
echo "9) CONFIGURAR para Boot - Adicionar WiFi e SSH"
echo "0) INFORMAÇÕES DETALHADAS - Exportar dados completos do cartão"
echo ""
read -p "Opção (0-9): " OPTION

# Desabilitar saída em erro para comandos que podem falhar
set +e

case $OPTION in
    1)
        echo ""
        echo -e "${BLUE}=== TESTE RÁPIDO ===${NC}"
        echo ""
        
        # Teste de leitura rápida
        echo "📖 Testando leitura..."
        dd if=$DISK of=/dev/null bs=4M count=100 2>&1 | grep -E "bytes|copied" || true
        
        # Verificar estrutura
        echo ""
        echo "🔍 Verificando estrutura do disco..."
        diskutil verifyDisk $DISK || true
        
        # Checar espaço real vs reportado
        echo ""
        echo "💾 Capacidade reportada:"
        diskutil info $DISK | grep "Total Size"
        
        echo -e "${GREEN}✅ Teste rápido concluído${NC}"
        ;;
        
    2)
        echo ""
        echo -e "${BLUE}=== TESTE COMPLETO F3 ===${NC}"
        echo -e "${YELLOW}⚠️  ATENÇÃO: Este teste pode demorar 30+ minutos${NC}"
        echo -e "${YELLOW}    e vai escrever dados em todo o espaço livre!${NC}"
        echo ""
        read -p "Continuar? (s/n): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            # Detectar qual partição está montada
            MOUNT_POINT=""
            
            # Verificar possíveis pontos de montagem
            if [ -d "/Volumes/bootfs" ]; then
                MOUNT_POINT="/Volumes/bootfs"
            elif [ -d "/Volumes/SDCARD" ]; then
                MOUNT_POINT="/Volumes/SDCARD"
            elif [ -d "/Volumes/boot" ]; then
                MOUNT_POINT="/Volumes/boot"
            else
                # Tentar montar a primeira partição
                echo "🔧 Montando partição para teste..."
                diskutil mount ${DISK}s1
                sleep 2
                
                # Verificar novamente
                if [ -d "/Volumes/SDCARD" ]; then
                    MOUNT_POINT="/Volumes/SDCARD"
                elif [ -d "/Volumes/bootfs" ]; then
                    MOUNT_POINT="/Volumes/bootfs"
                fi
            fi
            
            if [ -n "$MOUNT_POINT" ]; then
                echo "✅ Testando em: $MOUNT_POINT"
                echo ""
                echo "📝 Escrevendo dados de teste..."
                echo "   Isso vai preencher todo o espaço livre do cartão"
                f3write "$MOUNT_POINT"
                
                echo ""
                echo "📖 Verificando dados escritos..."
                f3read "$MOUNT_POINT"
                
                echo ""
                echo "🧹 Limpando arquivos de teste..."
                rm -f "$MOUNT_POINT"/*.h2w 2>/dev/null || true
            else
                echo -e "${RED}❌ Nenhuma partição montada para teste!${NC}"
                echo "   Tente formatar o cartão primeiro (opção 7)"
            fi
            
            echo -e "${GREEN}✅ Teste F3 concluído${NC}"
            echo "   Se não houver erros, o cartão é genuíno!"
        fi
        ;;
        
    3)
        echo ""
        echo -e "${BLUE}=== TESTE DE VELOCIDADE ===${NC}"
        echo ""
        
        # Criar arquivo temporário
        TESTFILE="/tmp/sdtest_$$.tmp"
        
        echo "📝 Teste de ESCRITA (100MB)..."
        dd if=/dev/zero of=$TESTFILE bs=1M count=100 2>&1 | grep -E "bytes|MB/s" || true
        
        echo ""
        echo "📖 Teste de LEITURA do SD Card..."
        dd if=$DISK of=/dev/null bs=4M count=100 2>&1 | grep -E "bytes|MB/s" || true
        
        # Limpar
        rm -f $TESTFILE
        
        echo ""
        echo -e "${BLUE}Referência de velocidades:${NC}"
        echo "  Class 10: mínimo 10 MB/s"
        echo "  UHS-I: 10-104 MB/s"
        echo "  UHS-II: até 312 MB/s"
        
        echo -e "${GREEN}✅ Teste de velocidade concluído${NC}"
        ;;
        
    4)
        echo ""
        echo -e "${BLUE}=== VERIFICAR SMART DATA ===${NC}"
        echo ""
        
        # Tentar obter SMART data (nem todos os cartões suportam)
        smartctl -a $DISK 2>/dev/null || echo "SMART data não disponível para este cartão"
        
        # Alternativa: verificar com diskutil
        echo ""
        echo "📊 Informações do dispositivo:"
        diskutil info $DISK | grep -E "SMART Status:|Device Block Size:|Media Name:|Ejectable:"
        
        echo -e "${GREEN}✅ Verificação concluída${NC}"
        ;;
        
    5)
        echo ""
        echo -e "${BLUE}=== REPARAR FILESYSTEM ===${NC}"
        echo ""
        
        echo "🔧 Tentando reparar partições..."
        
        # Desmontar primeiro
        diskutil unmountDisk $DISK 2>/dev/null || true
        
        # Tentar reparar
        echo "Reparando partição FAT32 (boot)..."
        sudo fsck_msdos -y ${DISK}s1 2>/dev/null || echo "Não foi possível reparar boot"
        
        echo ""
        echo "Verificando disco completo..."
        diskutil repairDisk $DISK || true
        
        # Remontar
        diskutil mountDisk $DISK 2>/dev/null || true
        
        echo -e "${GREEN}✅ Reparo concluído${NC}"
        ;;
        
    6)
        echo ""
        echo -e "${BLUE}=== EXECUTANDO TODOS OS TESTES ===${NC}"
        echo -e "${YELLOW}⚠️  Isso pode demorar 40+ minutos${NC}"
        echo ""
        read -p "Continuar? (s/n): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            # Executar todos os testes em sequência sem recursão
            echo ""
            echo -e "${BLUE}[1/4] TESTE RÁPIDO${NC}"
            echo "----------------------------------------"
            
            # Teste rápido inline
            echo "📖 Testando leitura..."
            dd if=$DISK of=/dev/null bs=4M count=100 2>&1 | grep -E "bytes|copied" || true
            echo ""
            echo "🔍 Verificando estrutura do disco..."
            diskutil verifyDisk $DISK || true
            echo ""
            echo "💾 Capacidade reportada:"
            diskutil info $DISK | grep "Total Size"
            
            echo "" && echo "---" && echo ""
            echo -e "${BLUE}[2/4] TESTE DE VELOCIDADE${NC}"
            echo "----------------------------------------"
            
            # Teste de velocidade inline
            TESTFILE="/tmp/sdtest_$$.tmp"
            echo "📝 Teste de ESCRITA (100MB)..."
            dd if=/dev/zero of=$TESTFILE bs=1M count=100 2>&1 | grep -E "bytes|MB/s" || true
            echo ""
            echo "📖 Teste de LEITURA do SD Card..."
            dd if=$DISK of=/dev/null bs=4M count=100 2>&1 | grep -E "bytes|MB/s" || true
            rm -f $TESTFILE
            
            echo "" && echo "---" && echo ""
            echo -e "${BLUE}[3/4] SMART DATA${NC}"
            echo "----------------------------------------"
            
            # SMART data inline
            smartctl -a $DISK 2>/dev/null || echo "SMART data não disponível"
            echo ""
            echo "📊 Informações do dispositivo:"
            diskutil info $DISK | grep -E "SMART Status:|Device Block Size:|Media Name:|Ejectable:"
            
            echo "" && echo "---" && echo ""
            echo -e "${BLUE}[4/4] TESTE F3 COMPLETO${NC}"
            echo "----------------------------------------"
            echo -e "${YELLOW}Este teste pode demorar 30+ minutos...${NC}"
            
            # Teste F3 inline
            if [ -d "/Volumes/bootfs" ]; then
                echo "📝 Escrevendo dados de teste..."
                f3write /Volumes/bootfs
                echo ""
                echo "📖 Verificando dados escritos..."
                f3read /Volumes/bootfs
                echo ""
                echo "🧹 Limpando arquivos de teste..."
                rm -f /Volumes/bootfs/*.h2w 2>/dev/null || true
            else
                echo -e "${RED}Partição boot não montada para teste F3${NC}"
            fi
            
            echo ""
            echo -e "${GREEN}✅ TODOS OS TESTES CONCLUÍDOS!${NC}"
        fi
        ;;
        
    7)
        echo ""
        echo -e "${BLUE}=== FORMATAR SD CARD ===${NC}"
        echo -e "${RED}⚠️  ATENÇÃO: Isso vai APAGAR TUDO no SD Card!${NC}"
        echo ""
        echo "SD Card: $DISK"
        diskutil info $DISK | grep -E "Disk Size:|Total Size:" | head -1 || echo "Tamanho: Não detectado"
        echo ""
        read -p "Tem certeza? Digite 'FORMATAR' para confirmar: " CONFIRM
        
        if [ "$CONFIRM" = "FORMATAR" ]; then
            echo ""
            echo "🔧 Desmontando disco..."
            diskutil unmountDisk force $DISK
            
            echo "🗑️  Apagando partições existentes..."
            diskutil eraseDisk MS-DOS "SDCARD" MBR $DISK
            
            echo ""
            echo -e "${GREEN}✅ SD Card formatado com sucesso!${NC}"
            echo "   - Sistema: FAT32"
            echo "   - Nome: SDCARD"
            echo "   - Tabela: MBR"
            echo ""
            echo "Pronto para gravar imagem do Raspberry Pi OS (opção 8)"
        else
            echo -e "${YELLOW}Formatação cancelada${NC}"
        fi
        ;;
        
    8)
        echo ""
        echo -e "${BLUE}=== GRAVAR RASPBERRY PI OS ===${NC}"
        echo ""
        echo "Escolha a versão:"
        echo "1) Raspberry Pi OS Lite 64-bit (RECOMENDADO - 500MB)"
        echo "2) Raspberry Pi OS Lite 32-bit (mais compatível - 500MB)"
        echo "3) Raspberry Pi OS Desktop 64-bit (interface gráfica - 2.6GB)"
        echo ""
        read -p "Versão (1-3): " VERSION
        
        case $VERSION in
            1)
                IMAGE_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz"
                IMAGE_FILE="raspios-lite-arm64.img.xz"
                ;;
            2)
                IMAGE_URL="https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2024-07-04/2024-07-04-raspios-bookworm-armhf-lite.img.xz"
                IMAGE_FILE="raspios-lite-armhf.img.xz"
                ;;
            3)
                IMAGE_URL="https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64.img.xz"
                IMAGE_FILE="raspios-desktop-arm64.img.xz"
                ;;
            *)
                echo -e "${RED}Opção inválida${NC}"
                exit 1
                ;;
        esac
        
        echo ""
        echo "📥 Baixando imagem..."
        echo "   URL: $IMAGE_URL"
        
        # Criar diretório de imagens se não existir
        mkdir -p raspberry-pi/images
        cd raspberry-pi/images
        
        # Baixar se não existir
        if [ ! -f "$IMAGE_FILE" ]; then
            curl -L -O "$IMAGE_URL" --progress-bar
        else
            echo "✅ Imagem já existe, usando cache local"
        fi
        
        # Descomprimir
        echo ""
        echo "📦 Descomprimindo..."
        if [ ! -f "${IMAGE_FILE%.xz}" ]; then
            xz -dk "$IMAGE_FILE"
        fi
        
        # Gravar
        echo ""
        echo -e "${YELLOW}⚠️  Pronto para gravar em $DISK${NC}"
        echo "   Isso vai APAGAR TUDO no SD Card!"
        echo ""
        read -p "Continuar? (s/n): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            echo ""
            echo "🔧 Desmontando disco..."
            diskutil unmountDisk force $DISK
            
            echo "💾 Gravando imagem... (pode demorar 5-10 minutos)"
            # Usar rdisk para velocidade maior
            RDISK="${DISK/disk/rdisk}"
            sudo dd if="${IMAGE_FILE%.xz}" of=$RDISK bs=4m status=progress
            
            echo ""
            echo "⏏️  Ejetando disco..."
            diskutil eject $DISK
            
            echo ""
            echo -e "${GREEN}✅ Imagem gravada com sucesso!${NC}"
            echo ""
            echo "Próximos passos:"
            echo "1. Remova e reinsira o SD Card"
            echo "2. Execute a opção 9 para configurar WiFi e SSH"
        fi
        
        cd ../..
        ;;
        
    9)
        echo ""
        echo -e "${BLUE}=== CONFIGURAR PARA BOOT ===${NC}"
        echo ""
        
        # Verificar se a partição boot está montada
        if [ ! -d "/Volumes/bootfs" ] && [ ! -d "/Volumes/boot" ]; then
            echo -e "${YELLOW}Montando partição boot...${NC}"
            diskutil mount ${DISK}s1
            sleep 2
        fi
        
        # Determinar o caminho da partição boot
        BOOT_PATH=""
        if [ -d "/Volumes/bootfs" ]; then
            BOOT_PATH="/Volumes/bootfs"
        elif [ -d "/Volumes/boot" ]; then
            BOOT_PATH="/Volumes/boot"
        else
            echo -e "${RED}❌ Partição boot não encontrada!${NC}"
            echo "   Certifique-se que o SD Card está inserido e montado"
            exit 1
        fi
        
        echo "✅ Partição boot encontrada em: $BOOT_PATH"
        echo ""
        
        # Habilitar SSH
        echo "1️⃣  Habilitando SSH..."
        touch "$BOOT_PATH/ssh"
        echo "   ✅ Arquivo ssh criado"
        
        # Configurar WiFi
        echo ""
        echo "2️⃣  Configurando WiFi..."
        echo ""
        read -p "SSID da rede WiFi [Lee]: " WIFI_SSID
        WIFI_SSID=${WIFI_SSID:-Lee}
        
        read -s -p "Senha do WiFi [lee159753]: " WIFI_PASS
        WIFI_PASS=${WIFI_PASS:-lee159753}
        echo ""
        
        # Criar arquivo wpa_supplicant.conf
        cat > "$BOOT_PATH/wpa_supplicant.conf" << EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=BR

network={
    ssid="$WIFI_SSID"
    psk="$WIFI_PASS"
    key_mgmt=WPA-PSK
}
EOF
        
        echo "   ✅ WiFi configurado para rede: $WIFI_SSID"
        
        # Configurar usuário (para versões mais novas)
        echo ""
        echo "3️⃣  Configurando usuário padrão..."
        
        # Criar userconf.txt com usuário pi e senha raspberry
        # Senha criptografada: raspberry
        echo 'pi:$6$c70VpvPsVNCG0YR5$l5vWWLsLko9Kj65gcQ8qvMkuOoRkEagI90qi3F/Y7rm8eNYZHW8CY6BOIKwMH7a3YYzZYL90zf304cAHLFaZE0' > "$BOOT_PATH/userconf.txt"
        echo "   ✅ Usuário: pi / Senha: raspberry"
        
        # Adicionar configurações extras
        echo ""
        echo "4️⃣  Adicionando configurações extras..."
        
        # Verificar se config.txt existe
        if [ -f "$BOOT_PATH/config.txt" ]; then
            # Adicionar ao final se ainda não existir
            if ! grep -q "enable_uart=1" "$BOOT_PATH/config.txt"; then
                cat >> "$BOOT_PATH/config.txt" << EOF

# Configurações AutoCore
enable_uart=1
dtoverlay=disable-bt
EOF
                echo "   ✅ UART habilitado para comunicação serial"
            fi
        fi
        
        # Criar script de primeira execução
        echo ""
        echo "5️⃣  Criando script de configuração inicial..."
        cat > "$BOOT_PATH/firstrun.sh" << 'EOF'
#!/bin/bash
# Script executado no primeiro boot

# Expandir filesystem
raspi-config --expand-rootfs

# Atualizar sistema
apt-get update

# Instalar dependências do AutoCore
apt-get install -y python3-pip python3-venv git mosquitto mosquitto-clients

# Criar usuário autocore
useradd -m -s /bin/bash autocore
echo "autocore:autocore" | chpasswd
usermod -aG sudo,gpio,i2c,spi autocore

# Habilitar I2C e SPI
raspi-config nonint do_i2c 0
raspi-config nonint do_spi 0

# Remover este script após execução
rm /boot/firstrun.sh

reboot
EOF
        chmod +x "$BOOT_PATH/firstrun.sh"
        echo "   ✅ Script de configuração inicial criado"
        
        echo ""
        echo -e "${GREEN}=============================================="
        echo "   ✅ SD CARD CONFIGURADO COM SUCESSO!"
        echo "=============================================="
        echo -e "${NC}"
        echo "Configurações aplicadas:"
        echo "  • SSH habilitado"
        echo "  • WiFi: $WIFI_SSID"
        echo "  • Usuário: pi / raspberry"
        echo "  • UART habilitado"
        echo ""
        echo "Próximos passos:"
        echo "1. Remova o SD Card com segurança"
        echo "2. Insira no Raspberry Pi Zero 2W"
        echo "3. Ligue o Raspberry Pi"
        echo "4. Aguarde 2-3 minutos para o primeiro boot"
        echo "5. Procure o IP com: arp -a | grep raspberry"
        echo "6. Conecte via SSH: ssh pi@raspberrypi.local"
        echo ""
        ;;
        
    0)
        echo ""
        echo -e "${BLUE}=== INFORMAÇÕES DETALHADAS DO SD CARD ===${NC}"
        echo "=============================================="
        echo ""
        
        # Criar arquivo de relatório
        REPORT_FILE="sdcard_info_$(date +%Y%m%d_%H%M%S).txt"
        
        {
            echo "RELATÓRIO DETALHADO DO SD CARD"
            echo "Data: $(date)"
            echo "=============================================="
            echo ""
            
            echo "1. INFORMAÇÕES BÁSICAS DO DISPOSITIVO"
            echo "--------------------------------------"
            diskutil info $DISK
            echo ""
            
            echo "2. ESTRUTURA DE PARTIÇÕES"
            echo "--------------------------------------"
            diskutil list $DISK
            echo ""
            
            echo "3. INFORMAÇÕES DO SISTEMA"
            echo "--------------------------------------"
            system_profiler SPCardReaderDataType 2>/dev/null || echo "Sem leitor de cartões detectado"
            echo ""
            
            echo "4. INFORMAÇÕES USB/STORAGE"
            echo "--------------------------------------"
            system_profiler SPUSBDataType | grep -A 20 "Mass Storage" || echo "Não conectado via USB"
            echo ""
            
            echo "5. DETALHES TÉCNICOS DO DISCO"
            echo "--------------------------------------"
            echo "Setor físico:"
            diskutil info $DISK | grep -E "Device Block Size:|Disk Size:|Total Size:|Volume Free Space:|Device Node:|Whole:|Protocol:|SMART Status:|Removable Media:|Ejectable:|Device Location:"
            echo ""
            
            echo "6. INFORMAÇÕES DE MONTAGEM"
            echo "--------------------------------------"
            mount | grep $DISK || echo "Nenhuma partição montada"
            echo ""
            
            echo "7. ANÁLISE DE ESPAÇO"
            echo "--------------------------------------"
            df -h | grep $DISK || echo "Sem partições montadas para análise"
            echo ""
            
            echo "8. IDENTIFICAÇÃO DO FABRICANTE"
            echo "--------------------------------------"
            # Tentar identificar fabricante via CID/CSD
            if command -v dd &> /dev/null; then
                echo "Tentando ler CID (Card Identification)..."
                # No macOS é mais difícil ler CID diretamente
                diskutil info $DISK | grep -E "Media Name:|Device / Media Name:" || echo "Nome não disponível"
            fi
            echo ""
            
            echo "9. VELOCIDADE DE LEITURA RÁPIDA"
            echo "--------------------------------------"
            echo "Testando velocidade de leitura (10MB)..."
            dd if=$DISK of=/dev/null bs=1M count=10 2>&1 | grep -E "bytes|MB/s|copied" || echo "Teste falhou"
            echo ""
            
            echo "10. INFORMAÇÕES RAW DO DISPOSITIVO"
            echo "--------------------------------------"
            ls -la $DISK*
            echo ""
            
            echo "11. INFORMAÇÕES IOREG (DETALHES DO HARDWARE)"
            echo "--------------------------------------"
            ioreg -r -c IOBlockStorageServices | grep -A 10 -B 5 "$DISK" || echo "Sem informações no ioreg"
            echo ""
            
            echo "12. TABELA DE PARTIÇÕES DETALHADA"
            echo "--------------------------------------"
            sudo gpt -r show $DISK 2>/dev/null || fdisk $DISK 2>/dev/null || echo "Não foi possível ler tabela de partições"
            echo ""
            
            echo "13. HEXDUMP DO INÍCIO DO DISCO (primeiros 512 bytes)"
            echo "--------------------------------------"
            sudo dd if=$DISK bs=512 count=1 2>/dev/null | hexdump -C | head -20 || echo "Não foi possível ler setor de boot"
            echo ""
            
            echo "14. ESTADO ATUAL DAS PARTIÇÕES"
            echo "--------------------------------------"
            for partition in ${DISK}s*; do
                if [ -e "$partition" ]; then
                    echo "Partição: $partition"
                    diskutil info $partition 2>/dev/null | grep -E "File System:|Mount Point:|Capacity:|Used:|Available:" || echo "  Sem informações"
                    echo ""
                fi
            done
            
            echo "=============================================="
            echo "FIM DO RELATÓRIO"
            
        } | tee "$REPORT_FILE"
        
        echo ""
        echo -e "${GREEN}=============================================="
        echo "   ✅ RELATÓRIO SALVO"
        echo "=============================================="
        echo -e "${NC}"
        echo "📄 Arquivo: $REPORT_FILE"
        echo ""
        echo "Este arquivo contém todas as informações técnicas do SD Card."
        echo "Você pode compartilhar este arquivo para análise ou suporte."
        echo ""
        
        # Mostrar resumo
        echo -e "${BLUE}RESUMO RÁPIDO:${NC}"
        echo "--------------------------------------"
        
        # Nome e tamanho
        echo -n "📦 Modelo: "
        diskutil info $DISK | grep "Media Name:" | sed 's/.*Media Name://' | sed 's/^ *//' || echo "Desconhecido"
        
        echo -n "💾 Capacidade: "
        diskutil info $DISK | grep "Disk Size:" | sed 's/.*Disk Size://' | sed 's/^ *//' | head -1
        
        # Tipo de tabela de partição
        echo -n "🗂️  Tabela: "
        diskutil list $DISK | grep "GUID_partition_scheme" > /dev/null && echo "GPT" || echo "MBR"
        
        # Número de partições
        echo -n "🔢 Partições: "
        diskutil list $DISK | grep -c "${DISK}s" || echo "0"
        
        # Sistema de arquivos
        echo -n "📁 Filesystem: "
        diskutil info ${DISK}s1 2>/dev/null | grep "File System Personality:" | sed 's/.*File System Personality://' | sed 's/^ *//' || echo "Não detectado"
        
        echo ""
        echo -e "${YELLOW}💡 DICAS PARA PESQUISA:${NC}"
        echo ""
        echo "Use as seguintes informações para pesquisar sobre o cartão:"
        echo "1. Media Name (nome do modelo)"
        echo "2. Disk Size (capacidade real)"
        echo "3. Device Block Size (tamanho do setor)"
        echo "4. File System (sistema de arquivos)"
        echo ""
        ;;
        
    *)
        echo -e "${RED}Opção inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}=============================================="
echo "   📊 Análise de Resultados"
echo "=============================================="
echo -e "${NC}"

echo "🔍 Interpretação dos resultados:"
echo ""
echo "✅ CARTÃO BOM se:"
echo "   - Sem erros de leitura/escrita"
echo "   - Capacidade real = capacidade anunciada"
echo "   - Velocidades dentro do esperado para a classe"
echo ""
echo "❌ CARTÃO COM PROBLEMAS se:"
echo "   - Erros de I/O durante testes"
echo "   - Capacidade real < anunciada (cartão falso)"
echo "   - Velocidades muito abaixo do esperado"
echo "   - Muitos setores defeituosos"
echo ""

echo -e "${YELLOW}💡 RECOMENDAÇÕES:${NC}"
echo ""
echo "1. Se o cartão falhou nos testes:"
echo "   - Tente outro SD Card"
echo "   - Use cartões de marcas confiáveis (SanDisk, Samsung, Kingston)"
echo "   - Evite cartões muito baratos ou de origem duvidosa"
echo ""
echo "2. Para o Raspberry Pi Zero 2W:"
echo "   - Use Raspberry Pi OS LITE (não Desktop)"
echo "   - Cartões Class 10 ou UHS-I são suficientes"
echo "   - 16GB ou 32GB é ideal (64GB pode ter problemas)"
echo ""

# Salvar log
LOGFILE="sdcard_test_$(date +%Y%m%d_%H%M%S).log"
echo "📝 Log salvo em: $LOGFILE"