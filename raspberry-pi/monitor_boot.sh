#!/bin/bash

# Monitor de boot do Raspberry Pi
echo "================================================"
echo "   🔍 Monitor de Boot - Raspberry Pi Zero 2W"
echo "================================================"
echo ""
echo "📍 Este script vai monitorar continuamente até encontrar o Pi"
echo ""

# Função para testar conexão
test_connection() {
    # Tentar por hostname
    if ping -c 1 -W 1 raspberrypi.local >/dev/null 2>&1; then
        return 0
    fi
    
    # Tentar IPs comuns
    for ip in 10.0.10.{1..254}; do
        if timeout 0.2 nc -zv $ip 22 >/dev/null 2>&1; then
            # Tentar conectar como pi
            if ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no pi@$ip "exit" 2>&1 | grep -q "password"; then
                echo $ip
                return 0
            fi
        fi
    done
    
    return 1
}

# Contador
COUNT=0
START_TIME=$(date +%s)

echo "⏱️  Iniciando monitoramento..."
echo "   Tentativa a cada 10 segundos"
echo "   Pressione Ctrl+C para parar"
echo ""

while true; do
    COUNT=$((COUNT + 1))
    ELAPSED=$(($(date +%s) - START_TIME))
    MINS=$((ELAPSED / 60))
    SECS=$((ELAPSED % 60))
    
    echo -n "[$(date '+%H:%M:%S')] Tentativa #$COUNT (${MINS}m ${SECS}s) ... "
    
    # Tentar encontrar
    if RESULT=$(test_connection); then
        echo ""
        echo ""
        echo "================================================"
        echo "🎉 RASPBERRY PI ENCONTRADO!"
        echo "================================================"
        echo ""
        
        if [ "$RESULT" == "0" ]; then
            echo "📍 Hostname: raspberrypi.local"
            IP=$(ping -c 1 raspberrypi.local 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
            echo "📍 IP: $IP"
        else
            echo "📍 IP: $RESULT"
        fi
        
        echo ""
        echo "Para conectar:"
        echo "  ssh pi@raspberrypi.local"
        if [ ! -z "$IP" ]; then
            echo "  ou"
            echo "  ssh pi@$IP"
        fi
        echo ""
        echo "Use a senha que você configurou no Imager"
        echo ""
        
        # Som de notificação (macOS)
        afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true
        
        exit 0
    else
        echo "não encontrado"
    fi
    
    # Dicas baseadas no tempo
    if [ $COUNT -eq 6 ]; then
        echo ""
        echo "💡 Dica: Verifique se a luz verde está piscando"
        echo ""
    elif [ $COUNT -eq 12 ]; then
        echo ""
        echo "💡 Dica: O primeiro boot pode levar até 5 minutos"
        echo ""
    elif [ $COUNT -eq 24 ]; then
        echo ""
        echo "⚠️  Demora anormal. Verificar:"
        echo "   - Luz verde piscando?"
        echo "   - SD Card bem inserido?"
        echo "   - Fonte de alimentação adequada?"
        echo ""
    fi
    
    sleep 10
done