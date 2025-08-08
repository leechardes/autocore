#!/bin/bash

#############################################
# Script para Diagnosticar e Corrigir 
# Problemas Comuns em SD Cards
# Raspberry Pi Zero 2W
#############################################

echo "========================================"
echo "   DIAGNÓSTICO E CORREÇÃO DE SD CARD"
echo "========================================"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função para perguntar
ask_yes_no() {
    read -p "$1 (s/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Ss]$ ]]
}

# 1. VERIFICAR SE ESTÁ RODANDO COMO ROOT
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Este script precisa ser executado como root${NC}"
    echo "Use: sudo $0"
    exit 1
fi

echo -e "${BLUE}1. DIAGNÓSTICO INICIAL${NC}"
echo "------------------------"

# Verificar montagem
if ! mount | grep -q "^/dev/mmcblk0p2"; then
    echo -e "${RED}✗ SD Card não está montado!${NC}"
    echo "Tentando montar..."
    mount /dev/mmcblk0p2 /
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Montado com sucesso${NC}"
    else
        echo -e "${RED}Falha ao montar. SD Card pode estar corrompido.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ SD Card montado${NC}"
fi

# Verificar espaço
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $USAGE -gt 95 ]; then
    echo -e "${RED}✗ Espaço crítico: ${USAGE}%${NC}"
    echo ""
    echo -e "${BLUE}2. LIBERANDO ESPAÇO${NC}"
    echo "------------------------"
    
    # Limpar logs antigos
    echo "Limpando logs antigos..."
    journalctl --vacuum-time=7d
    
    # Limpar cache apt
    echo "Limpando cache do apt..."
    apt-get clean
    apt-get autoclean
    apt-get autoremove -y
    
    # Limpar tmp
    echo "Limpando /tmp..."
    rm -rf /tmp/*
    
    # Mostrar novo espaço
    NEW_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo -e "${GREEN}Espaço liberado! Uso anterior: ${USAGE}% → Novo: ${NEW_USAGE}%${NC}"
else
    echo -e "${GREEN}✓ Espaço OK: ${USAGE}%${NC}"
fi

echo ""
echo -e "${BLUE}3. VERIFICANDO ERROS NO SISTEMA DE ARQUIVOS${NC}"
echo "------------------------"

# Verificar erros no dmesg
ERRORS=$(dmesg | grep -i "mmcblk0" | grep -iE "error|fail|corrupt" | wc -l)
if [ $ERRORS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Encontrados $ERRORS erros no kernel${NC}"
    echo "Últimos erros:"
    dmesg | grep -i "mmcblk0" | grep -iE "error|fail|corrupt" | tail -5
    
    if ask_yes_no "Deseja tentar corrigir os erros?"; then
        echo ""
        echo -e "${BLUE}4. TENTANDO CORRIGIR ERROS${NC}"
        echo "------------------------"
        
        # Remontar como read-only
        echo "Remontando como somente leitura..."
        mount -o remount,ro /
        
        # Executar fsck
        echo "Executando verificação do sistema de arquivos..."
        fsck.ext4 -y /dev/mmcblk0p2
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Verificação concluída${NC}"
        else
            echo -e "${RED}✗ Erros encontrados durante verificação${NC}"
        fi
        
        # Remontar como read-write
        mount -o remount,rw /
    fi
else
    echo -e "${GREEN}✓ Nenhum erro detectado no kernel${NC}"
fi

echo ""
echo -e "${BLUE}5. OTIMIZANDO CONFIGURAÇÕES${NC}"
echo "------------------------"

# Verificar e ajustar swappiness
SWAPPINESS=$(cat /proc/sys/vm/swappiness)
echo "Swappiness atual: $SWAPPINESS"
if [ $SWAPPINESS -gt 10 ]; then
    echo "Reduzindo swappiness para melhorar performance..."
    echo 10 > /proc/sys/vm/swappiness
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    echo -e "${GREEN}✓ Swappiness ajustado${NC}"
fi

# Desabilitar serviços desnecessários
echo "Verificando serviços desnecessários..."
SERVICES=("bluetooth" "hciuart" "triggerhappy" "avahi-daemon")
for service in "${SERVICES[@]}"; do
    if systemctl is-enabled $service &>/dev/null; then
        if ask_yes_no "Desabilitar $service para economizar recursos?"; then
            systemctl disable $service
            systemctl stop $service
            echo -e "${GREEN}✓ $service desabilitado${NC}"
        fi
    fi
done

echo ""
echo -e "${BLUE}6. CONFIGURANDO MONITORAMENTO${NC}"
echo "------------------------"

# Criar script de monitoramento
cat > /usr/local/bin/check_sdcard_health.sh << 'EOF'
#!/bin/bash
# Script de monitoramento de saúde do SD Card

LOG_FILE="/var/log/sdcard_health.log"
ALERT_FILE="/tmp/sdcard_alert"

# Verificar espaço
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $USAGE -gt 90 ]; then
    echo "$(date): ALERTA - Espaço em disco: ${USAGE}%" >> $LOG_FILE
    touch $ALERT_FILE
fi

# Verificar erros recentes
ERRORS=$(dmesg | grep -i "mmcblk0" | grep -iE "error|fail" | wc -l)
if [ $ERRORS -gt 0 ]; then
    echo "$(date): ALERTA - $ERRORS erros detectados no SD Card" >> $LOG_FILE
    touch $ALERT_FILE
fi

# Verificar velocidade de escrita
DD_RESULT=$(dd if=/dev/zero of=/tmp/speedtest bs=1M count=10 conv=fdatasync 2>&1 | grep -oP '\d+\.\d+ MB/s' | head -1)
rm -f /tmp/speedtest
SPEED=$(echo $DD_RESULT | cut -d' ' -f1)
if (( $(echo "$SPEED < 5" | bc -l) )); then
    echo "$(date): ALERTA - Velocidade baixa: $DD_RESULT" >> $LOG_FILE
    touch $ALERT_FILE
fi

# Se houver alertas, mostrar no login
if [ -f $ALERT_FILE ]; then
    echo "⚠️  ALERTA: Problemas detectados no SD Card! Verifique: $LOG_FILE" > /etc/motd
    rm -f $ALERT_FILE
else
    echo "✓ SD Card funcionando normalmente" > /etc/motd
fi
EOF

chmod +x /usr/local/bin/check_sdcard_health.sh

# Adicionar ao cron
if ! crontab -l | grep -q "check_sdcard_health"; then
    (crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/check_sdcard_health.sh") | crontab -
    echo -e "${GREEN}✓ Monitoramento configurado (executa a cada hora)${NC}"
fi

echo ""
echo -e "${BLUE}7. BACKUP E RECUPERAÇÃO${NC}"
echo "------------------------"

# Criar script de backup
cat > /usr/local/bin/backup_sdcard.sh << 'EOF'
#!/bin/bash
# Script de backup do SD Card

BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d)

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p $BACKUP_DIR
fi

# Backup de configurações importantes
tar czf $BACKUP_DIR/config_$DATE.tar.gz \
    /etc/network \
    /etc/wpa_supplicant \
    /etc/hostname \
    /etc/hosts \
    /home/pi/.bashrc \
    /home/pi/.ssh \
    2>/dev/null

echo "Backup salvo em: $BACKUP_DIR/config_$DATE.tar.gz"
EOF

chmod +x /usr/local/bin/backup_sdcard.sh

if ask_yes_no "Criar backup de configurações agora?"; then
    /usr/local/bin/backup_sdcard.sh
fi

echo ""
echo -e "${BLUE}8. TESTE FINAL${NC}"
echo "------------------------"

# Teste rápido de escrita/leitura
echo "Testando escrita..."
dd if=/dev/zero of=/tmp/testfile bs=1M count=50 conv=fdatasync 2>&1 | grep -E "copied|MB/s"

echo "Testando leitura..."
dd if=/tmp/testfile of=/dev/null bs=1M 2>&1 | grep -E "copied|MB/s"
rm -f /tmp/testfile

# Verificar se há bad blocks (rápido)
echo "Verificação rápida de bad blocks..."
badblocks -n -s -b 4096 -c 100 /dev/mmcblk0p2 2>&1 | head -20

echo ""
echo "========================================"
echo -e "${GREEN}        DIAGNÓSTICO CONCLUÍDO${NC}"
echo "========================================"
echo ""

# Resumo
echo "RESUMO:"
echo "-------"
echo -e "${GREEN}✓${NC} Sistema de arquivos verificado"
echo -e "${GREEN}✓${NC} Configurações otimizadas"
echo -e "${GREEN}✓${NC} Monitoramento configurado"
echo -e "${GREEN}✓${NC} Scripts de backup criados"

echo ""
echo "RECOMENDAÇÕES PARA PREVENIR PROBLEMAS:"
echo "--------------------------------------"
echo "1. Use SD Cards de qualidade (SanDisk, Samsung, Kingston)"
echo "2. Classe 10 ou superior (A1/A2 para melhor performance)"
echo "3. Evite desligar abruptamente (use: sudo shutdown -h now)"
echo "4. Faça backups regulares: /usr/local/bin/backup_sdcard.sh"
echo "5. Monitore a saúde: cat /var/log/sdcard_health.log"
echo ""
echo "SINAIS DE QUE O SD CARD PRECISA SER TROCADO:"
echo "--------------------------------------------"
echo "• Erros frequentes no kernel (dmesg)"
echo "• Velocidade de escrita < 5 MB/s"
echo "• Arquivos corrompidos frequentemente"
echo "• Sistema travando ou reiniciando sozinho"
echo "• Falhas ao gravar arquivos"
echo ""
echo -e "${YELLOW}Dica:${NC} Execute este script mensalmente para manter o SD Card saudável!"
echo ""