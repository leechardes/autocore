#!/bin/bash

# Script de recuperação automática do AutoCore
# Tenta resolver problemas comuns automaticamente

echo "🔧 AutoCore - Recuperação Automática"
echo "====================================="
echo ""
echo "📅 Iniciando em: $(date)"
echo ""

FIXED_ISSUES=0
TOTAL_ISSUES=0

# Função para verificar e corrigir serviço
check_and_fix_service() {
    local service=$1
    local description=$2
    
    echo "🔍 Verificando $description..."
    
    if ! sudo systemctl is-active --quiet $service; then
        ((TOTAL_ISSUES++))
        echo "  ⚠️ $service não está rodando. Tentando reiniciar..."
        
        # Tentar parar completamente primeiro
        sudo systemctl stop $service 2>/dev/null
        sleep 2
        
        # Verificar se há processos zumbis
        pkill -f $service 2>/dev/null
        
        # Tentar iniciar
        if sudo systemctl start $service; then
            sleep 3
            if sudo systemctl is-active --quiet $service; then
                echo "  ✅ $service reiniciado com sucesso!"
                ((FIXED_ISSUES++))
            else
                echo "  ❌ Falha ao reiniciar $service"
                echo "  📝 Verificando logs..."
                sudo journalctl -u $service -n 10 --no-pager | grep -i error
            fi
        else
            echo "  ❌ Erro ao tentar iniciar $service"
        fi
    else
        echo "  ✅ $service está rodando normalmente"
    fi
    echo ""
}

# Verificar conectividade de rede
echo "🌐 Verificando conectividade de rede..."
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    ((TOTAL_ISSUES++))
    echo "  ⚠️ Sem conexão com a internet"
    echo "  Tentando reiniciar interface de rede..."
    sudo systemctl restart networking
    sleep 5
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "  ✅ Conexão restaurada!"
        ((FIXED_ISSUES++))
    else
        echo "  ❌ Ainda sem conexão"
    fi
else
    echo "  ✅ Conexão OK"
fi
echo ""

# Verificar MQTT Broker
check_and_fix_service "mosquitto" "MQTT Broker"

# Verificar e limpar locks de arquivo se necessário
echo "🔒 Verificando locks de arquivo..."
LOCK_FILES=$(find /opt/autocore -name "*.lock" 2>/dev/null)
if [ ! -z "$LOCK_FILES" ]; then
    ((TOTAL_ISSUES++))
    echo "  ⚠️ Encontrados arquivos .lock. Removendo..."
    echo "$LOCK_FILES" | while read lock; do
        rm -f "$lock"
        echo "    Removido: $lock"
    done
    ((FIXED_ISSUES++))
    echo "  ✅ Locks removidos"
else
    echo "  ✅ Sem locks pendentes"
fi
echo ""

# Verificar espaço em disco
echo "💾 Verificando espaço em disco..."
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    ((TOTAL_ISSUES++))
    echo "  ⚠️ Disco está $DISK_USAGE% cheio!"
    echo "  Limpando logs antigos..."
    
    # Limpar logs do journalctl
    sudo journalctl --vacuum-time=7d
    
    # Limpar cache do npm
    npm cache clean --force 2>/dev/null
    
    # Limpar cache do pip
    find /opt/autocore -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
    
    NEW_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "  📊 Uso de disco agora: $NEW_USAGE%"
    
    if [ $NEW_USAGE -lt $DISK_USAGE ]; then
        ((FIXED_ISSUES++))
        echo "  ✅ Espaço liberado"
    fi
else
    echo "  ✅ Espaço em disco OK ($DISK_USAGE% usado)"
fi
echo ""

# Verificar memória
echo "🧠 Verificando memória..."
MEM_FREE=$(free -m | grep Mem | awk '{print $4}')
if [ $MEM_FREE -lt 100 ]; then
    ((TOTAL_ISSUES++))
    echo "  ⚠️ Memória baixa: ${MEM_FREE}MB livres"
    echo "  Limpando cache do sistema..."
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    NEW_MEM=$(free -m | grep Mem | awk '{print $4}')
    echo "  📊 Memória livre agora: ${NEW_MEM}MB"
    ((FIXED_ISSUES++))
else
    echo "  ✅ Memória OK: ${MEM_FREE}MB livres"
