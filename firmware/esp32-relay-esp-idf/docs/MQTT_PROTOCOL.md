# 📡 Protocolo MQTT - ESP32-Relay AutoCore

## 📋 Visão Geral

Este documento define o protocolo de comunicação MQTT entre o ESP32-Relay e o sistema AutoCore.

## 🔗 Estrutura de Tópicos

### Base Topic Pattern
```
autocore/devices/{device_uuid}/
```

Onde `device_uuid` é o identificador único do dispositivo (ex: `esp32-504d34313221267d`)

## 📤 Tópicos de Publicação (ESP32 → Backend)

### 1. Status do Dispositivo
**Tópico:** `autocore/devices/{uuid}/status`  
**Retain:** true  
**QoS:** 1  
**Payload:**
```json
{
  "uuid": "esp32-504d34313221267d",
  "board_id": 1,
  "status": "online",  // "online" | "offline"
  "timestamp": "2025-08-11T17:30:00",
  "type": "esp32_relay",
  "channels": 16,
  "firmware_version": "2.0.0",
  "ip_address": "10.0.10.130",
  "wifi_rssi": -45,
  "uptime": 3600,
  "free_memory": 200000
}
```

### 2. Estado dos Relés
**Tópico:** `autocore/devices/{uuid}/relays/state`  
**Retain:** true  
**QoS:** 1  
**Payload:**
```json
{
  "uuid": "esp32-504d34313221267d",
  "board_id": 1,
  "timestamp": "2025-08-11T17:30:00",
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
  }
}
```

### 3. Telemetria
**Tópico:** `autocore/devices/{uuid}/telemetry`  
**Retain:** false  
**QoS:** 0  
**Payload (Mudança de Estado):**
```json
{
  "uuid": "esp32-504d34313221267d",
  "board_id": 1,
  "timestamp": "2025-08-11T17:30:00",
  "event": "relay_change",
  "channel": 3,
  "state": true,
  "trigger": "mqtt",  // "mqtt" | "web" | "button" | "auto"
  "source": "api"     // origem do comando
}
```

**Payload (Desligamento de Segurança):**
```json
{
  "uuid": "esp32-504d34313221267d",
  "board_id": 1,
  "timestamp": "2025-08-11T17:30:00",
  "event": "safety_shutoff",
  "channel": 3,
  "reason": "heartbeat_timeout",
  "timeout": 1.0
}
```

## 📥 Tópicos de Subscrição (Backend → ESP32)

### 1. Comando de Relé
**Tópico:** `autocore/devices/{uuid}/relay/command`  
**QoS:** 1  
**Payload:**
```json
{
  "channel": 1,        // 1-16 ou "all"
  "command": "on",     // "on" | "off" | "toggle"
  "source": "api",     // origem do comando
  "is_momentary": false,  // opcional: relé momentâneo
  "user": "admin"      // opcional: usuário que executou
}
```

### 2. Comandos Gerais
**Tópico:** `autocore/devices/{uuid}/commands/+`  
**QoS:** 1  

#### Reset Command
**Tópico:** `autocore/devices/{uuid}/commands/reset`
```json
{
  "command": "reset",
  "type": "all"  // "all" | "relays" | "config"
}
```

#### Status Request
**Tópico:** `autocore/devices/{uuid}/commands/status`
```json
{
  "command": "status"
}
```

#### Reboot Command
**Tópico:** `autocore/devices/{uuid}/commands/reboot`
```json
{
  "command": "reboot",
  "delay": 5  // segundos antes de reiniciar
}
```

#### OTA Update
**Tópico:** `autocore/devices/{uuid}/commands/ota`
```json
{
  "command": "ota",
  "url": "http://server/firmware.bin",
  "version": "2.1.0",
  "checksum": "md5hash"
}
```

### 3. Heartbeat (Para Relés Momentâneos)
**Tópico:** `autocore/devices/{uuid}/relay/heartbeat`  
**QoS:** 0  
**Payload:**
```json
{
  "channel": 3,
  "timestamp": 1699999999
}
```

## 🔄 Fluxos de Comunicação

