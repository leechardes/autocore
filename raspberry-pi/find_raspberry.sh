#!/bin/bash

# Script para encontrar Raspberry Pi na rede
echo "🔍 Procurando Raspberry Pi na rede..."

# Método 1: Tentar por hostname
echo "Tentando raspberrypi.local..."
if ping -c 1 raspberrypi.local > /dev/null 2>&1; then
    echo "✅ Encontrado via hostname!"
    IP=$(ping -c 1 raspberrypi.local | grep "PING" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    echo "IP: $IP"
    echo ""
    echo "Para conectar:"
    echo "  ssh pi@raspberrypi.local"
    echo "  ou"
    echo "  ssh pi@$IP"
    exit 0
fi

# Método 2: Varrer a rede local
echo "Varrendo rede local..."

# Descobrir o range da rede
NETWORK=$(ipconfig getifaddr en0 | cut -d. -f1-3)

if [ -z "$NETWORK" ]; then
    NETWORK=$(ipconfig getifaddr en1 | cut -d. -f1-3)
fi

echo "Rede: $NETWORK.0/24"

# Fazer ping sweep
for i in {1..254}; do
    (ping -c 1 -W 1 $NETWORK.$i > /dev/null 2>&1 && echo "$NETWORK.$i está ativo") &
done
wait

# Verificar ARP table por MACs da Raspberry Pi
echo ""
echo "Procurando por MACs da Raspberry Pi Foundation..."
arp -a | grep -iE "(b8:27:eb|dc:a6:32|e4:5f:01|28:cd:c1|2c:cf:67|d8:3a:dd)" | while read line; do
    IP=$(echo $line | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
    echo "🎯 Possível Raspberry Pi encontrado: $IP"
    echo "  Testando SSH..."
    if nc -zv -w 2 $IP 22 > /dev/null 2>&1; then
        echo "  ✅ SSH ativo em $IP"
        echo ""
        echo "Para conectar:"
        echo "  ssh pi@$IP"
    fi
done

echo ""
echo "Dica: Se não encontrar, aguarde mais 1-2 minutos e tente novamente"