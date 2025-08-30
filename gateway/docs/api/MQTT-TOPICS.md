# MQTT Topics - AutoCore Gateway

## 📡 Estrutura de Tópicos

O AutoCore Gateway usa uma estrutura hierárquica de tópicos MQTT para organizar a comunicação com dispositivos ESP32.

### Formato Base
```
autocore/{categoria}/{device_uuid}/{tipo}/{subtipo}
```

## 📋 Tópicos do Sistema

### 1. Device Management

#### Device Announce
**Tópico**: `autocore/devices/{device_uuid}/announce`
**Direção**: ESP32 → Gateway
**QoS**: 1 (At least once)
**Descrição**: Dispositivo se anuncia na rede

**Payload**:
```json
{
  "device_type": "display_small",
  "firmware_version": "1.2.0",
  "capabilities": ["relay", "can_bus", "display"],
  "ip_address": "192.168.1.100",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "relay_count": 4,
  "hardware_revision": "v2.1",
  "serial_number": "ESP32-001"
}
```

#### Device Status
**Tópico**: `autocore/devices/{device_uuid}/status`
**Direção**: ESP32 → Gateway
**QoS**: 0 (At most once)
**Descrição**: Status periódico do dispositivo

**Payload**:
```json
{
  "timestamp": "2025-01-08T10:30:00Z",
  "uptime": 86400,
  "free_memory": 45312,
  "cpu_temperature": 45.5,
  "wifi_signal": -65,
  "battery_level": 87.2,
  "errors": [],
  "last_restart_reason": "normal"
}
```

#### Device Command
**Tópico**: `autocore/devices/{device_uuid}/command`
**Direção**: Gateway → ESP32
**QoS**: 2 (Exactly once)
**Descrição**: Comandos para dispositivo

**Payload**:
```json
{
  "command_id": "cmd_12345",
  "command_type": "relay_control",
  "timestamp": "2025-01-08T10:30:00Z",
  "parameters": {
    "relay_id": 1,
    "state": true,
    "duration": 5000
  },
  "timeout": 30
}
```

#### Device Response
**Tópico**: `autocore/devices/{device_uuid}/response`
**Direção**: ESP32 → Gateway
**QoS**: 1 (At least once)
**Descrição**: Resposta a comandos

**Payload**:
```json
{
  "command_id": "cmd_12345",
  "timestamp": "2025-01-08T10:30:05Z",
  "success": true,
  "execution_time": 2.3,
  "result": {
    "relay_id": 1,
    "previous_state": false,
    "new_state": true
  },
  "error_message": null
}
```

### 2. Telemetry Data

#### Telemetry Stream
**Tópico**: `autocore/devices/{device_uuid}/telemetry`
**Direção**: ESP32 → Gateway
**QoS**: 0 (At most once)
**Descrição**: Dados de sensores em tempo real

**Payload**:
```json
{
  "timestamp": "2025-01-08T10:30:00Z",
  "can_data": {
    "signals": {
      "RPM": {"value": 2500, "unit": "rpm", "can_id": "0x200"},
      "TPS": {"value": 45.2, "unit": "%", "can_id": "0x201"},
      "ECT": {"value": 85.7, "unit": "°C", "can_id": "0x202"}
    }
  },
  "analog_sensors": {
    "fuel_level": 67.8,
    "oil_pressure": 45.2
  },
  "system_status": {
    "cpu_temperature": 42.1,
    "memory_usage": 68,
    "wifi_signal": -58
  },
  "gps": {
    "latitude": -23.5505,
    "longitude": -46.6333,
    "altitude": 760,
    "speed": 65.4,
    "heading": 180.5,
    "satellites": 8,
    "accuracy": 3.2
  }
}
```

### 3. Relay Control

#### Relay Command
**Tópico**: `autocore/devices/{device_uuid}/relay/command`
**Direção**: Gateway → ESP32
**QoS**: 2 (Exactly once)
**Descrição**: Comandos específicos para relés

**Payload**:
```json
{
  "command_id": "relay_cmd_456",
  "timestamp": "2025-01-08T10:30:00Z",
  "relays": [
    {
      "relay_id": 1,
      "action": "turn_on",
      "duration": 5000
    },
    {
      "relay_id": 3, 
      "action": "toggle"
    }
  ]
}
```

#### Relay Status
**Tópico**: `autocore/devices/{device_uuid}/relay/status`
**Direção**: ESP32 → Gateway
**QoS**: 1 (At least once)
**Descrição**: Status dos relés

**Payload**:
```json
{
  "timestamp": "2025-01-08T10:30:00Z",
  "relays": [
    {
      "relay_id": 1,
      "state": true,
      "current": 0.8,
      "voltage": 12.1,
      "temperature": 35.2,
      "switch_count": 1247,
      "last_switched": "2025-01-08T10:29:55Z"
    }
  ],
  "power_consumption": 15.6,
  "errors": []
}
```