### Fluxo de Inicialização
```mermaid
sequenceDiagram
    participant ESP32
    participant MQTT Broker
    participant Backend
    
    ESP32->>MQTT Broker: Connect
    ESP32->>MQTT Broker: Subscribe to /relay/command
    ESP32->>MQTT Broker: Subscribe to /commands/+
    ESP32->>MQTT Broker: Publish /status (online)
    ESP32->>MQTT Broker: Publish /relays/state (initial)
    MQTT Broker->>Backend: Notify device online
```

### Fluxo de Comando de Relé
```mermaid
sequenceDiagram
    participant Backend
    participant MQTT Broker
    participant ESP32
    participant Hardware
    
    Backend->>MQTT Broker: Publish /relay/command
    MQTT Broker->>ESP32: Deliver command
    ESP32->>Hardware: Set relay state
    ESP32->>MQTT Broker: Publish /relays/state
    ESP32->>MQTT Broker: Publish /telemetry
    MQTT Broker->>Backend: Notify state change
```

### Fluxo de Relé Momentâneo
```mermaid
sequenceDiagram
    participant Backend
    participant MQTT Broker
    participant ESP32
    
    Backend->>MQTT Broker: /relay/command (momentary=true)
    MQTT Broker->>ESP32: Deliver command
    ESP32->>ESP32: Start heartbeat monitor
    loop Every 100ms
        Backend->>MQTT Broker: /relay/heartbeat
        MQTT Broker->>ESP32: Heartbeat received
    end
    Note over ESP32: If no heartbeat for 1s
    ESP32->>ESP32: Auto shutoff
    ESP32->>MQTT Broker: Publish /telemetry (safety_shutoff)
```

## 🔐 Segurança e Confiabilidade

### Quality of Service (QoS)
- **QoS 0**: Telemetria, heartbeats (fire-and-forget)
- **QoS 1**: Comandos, estados (garantir entrega)
- **QoS 2**: Não utilizado (overhead desnecessário)

### Retained Messages
- **Status**: Sempre retained (último estado conhecido)
- **State**: Sempre retained (estado atual dos relés)
- **Telemetry**: Nunca retained (eventos temporais)
- **Commands**: Nunca retained (evitar comandos duplicados)

### Last Will Testament (LWT)
```json
{
  "topic": "autocore/devices/{uuid}/status",
  "payload": {
    "uuid": "esp32-504d34313221267d",
    "status": "offline",
    "timestamp": "2025-08-11T17:30:00"
  },
  "retain": true,
  "qos": 1
}
```

## 📊 Métricas e Monitoramento

### Publicação Periódica (a cada 30s)
- Estado dos relés
- Status do dispositivo
- Métricas de sistema (memória, uptime, RSSI)

### Eventos Imediatos
- Mudanças de estado de relé
- Comandos recebidos
- Erros e alertas
- Desligamentos de segurança

## 🛠️ Configuração Recomendada

### ESP32 Settings
```c
#define MQTT_QOS_STATUS     1
#define MQTT_QOS_STATE      1
#define MQTT_QOS_TELEMETRY  0
#define MQTT_QOS_COMMANDS   1

#define MQTT_RETAIN_STATUS  true
#define MQTT_RETAIN_STATE   true
#define MQTT_RETAIN_TELEMETRY false

#define MQTT_KEEPALIVE      60    // segundos
#define MQTT_TIMEOUT        5000  // ms
#define TELEMETRY_INTERVAL  30    // segundos
```

### Broker Settings
```yaml
# mosquitto.conf
max_keepalive 120
persistent_client_expiration 1d
retain_available true
max_queued_messages 1000
```

## 📝 Notas de Implementação

1. **Parsing JSON**: Usar cJSON para parsing eficiente
2. **Buffer Sizes**: Mínimo 1024 bytes para payloads
3. **Error Handling**: Sempre validar JSON antes de processar
4. **Timestamps**: ISO 8601 ou Unix timestamp
5. **Channel Numbering**: 1-16 (não 0-15)
6. **State Values**: Booleanos, não inteiros

## 🔄 Versionamento

- **Protocolo Version**: 1.0.0
- **Compatibilidade**: Backward compatible
- **Breaking Changes**: Anunciados com 30 dias de antecedência

---

**Última Atualização:** 11 de Agosto de 2025  
**Versão do Protocolo:** 1.0.0  
**Maintainer:** AutoCore Team