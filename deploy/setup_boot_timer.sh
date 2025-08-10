#!/bin/bash

# Script para configurar medição de tempo de boot no Raspberry Pi
# Mede o tempo desde o início do boot até todos os serviços estarem prontos

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}⏱️ Configuração de Medição de Tempo de Boot${NC}"
echo "============================================="

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Este script precisa ser executado como root${NC}"
    echo "Use: sudo $0"
    exit 1
fi

# 1. Criar script de boot timing
echo -e "${GREEN}📝 Criando script de medição de boot...${NC}"

cat > /usr/local/bin/autocore-boot-timer.sh << 'EOF'
#!/bin/bash

# Script executado no boot para registrar tempo

BOOT_LOG="/var/log/autocore-boot-time.log"
BOOT_START_FILE="/tmp/boot_start_time"

# Se é o início do boot, registrar tempo
if [ ! -f "$BOOT_START_FILE" ]; then
    date +%s > "$BOOT_START_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Boot iniciado" >> "$BOOT_LOG"
    exit 0
fi

# Função para verificar se todos os serviços estão prontos
check_services_ready() {
    local all_ready=true
    
    # Lista de serviços para verificar
    services=(
        "mosquitto"
        "autocore-gateway"
        "autocore-config-app"
        "autocore-config-frontend"
        "autocore-bluetooth"
    )
    
    for service in "${services[@]}"; do
        if systemctl list-units --full --all | grep -q "$service.service"; then
            if ! systemctl is-active --quiet "$service"; then
                all_ready=false
                break
            fi
        fi
    done
    
    echo $all_ready
}

# Aguardar todos os serviços estarem prontos
max_wait=120  # Máximo 2 minutos
waited=0

while [ $waited -lt $max_wait ]; do
    if [ "$(check_services_ready)" = "true" ]; then
        # Calcular tempo de boot
        BOOT_START=$(cat "$BOOT_START_FILE")
        BOOT_END=$(date +%s)
        BOOT_TIME=$((BOOT_END - BOOT_START))
        
        # Converter para minutos e segundos
        MINUTES=$((BOOT_TIME / 60))
        SECONDS=$((BOOT_TIME % 60))
        
        # Registrar no log
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Boot completo em ${MINUTES}m ${SECONDS}s (${BOOT_TIME}s total)" >> "$BOOT_LOG"
        
        # Salvar último tempo de boot
        echo "$BOOT_TIME" > /var/lib/autocore/last_boot_time
        
        # Limpar arquivo temporário
        rm -f "$BOOT_START_FILE"
        
        # Notificar via MQTT se disponível
        if command -v mosquitto_pub >/dev/null 2>&1; then
            mosquitto_pub -h localhost -t "autocore/system/boot_time" \
                -m "{\"boot_time\": $BOOT_TIME, \"timestamp\": \"$(date -Iseconds)\"}" 2>/dev/null || true
        fi
        
        exit 0
    fi
    
    sleep 1
    waited=$((waited + 1))
done

# Se chegou aqui, timeout
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Boot timeout - nem todos os serviços iniciaram" >> "$BOOT_LOG"
rm -f "$BOOT_START_FILE"
EOF

chmod +x /usr/local/bin/autocore-boot-timer.sh

# 2. Criar serviço systemd para medir tempo no início do boot
echo -e "${GREEN}🔧 Criando serviço de início de boot...${NC}"

cat > /etc/systemd/system/autocore-boot-start.service << EOF
[Unit]
Description=AutoCore Boot Timer Start
DefaultDependencies=no
Before=sysinit.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/autocore-boot-timer.sh
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
EOF

# 3. Criar serviço para medir quando tudo está pronto
cat > /etc/systemd/system/autocore-boot-complete.service << EOF
[Unit]
Description=AutoCore Boot Timer Complete
After=network-online.target multi-user.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/autocore-boot-timer.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# 4. Criar comando para ver tempo de boot
echo -e "${GREEN}📝 Criando comando de consulta...${NC}"

cat > /usr/local/bin/autocore-boot-time << 'EOF'
#!/bin/bash

# Comando para ver informações de boot

echo "⏱️ AutoCore - Informações de Boot"
echo "=================================="
echo ""

# Último tempo de boot
if [ -f /var/lib/autocore/last_boot_time ]; then
    LAST_TIME=$(cat /var/lib/autocore/last_boot_time)
    MINUTES=$((LAST_TIME / 60))
    SECONDS=$((LAST_TIME % 60))
    echo "📊 Último boot: ${MINUTES}m ${SECONDS}s"
else
    echo "📊 Último boot: N/A (primeira inicialização)"
fi

# Uptime atual
echo "⏰ Sistema ligado há: $(uptime -p)"

# Tempo de boot do systemd
SYSTEMD_TIME=$(systemd-analyze | grep "Startup finished" | tail -1)
if [ ! -z "$SYSTEMD_TIME" ]; then
    echo "🔧 Tempo systemd: $SYSTEMD_TIME"
fi

echo ""
echo "📈 Histórico recente de boots:"
echo "------------------------------"
if [ -f /var/log/autocore-boot-time.log ]; then
    tail -5 /var/log/autocore-boot-time.log | while read line; do
        echo "  $line"
    done
else
    echo "  Nenhum registro encontrado"
fi

echo ""
echo "🔍 Análise detalhada do systemd:"
echo "--------------------------------"
systemd-analyze blame | head -10

echo ""
echo "📊 Serviços AutoCore:"
echo "-------------------"
for service in mosquitto autocore-gateway autocore-config-app autocore-config-frontend autocore-bluetooth; do
    if systemctl list-units --full --all | grep -q "$service.service"; then
        status=$(systemctl is-active $service 2>/dev/null || echo "não instalado")
        if [ "$status" = "active" ]; then
            startup_time=$(systemd-analyze blame | grep "$service.service" | awk '{print $1}')
            echo "  ✅ $service: ativo (startup: ${startup_time:-N/A})"
        else
            echo "  ❌ $service: $status"
        fi
    fi
done

echo ""
echo "💡 Dica: Para otimizar o boot, use:"
echo "  systemd-analyze critical-chain"
echo "  systemd-analyze plot > boot.svg"
EOF

chmod +x /usr/local/bin/autocore-boot-time

# 5. Criar diretório para dados
mkdir -p /var/lib/autocore

# 6. Habilitar serviços
echo -e "${GREEN}🚀 Habilitando serviços...${NC}"
systemctl daemon-reload
systemctl enable autocore-boot-start.service
systemctl enable autocore-boot-complete.service

# 7. Criar alias útil
echo -e "${GREEN}📝 Criando alias...${NC}"
echo "alias boottime='autocore-boot-time'" >> /etc/bash.bashrc

echo ""
echo -e "${GREEN}✅ Configuração concluída!${NC}"
echo ""
echo -e "${BLUE}📊 Comandos disponíveis:${NC}"
echo "  autocore-boot-time  - Ver informações de boot"
echo "  boottime           - Alias curto"
echo "  systemd-analyze    - Análise detalhada do systemd"
echo ""
echo -e "${YELLOW}⚠️ O sistema precisa ser reiniciado para começar a medir${NC}"
echo ""
echo "Após o reboot, use 'boottime' para ver o tempo de inicialização"
echo ""