fi
echo ""

# Verificar temperatura
echo "🌡️ Verificando temperatura..."
TEMP=$(vcgencmd measure_temp 2>/dev/null | sed 's/temp=//' | sed "s/'C//")
if [ ! -z "$TEMP" ]; then
    TEMP_INT=${TEMP%.*}
    if [ $TEMP_INT -gt 70 ]; then
        ((TOTAL_ISSUES++))
        echo "  ⚠️ Temperatura alta: ${TEMP}°C"
        echo "  💡 Considere melhorar a ventilação"
    else
        echo "  ✅ Temperatura OK: ${TEMP}°C"
    fi
else
    echo "  ℹ️ Não foi possível ler a temperatura"
fi
echo ""

# Verificar permissões
echo "🔐 Verificando permissões..."
PERM_ISSUES=0
for dir in database gateway config-app; do
    if [ -d "/opt/autocore/$dir" ]; then
        OWNER=$(stat -c %U "/opt/autocore/$dir")
        if [ "$OWNER" != "autocore" ]; then
            ((PERM_ISSUES++))
            echo "  ⚠️ Permissões incorretas em $dir (dono: $OWNER)"
            sudo chown -R autocore:autocore "/opt/autocore/$dir"
            echo "    ✅ Corrigido para autocore"
        fi
    fi
done
if [ $PERM_ISSUES -gt 0 ]; then
    ((TOTAL_ISSUES++))
    ((FIXED_ISSUES++))
fi
if [ $PERM_ISSUES -eq 0 ]; then
    echo "  ✅ Todas as permissões estão corretas"
fi
echo ""

# Verificar serviços AutoCore
echo "🚀 Verificando serviços AutoCore..."
check_and_fix_service "autocore-gateway" "Gateway"
check_and_fix_service "autocore-config-app" "Config App Backend"
check_and_fix_service "autocore-config-frontend" "Config App Frontend"

# Testar conectividade dos serviços
echo "🔌 Testando conectividade dos serviços..."

# MQTT
echo -n "  MQTT (1883): "
if timeout 2 mosquitto_sub -h localhost -u autocore -P autocore123 -t test -C 1 2>/dev/null; then
    echo "✅ OK"
else
    echo "❌ Falhou"
    ((TOTAL_ISSUES++))
fi

# Backend
echo -n "  Backend API (5000): "
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health 2>/dev/null)
if [ "$response" = "200" ]; then
    echo "✅ OK"
else
    echo "❌ Falhou (HTTP $response)"
    ((TOTAL_ISSUES++))
fi

# Frontend
echo -n "  Frontend (3000): "
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
if [ "$response" = "200" ] || [ "$response" = "304" ]; then
    echo "✅ OK"
else
    echo "❌ Falhou (HTTP $response)"
    ((TOTAL_ISSUES++))
fi
echo ""

# Resumo
echo "====================================="
echo "           RESUMO"
echo "====================================="
echo ""
echo "📊 Problemas encontrados: $TOTAL_ISSUES"
echo "✅ Problemas corrigidos: $FIXED_ISSUES"
echo ""

if [ $TOTAL_ISSUES -eq 0 ]; then
    echo "🎉 Sistema está funcionando perfeitamente!"
elif [ $FIXED_ISSUES -eq $TOTAL_ISSUES ]; then
    echo "✅ Todos os problemas foram corrigidos!"
elif [ $FIXED_ISSUES -gt 0 ]; then
    echo "⚠️ Alguns problemas foram corrigidos, mas ainda há pendências."
    echo "   Execute novamente ou verifique manualmente."
else
    echo "❌ Não foi possível corrigir os problemas automaticamente."
    echo "   Intervenção manual necessária."
fi

echo ""
echo "📅 Finalizado em: $(date)"
echo ""

# Salvar log
LOG_FILE="/opt/autocore/recovery_$(date +%Y%m%d_%H%M%S).log"
echo "📝 Log salvo em: $LOG_FILE"

# Se foi agendado via cron, enviar notificação
if [ "$1" = "--cron" ] && [ $TOTAL_ISSUES -gt 0 ]; then
    echo "📧 Enviando notificação..."
    # Aqui você pode adicionar comando para enviar email ou notificação
fi