#!/bin/bash

# Script para debugar o simulador de relés no Raspberry Pi

echo "🔍 Debug do Simulador de Relés - AutoCore"
echo "=========================================="
echo ""

# 1. Verificar se o backend está rodando
echo "1️⃣ Verificando Backend API..."
if curl -s http://localhost:8081/health >/dev/null 2>&1; then
    echo "   ✅ Backend está rodando na porta 8081"
else
    echo "   ❌ Backend não está respondendo"
    echo "   Verifique: sudo journalctl -u autocore-config-app -n 50"
fi
echo ""

# 2. Verificar banco de dados
echo "2️⃣ Verificando Banco de Dados..."
if [ -f /opt/autocore/database/autocore.db ]; then
    echo "   ✅ Banco de dados existe"
    
    # Verificar dispositivos ESP32
    echo "   📊 Dispositivos ESP32_RELAY cadastrados:"
    sqlite3 /opt/autocore/database/autocore.db "SELECT id, uuid, name, type FROM devices WHERE type='esp32_relay';" 2>/dev/null | while IFS='|' read id uuid name type; do
        echo "      • ID: $id | UUID: $uuid | Nome: $name"
    done
    
    # Verificar placas de relé
    echo "   📊 Placas de Relé cadastradas:"
    sqlite3 /opt/autocore/database/autocore.db "SELECT rb.id, rb.device_id, d.name, rb.total_channels FROM relay_boards rb JOIN devices d ON rb.device_id = d.id;" 2>/dev/null | while IFS='|' read id device_id device_name channels; do
        echo "      • ID: $id | Device: $device_name (ID: $device_id) | Canais: $channels"
    done
else
    echo "   ❌ Banco de dados não encontrado em /opt/autocore/database/autocore.db"
fi
echo ""

# 3. Verificar MQTT
echo "3️⃣ Verificando MQTT Broker..."
if sudo systemctl is-active --quiet mosquitto; then
    echo "   ✅ Mosquitto está ativo"
    
    # Testar conexão com credenciais
    if [ -f /opt/autocore/config-app/backend/.env ]; then
        MQTT_USER=$(grep MQTT_USERNAME /opt/autocore/config-app/backend/.env | cut -d'=' -f2)
        MQTT_PASS=$(grep MQTT_PASSWORD /opt/autocore/config-app/backend/.env | cut -d'=' -f2)
        
        if [ ! -z "$MQTT_USER" ] && [ ! -z "$MQTT_PASS" ]; then
            echo "   🔐 Testando autenticação MQTT..."
            if timeout 1 mosquitto_sub -h localhost -u "$MQTT_USER" -P "$MQTT_PASS" -t test -C 1 >/dev/null 2>&1; then
                echo "   ✅ Autenticação MQTT OK (user: $MQTT_USER)"
            else
                echo "   ❌ Falha na autenticação MQTT"
                echo "      User: $MQTT_USER"
                echo "      Verifique a senha em /opt/autocore/config-app/backend/.env"
            fi
        else
            echo "   ⚠️ Credenciais MQTT não encontradas no .env"
        fi
    fi
else
    echo "   ❌ Mosquitto não está rodando"
fi
echo ""

# 4. Verificar logs recentes do backend
echo "4️⃣ Últimos logs do Backend (erros)..."
sudo journalctl -u autocore-config-app -p err -n 10 --no-pager 2>/dev/null | tail -5 || echo "   Sem erros recentes"
echo ""

# 5. Verificar endpoint do simulador
echo "5️⃣ Testando Endpoint do Simulador..."
# Tentar listar simuladores ativos
response=$(curl -s http://localhost:8081/api/simulator/status 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "   Response: $response"
else
    echo "   ⚠️ Endpoint /api/simulator/status não está disponível"
fi
echo ""

# 6. Verificar Python e dependências
echo "6️⃣ Verificando Ambiente Python..."
if [ -d /opt/autocore/config-app/backend/.venv ]; then
    echo "   ✅ Virtual environment existe"
    
    # Verificar paho-mqtt
    /opt/autocore/config-app/backend/.venv/bin/pip list 2>/dev/null | grep -i mqtt | while read pkg version; do
        echo "   📦 $pkg: $version"
    done
else
    echo "   ❌ Virtual environment não encontrado"
fi
echo ""

# 7. Verificar processos Python relacionados
echo "7️⃣ Processos Python AutoCore..."
ps aux | grep -E "python.*autocore" | grep -v grep | while read line; do
    pid=$(echo $line | awk '{print $2}')
    cmd=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
    echo "   • PID $pid: $cmd" | head -c 100
    echo "..."
done
echo ""

# 8. Sugestões
echo "💡 Sugestões de Debug:"
echo "----------------------"
echo "1. Ver logs completos do backend:"
echo "   sudo journalctl -u autocore-config-app -f"
echo ""
echo "2. Reiniciar o backend:"
echo "   sudo systemctl restart autocore-config-app"
echo ""
echo "3. Testar manualmente o simulador:"
echo "   cd /opt/autocore/config-app/backend"
echo "   source .venv/bin/activate"
echo "   python -c 'from simulators.relay_simulator import simulator_manager; print(simulator_manager)'"
echo ""
echo "4. Verificar se o endpoint está registrado:"
echo "   curl http://localhost:8081/docs"
echo ""