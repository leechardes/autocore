# MQTT Protocol v2.2.0 Specification

## 📡 Visão Geral

O protocolo MQTT v2.2.0 do AutoCore define a comunicação entre displays ESP32 e o sistema backend para controle de dispositivos, telemetria e configuração.

### Características Principais
- **Versão**: 2.2.0
- **Formato**: JSON estruturado
- **QoS**: Variável por tipo de mensagem
- **Heartbeat**: Para comandos momentários
- **UUID**: Identificação única de dispositivos

## 🏗️ Estrutura Base das Mensagens

### Campos Obrigatórios
Todas as mensagens MQTT devem conter:

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z"
}
```

### Device UUID Format
```cpp
// Baseado no MAC address
"esp32-display-{últimos 3 bytes do MAC em hex}"
// Exemplo: "esp32-display-a1b2c3"
```

### ISO Timestamp
```cpp
// Formato ISO 8601 UTC
"YYYY-MM-DDTHH:mm:ssZ"
// Exemplo: "2025-01-18T15:30:45Z"
```

## 🎛️ Comandos de Relay

### Relay Control - SET
**Tópico**: `autocore/devices/{target_uuid}/relays/set`  
**QoS**: 1 (At least once)

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-sender",
  "timestamp": "2025-01-18T15:30:45Z",
  "channel": 1,
  "state": true,
  "function_type": "toggle",
  "user": "display_touch",
  "source_uuid": "esp32-display-sender"
}
```

#### Parâmetros
- **channel**: 1-16 (número do canal)
- **state**: `true`/`false` (estado do relay)
- **function_type**: `"toggle"` | `"momentary"`
- **user**: Identificação do usuário/origem
- **source_uuid**: UUID do dispositivo que enviou o comando

### Relay Status - Feedback
**Tópico**: `autocore/devices/{device_uuid}/relays/status`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "relay-board-xyz789",
  "timestamp": "2025-01-18T15:30:46Z",
  "channel": 1,
  "state": true,
  "confirmation": true,
  "request_id": "esp32-display-abc123_1737216645_42"
}
```

### Heartbeat - Momentary Commands
**Tópico**: `autocore/devices/{target_uuid}/relays/heartbeat`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-sender",
  "timestamp": "2025-01-18T15:30:45Z",
  "channel": 1,
  "source_uuid": "esp32-display-sender",
  "target_uuid": "relay-board-xyz789",
  "sequence": 1
}
```

#### Configuração Heartbeat
```cpp
#define HEARTBEAT_INTERVAL_MS 500    // 500ms entre heartbeats
#define HEARTBEAT_TIMEOUT_MS 1000    // Timeout para resposta
#define MAX_CHANNELS 16              // Máximo canais simultâneos
```

## 🎮 Comandos de Sistema

### Preset Execution
**Tópico**: `autocore/preset/execute`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "preset_id": "living_room_evening",
  "source": "esp32-display-abc123",
  "parameters": {}
}
```

### Mode Control
**Tópico**: `autocore/system/control`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "command_type": "set_mode",
  "mode": "night_mode",
  "user": "display_touch",
  "source_uuid": "esp32-display-abc123"
}
```

### Action Commands
**Tópico**: `autocore/system/control`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "command_type": "action",
  "action": "emergency_stop",
  "user": "display_touch",
  "source_uuid": "esp32-display-abc123",
  "parameters": {
    "reason": "manual_trigger",
    "priority": "high"
  }
}
```

## 📊 Telemetria

### Touch Events
**Tópico**: `autocore/devices/{uuid}/telemetry/touch`  
**QoS**: 0 (Fire and forget)

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "event": "button_press",
  "data": {
    "button_id": "relay_1_toggle",
    "screen": "home",
    "coordinates": {"x": 120, "y": 180},
    "pressure": 512
  }
}
```

