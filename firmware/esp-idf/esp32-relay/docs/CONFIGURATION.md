# ⚙️ Guia de Configuração - ESP32-Relay ESP-IDF

Guia completo para configuração do sistema ESP32-Relay ESP-IDF.

## 📖 Índice

- [🚀 Configuração Inicial](#-configuração-inicial)
- [🌐 Configuração WiFi](#-configuração-wifi)
- [📡 Configuração MQTT](#-configuração-mqtt)
- [🔧 Configuração via Menuconfig](#-configuração-via-menuconfig)
- [💾 Configuração NVS](#-configuração-nvs)
- [🔌 Configuração de Hardware](#-configuração-de-hardware)
- [⚡ Sistema Momentâneo](#-sistema-momentâneo)
- [🛠️ Configuração Avançada](#%EF%B8%8F-configuração-avançada)
- [📋 Variáveis de Ambiente](#-variáveis-de-ambiente)
- [🔍 Validação](#-validação)

## 🚀 Configuração Inicial

### Método 1: Interface Web (Recomendado)

1. **Power On**: ESP32 inicia em modo AP
2. **Connect WiFi**: 
   - SSID: `ESP32-Relay-XXXXXX` (onde XXXXXX são últimos 6 dígitos do MAC)
   - Password: `12345678`
3. **Open Browser**: `http://192.168.4.1`
4. **Fill Form**:
   ```
   WiFi Network: [Sua rede WiFi]
   WiFi Password: [Senha da rede]
   Backend IP: 192.168.1.100
   Backend Port: 8081
   Device Name: ESP32 Relay Principal
   Relay Channels: 16
   ```
5. **Save Config**: Click "Salvar Configuração"
6. **Auto Restart**: Sistema reinicia automaticamente

### Método 2: Serial Terminal

```bash
# 1. Conectar ao monitor serial
idf.py monitor

# 2. Aguardar boot e pressionar 'r' para reset config
# 3. Sistema entra em modo AP para configuração
```

### Método 3: Hard Reset

```bash
# 1. Desligar ESP32
# 2. Pressionar e manter botão BOOT
# 3. Ligar ESP32 mantendo BOOT pressionado por 3s
# 4. Soltar BOOT - sistema inicia em modo AP
```

## 🌐 Configuração WiFi

### Configuração Básica

| Parâmetro | Valor Padrão | Descrição |
|-----------|--------------|-----------|
| `WiFi SSID` | - | Nome da rede WiFi |
| `WiFi Password` | - | Senha da rede WiFi |
| `WiFi Timeout` | 15000ms | Timeout para conexão |
| `Reconnect Attempts` | 5 | Tentativas de reconexão |
| `AP Mode SSID` | `ESP32-Relay-XXXXXX` | SSID do modo AP |
| `AP Mode Password` | `12345678` | Senha do modo AP |

### Configuração Avançada WiFi

Via `idf.py menuconfig` → `ESP32 Relay Configuration` → `WiFi Settings`:

```
CONFIG_ESP32_RELAY_WIFI_SSID_MAX_LEN=32
CONFIG_ESP32_RELAY_WIFI_PASSWORD_MAX_LEN=64
CONFIG_ESP32_RELAY_WIFI_TIMEOUT_MS=15000
CONFIG_ESP32_RELAY_WIFI_RECONNECT_ATTEMPTS=5
CONFIG_ESP32_RELAY_AP_PASSWORD="12345678"
CONFIG_ESP32_RELAY_AP_CHANNEL=6
CONFIG_ESP32_RELAY_AP_MAX_CONNECTIONS=4
```

### Modo Dual WiFi

O sistema opera em dual mode inteligente:

```c
// Prioridade de conexão
1. STA Mode (Station) - Conexão à rede existente
2. AP Mode (Access Point) - Apenas se STA falhar
3. Dual Mode - STA + AP simultâneo (avançado)
```

**Configurar Dual Mode:**
```c
// Via menuconfig
CONFIG_ESP32_RELAY_DUAL_MODE=y
```

## 📡 Configuração MQTT

### Parâmetros Básicos

| Parâmetro | Valor Padrão | Descrição |
|-----------|--------------|-----------|
| `Backend IP` | - | IP do servidor AutoCore |
| `Backend Port` | 8081 | Porta do servidor AutoCore |
| `MQTT Broker IP` | (Auto) | IP do broker MQTT |
| `MQTT Broker Port` | 1883 | Porta do broker MQTT |
| `Device UUID` | `esp32_relay_XXXXXX` | ID único do dispositivo |

### Auto-Registro

O sistema realiza auto-registro automático:

```bash
# 1. Sistema conecta ao WiFi
# 2. Faz POST para backend:
curl -X POST http://{backend_ip}:{port}/api/devices \
  -H "Content-Type: application/json" \
  -d '{
    "uuid": "esp32_relay_93ce30",
    "name": "ESP32 Relay Principal",
    "type": "esp32_relay",
    "mac_address": "aa:bb:cc:dd:ee:ff",
    "ip_address": "192.168.1.105"
  }'

# 3. Backend responde com credenciais MQTT
# 4. Sistema conecta ao broker MQTT
```

### Configuração Manual MQTT

Se auto-registro falhar, configure manualmente via `menuconfig`:

```
ESP32 Relay Configuration →
  MQTT Settings →
    [*] Enable Manual MQTT Config
    (192.168.1.100) MQTT Broker IP
    (1883) MQTT Broker Port
    (esp32_relay) MQTT Username
    (password123) MQTT Password
    (esp32_relay_01) Device UUID
```

### Tópicos MQTT

```bash
# Estrutura base
autocore/devices/{device_uuid}/

# Publicação (ESP32 → Broker)
autocore/devices/esp32_relay_93ce30/status
autocore/devices/esp32_relay_93ce30/relays/state  
autocore/devices/esp32_relay_93ce30/telemetry

# Subscrição (Broker → ESP32)
autocore/devices/esp32_relay_93ce30/relay/command
autocore/devices/esp32_relay_93ce30/relay/heartbeat
autocore/devices/esp32_relay_93ce30/commands/+
```

## 🔧 Configuração via Menuconfig

```bash
# Abrir menu de configuração
idf.py menuconfig
```

### Menu Principal: "ESP32 Relay Configuration"

```
ESP32 Relay Configuration  --->
    General Settings  --->
        Device Settings  --->
        WiFi Settings  --->
        MQTT Settings  --->
        Hardware Settings  --->
    Performance Settings  --->
    Debug Settings  --->
    Momentary Relay Settings  --->
```

### Device Settings

```
Device Settings  --->
    (16) Maximum Relay Channels (1-16)
    (esp32_relay) Device Name Prefix
    [*] Enable Device Auto-Registration
    [*] Enable NVS Storage
    (ESP32-WROOM-32) Hardware Version String
    (2.0.0) Firmware Version
```

### Performance Settings

```
Performance Settings  --->
    [*] Enable Dual Core Optimization
    (0) Main Task Core (0-1) 
    (1) MQTT Task Core (0-1)
    (5) Main Task Priority
    (5) MQTT Task Priority
    (8192) Main Task Stack Size
    (4096) MQTT Task Stack Size
    (30) Telemetry Interval (seconds)
```

### Debug Settings

```
Debug Settings  --->
    Log Level
        ( ) None
        ( ) Error
        ( ) Warning  
        (X) Info
        ( ) Debug
        ( ) Verbose
    [*] Enable Serial Monitor
    [*] Enable Performance Monitoring
    [ ] Enable Memory Debug
```

## 💾 Configuração NVS

O sistema usa NVS (Non-Volatile Storage) para persistir configurações.

### Estrutura NVS

```c
// Namespace: "esp32_relay"
typedef struct {
    char device_id[32];           // ID único do dispositivo
    char device_name[64];         // Nome amigável
    bool configured;              // Se foi configurado
    
    // WiFi
    char wifi_ssid[32];
    char wifi_password[64];
    
    // Backend/MQTT
    char backend_ip[16];
    int backend_port;
    char mqtt_broker[16];
    int mqtt_port;
    char mqtt_username[32];
    char mqtt_password[64];
    
    // Hardware
    int relay_channels;
    bool relay_states[16];        // Estados dos relés
    
    // Sistema
    char firmware_version[16];
    char hardware_version[32];
} device_config_t;
```

### Comandos NVS

```bash
# Ver dados NVS
idf.py partition_table
idf.py nvs-dump

# Apagar NVS (factory reset)
idf.py erase_flash
```

### Backup/Restore NVS

```bash
# Backup
idf.py nvs-backup --output backup.bin

# Restore  
idf.py write_flash 0x9000 backup.bin
```

## 🔌 Configuração de Hardware

### Pinout Padrão

```
Canal | GPIO | Função     | Canal | GPIO | Função
------|------|------------|-------|------|--------
0     | 2    | Relé 1     | 8     | 17   | Relé 9
1     | 4    | Relé 2     | 9     | 18   | Relé 10
2     | 5    | Relé 3     | 10    | 19   | Relé 11
3     | 12   | Relé 4     | 11    | 21   | Relé 12
4     | 13   | Relé 5     | 12    | 22   | Relé 13
5     | 14   | Relé 6     | 13    | 23   | Relé 14
6     | 15   | Relé 7     | 14    | 25   | Relé 15
7     | 16   | Relé 8     | 15    | 26   | Relé 16
```

### Configuração de Pinout Customizado

Via `menuconfig` → `Hardware Settings`:

```
Hardware Settings  --->
    [*] Enable Custom GPIO Mapping
    GPIO Mapping  --->
        (2) Relay Channel 1 GPIO
        (4) Relay Channel 2 GPIO
        (5) Relay Channel 3 GPIO
        ... (configurar todos os canais)
```

### Configuração de Pull-up/Pull-down

```c
// Via código ou menuconfig
CONFIG_ESP32_RELAY_GPIO_PULLUP=y      // Pull-up interno
CONFIG_ESP32_RELAY_GPIO_PULLDOWN=n    // Pull-down desabilitado
CONFIG_ESP32_RELAY_ACTIVE_LEVEL=1     // Nível ativo (0=LOW, 1=HIGH)
```

### Proteções de Hardware

```
Hardware Protection  --->
    [*] Enable GPIO Input Protection
    [*] Enable Current Limiting
    [*] Enable Overvoltage Protection
    (100) Maximum Current per Channel (mA)
    (5.5) Maximum Voltage (V)
```

## ⚡ Sistema Momentâneo

### Configuração Momentânea

```
Momentary Relay Settings  --->
    [*] Enable Momentary Relay System
    (1000) Heartbeat Timeout (ms)
    (100) Check Interval (ms)
    (16) Maximum Momentary Channels
    [*] Enable Safety Shutoff
    [*] Enable Heartbeat Telemetry
```

### Timeouts Configuráveis

| Parâmetro | Padrão | Faixa | Descrição |
|-----------|--------|-------|-----------|
| `Heartbeat Timeout` | 1000ms | 500-5000ms | Tempo sem heartbeat = desliga |
| `Check Interval` | 100ms | 50-500ms | Frequência de verificação |
| `Startup Grace` | 2000ms | 1000-10000ms | Tempo inicial sem verificação |

### Configuração por Canal

```c
// Configuração individual por canal
typedef struct {
    int channel;                    // 1-16
    bool momentary_enabled;         // Habilitado para momentâneo
    int timeout_ms;                 // Timeout específico
    int check_interval_ms;          // Intervalo específico
    bool auto_shutoff;              // Shutoff automático
} momentary_channel_config_t;
```

## 🛠️ Configuração Avançada

### Build Configuration

```bash
# Configurações de build específicas
idf.py menuconfig

# Compiler optimizations
Component config → 
    Compiler options →
        [*] Optimize for performance (-O2)
        [*] Enable Link Time Optimization
```

### Memory Configuration

```
Component config →
    ESP32-specific →
        (240) CPU frequency (MHz)
        [*] Support for external RAM
        Main XTAL frequency →
            (X) 40 MHz
```

### Partition Table

Arquivo `partitions.csv`:
```csv
# Name,   Type, SubType, Offset,  Size,     Flags
nvs,      data, nvs,     0x9000,  0x4000,
phy_init, data, phy,     0xd000,  0x1000,
factory,  app,  factory, 0x10000, 0x140000,
storage,  data, spiffs,  0x150000,0x2B0000,
```

### Logging Configuration

```
Component config →
    Log output →
        Default log verbosity (Info)
        [*] Use ANSI terminal colors
        [*] Enable timestamps
        (256) Log buffer size
```

## 📋 Variáveis de Ambiente

### Build Time Variables

```bash
export IDF_PATH=/path/to/esp-idf
export PATH=$PATH:$IDF_PATH/tools

# Configurações específicas do projeto
export ESP32_RELAY_DEFAULT_SSID="AutoCore_Network"
export ESP32_RELAY_DEFAULT_PASSWORD="password123"  
export ESP32_RELAY_DEFAULT_BACKEND="192.168.1.100:8081"
```

### Runtime Configuration

```c
// Via sdkconfig
CONFIG_ESP32_RELAY_DEFAULT_BACKEND_IP="192.168.1.100"
CONFIG_ESP32_RELAY_DEFAULT_BACKEND_PORT=8081
CONFIG_ESP32_RELAY_DEFAULT_AP_PASSWORD="12345678"
CONFIG_ESP32_RELAY_MAX_CHANNELS=16
CONFIG_ESP32_RELAY_WIFI_TIMEOUT_MS=15000
CONFIG_ESP32_RELAY_TELEMETRY_INTERVAL_S=30
```

### Environment Overrides

O sistema permite override de configurações via definições de compilação:

```bash
# Build com configurações customizadas
idf.py build \
  -DCONFIG_ESP32_RELAY_DEFAULT_BACKEND_IP=\"10.0.0.100\" \
  -DCONFIG_ESP32_RELAY_DEFAULT_BACKEND_PORT=9091 \
  -DCONFIG_ESP32_RELAY_MAX_CHANNELS=8
```

## 🔍 Validação

### Validar Configuração

```bash
# 1. Verificar configuração via HTTP
curl http://192.168.1.105/api/status | jq '.configuration'

# 2. Verificar logs de inicialização
idf.py monitor | grep "CONFIG"

# 3. Verificar NVS
idf.py nvs-dump | grep esp32_relay
```

### Validar Conectividade

```bash
# WiFi
ping 192.168.1.105

# Backend
curl -f http://192.168.1.100:8081/api/health

# MQTT
mosquitto_pub -h 192.168.1.100 \
  -t "autocore/devices/esp32_relay_93ce30/commands/status" \
  -m '{"command":"status"}'
```

### Validar Hardware

```python
#!/usr/bin/env python3
"""
Script de validação de hardware
"""

import requests
import json
import time

def test_relay_channels(device_ip, max_channels=16):
    """Testa todos os canais de relé"""
    
    results = []
    
    for channel in range(1, max_channels + 1):
        # Liga relé
        response = requests.post(
            f"http://{device_ip}/api/relay/{channel}",
            json={"action": "on", "source": "validation"}
        )
        
        if response.status_code == 200:
            time.sleep(0.5)  # Aguarda ativação
            
            # Verifica status
            status = requests.get(f"http://{device_ip}/api/status")
            relay_states = status.json()['relay_states']
            
            if relay_states[channel-1]:  # Array 0-indexed
                results.append(f"✅ Canal {channel}: OK")
            else:
                results.append(f"❌ Canal {channel}: Falha na ativação")
                
            # Desliga relé
            requests.post(
                f"http://{device_ip}/api/relay/{channel}",
                json={"action": "off", "source": "validation"}
            )
        else:
            results.append(f"❌ Canal {channel}: Erro HTTP {response.status_code}")
    
    return results

# Executar validação
device_ip = "192.168.1.105"
results = test_relay_channels(device_ip)

for result in results:
    print(result)
```

### Diagnóstico Completo

```bash
#!/bin/bash
# script: diagnose_esp32_relay.sh

echo "🔍 ESP32-Relay Diagnostic Report"
echo "=================================="

# 1. Network connectivity
echo "1. Network Test:"
ping -c 3 192.168.1.105 && echo "✅ Ping OK" || echo "❌ Ping Failed"

# 2. HTTP API
echo "2. HTTP API Test:"
curl -s -f http://192.168.1.105/api/status > /dev/null && echo "✅ HTTP OK" || echo "❌ HTTP Failed"

# 3. Configuration
echo "3. Configuration:"
CONFIG=$(curl -s http://192.168.1.105/api/status | jq '.configuration')
echo $CONFIG | jq '.'

# 4. System Status  
echo "4. System Status:"
STATUS=$(curl -s http://192.168.1.105/api/status)
echo "Uptime: $(echo $STATUS | jq -r '.uptime')s"
echo "Free Memory: $(echo $STATUS | jq -r '.free_memory') bytes"
echo "WiFi RSSI: $(echo $STATUS | jq -r '.wifi_rssi') dBm"

# 5. MQTT Test
echo "5. MQTT Test:"
timeout 5 mosquitto_sub -h 192.168.1.100 \
  -t "autocore/devices/+/status" \
  -C 1 > /dev/null && echo "✅ MQTT OK" || echo "❌ MQTT Failed"

echo "=================================="
echo "✅ Diagnostic Complete"
```

## 📚 Exemplo de Configuração Completa

### Arquivo de Configuração JSON

```json
{
  "device": {
    "name": "ESP32 Relay Sala Principal",
    "location": "Sala de Controle",
    "channels": 16
  },
  "wifi": {
    "ssid": "AutoCore_Network",
    "password": "SecurePassword123!",
    "timeout_ms": 15000,
    "reconnect_attempts": 5
  },
  "backend": {
    "ip": "192.168.1.100",
    "port": 8081,
    "auto_register": true
  },
  "mqtt": {
    "broker": "192.168.1.100", 
    "port": 1883,
    "keepalive": 60,
    "qos_commands": 1,
    "qos_telemetry": 0
  },
  "hardware": {
    "relay_pins": [2,4,5,12,13,14,15,16,17,18,19,21,22,23,25,26],
    "active_level": 1,
    "pullup_enabled": true
  },
  "momentary": {
    "enabled": true,
    "timeout_ms": 1000,
    "check_interval_ms": 100,
    "max_channels": 16
  },
  "performance": {
    "dual_core": true,
    "main_core": 0,
    "mqtt_core": 1,
    "telemetry_interval": 30
  }
}
```

### Script de Aplicação da Configuração

```python
#!/usr/bin/env python3
"""
Aplica configuração completa via HTTP API
"""

import json
import requests
from urllib.parse import urlencode

def apply_config(device_ip, config_file):
    """Aplica configuração a partir de arquivo JSON"""
    
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    # Converte para formato form-data esperado pela API
    form_data = {
        'wifi_ssid': config['wifi']['ssid'],
        'wifi_password': config['wifi']['password'],
        'backend_ip': config['backend']['ip'],
        'backend_port': config['backend']['port'],
        'device_name': config['device']['name'],
        'relay_channels': config['device']['channels']
    }
    
    # Envia configuração
    response = requests.post(
        f"http://{device_ip}/config",
        data=urlencode(form_data),
        headers={'Content-Type': 'application/x-www-form-urlencoded'}
    )
    
    if response.status_code == 200:
        print("✅ Configuração aplicada com sucesso")
        print("⏳ Sistema reiniciando...")
        return True
    else:
        print(f"❌ Erro ao aplicar configuração: {response.status_code}")
        return False

# Uso
apply_config("192.168.4.1", "config.json")
```

---

## 🔗 Links Relacionados

- [🏗️ Arquitetura](ARCHITECTURE.md) - Arquitetura técnica do sistema
- [🔧 API Reference](API.md) - Documentação completa das APIs
- [🛠️ Development](DEVELOPMENT.md) - Guia para desenvolvedores
- [🚀 Deployment](DEPLOYMENT.md) - Instruções de produção
- [🚨 Troubleshooting](TROUBLESHOOTING.md) - Soluções para problemas

---

**Documento**: Guia de Configuração ESP32-Relay  
**Versão**: 2.0.0  
**Última Atualização**: 11 de Agosto de 2025  
**Autor**: AutoCore Team