# 🔧 API Reference - ESP32-Relay ESP-IDF

Documentação completa das APIs HTTP e MQTT do sistema ESP32-Relay.

## 📖 Índice

- [🌐 HTTP API](#-http-api)
  - [Endpoints Disponíveis](#endpoints-disponíveis)
  - [Configuração](#configuração)
  - [Status e Monitoramento](#status-e-monitoramento)
  - [Controle de Relés](#controle-de-relés)
- [📡 MQTT API](#-mqtt-api)
  - [Estrutura de Tópicos](#estrutura-de-tópicos)
  - [Comandos de Relé](#comandos-de-relé)
  - [Comandos do Sistema](#comandos-do-sistema)
  - [Telemetria](#telemetria)
- [⚡ Sistema Momentâneo](#-sistema-momentâneo)
- [🔍 Exemplos Práticos](#-exemplos-práticos)
- [❌ Códigos de Erro](#-códigos-de-erro)

## 🌐 HTTP API

A API HTTP é utilizada principalmente para configuração inicial e monitoramento via web interface.

### Endpoints Disponíveis

| Método | Endpoint | Função | Autenticação |
|--------|----------|---------|--------------|
| `GET` | `/` | Interface web de configuração | Não |
| `GET` | `/api/status` | Status detalhado do sistema | Não |
| `POST` | `/config` | Salvar configuração | Não |
| `POST` | `/api/relay/<channel>` | Controlar relé específico | Não |
| `POST` | `/reboot` | Reiniciar sistema | Não |
| `POST` | `/reset` | Reset de fábrica | Não |

### Configuração

#### `POST /config`

Salva nova configuração no sistema.

**Content-Type:** `application/x-www-form-urlencoded`

**Parâmetros:**
```
wifi_ssid=MinhaRede
wifi_password=minhaSenha123
backend_ip=192.168.1.100
backend_port=8081
relay_channels=16
device_name=ESP32 Sala Principal
```

**Resposta Sucesso (200):**
```html
<!DOCTYPE html>
<html>
<head>
    <title>ESP32 Relay - Configuração Salva</title>
    <meta http-equiv="refresh" content="5;url=/">
</head>
<body>
    <h2>✅ Configuração Salva com Sucesso!</h2>
    <p>O sistema será reiniciado em 5 segundos...</p>
    <p><a href="/">Voltar</a></p>
</body>
</html>
```

**Resposta Erro (400):**
```html
<!DOCTYPE html>
<html>
<body>
    <h2>❌ Erro na Configuração</h2>
    <p>Parâmetros inválidos ou faltando</p>
    <p><a href="/">Voltar</a></p>
</body>
</html>
```

### Status e Monitoramento

#### `GET /api/status`

Retorna status detalhado do sistema em JSON.

**Resposta (200):**
```json
{
  "device_id": "esp32_relay_93ce30",
  "device_name": "ESP32 Relay Principal", 
  "firmware_version": "2.0.0",
  "build_number": 31,
  "uptime": 3600,
  "wifi_connected": true,
  "wifi_ssid": "AutoCore_Network",
  "ip_address": "192.168.1.105",
  "wifi_rssi": -45,
  "mqtt_connected": true,
  "mqtt_registered": true,
  "free_memory": 45000,
  "min_free_memory": 42000,
  "relay_channels": 16,
  "relay_states": [false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, true],
  "system_info": {
    "chip": "ESP32",
    "cores": 2,
    "flash_size": 4194304,
    "psram": false
  },
  "configuration": {
    "configured": true,
    "backend_ip": "192.168.1.100",
    "backend_port": 8081
  },
  "performance": {
    "http_requests": 127,
    "mqtt_commands": 45,
    "relay_switches": 23,
    "boot_time_ms": 980
  }
}
```

### Controle de Relés

#### `POST /api/relay/<channel>`

Controla relé específico via HTTP.

**URL Examples:**
- `/api/relay/1` - Controlar relé canal 1
- `/api/relay/all` - Controlar todos os relés

**Content-Type:** `application/json`

**Payload:**
```json
{
  "action": "on",        // "on" | "off" | "toggle"
  "is_momentary": false, // opcional: relé momentâneo
  "source": "web"       // opcional: origem do comando
}
```

**Resposta Sucesso (200):**
```json
{
  "status": "success",
  "channel": 1,
  "action": "on",
  "new_state": true,
  "timestamp": "2025-08-11T20:30:00Z"
}
```

**Resposta Erro (400):**
```json
{
  "status": "error",
  "message": "Canal inválido ou ação não suportada",
  "valid_channels": "1-16 ou 'all'",
  "valid_actions": ["on", "off", "toggle"]
}
```

## 📡 MQTT API

A API MQTT é utilizada para integração com o backend AutoCore e controle automatizado.

### Estrutura de Tópicos

**Base Pattern:** `autocore/devices/{device_uuid}/`

Onde `{device_uuid}` é o identificador único do dispositivo (ex: `esp32_relay_93ce30`).

#### Tópicos de Publicação (ESP32 → Broker)

| Tópico | QoS | Retain | Função |
|--------|-----|---------|---------|
| `status` | 1 | true | Status do dispositivo |
| `relays/state` | 1 | true | Estado atual dos relés |
| `telemetry` | 0 | false | Eventos de telemetria |

#### Tópicos de Subscrição (Broker → ESP32)

| Tópico | QoS | Função |
|--------|-----|---------|
| `relay/command` | 1 | Comandos de relé |
| `relay/heartbeat` | 0 | Heartbeat para momentâneos |
| `commands/+` | 1 | Comandos do sistema |

### Comandos de Relé

#### Comando Padrão

**Tópico:** `autocore/devices/{uuid}/relay/command`

```json
{
  "channel": 1,        // 1-16 ou "all"
  "command": "on",     // "on" | "off" | "toggle"
  "source": "api",     // origem do comando
  "user": "admin"      // opcional: usuário
}
```

#### Comando Momentâneo (NEW!)

**Tópico:** `autocore/devices/{uuid}/relay/command`

```json
{
  "channel": 3,
  "command": "on",
  "is_momentary": true,  // Ativa sistema momentâneo
  "source": "automation",
  "user": "system"
}
```

**Resposta (Telemetria):**
```json
{
  "uuid": "esp32_relay_93ce30",
  "board_id": 1,
  "timestamp": "2025-08-11T20:30:00Z",
  "event": "relay_change",
  "channel": 3,
  "state": true,
  "trigger": "mqtt",
  "source": "automation",
  "is_momentary": true
}
```

#### Heartbeat (Para Relés Momentâneos)

**Tópico:** `autocore/devices/{uuid}/relay/heartbeat`

```json
{
  "channel": 3,
  "timestamp": 1699999999
}
```

**Comportamento:**
- **Frequência:** Máximo a cada 100ms (recomendado: 50-100ms)
- **Timeout:** 1000ms (1 segundo sem heartbeat = desliga)
- **Auto-recovery:** Se relé desligar, heartbeat pode religá-lo

### Comandos do Sistema

#### Reset do Sistema

**Tópico:** `autocore/devices/{uuid}/commands/reset`

```json
{
  "command": "reset",
  "type": "all"  // "all" | "relays" | "config"
}
```

**Tipos de Reset:**
- `all` - Reset completo (config + relés + reboot)
- `relays` - Apenas desligar todos os relés
- `config` - Reset configuração para padrão

#### Solicitar Status

**Tópico:** `autocore/devices/{uuid}/commands/status`

```json
{
  "command": "status"
}
```

**Resposta:** Publica no tópico `status` imediatamente.

#### Reiniciar Sistema

**Tópico:** `autocore/devices/{uuid}/commands/reboot`

```json
{
  "command": "reboot",
  "delay": 5  // segundos antes de reiniciar
}
```

#### Atualização OTA

**Tópico:** `autocore/devices/{uuid}/commands/ota`

```json
{
  "command": "ota",
  "url": "http://192.168.1.100:8081/firmware/esp32-relay-v2.1.0.bin",
  "version": "2.1.0",
  "checksum": "md5:a1b2c3d4e5f6..."
}
```

### Telemetria

#### Status do Dispositivo

**Tópico:** `autocore/devices/{uuid}/status`
**QoS:** 1, **Retain:** true

```json
{
  "uuid": "esp32_relay_93ce30",
  "board_id": 1,
  "status": "online",
  "timestamp": "2025-08-11T20:30:00Z",
  "type": "esp32_relay",
  "channels": 16,
  "firmware_version": "2.0.0",
  "hardware_version": "ESP32-WROOM-32",
  "ip_address": "192.168.1.105",
  "wifi_ssid": "AutoCore_Network",
  "wifi_rssi": -45,
  "uptime": 3600,
  "free_memory": 45000,
  "boot_time_ms": 980
}
```

#### Estado dos Relés

**Tópico:** `autocore/devices/{uuid}/relays/state`
**QoS:** 1, **Retain:** true

```json
{
  "uuid": "esp32_relay_93ce30",
  "board_id": 1,
  "timestamp": "2025-08-11T20:30:00Z",
  "channels": {
    "1": false,
    "2": false,
    "3": true,
    "4": false,
    "5": false,
    "6": false,
    "7": false,
    "8": false,
    "9": false,
    "10": false,
    "11": false,
    "12": false,
    "13": false,
    "14": false,
    "15": false,
    "16": false
  },
  "momentary_active": [3]  // Canais com monitoramento ativo
}
```

#### Eventos de Telemetria

**Tópico:** `autocore/devices/{uuid}/telemetry`
**QoS:** 0, **Retain:** false

**Mudança de Estado:**
```json
{
  "uuid": "esp32_relay_93ce30",
  "board_id": 1,
  "timestamp": "2025-08-11T20:30:00Z",
  "event": "relay_change",
  "channel": 3,
  "state": true,
  "trigger": "mqtt",
  "source": "automation",
  "user": "system",
  "is_momentary": true
}
```

**Desligamento de Segurança:**
```json
{
  "uuid": "esp32_relay_93ce30",
  "board_id": 1,
  "timestamp": "2025-08-11T20:30:00Z",
  "event": "safety_shutoff",
  "channel": 3,
  "reason": "heartbeat_timeout",
  "timeout": 1.0,
  "last_heartbeat": "2025-08-11T20:29:59Z"
}
```

## ⚡ Sistema Momentâneo

### API Completa

#### 1. Ativar Relé Momentâneo

```bash
mosquitto_pub -h broker.autocore.local \
  -t "autocore/devices/esp32_relay_93ce30/relay/command" \
  -m '{"channel":3,"command":"on","is_momentary":true,"source":"api"}'
```

#### 2. Loop de Heartbeat (Python)

```python
import time
import json
import paho.mqtt.client as mqtt

client = mqtt.Client()
client.connect("broker.autocore.local", 1883, 60)

channel = 3
while True:
    heartbeat = {
        "channel": channel,
        "timestamp": int(time.time())
    }
    
    client.publish(
        f"autocore/devices/esp32_relay_93ce30/relay/heartbeat",
        json.dumps(heartbeat)
    )
    
    time.sleep(0.1)  # 100ms
```

#### 3. Monitor de Eventos

```bash
# Monitor todos os eventos
mosquitto_sub -h broker.autocore.local \
  -t "autocore/devices/esp32_relay_93ce30/telemetry" \
  -v

# Resultado esperado:
# autocore/devices/esp32_relay_93ce30/telemetry {"event":"relay_change","channel":3,"state":true}
# autocore/devices/esp32_relay_93ce30/telemetry {"event":"safety_shutoff","channel":3,"reason":"heartbeat_timeout"}
```

## 🔍 Exemplos Práticos

### Cenário 1: Configuração Inicial

```bash
# 1. Conectar ao AP do ESP32
wifi_ssid="ESP32-Relay-93ce30"
wifi_password="12345678"

# 2. Acessar interface web
curl http://192.168.4.1/api/status

# 3. Configurar via POST
curl -X POST http://192.168.4.1/config \
  -d "wifi_ssid=MinhaRede" \
  -d "wifi_password=senha123" \
  -d "backend_ip=192.168.1.100" \
  -d "backend_port=8081" \
  -d "relay_channels=16"
```

### Cenário 2: Controle Básico de Relés

```bash
# Via HTTP
curl -X POST http://192.168.1.105/api/relay/1 \
  -H "Content-Type: application/json" \
  -d '{"action":"on","source":"manual"}'

# Via MQTT
mosquitto_pub -h 192.168.1.100 \
  -t "autocore/devices/esp32_relay_93ce30/relay/command" \
  -m '{"channel":1,"command":"on","source":"automation"}'
```

### Cenário 3: Automação com Sistema Momentâneo

```python
#!/usr/bin/env python3
"""
Exemplo: Controle de portão automático
Ativa relé momentâneo e mantém por 10 segundos
"""

import time
import json
import paho.mqtt.client as mqtt

class GateController:
    def __init__(self, broker_host, device_uuid):
        self.client = mqtt.Client()
        self.broker = broker_host
        self.device = device_uuid
        self.base_topic = f"autocore/devices/{device_uuid}"
        
    def activate_gate(self, channel=1, duration=10):
        # 1. Ativar relé momentâneo
        cmd = {
            "channel": channel,
            "command": "on", 
            "is_momentary": True,
            "source": "gate_automation"
        }
        
        self.client.connect(self.broker, 1883, 60)
        self.client.publish(f"{self.base_topic}/relay/command", 
                           json.dumps(cmd))
        
        # 2. Manter ativo com heartbeat
        start_time = time.time()
        while (time.time() - start_time) < duration:
            heartbeat = {
                "channel": channel,
                "timestamp": int(time.time())
            }
            
            self.client.publish(f"{self.base_topic}/relay/heartbeat",
                               json.dumps(heartbeat))
            time.sleep(0.05)  # 50ms heartbeat
            
        # 3. Parar heartbeat = desliga automaticamente
        print(f"Portão ativo por {duration}s - desligando automaticamente")
        self.client.disconnect()

# Uso
gate = GateController("192.168.1.100", "esp32_relay_93ce30")
gate.activate_gate(channel=1, duration=10)
```

### Cenário 4: Monitoramento em Tempo Real

```python
#!/usr/bin/env python3
"""
Monitor completo do sistema ESP32-Relay
"""

import json
import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags, rc):
    print(f"Conectado ao broker (code: {rc})")
    # Subscribe a todos os tópicos do device
    client.subscribe("autocore/devices/esp32_relay_93ce30/+")
    client.subscribe("autocore/devices/esp32_relay_93ce30/relays/+")

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = json.loads(msg.payload.decode())
    
    if topic.endswith('/status'):
        print(f"📊 Status: {payload['status']} - Uptime: {payload['uptime']}s")
    elif topic.endswith('/relays/state'):
        active_relays = [k for k,v in payload['channels'].items() if v]
        print(f"🔌 Relés Ativos: {active_relays}")
    elif topic.endswith('/telemetry'):
        event = payload['event']
        if event == 'relay_change':
            print(f"⚡ Relé {payload['channel']}: {payload['state']}")
        elif event == 'safety_shutoff':
            print(f"🛑 ALERTA: Safety shutoff canal {payload['channel']}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("192.168.1.100", 1883, 60)
client.loop_forever()
```

## ❌ Códigos de Erro

### HTTP Status Codes

| Código | Significado | Exemplo |
|--------|-------------|---------|
| `200` | Sucesso | Operação concluída com sucesso |
| `400` | Bad Request | JSON inválido ou parâmetros faltando |
| `404` | Not Found | Endpoint não existe |
| `405` | Method Not Allowed | Método HTTP não suportado |
| `500` | Internal Server Error | Erro interno do sistema |
| `503` | Service Unavailable | Sistema em manutenção ou sobrecarregado |

### MQTT Error Responses

Quando ocorre erro em comandos MQTT, o sistema publica no tópico de telemetria:

```json
{
  "uuid": "esp32_relay_93ce30",
  "timestamp": "2025-08-11T20:30:00Z",
  "event": "command_error",
  "error_code": "INVALID_CHANNEL",
  "error_message": "Canal deve estar entre 1-16",
  "original_command": {
    "channel": 99,
    "command": "on"
  }
}
```

#### Códigos de Erro MQTT

| Código | Descrição | Ação Recomendada |
|--------|-----------|------------------|
| `INVALID_CHANNEL` | Canal fora do range 1-16 | Verificar número do canal |
| `INVALID_COMMAND` | Comando não reconhecido | Usar: on, off, toggle |
| `JSON_PARSE_ERROR` | JSON malformado | Validar sintaxe JSON |
| `MQTT_NOT_CONNECTED` | Cliente MQTT desconectado | Verificar conectividade |
| `MEMORY_ERROR` | Memória insuficiente | Aguardar ou reiniciar sistema |
| `HARDWARE_ERROR` | Falha de hardware | Verificar conexões físicas |
| `TIMEOUT_ERROR` | Operação expirou | Tentar novamente |

### System Health Check

Para verificar se o sistema está funcionando corretamente:

```bash
# 1. Verificar conectividade
ping 192.168.1.105

# 2. Testar HTTP API
curl -f http://192.168.1.105/api/status | jq '.wifi_connected'

# 3. Testar MQTT
mosquitto_pub -h 192.168.1.100 \
  -t "autocore/devices/esp32_relay_93ce30/commands/status" \
  -m '{"command":"status"}'

# 4. Monitor resposta (timeout 5s)
timeout 5 mosquitto_sub -h 192.168.1.100 \
  -t "autocore/devices/esp32_relay_93ce30/status" \
  -C 1
```

---

## 🔗 Documentação Relacionada

- [📡 Protocolo MQTT](MQTT_PROTOCOL.md) - Especificação completa do protocolo
- [🏗️ Arquitetura](ARCHITECTURE.md) - Arquitetura técnica do sistema
- [⚙️ Configuração](CONFIGURATION.md) - Guia de configuração completo  
- [🛠️ Development](DEVELOPMENT.md) - Guia para desenvolvedores
- [🚨 Troubleshooting](TROUBLESHOOTING.md) - Soluções para problemas

---

**Documento**: API Reference ESP32-Relay  
**Versão**: 2.0.0  
**Última Atualização**: 11 de Agosto de 2025  
**Autor**: AutoCore Team