### System Status
**Tópico**: `autocore/devices/{uuid}/status`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "status": "online",
  "uptime": 86400,
  "free_heap": 180000,
  "wifi_rssi": -45,
  "display_brightness": 80,
  "last_activity": "2025-01-18T15:25:00Z"
}
```

### System Telemetry
**Tópico**: `autocore/devices/{uuid}/telemetry/system`  
**QoS**: 0

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "metrics": {
    "cpu_freq_mhz": 240,
    "free_heap": 180000,
    "largest_free_block": 65536,
    "wifi_rssi": -45,
    "uptime_seconds": 86400,
    "last_reset_reason": "power_on"
  }
}
```

## ⚙️ Configuração

### Configuration Update
**Tópico**: `autocore/devices/{uuid}/config/update`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "backend-system",
  "timestamp": "2025-01-18T15:30:45Z",
  "config_type": "screen_layout",
  "version": "1.2.3",
  "data": {
    "screens": [...],
    "buttons": [...],
    "theme": {...}
  }
}
```

### Configuration Acknowledgment
**Tópico**: `autocore/devices/{uuid}/config/ack`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:46Z",
  "config_type": "screen_layout",
  "version": "1.2.3",
  "status": "applied",
  "message": "Configuration updated successfully"
}
```

## 🚨 Error Handling

### Error Codes
```cpp
enum ErrorCode {
    ERR_001_COMMAND_FAILED,     // Comando falhou na execução
    ERR_002_INVALID_PAYLOAD,    // Payload JSON inválido
    ERR_003_TIMEOUT,            // Timeout na operação
    ERR_004_UNAUTHORIZED,       // Não autorizado
    ERR_005_DEVICE_BUSY,        // Dispositivo ocupado
    ERR_006_HARDWARE_FAULT,     // Falha de hardware
    ERR_007_NETWORK_ERROR,      // Erro de rede
    ERR_008_PROTOCOL_MISMATCH   // Versão incompatível
};
```

### Error Response
**Tópico**: `autocore/devices/{uuid}/error`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "error_code": "ERR_001",
  "error_type": "command_failed",
  "message": "Failed to execute relay command",
  "context": {
    "original_command": "relay_set",
    "channel": 1,
    "target_device": "relay-board-xyz789"
  }
}
```

## 🔒 Segurança e Validação

### Protocol Version Validation
```cpp
bool validateProtocolVersion(const JsonDocument& doc) {
    if (!doc["protocol_version"].is<String>()) {
        return false;
    }
    String version = doc["protocol_version"];
    return version.startsWith("2.");  // Aceitar 2.x
}
```

### Rate Limiting
```cpp
#define MAX_MESSAGES_PER_SECOND 100
#define MAX_PAYLOAD_SIZE 65536
```

### Timeouts
```cpp
#define COMMAND_TIMEOUT_MS 30000      // 30 segundos para comandos
#define HEARTBEAT_TIMEOUT_MS 1000     // 1 segundo para heartbeat
#define STATUS_INTERVAL_MS 30000      // 30 segundos entre status
```

## 📈 QoS Strategy

| Tipo de Mensagem | QoS | Justificativa |
|------------------|-----|---------------|
| Telemetria | 0 | Performance, dados não críticos |
| Comandos | 1 | Garantir entrega |
| Status | 1 | Confirmar estado |
| Heartbeat | 1 | Controle momento real |
| Configuração | 1 | Dados críticos |
| Erros | 1 | Notificação garantida |

## 🔄 Fluxo de Comunicação

### Comando Relay Toggle
1. Display → `autocore/devices/{relay}/relays/set` (state: true)
2. Relay Board → `autocore/devices/{relay}/relays/status` (confirmation)
3. Display atualiza UI baseado na confirmação

### Comando Relay Momentary
1. Touch Press → `autocore/devices/{relay}/relays/set` (state: true)
2. Iniciar heartbeat a cada 500ms
3. Touch Release → `autocore/devices/{relay}/relays/set` (state: false)
4. Parar heartbeat

### Device Registration
1. Boot → Device Registration via HTTP API
2. Receber credenciais MQTT dinâmicas
3. Conectar MQTT com credenciais
4. Enviar status inicial