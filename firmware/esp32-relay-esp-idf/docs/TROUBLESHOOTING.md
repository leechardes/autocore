# 🚨 Troubleshooting - ESP32-Relay ESP-IDF

Guia de solução de problemas comuns do sistema ESP32-Relay.

## 📖 Índice

- [🔧 Problemas de Build](#-problemas-de-build)
- [📶 Problemas de WiFi](#-problemas-de-wifi)
- [📡 Problemas MQTT](#-problemas-mqtt)
- [🔌 Problemas de Hardware](#-problemas-de-hardware)
- [💾 Problemas de Memória](#-problemas-de-memória)
- [⚡ Sistema Momentâneo](#-sistema-momentâneo)
- [🛠️ Ferramentas de Diagnóstico](#%EF%B8%8F-ferramentas-de-diagnóstico)

## 🔧 Problemas de Build

### ESP-IDF não encontrado

**Sintomas:**
```bash
idf.py: command not found
```

**Soluções:**
```bash
# 1. Verificar instalação ESP-IDF
ls $HOME/esp/esp-idf

# 2. Configurar ambiente
. $HOME/esp/esp-idf/export.sh

# 3. Adicionar ao .bashrc permanentemente  
echo '. $HOME/esp/esp-idf/export.sh' >> ~/.bashrc
```

### Erro de dependências

**Sintomas:**
```
Error: esp_idf_version requirement "5.0" is not met
```

**Soluções:**
```bash
# 1. Verificar versão ESP-IDF
idf.py --version

# 2. Atualizar ESP-IDF
cd $HOME/esp/esp-idf
git pull
git submodule update --init --recursive
./install.sh

# 3. Limpar build cache
idf.py fullclean
```

### Erro de compilação C

**Sintomas:**
```
fatal error: 'component.h' file not found
```

**Soluções:**
```bash
# 1. Verificar include paths
idf.py build --verbose

# 2. Limpar e reconstruir
make fullclean
idf.py build

# 3. Verificar CMakeLists.txt
```

## 📶 Problemas de WiFi

### WiFi não conecta

**Sintomas:**
```
WiFi connection failed: ESP_ERR_WIFI_TIMEOUT
```

**Diagnóstico:**
```bash
# 1. Verificar logs WiFi
idf.py monitor --print_filter="wifi*:V,ESP32_RELAY*:D"

# 2. Testar conectividade manual
curl http://192.168.4.1/api/status  # Via AP mode

# 3. Verificar força do sinal
iwlist scan | grep -A 5 "SeuSSID"
```

**Soluções:**
```bash
# 1. Verificar credenciais
# Via interface web: http://192.168.4.1

# 2. Reset configuração WiFi
idf.py monitor
# Pressionar 'r' durante boot para reset

# 3. Verificar configurações de rede
# - SSID correto
# - Senha correta  
# - Rede 2.4GHz (não 5GHz)
# - Sem caracteres especiais
```

### IP não obtido (DHCP)

**Sintomas:**
```
WiFi connected but no IP assigned
```

**Soluções:**
```bash
# 1. Verificar DHCP do router
ping 192.168.1.1  # Gateway padrão

# 2. Configurar IP estático (temporário)
# Via menuconfig: Static IP configuration

# 3. Verificar conflitos de MAC
# Reiniciar router se necessário
```

### Reconnect frequente

**Sintomas:**
```
WiFi disconnected, reason: WIFI_REASON_NO_AP_FOUND
```

**Soluções:**
```bash
# 1. Aumentar timeout de conexão
# Via menuconfig: WiFi timeout settings

# 2. Verificar interferência
# Mudar canal do WiFi no router

# 3. Melhorar qualidade do sinal
# - Aproximar ESP32 do router
# - Verificar antenas
# - Remover obstáculos
```

## 📡 Problemas MQTT

### MQTT não conecta

**Sintomas:**
```
MQTT connection failed: ESP_ERR_MQTT_CONNECTION_REFUSED
```

**Diagnóstico:**
```bash
# 1. Testar broker manualmente
mosquitto_pub -h 192.168.1.100 -t "test" -m "hello"

# 2. Verificar conectividade de rede
ping 192.168.1.100

# 3. Verificar logs MQTT
idf.py monitor --print_filter="MQTT*:V"
```

**Soluções:**
```bash
# 1. Verificar credenciais MQTT
curl http://192.168.1.105/api/status | jq '.configuration'

# 2. Verificar broker status
systemctl status mosquitto

# 3. Verificar firewall
sudo ufw allow 1883
```

### Auto-registro falha

**Sintomas:**
```
Smart MQTT registration failed
```

**Soluções:**
```bash
# 1. Verificar backend acessível
curl http://192.168.1.100:8081/api/health

# 2. Verificar endpoint de registro
curl -X POST http://192.168.1.100:8081/api/devices \
  -H "Content-Type: application/json" \
  -d '{"test": true}'

# 3. Configurar manualmente via menuconfig
idf.py menuconfig
# MQTT Settings → Enable Manual MQTT Config
```

### Comandos MQTT não executam

**Sintomas:**
- Comandos enviados mas relés não respondem

**Diagnóstico:**
```bash
# 1. Monitor tópicos MQTT
mosquitto_sub -h 192.168.1.100 -t "#" -v

# 2. Verificar formato JSON
echo '{"channel":1,"command":"on"}' | jq '.'

# 3. Testar comando manual
mosquitto_pub -h 192.168.1.100 \
  -t "autocore/devices/esp32_relay_93ce30/relay/command" \
  -m '{"channel":1,"command":"on","source":"debug"}'
```

**Soluções:**
```bash
# 1. Verificar UUID do dispositivo
curl http://192.168.1.105/api/status | jq '.device_id'

# 2. Usar tópico correto
# autocore/devices/{device_uuid}/relay/command

# 3. Validar JSON payload
```

## 🔌 Problemas de Hardware

### Relés não funcionam

**Sintomas:**
- Comando recebido mas relé não ativa

**Diagnóstico:**
```bash
# 1. Testar GPIO individualmente
# Via HTTP API:
curl -X POST http://192.168.1.105/api/relay/1 \
  -H "Content-Type: application/json" \
  -d '{"action":"on","source":"test"}'

# 2. Verificar tensão nos pinos
# Usar multímetro nos GPIOs

# 3. Verificar logs de hardware
idf.py monitor --print_filter="RELAY*:D,GPIO*:D"
```

**Soluções:**
```bash
# 1. Verificar conexões físicas
# - Pinos GPIO corretos
# - Alimentação adequada
# - Aterramento comum

# 2. Verificar configuração de pinos
# Via menuconfig: Hardware Settings → GPIO Mapping

# 3. Testar com LED
# Substituir relé por LED + resistor para teste
```

### GPIOs conflitantes

**Sintomas:**
```
GPIO pin already in use
```

**Soluções:**
```bash
# 1. Verificar mapeamento de pinos
cat main/relay_control.c | grep "relay_pins"

# 2. Verificar conflitos com funções ESP32
# Evitar: GPIO 0, 2, 15 (boot pins)
# Evitar: GPIO 6-11 (flash)

# 3. Usar menuconfig para remapear
idf.py menuconfig → Hardware Settings
```

### Alimentação insuficiente

**Sintomas:**
- Reset inesperados
- Relés funcionam parcialmente

**Diagnóstico:**
```bash
# 1. Monitor logs de reset
idf.py monitor | grep "reset"

# 2. Verificar tensão de alimentação
# Medir 3.3V e 5V nos pontos de teste

# 3. Calcular consumo total
# ESP32: ~240mA
# Relés: ~20mA cada (bobina)
```

**Soluções:**
```bash
# 1. Fonte adequada
# Mínimo: 5V/2A para 16 relés + ESP32

# 2. Capacitores de desacoplamento
# 100nF cerâmico + 10uF eletrolítico por relé

# 3. Separar alimentação
# ESP32: 3.3V regulada
# Relés: 5V/12V direto da fonte
```

## 💾 Problemas de Memória

### Heap overflow

**Sintomas:**
```
CORRUPT HEAP: Bad head at 0x3ffb8000
```

**Diagnóstico:**
```bash
# 1. Monitor uso de memória
idf.py monitor | grep "Free heap"

# 2. Ativar heap tracing
# Via menuconfig: Component config → Heap memory debugging

# 3. Análise de tamanho
idf.py size-components
```

**Soluções:**
```bash
# 1. Reduzir buffer sizes
# Via menuconfig: ESP32 Relay Configuration → Buffer sizes

# 2. Otimizar stack sizes
# Verificar tasks com uxTaskGetStackHighWaterMark()

# 3. Liberar recursos não utilizados
# - Desabilitar componentes desnecessários
# - Usar PROGMEM para constantes
```

### Stack overflow

**Sintomas:**
```
***ERROR*** A stack overflow in task mqtt_task has been detected
```

**Soluções:**
```bash
# 1. Aumentar stack size
# xTaskCreatePinnedToCore(..., stack_size, ...)

# 2. Verificar recursão
# Evitar funções recursivas profundas

# 3. Usar heap para buffers grandes
# malloc() em vez de arrays locais
```

### Flash overflow

**Sintomas:**
```
region 'irom0_0_seg' overflowed by X bytes
```

**Soluções:**
```bash
# 1. Ativar otimização de tamanho
# Via menuconfig: Compiler optimization → Size (-Os)

# 2. Remover debugging
# CONFIG_ESP32_RELAY_LOG_LEVEL=2

# 3. Usar partição maior
# Modificar partitions.csv
```

## ⚡ Sistema Momentâneo

### Heartbeat timeout prematuro

**Sintomas:**
- Relé desliga antes do esperado

**Diagnóstico:**
```bash
# 1. Verificar timing de heartbeat
mosquitto_sub -h 192.168.1.100 \
  -t "autocore/devices/+/relay/heartbeat" -v

# 2. Verificar logs de timeout
idf.py monitor --print_filter="MQTT_MOMENTARY*:D"
```

**Soluções:**
```bash
# 1. Ajustar timeout
# Via menuconfig: Momentary Relay Settings → Timeout

# 2. Verificar frequência de heartbeat
# Máximo 100ms entre heartbeats

# 3. Verificar latência de rede
ping -i 0.1 192.168.1.105
```

### Safety shutoff não funciona

**Sintomas:**
- Relé não desliga após timeout

**Diagnóstico:**
```bash
# 1. Verificar timer ESP32
# Logs devem mostrar timer callbacks

# 2. Testar manualmente
# Parar heartbeat e aguardar 1s
```

**Soluções:**
```bash
# 1. Verificar configuração momentânea  
# CONFIG_ESP32_RELAY_MOMENTARY_ENABLED=y

# 2. Verificar mutex locks
# Evitar deadlocks no sistema momentâneo

# 3. Reset sistema momentâneo
curl -X POST http://192.168.1.105/api/relay/all \
  -H "Content-Type: application/json" \
  -d '{"action":"off","source":"reset"}'
```

## 🛠️ Ferramentas de Diagnóstico

### Script de Diagnóstico Completo

```bash
#!/bin/bash
# scripts/diagnose.sh

echo "🔍 ESP32-Relay Diagnostic Tool"
echo "=============================="

DEVICE_IP="192.168.1.105"
MQTT_BROKER="192.168.1.100"

# 1. Network connectivity
echo "1. Network Test:"
if ping -c 3 $DEVICE_IP > /dev/null 2>&1; then
    echo "✅ Ping OK"
else
    echo "❌ Ping Failed - Check network connection"
    exit 1
fi

# 2. HTTP API
echo "2. HTTP API Test:"
if curl -s -f http://$DEVICE_IP/api/status > /dev/null; then
    echo "✅ HTTP API OK"
    
    # Get basic info
    STATUS=$(curl -s http://$DEVICE_IP/api/status)
    echo "   Device ID: $(echo $STATUS | jq -r '.device_id')"
    echo "   Uptime: $(echo $STATUS | jq -r '.uptime')s"
    echo "   Free Memory: $(echo $STATUS | jq -r '.free_memory') bytes"
    echo "   WiFi RSSI: $(echo $STATUS | jq -r '.wifi_rssi') dBm"
else
    echo "❌ HTTP API Failed"
fi

# 3. MQTT connectivity
echo "3. MQTT Test:"
if timeout 5 mosquitto_pub -h $MQTT_BROKER \
   -t "autocore/test" -m "ping" > /dev/null 2>&1; then
    echo "✅ MQTT Broker OK"
else
    echo "❌ MQTT Broker Failed"
fi

# 4. Device registration
echo "4. MQTT Device Test:"
if timeout 10 mosquitto_sub -h $MQTT_BROKER \
   -t "autocore/devices/+/status" -C 1 > /dev/null 2>&1; then
    echo "✅ Device publishing to MQTT"
else
    echo "❌ No MQTT messages from device"
fi

# 5. Relay test
echo "5. Relay Test:"
for i in {1..3}; do
    curl -s -X POST http://$DEVICE_IP/api/relay/$i \
      -H "Content-Type: application/json" \
      -d '{"action":"toggle","source":"diagnostic"}' > /dev/null
    sleep 0.5
done
echo "✅ Relay test commands sent"

echo "=============================="
echo "✅ Diagnostic complete"
```

### Monitor de Performance

```python
#!/usr/bin/env python3
# scripts/performance_monitor.py

import requests
import time
import json
from datetime import datetime

class PerformanceMonitor:
    def __init__(self, device_ip):
        self.device_ip = device_ip
        
    def monitor_continuous(self, interval=10):
        """Monitor device performance continuously"""
        
        print("📊 Performance Monitor Started")
        print("-" * 50)
        
        while True:
            try:
                response = requests.get(
                    f"http://{self.device_ip}/api/status",
                    timeout=5
                )
                
                if response.status_code == 200:
                    data = response.json()
                    
                    timestamp = datetime.now().strftime("%H:%M:%S")
                    uptime = data.get('uptime', 0)
                    memory = data.get('free_memory', 0)
                    rssi = data.get('wifi_rssi', 0)
                    
                    # Performance indicators
                    memory_mb = memory / 1024
                    uptime_hours = uptime / 3600
                    
                    print(f"[{timestamp}] "
                          f"Uptime: {uptime_hours:.1f}h | "
                          f"Memory: {memory_mb:.1f}KB | "
                          f"RSSI: {rssi}dBm")
                          
                    # Alerts
                    if memory < 20000:
                        print("⚠️  LOW MEMORY WARNING")
                    if rssi < -70:
                        print("⚠️  WEAK WIFI SIGNAL")
                        
                else:
                    print(f"❌ HTTP Error: {response.status_code}")
                    
            except Exception as e:
                print(f"❌ Connection error: {e}")
                
            time.sleep(interval)

# Usage
monitor = PerformanceMonitor("192.168.1.105")
monitor.monitor_continuous(interval=5)
```

### Factory Reset Tool

```bash
#!/bin/bash
# scripts/factory_reset.sh

DEVICE_IP="192.168.1.105"

echo "🔄 ESP32-Relay Factory Reset Tool"
echo "=================================="

echo "⚠️  WARNING: This will erase all configuration!"
echo "Device IP: $DEVICE_IP"
echo ""
read -p "Are you sure? (type 'YES' to confirm): " confirm

if [ "$confirm" != "YES" ]; then
    echo "❌ Factory reset cancelled"
    exit 1
fi

echo "🔄 Performing factory reset..."

# Method 1: HTTP API
curl -X POST http://$DEVICE_IP/reset \
  -H "Content-Type: application/json" \
  -d '{"confirm": true, "type": "factory"}'

if [ $? -eq 0 ]; then
    echo "✅ Factory reset command sent via HTTP"
else
    echo "⚠️  HTTP method failed, trying MQTT..."
    
    # Method 2: MQTT (if available)
    mosquitto_pub -h 192.168.1.100 \
      -t "autocore/devices/+/commands/reset" \
      -m '{"command":"reset","type":"factory","confirm":true}'
fi

echo ""
echo "📱 Device should restart in AP mode:"
echo "   SSID: ESP32-Relay-XXXXXX"  
echo "   Password: 12345678"
echo "   Config URL: http://192.168.4.1"
echo ""
echo "✅ Factory reset complete"
```

---

## 🔗 Links Relacionados

- [⚙️ Configuração](CONFIGURATION.md) - Configuração detalhada  
- [🛠️ Development](DEVELOPMENT.md) - Guia para desenvolvedores
- [🚀 Deployment](DEPLOYMENT.md) - Instruções de produção
- [🏗️ Arquitetura](ARCHITECTURE.md) - Arquitetura do sistema
- [🔧 API Reference](API.md) - Documentação das APIs

---

**Documento**: Troubleshooting ESP32-Relay  
**Versão**: 2.0.0  
**Última Atualização**: 11 de Agosto de 2025  
**Autor**: AutoCore Team