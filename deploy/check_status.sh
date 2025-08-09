#!/bin/bash

# Script de verificação rápida do status do AutoCore
# Executa no Raspberry Pi para diagnosticar problemas

echo "🔍 AutoCore - Verificação de Status"
echo "===================================="
echo ""
echo "📅 $(date)"
echo "🖥️ $(hostname) - $(hostname -I | awk '{print $1}')"
echo ""

# Verificar serviços
echo "📊 Status dos Serviços:"
echo "-----------------------"
for service in autocore-gateway autocore-config-app autocore-config-frontend mosquitto; do
    if sudo systemctl is-active --quiet $service; then
        uptime=$(sudo systemctl show $service --property=ActiveEnterTimestamp --value 2>/dev/null)
        echo "✅ $service: ATIVO"
    else
        echo "❌ $service: INATIVO"
    fi
done
echo ""

# Verificar portas
echo "🔌 Portas Abertas:"
echo "------------------"
netstat -tln 2>/dev/null | grep -E ':(1883|3000|5000)' | while read line; do
    port=$(echo $line | awk '{print $4}' | rev | cut -d: -f1 | rev)
    case $port in
        1883) echo "✅ Porta $port: MQTT Broker" ;;
        3000) echo "✅ Porta $port: Config App Frontend" ;;
        5000) echo "✅ Porta $port: Config App Backend" ;;
    esac
done
echo ""

# Verificar conectividade
echo "🌐 Teste de Conectividade:"
echo "--------------------------"

# MQTT
timeout 1 mosquitto_sub -h localhost -u autocore -P autocore123 -t test -C 1 2>/dev/null && echo "✅ MQTT: Conectado" || echo "❌ MQTT: Falha"

# Backend API
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health 2>/dev/null)
if [ "$response" = "200" ]; then
    echo "✅ Backend API: Respondendo (HTTP $response)"
else
    echo "❌ Backend API: Não respondendo"
fi

# Frontend
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
if [ "$response" = "200" ] || [ "$response" = "304" ]; then
    echo "✅ Frontend: Respondendo (HTTP $response)"
else
    echo "❌ Frontend: Não respondendo"
fi
echo ""

# Verificar recursos
echo "💻 Recursos do Sistema:"
echo "-----------------------"
echo "🧠 Memória: $(free -h | grep Mem | awk '{print "Total: "$2", Usado: "$3", Livre: "$4}')"
echo "💾 Disco: $(df -h / | tail -1 | awk '{print "Usado: "$3" de "$2" ("$5")"}')"
echo "🌡️ Temperatura: $(vcgencmd measure_temp 2>/dev/null || echo 'N/A')"
echo "⏰ Uptime: $(uptime -p)"
echo ""

# Verificar logs de erro recentes
echo "⚠️ Erros Recentes (últimas 2 horas):"
echo "------------------------------------"
ERROR_COUNT=$(sudo journalctl -p err --since "2 hours ago" 2>/dev/null | wc -l)
if [ $ERROR_COUNT -gt 0 ]; then
    echo "Encontrados $ERROR_COUNT erros. Últimos 5:"
    sudo journalctl -p err --since "2 hours ago" --no-pager | tail -5
else
    echo "✅ Nenhum erro nas últimas 2 horas"
fi
echo ""

# Verificar processos Python
echo "🐍 Processos Python AutoCore:"
echo "-----------------------------"
ps aux | grep -E "(autocore|gateway|config-app)" | grep python | grep -v grep | while read line; do
    pid=$(echo $line | awk '{print $2}')
    cmd=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
    echo "PID $pid: $cmd"
done
echo ""

# URLs de acesso
echo "🌐 URLs de Acesso:"
echo "------------------"
IP=$(hostname -I | awk '{print $1}')
echo "📱 Config App: http://$IP:3000"
echo "🔌 Backend API: http://$IP:5000"
echo "🦟 MQTT Broker: $IP:1883"
echo ""

# Comandos úteis
echo "📝 Comandos Úteis:"
echo "------------------"
echo "Ver logs do gateway:     sudo journalctl -u autocore-gateway -f"
echo "Ver logs do backend:     sudo journalctl -u autocore-config-app -f"
echo "Ver logs do frontend:    sudo journalctl -u autocore-config-frontend -f"
echo "Reiniciar tudo:         sudo systemctl restart autocore-*"
echo "Parar tudo:             sudo systemctl stop autocore-*"
echo ""

# Verificar se precisa de ações
NEEDS_ACTION=false
for service in autocore-gateway autocore-config-app autocore-config-frontend; do
    if ! sudo systemctl is-active --quiet $service; then
        NEEDS_ACTION=true
        break
    fi
done

if [ "$NEEDS_ACTION" = true ]; then
    echo "⚠️ AÇÃO NECESSÁRIA:"
    echo "-------------------"
    echo "Alguns serviços não estão rodando."
    echo "Tente executar: sudo systemctl restart autocore-*"
    echo "Para mais detalhes: sudo ./check_status.sh --verbose"
else
    echo "✅ SISTEMA OPERACIONAL"
    echo "----------------------"
    echo "Todos os serviços estão rodando normalmente!"
fi
echo ""

# Modo verbose
if [ "$1" = "--verbose" ] || [ "$1" = "-v" ]; then
    echo "🔍 MODO DETALHADO"
    echo "=================="
    
    for service in autocore-gateway autocore-config-app autocore-config-frontend; do
        echo ""
        echo "📋 Serviço: $service"
        echo "------------------------"
        sudo systemctl status $service --no-pager | head -20
        echo ""
        echo "📜 Últimos logs:"
        sudo journalctl -u $service -n 10 --no-pager
        echo ""
    done
fi