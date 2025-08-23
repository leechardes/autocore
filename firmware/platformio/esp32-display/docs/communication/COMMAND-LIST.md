# Lista Completa de Comandos MQTT

## 🎛️ Comandos de Relay

### 1. Relay Control (SET)
**Comando**: Controlar estado de relay individual  
**Tópico**: `autocore/devices/{target_uuid}/relays/set`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "channel": 1,
  "state": true,
  "function_type": "toggle",
  "user": "display_touch",
  "source_uuid": "esp32-display-abc123"
}
```

**Parâmetros**:
- `channel`: 1-16 (número do canal)
- `state`: `true`/`false` 
- `function_type`: `"toggle"` | `"momentary"`

**Tipos de Função**:
- **toggle**: Liga/desliga e mantém estado
- **momentary**: Liga apenas enquanto pressionado

### 2. Relay Heartbeat
**Comando**: Manter relay ativo (comandos momentários)  
**Tópico**: `autocore/devices/{target_uuid}/relays/heartbeat`  
**QoS**: 1  
**Frequência**: 500ms

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "channel": 1,
  "source_uuid": "esp32-display-abc123",
  "target_uuid": "relay-board-xyz789",
  "sequence": 1
}
```

## 🎮 Comandos de Sistema

### 3. Preset Execution
**Comando**: Executar preset configurado  
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

**Presets Comuns**:
- `"all_lights_on"` - Todas as luzes
- `"all_lights_off"` - Desligar tudo
- `"living_room_evening"` - Cenário sala noite
- `"bedroom_morning"` - Cenário quarto manhã
- `"security_mode"` - Modo segurança

### 4. Mode Control
**Comando**: Alterar modo do sistema  
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

**Modos Disponíveis**:
- `"normal_mode"` - Operação normal
- `"night_mode"` - Modo noturno
- `"eco_mode"` - Economia de energia
- `"security_mode"` - Modo segurança
- `"maintenance_mode"` - Manutenção

### 5. Action Commands
**Comando**: Executar ação específica  
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
    "reason": "manual_trigger"
  }
}
```

**Ações Disponíveis**:
- `"emergency_stop"` - Parada de emergência
- `"system_restart"` - Reiniciar sistema
- `"config_reload"` - Recarregar configuração
- `"backup_settings"` - Backup configurações
- `"factory_reset"` - Reset fábrica

## 📊 Comandos de Telemetria

### 6. Touch Event
**Comando**: Reportar evento de toque  
**Tópico**: `autocore/devices/{uuid}/telemetry/touch`  
**QoS**: 0

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

**Tipos de Evento**:
- `"button_press"` - Botão pressionado
- `"button_release"` - Botão liberado
- `"screen_change"` - Mudança de tela
- `"gesture"` - Gesto detectado

### 7. System Status
**Comando**: Reportar status do sistema  
**Tópico**: `autocore/devices/{uuid}/status`  
**QoS**: 1  
**Frequência**: 30 segundos

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

### 8. System Metrics
**Comando**: Métricas detalhadas do sistema  
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
    "temperature": 45.5
  }
}
```

## ⚙️ Comandos de Configuração

### 9. Configuration Update
**Comando**: Atualizar configuração do dispositivo  
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

**Tipos de Configuração**:
- `"screen_layout"` - Layout das telas
- `"button_mapping"` - Mapeamento botões
- `"theme"` - Tema visual
- `"network"` - Configurações rede
- `"system"` - Configurações sistema

### 10. Configuration Acknowledgment
**Comando**: Confirmar aplicação de configuração  
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

## 🔧 Comandos de Device Management

### 11. Device Registration
**Comando**: Registrar dispositivo no sistema  
**Método**: HTTP POST (não MQTT)  
**Endpoint**: `/api/v1/devices/register`

```json
{
  "device_type": "esp32_display",
  "uuid": "esp32-display-abc123",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "firmware_version": "1.0.0",
  "hardware_revision": "v2.1",
  "capabilities": ["touch", "display", "wifi"]
}
```

### 12. OTA Update Notification
**Comando**: Notificar atualização disponível  
**Tópico**: `autocore/devices/{uuid}/ota/available`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "backend-system",
  "timestamp": "2025-01-18T15:30:45Z",
  "version": "1.1.0",
  "url": "https://ota.autocore.com/firmware/v1.1.0.bin",
  "checksum": "sha256:abc123...",
  "mandatory": false,
  "release_notes": "Bug fixes and improvements"
}
```

## 🚨 Comandos de Error e Debug

### 13. Error Report
**Comando**: Reportar erro do dispositivo  
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

### 14. Debug Information
**Comando**: Informações de debug  
**Tópico**: `autocore/devices/{uuid}/debug`  
**QoS**: 0

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-abc123",
  "timestamp": "2025-01-18T15:30:45Z",
  "debug_level": "info",
  "component": "touch_handler",
  "message": "Touch calibration completed",
  "data": {
    "x_cal": [300, 3700],
    "y_cal": [300, 3700]
  }
}
```

## 📱 Comandos Específicos do Display

### 15. Display Control
**Comando**: Controlar display (brilho, sleep)  
**Tópico**: `autocore/devices/{uuid}/display/control`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "backend-system",
  "timestamp": "2025-01-18T15:30:45Z",
  "command": "set_brightness",
  "value": 80
}
```

**Comandos Disponíveis**:
- `"set_brightness"` - Ajustar brilho (0-100)
- `"sleep"` - Colocar display em sleep
- `"wake"` - Acordar display
- `"calibrate_touch"` - Calibrar touch
- `"show_message"` - Exibir mensagem

### 16. Screen Navigation
**Comando**: Navegar entre telas  
**Tópico**: `autocore/devices/{uuid}/screen/navigate`  
**QoS**: 1

```json
{
  "protocol_version": "2.2.0",
  "uuid": "backend-system",
  "timestamp": "2025-01-18T15:30:45Z",
  "screen_id": "settings",
  "transition": "slide_left"
}
```

## 📋 Resumo por Categoria

### Controle de Dispositivos (6 comandos)
1. Relay Control SET
2. Relay Heartbeat
3. Preset Execution
4. Mode Control
5. Action Commands
6. Display Control

### Telemetria (3 comandos)
7. Touch Events
8. System Status  
9. System Metrics

### Configuração (3 comandos)
10. Configuration Update
11. Configuration ACK
12. Device Registration

### Gerenciamento (3 comandos)
13. OTA Update
14. Error Report
15. Debug Information

### Display Específico (1 comando)
16. Screen Navigation

**Total**: 16 tipos de comandos MQTT implementados