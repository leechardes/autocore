#!/bin/bash

# Script de teste local do check_status.sh
# Executa simulando o ambiente do Raspberry Pi

echo "==========================================
     VERIFICAÇÕES DE CONECTIVIDADE
=========================================="
echo ""

# Função para testar porta
test_port() {
    local port=$1
    local service=$2
    
    if nc -z localhost $port 2>/dev/null; then
        echo "✅ $service (porta $port): ATIVO"
    else
        echo "❌ $service (porta $port): INATIVO"
    fi
}

# MQTT
echo "🦟 MQTT (porta 1883):"
if command -v mosquitto_sub >/dev/null 2>&1; then
    # Tentar ler senha do .env se existir
    if [ -f ../gateway/.env ]; then
        MQTT_PASS=$(grep MQTT_PASSWORD ../gateway/.env | cut -d'=' -f2)
    else
        MQTT_PASS="autocore123"
    fi
    
    timeout 1 mosquitto_sub -h localhost -u autocore -P "$MQTT_PASS" -t test -C 1 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "   ✅ Conexão OK"
    else
        echo "   ❌ Falha na conexão (verifique usuário/senha)"
    fi
else
    echo "   ⚠️ mosquitto_sub não instalado"
fi

# Backend API
echo ""
echo "🔌 Backend API (porta 8081):"
if command -v curl >/dev/null 2>&1; then
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:8081/health 2>/dev/null || echo "000")
    if [ "$response" = "200" ]; then
        echo "   ✅ Respondendo (HTTP $response)"
    elif [ "$response" = "000" ]; then
        echo "   ❌ Não respondendo (serviço parado ou porta incorreta)"
    else
        echo "   ⚠️ Resposta inesperada (HTTP $response)"
    fi
else
    echo "   ⚠️ curl não instalado"
fi

# Frontend
echo ""
echo "📱 Frontend (porta 8080):"
if command -v curl >/dev/null 2>&1; then
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:8080 2>/dev/null || echo "000")
    if [ "$response" = "200" ] || [ "$response" = "304" ]; then
        echo "   ✅ Respondendo (HTTP $response)"
    elif [ "$response" = "000" ]; then
        echo "   ❌ Não respondendo (serviço parado ou porta incorreta)"
    else
        echo "   ⚠️ Resposta inesperada (HTTP $response)"
    fi
else
    echo "   ⚠️ curl não instalado"
fi

echo ""
echo "==========================================
     PORTAS CONFIGURADAS NO SISTEMA
=========================================="
echo ""
echo "📋 Configuração esperada:"
echo "   • Frontend: 8080"
echo "   • Backend API: 8081"
echo "   • MQTT Broker: 1883"
echo ""

# Verificar quais portas estão realmente abertas
echo "🔍 Portas atualmente abertas:"
if command -v lsof >/dev/null 2>&1; then
    lsof -i -P -n | grep LISTEN | grep -E ':(8080|8081|1883|3000|5000)' | while read line; do
        port=$(echo $line | grep -oE ':[0-9]+' | cut -d: -f2 | head -1)
        process=$(echo $line | awk '{print $1}')
        echo "   • Porta $port: $process"
    done
else
    netstat -tln 2>/dev/null | grep -E ':(8080|8081|1883|3000|5000)' | while read line; do
        port=$(echo $line | awk '{print $4}' | rev | cut -d: -f1 | rev)
        echo "   • Porta $port: ABERTA"
    done
fi

echo ""
echo "==========================================
     DIAGNÓSTICO
=========================================="
echo ""

# Verificar se as portas antigas estão em uso
OLD_PORTS_IN_USE=false
if lsof -i :3000 >/dev/null 2>&1; then
    echo "⚠️ Porta 3000 (antiga frontend) ainda está em uso"
    OLD_PORTS_IN_USE=true
fi
if lsof -i :5000 >/dev/null 2>&1; then
    echo "⚠️ Porta 5000 (antiga backend) ainda está em uso"
    OLD_PORTS_IN_USE=true
fi

if [ "$OLD_PORTS_IN_USE" = true ]; then
    echo ""
    echo "💡 Sugestão: Reinicie os serviços com as novas portas:"
    echo "   make stop && make start"
else
    echo "✅ Portas antigas (3000, 5000) estão livres"
fi

echo ""
echo "📝 Para corrigir problemas de conexão:"
echo "   1. Verifique se os serviços estão rodando nas portas corretas"
echo "   2. Confirme as variáveis de ambiente nos arquivos .env"
echo "   3. Reinicie os serviços se necessário"
echo ""