# 📡 MQTT Protocol - AutoTech HMI Display v2

## 📋 Índice

- [Visão Geral do Protocolo](#visão-geral-do-protocolo)
- [Estrutura de Tópicos](#estrutura-de-tópicos)
- [Mensagens de Sistema](#mensagens-de-sistema)
- [Configuração Dinâmica](#configuração-dinâmica)
- [Controle de Dispositivos](#controle-de-dispositivos)
- [Status e Telemetria](#status-e-telemetria)
- [Sistema de Presets](#sistema-de-presets)
- [Segurança e Autenticação](#segurança-e-autenticação)
- [QoS e Retenção](#qos-e-retenção)
- [Exemplos Práticos](#exemplos-práticos)

## 🎯 Visão Geral do Protocolo

O AutoTech HMI Display v2 utiliza MQTT como protocolo principal de comunicação, implementando uma arquitetura **publish/subscribe** que permite:

- **Configuração dinâmica** via hot-reload
- **Controle em tempo real** de dispositivos
- **Telemetria bidirecional** 
- **Sistema distribuído** com múltiplos dispositivos
- **Escalabilidade horizontal**

### Características Principais
- **QoS 0-2** suportado dependendo da criticidade
- **Retained messages** para configurações persistentes
- **Last Will Testament** para detecção de desconexão
- **Clean Session** configurável por dispositivo
- **Keep Alive** otimizado para ESP32

## 🗂️ Estrutura de Tópicos

### Hierarquia Base
```
autocore/
├── discovery/              # Auto-discovery de dispositivos
├── gateway/                # Gateway central
├── {device_type}_{id}/     # Dispositivos específicos
├── broadcast/              # Mensagens broadcast
└── system/                 # Controle de sistema
```

### Convenções de Nomenclatura
```
autocore/{component}/{device_id}/{category}/{action}

Exemplos:
autocore/hmi_display_1/status/health
autocore/relay_board_1/command/channel
autocore/gateway/config/response
autocore/sensor_board_2/telemetry/data
```

### Device Types Suportados
| Type | Descrição | Exemplo ID |
|------|-----------|------------|
| `hmi_display` | Interface HMI | `hmi_display_1` |
| `relay_board` | Placa de relés | `relay_board_1` |
| `sensor_board` | Placa de sensores | `sensor_board_1` |
| `gateway` | Gateway central | `gateway_main` |
| `4x4_controller` | Controlador 4x4 | `4x4_controller_1` |

## 🔄 Mensagens de Sistema

### Discovery Protocol

#### Device Announce
**Tópico**: `autocore/discovery/announce`
**Payload**:
```json
{
  "device_id": "hmi_display_1",
  "device_type": "hmi_display",
  "firmware_version": "2.0.0",
  "ip_address": "192.168.4.20",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "capabilities": [
    "touchscreen",
    "physical_buttons",
    "status_leds",
    "hot_reload"
  ],
  "uptime": 15432,
  "timestamp": 1674567890
}
```

#### Device Registration
**Tópico**: `autocore/discovery/register`
**Payload**:
```json
{
  "device_id": "hmi_display_1",
  "status": "registered",
  "assigned_topics": [
    "autocore/hmi_display_1/command",
    "autocore/hmi_display_1/status",
    "autocore/gateway/config/response"
  ],
  "config_version": "2.0.1"
}
```

### System Control

#### System Ping
**Request Tópico**: `autocore/system/ping`
**Request Payload**:
```json
{
  "source": "gateway_main",
  "timestamp": 1674567890,
  "sequence": 12345
}
```

**Response Tópico**: `autocore/{device_id}/pong`
**Response Payload**:
```json
{
  "device_id": "hmi_display_1",
  "timestamp": 1674567891,
  "sequence": 12345,
  "uptime": 15433,
  "free_heap": 180000,
  "rssi": -65
}
```

#### Emergency Stop
**Tópico**: `autocore/system/emergency_stop`
**Payload**:
```json
{
  "action": "activate",
  "source": "hmi_display_1",
  "reason": "user_initiated",
  "timestamp": 1674567890,
  "priority": "critical"
}
```

## ⚙️ Configuração Dinâmica

### Configuration Request
**Tópico**: `autocore/gateway/config/request`
**Payload**:
```json
{
  "device_id": "hmi_display_1",
  "config_version": "1.9.5",
  "request_type": "full_config",
  "timestamp": 1674567890
}
```

### Configuration Response
**Tópico**: `autocore/gateway/config/response`
**QoS**: 1 (garantir entrega)
**Retained**: true
**Payload**:
```json
{
  "version": "2.0.0",
  "target_device": "hmi_display_1",
  "config_hash": "sha256:abc123...",
  "timestamp": 1674567891,
  "system": {
    "name": "Veículo Principal",
    "language": "pt-BR",
    "theme": "dark_blue",
    "timeout_screen": 30,
    "brightness": 80
  },
  "screens": {
    "home": {
      "type": "menu",
      "title": "Menu Principal",
      "layout": "grid_2x3",
      "items": [
        {
          "id": "luz_alta",
          "type": "relay",
          "label": "Farol Alto",
          "icon": "light_high",
          "device": "relay_board_1",
          "channel": 1,
          "mode": "toggle",
          "safety": {
            "interlock": ["luz_baixa"],
            "timeout": 0
          }
        }
      ]
    }
  },
  "devices": {
    "relay_board_1": {
      "type": "relay_board",
      "ip": "192.168.4.21",
      "channels": 16,
      "interlocks": {
        "1": [2],
        "2": [1]
      }
    }
  },
  "presets": {
    "trilha_noturna": {
      "name": "Trilha Noturna",
      "icon": "moon",
      "sequence": [
        {"device": "relay_board_1", "channel": 1, "state": true, "delay": 0},
        {"device": "relay_board_1", "channel": 5, "state": true, "delay": 500}
      ]
    }
  }
}
```

### Configuration Update
**Tópico**: `autocore/gateway/config/update`
**Payload**:
```json
{
  "device_id": "hmi_display_1",
  "update_type": "partial",
  "section": "screens.home.items",
  "data": {
    // Apenas a seção modificada
  },
  "version": "2.0.1",
  "timestamp": 1674567892
}
```

### Hot Reload Acknowledgment
**Tópico**: `autocore/hmi_display_1/config/ack`
**Payload**:
```json
{
  "config_version": "2.0.1",
  "status": "applied",
  "reload_time": 1.2,
  "screens_loaded": 3,
  "items_created": 12,
  "memory_used": 125000,
  "timestamp": 1674567893
}
```

## 🎛️ Controle de Dispositivos

### Relay Control

#### Command Request
**Tópico**: `autocore/relay_board_1/command`
**QoS**: 1
**Payload**:
```json
{
  "channel": 1,
  "state": true,
  "source": "hmi_display_1",
  "user": "touch_interface",
  "validate": true,
  "timestamp": 1674567890
}
```

#### Batch Command
**Tópico**: `autocore/relay_board_1/command/batch`
**Payload**:
```json
{
  "commands": [
    {"channel": 1, "state": true, "delay": 0},
    {"channel": 2, "state": false, "delay": 500},
    {"channel": 3, "state": true, "delay": 1000}
  ],
  "source": "preset_system",
  "preset_id": "trilha_noturna",
  "timestamp": 1674567890
}
```

#### Command Response
**Tópico**: `autocore/relay_board_1/response`
**Payload**:
```json
{
  "channel": 1,
  "state": true,
  "result": "success",
  "execution_time": 45,
  "current_draw": 2.3,
  "validation_passed": true,
  "interlocks_checked": ["channel_2"],
  "timestamp": 1674567891
}
```

### Preset Execution

#### Execute Preset
**Tópico**: `autocore/preset/execute`
**Payload**:
```json
{
  "preset_id": "trilha_noturna",
  "source": "hmi_display_1",
  "parameters": {
    "intensity": 80,
    "delay_multiplier": 1.0
  },
  "timestamp": 1674567890
}
```

#### Preset Status
**Tópico**: `autocore/preset/status`
**Payload**:
```json
{
  "preset_id": "trilha_noturna",
  "status": "executing",
  "progress": 60,
  "current_step": 3,
  "total_steps": 5,
  "estimated_completion": 2.5,
  "timestamp": 1674567891
}
```

## 📊 Status e Telemetria

### Device Status

#### Health Status
**Tópico**: `autocore/hmi_display_1/status/health`
**Interval**: 30 segundos
**QoS**: 0
**Payload**:
```json
{
  "status": "healthy",
  "uptime": 15432,
  "free_heap": 180000,
  "min_free_heap": 165000,
  "cpu_usage": 25.5,
  "temperature": 45.2,
  "wifi_rssi": -65,
  "mqtt_queue": 0,
  "last_config_update": 1674567000,
  "timestamp": 1674567890
}
```

#### Operational Status
**Tópico**: `autocore/hmi_display_1/status/operational`
**Interval**: 10 segundos durante operação
**Payload**:
```json
{
  "current_screen": "lighting",
  "screen_stack": ["home", "lighting"],
  "active_items": [
    {"id": "luz_alta", "state": true},
    {"id": "luz_baixa", "state": false}
  ],
  "user_activity": {
    "last_touch": 1674567885,
    "last_button": 1674567880,
    "interaction_count": 42
  },
  "display": {
    "brightness": 80,
    "orientation": 1,
    "backlight_timeout": 30
  },
  "timestamp": 1674567890
}
```

### Telemetry Data

#### Performance Telemetry
**Tópico**: `autocore/hmi_display_1/telemetry/performance`
**Interval**: 60 segundos
**Payload**:
```json
{
  "metrics": {
    "screen_transitions": {
      "total": 156,
      "avg_time": 0.8,
      "max_time": 2.1
    },
    "touch_events": {
      "total": 234,
      "avg_response": 30,
      "max_response": 85
    },
    "config_reloads": {
      "total": 3,
      "avg_time": 1.2,
      "last_reload": 1674567000
    },
    "memory": {
      "heap_fragmentation": 12.5,
      "max_block_size": 65536,
      "allocations_failed": 0
    }
  },
  "timestamp": 1674567890
}
```

#### Error Telemetry
**Tópico**: `autocore/hmi_display_1/telemetry/errors`
**QoS**: 1
**Payload**:
```json
{
  "errors": [
    {
      "code": "MQTT_RECONNECT",
      "message": "MQTT connection lost, reconnecting",
      "timestamp": 1674567800,
      "severity": "warning",
      "count": 1
    }
  ],
  "error_counts": {
    "total_errors": 5,
    "critical_errors": 0,
    "warnings": 3,
    "info": 2
  },
  "timestamp": 1674567890
}
```

## 🎨 Sistema de Presets

### Preset Definition
**Tópico**: `autocore/preset/define`
**QoS**: 1
**Retained**: true
**Payload**:
```json
{
  "preset_id": "setup_acampamento",
  "name": "Setup Acampamento",
  "description": "Configuração automática para acampamento",
  "icon": "camping",
  "category": "outdoor",
  "sequence": [
    {
      "type": "relay_command",
      "device": "relay_board_1",
      "channel": 8,
      "state": true,
      "delay": 0,
      "description": "Ligar luz externa"
    },
    {
      "type": "relay_command", 
      "device": "relay_board_1",
      "channel": 12,
      "state": true,
      "delay": 1000,
      "description": "Ligar bomba d'água"
    },
    {
      "type": "system_command",
      "action": "display_message",
      "message": "Setup de acampamento ativo",
      "duration": 3000,
      "delay": 2000
    }
  ],
  "conditions": {
    "engine_off": true,
    "parking_brake": true
  },
  "timeout": 30000,
  "auto_reverse": true,
  "created_by": "gateway_main",
  "timestamp": 1674567890
}
```

### Preset Execution Log
**Tópico**: `autocore/preset/log`
**Payload**:
```json
{
  "preset_id": "setup_acampamento",
  "execution_id": "exec_001",
  "steps_completed": [
    {
      "step": 1,
      "result": "success",
      "execution_time": 45,
      "timestamp": 1674567891
    },
    {
      "step": 2,
      "result": "success", 
      "execution_time": 120,
      "timestamp": 1674567893
    }
  ],
  "total_execution_time": 3200,
  "final_status": "completed",
  "timestamp": 1674567894
}
```

## 🔐 Segurança e Autenticação

### Authentication Protocol

#### Device Authentication
**Tópico**: `autocore/auth/device_login`
**QoS**: 2
**Payload**:
```json
{
  "device_id": "hmi_display_1",
  "device_type": "hmi_display",
  "auth_method": "certificate",
  "certificate_fingerprint": "SHA256:abcd1234...",
  "challenge_response": "encrypted_response_here",
  "firmware_signature": "signature_here",
  "timestamp": 1674567890
}
```

#### Authentication Response
**Tópico**: `autocore/auth/response`
**Payload**:
```json
{
  "device_id": "hmi_display_1",
  "auth_status": "granted",
  "session_token": "jwt_token_here",
  "permissions": [
    "relay_board_1:control",
    "sensor_board_1:read",
    "config:receive",
    "telemetry:send"
  ],
  "session_expires": 1674654290,
  "timestamp": 1674567890
}
```

### Access Control

#### Permission Check
**Tópico**: `autocore/auth/permission_check`
**Payload**:
```json
{
  "device_id": "hmi_display_1",
  "session_token": "jwt_token_here",
  "requested_action": "relay_board_1:control:channel_1",
  "resource": "relay_board_1",
  "timestamp": 1674567890
}
```

### Audit Trail

#### Security Event
**Tópico**: `autocore/security/event`
**QoS**: 2
**Payload**:
```json
{
  "event_type": "unauthorized_access_attempt",
  "source_device": "unknown_device",
  "source_ip": "192.168.4.99",
  "target_resource": "relay_board_1",
  "action_attempted": "channel_control",
  "severity": "high",
  "blocked": true,
  "timestamp": 1674567890
}
```

## ⚡ QoS e Retenção

### QoS Guidelines

| Tipo de Mensagem | QoS | Retain | Razão |
|------------------|-----|--------|--------|
| **Configuration** | 1 | Yes | Garantir entrega e persistência |
| **Device Commands** | 1 | No | Garantir entrega sem persistir |
| **Status/Health** | 0 | No | Performance, dados temporais |
| **Telemetry** | 0 | No | Volume alto, perda aceitável |
| **Security Events** | 2 | Yes | Crítico, garantir entrega única |
| **Emergency Stop** | 2 | No | Crítico mas temporal |
| **Discovery** | 1 | No | Importante mas temporal |
| **Presets** | 1 | Yes | Importantes e reutilizáveis |

### Retention Policy

#### Retained Messages
```json
{
  "retained_topics": [
    "autocore/gateway/config/response",
    "autocore/preset/define",
    "autocore/security/device_permissions",
    "autocore/discovery/device_registry"
  ],
  "retention_duration": {
    "config": "permanent",
    "presets": "permanent", 
    "security": "7_days",
    "discovery": "24_hours"
  }
}
```

### Last Will Testament

#### HMI Display LWT
**Tópico**: `autocore/hmi_display_1/status/lwt`
**QoS**: 1
**Retained**: true
**Payload**:
```json
{
  "device_id": "hmi_display_1",
  "status": "offline",
  "last_seen": 1674567890,
  "reason": "connection_lost",
  "uptime": 15432,
  "emergency_state": false
}
```

## 💡 Exemplos Práticos

### Cenário 1: Inicialização do Sistema

```bash
# 1. Device announce
mosquitto_pub -h localhost -t "autocore/discovery/announce" -m '{
  "device_id": "hmi_display_1",
  "device_type": "hmi_display",
  "firmware_version": "2.0.0",
  "ip_address": "192.168.4.20"
}'

# 2. Request configuration
mosquitto_pub -h localhost -t "autocore/gateway/config/request" -m '{
  "device_id": "hmi_display_1",
  "config_version": "0.0.0",
  "request_type": "full_config"
}'

# 3. Receive configuration (simulated)
mosquitto_pub -h localhost -t "autocore/gateway/config/response" -r -m '{
  "version": "2.0.0",
  "target_device": "hmi_display_1",
  "system": {"name": "Meu Veículo"},
  "screens": {"home": {...}}
}'
```

### Cenário 2: Controle de Relé

```bash
# Monitor status do relé
mosquitto_sub -h localhost -t "autocore/relay_board_1/status" -v &

# Enviar comando
mosquitto_pub -h localhost -t "autocore/relay_board_1/command" -m '{
  "channel": 1,
  "state": true,
  "source": "hmi_display_1"
}'

# Verificar resposta
mosquitto_sub -h localhost -t "autocore/relay_board_1/response" -v
```

### Cenário 3: Execução de Preset

```bash
# Definir preset
mosquitto_pub -h localhost -t "autocore/preset/define" -r -m '{
  "preset_id": "luzes_noturnas",
  "name": "Luzes Noturnas",
  "sequence": [
    {"device": "relay_board_1", "channel": 1, "state": true},
    {"device": "relay_board_1", "channel": 5, "state": true}
  ]
}'

# Executar preset
mosquitto_pub -h localhost -t "autocore/preset/execute" -m '{
  "preset_id": "luzes_noturnas",
  "source": "hmi_display_1"
}'

# Monitor execução
mosquitto_sub -h localhost -t "autocore/preset/status" -v
```

### Cenário 4: Hot Reload de Configuração

```bash
# Monitor config acknowledgment
mosquitto_sub -h localhost -t "autocore/hmi_display_1/config/ack" -v &

# Enviar configuração atualizada
mosquitto_pub -h localhost -t "autocore/gateway/config/response" -r -m '{
  "version": "2.0.1",
  "target_device": "hmi_display_1",
  "screens": {
    "home": {
      "items": [
        {
          "id": "nova_luz",
          "type": "relay",
          "label": "Nova Luz"
        }
      ]
    }
  }
}'

# Verificar aplicação
# Dispositivo deve enviar ACK automaticamente
```

### Cenário 5: Monitoramento de Sistema

```bash
# Terminal 1: Monitor health
mosquitto_sub -h localhost -t "autocore/+/status/health" -v

# Terminal 2: Monitor operacional
mosquitto_sub -h localhost -t "autocore/+/status/operational" -v  

# Terminal 3: Monitor telemetria
mosquitto_sub -h localhost -t "autocore/+/telemetry/+" -v

# Terminal 4: Monitor erros
mosquitto_sub -h localhost -t "autocore/+/telemetry/errors" -v
```

### Debugging MQTT

```bash
# Monitor todos os tópicos AutoTech
mosquitto_sub -h localhost -t "autocore/#" -v

# Monitor com timestamp
mosquitto_sub -h localhost -t "autocore/#" -v | ts '[%Y-%m-%d %H:%M:%S]'

# Salvar logs
mosquitto_sub -h localhost -t "autocore/#" -v > mqtt_debug.log

# Test broker connectivity
mosquitto_pub -h localhost -t "test" -m "hello"
mosquitto_sub -h localhost -t "test"
```

## 📚 Referências Técnicas

### MQTT Broker Configuration

#### Mosquitto.conf Exemplo
```conf
# Basic settings
port 1883
allow_anonymous false
password_file /etc/mosquitto/passwd

# TLS settings
port 8883
cafile /etc/mosquitto/ca.crt
certfile /etc/mosquitto/server.crt
keyfile /etc/mosquitto/server.key

# Persistence
persistence true
persistence_location /var/lib/mosquitto/

# Logging
log_dest file /var/log/mosquitto/mosquitto.log
log_type error
log_type warning
log_type notice
log_type information

# ACL
acl_file /etc/mosquitto/acl.conf
```

### Performance Recommendations

#### Connection Settings
```cpp
// ESP32 MQTT Client optimal settings
#define MQTT_KEEPALIVE 60
#define MQTT_SOCKET_TIMEOUT 5
#define MQTT_MAX_PACKET_SIZE 20480
#define MQTT_VERSION MQTT_VERSION_3_1_1
#define MQTT_CLEAN_SESSION true
```

#### Topic Design Best Practices
1. **Hierarchical**: Use clear hierarchy (device/category/action)
2. **Specific**: Avoid wildcard subscriptions when possible
3. **Short**: Keep topic names concise but descriptive
4. **Consistent**: Follow naming conventions strictly
5. **Versioned**: Include version in topic structure when needed

---

**Versão**: 2.0.0  
**Última Atualização**: Janeiro 2025  
**Autor**: AutoTech Team  
**Protocolo**: MQTT 3.1.1 / 5.0