### 4. System Topics

#### Gateway Status
**Tópico**: `autocore/devices/{gateway_uuid}/status`
**Direção**: Gateway → Broker
**QoS**: 1 (At least once) 
**Retained**: true
**Descrição**: Status do Gateway

**Payload**:
```json
{
  "protocol_version": "2.2.0",
  "uuid": "gateway-001",
  "timestamp": "2025-01-08T10:30:00Z",
  "message_type": "gateway_status",
  "status": "online",
  "device_type": "gateway",
  "uptime": 86400,
  "devices_online": 5,
  "memory_usage": {
    "ram_mb": 45.2,
    "cpu_percent": 12.5
  }
}
```

#### System Broadcast
**Tópico**: `autocore/system/broadcast`
**Direção**: Gateway → ESP32 (todos)
**QoS**: 1 (At least once)
**Retained**: true
**Descrição**: Mensagens para todos dispositivos

**Payload**:
```json
{
  "message_type": "config_update",
  "timestamp": "2025-01-08T10:30:00Z",
  "data": {
    "ntp_server": "pool.ntp.org",
    "timezone": "America/Sao_Paulo",
    "log_level": "INFO"
  }
}
```

### 5. Discovery

#### Device Discovery
**Tópico**: `autocore/discovery/{device_uuid}`
**Direção**: ESP32 → Gateway
**QoS**: 1 (At least once)
**Descrição**: Descoberta de dispositivos na rede

**Payload**:
```json
{
  "discovery_type": "network_scan",
  "timestamp": "2025-01-08T10:30:00Z",
  "device_info": {
    "ip_address": "192.168.1.105",
    "mac_address": "BB:CC:DD:EE:FF:AA",
    "device_type": "unknown",
    "signal_strength": -72
  }
}
```

## 🔧 Configuração de Tópicos

### Wildcards para Subscrição

O Gateway subscreve aos seguintes patterns:
```python
SUBSCRIPTION_TOPICS = [
    'autocore/devices/+/announce',      # + = qualquer device_uuid
    'autocore/devices/+/status', 
    'autocore/devices/+/telemetry',
    'autocore/devices/+/response',
    'autocore/devices/+/relay/status',
    'autocore/discovery/+',
]
```

### QoS Levels por Tipo

```python
QOS_MAPPING = {
    'command': 2,           # Critical commands
    'relay_command': 2,     # Critical relay control
    'announce': 1,          # Device registration
    'response': 1,          # Command responses
    'relay_status': 1,      # Relay state updates
    'status': 0,            # Regular status updates
    'telemetry': 0,         # High-frequency data
    'discovery': 1,         # Network discovery
    'broadcast': 1          # System messages
}
```

## 📏 Limitações e Boas Práticas

### Tamanhos de Payload
- **Máximo recomendado**: 1KB por mensagem
- **Telemetria**: 512 bytes típico
- **Comandos**: 256 bytes típico
- **Status**: 384 bytes típico

### Frequência de Mensagens
- **Telemetria CAN**: 10Hz (100ms)
- **Status dispositivo**: 0.2Hz (5s)
- **Heartbeat Gateway**: 0.033Hz (30s)
- **Comandos**: Sob demanda

### Retenção de Mensagens
- **Gateway Status**: Retained (último status sempre disponível)
- **System Broadcast**: Retained (configurações persistentes)
- **Demais tópicos**: Não retained (dados temporais)

### Validação de Tópicos

```python
def is_valid_device_topic(topic: str) -> bool:
    """Valida formato de tópico de dispositivo"""
    parts = topic.split('/')
    return (
        len(parts) >= 3 and
        parts[0] == 'autocore' and
        parts[1] == 'devices' and
        len(parts[2]) > 0 and  # UUID não vazio
        parts[2] != '+'        # Não é wildcard
    )
```

## 🔐 Segurança

### Autenticação
- Username/password por dispositivo (opcional)
- Client ID único por dispositivo
- TLS encryption (recomendado para produção)

### Autorização
- ACL por device UUID
- Topics read/write permissions
- Rate limiting por cliente

### Exemplo ACL (mosquitto.conf)
```
# Gateway permissions
user gateway
topic readwrite autocore/devices/+/command
topic readwrite autocore/devices/+/status
topic read autocore/devices/+/telemetry

# Device permissions
pattern read autocore/devices/%c/command
pattern write autocore/devices/%c/status
pattern write autocore/devices/%c/telemetry
```

---

Esta documentação garante comunicação padronizada e confiável entre Gateway e dispositivos ESP32.