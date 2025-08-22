# Endpoints - Comandos e Controle

Sistema de comandos para controle remoto de dispositivos e relés.

## 📋 Visão Geral

Os endpoints de comandos permitem:
- Controlar relés remotamente
- Enviar comandos para dispositivos ESP32
- Executar macros automatizadas
- Monitorar status de execução

## ⚡ Endpoints de Relés

### `GET /api/relays/boards`

Lista todas as placas de relé ativas no sistema.

**Resposta:**
```json
[
  {
    "id": 1,
    "device_id": 2,
    "name": "Placa da Garagem",
    "total_channels": 16,
    "board_model": "16CH_5V",
    "is_active": true
  }
]
```

---

### `GET /api/relays/channels`

Lista todos os canais de relé disponíveis.

**Parâmetros de Query:**
- `board_id` (integer, opcional): Filtrar por placa específica

**Resposta:**
```json
[
  {
    "id": 1,
    "board_id": 1,
    "channel_number": 1,
    "name": "Luz da Garagem",
    "description": "Iluminação principal da garagem",
    "function_type": "toggle",
    "icon": "lightbulb",
    "color": "#FFD700",
    "protection_mode": "none"
  }
]
```

---

### `POST /api/relays/boards`

Cria uma nova placa de relé associada a um dispositivo.

**Body (JSON):**
```json
{
  "device_id": 3,
  "total_channels": 8,
  "board_model": "8CH_5V",
  "name": "Placa do Jardim"
}
```

**Resposta:**
```json
{
  "success": true,
  "message": "Placa criada com sucesso",
  "name": "Placa do Jardim"
}
```

---

### `PATCH /api/relays/channels/{channel_id}`

Atualiza configurações de um canal de relé.

**Body (JSON) - Parcial:**
```json
{
  "name": "Nova Luz",
  "description": "Descrição atualizada",
  "function_type": "momentary",
  "icon": "bulb",
  "color": "#FF5722",
  "protection_mode": "timeout"
}
```

**Resposta:**
```json
{
  "id": 1,
  "name": "Nova Luz",
  "message": "Canal atualizado com sucesso"
}
```

---

### `POST /api/relays/channels/{channel_id}/reset`

Reseta configurações de um canal para valores padrão.

**Resposta:**
```json
{
  "id": 1,
  "name": "Canal 1",
  "function_type": "toggle",
  "message": "Canal resetado com sucesso"
}
```

---

### `DELETE /api/relays/channels/{channel_id}`

Desativa um canal de relé (soft delete).

---

### `POST /api/relays/channels/{channel_id}/activate`

Reativa um canal de relé desativado.

## 🎛️ Endpoints de Controle MQTT

### `POST /api/mqtt/publish`

Publica mensagem MQTT para controle de dispositivos.

**Body (JSON):**
```json
{
  "topic": "autocore/devices/esp32-001/command",
  "payload": {
    "command": "relay_toggle",
    "channel": 1,
    "timestamp": "2025-01-22T10:00:00Z"
  },
  "qos": 1,
  "retain": false
}
```

**Resposta:**
```json
{
  "success": true,
  "message": "Comando enviado com sucesso",
  "topic": "autocore/devices/esp32-001/command",
  "message_id": "msg_12345"
}
```

---

### `POST /api/mqtt/relay/toggle`

Comando específico para toggle de relé.

**Body (JSON):**
```json
{
  "device_uuid": "esp32-relay-001",
  "channel": 1,
  "board_id": 1
}
```

**Resposta:**
```json
{
  "success": true,
  "command": "relay_toggle",
  "device_uuid": "esp32-relay-001",
  "channel": 1,
  "timestamp": "2025-01-22T10:00:00Z"
}
```

---

### `POST /api/mqtt/relay/set`

Define estado específico do relé (ON/OFF).

**Body (JSON):**
```json
{
  "device_uuid": "esp32-relay-001", 
  "channel": 2,
  "state": true,
  "duration": 5000
}
```

**Resposta:**
```json
{
  "success": true,
  "command": "relay_set",
  "device_uuid": "esp32-relay-001",
  "channel": 2,
  "state": "on",
  "duration_ms": 5000
}
```

## 🎯 Endpoints de Macros

### `GET /api/macros`

Lista macros disponíveis no sistema.

**Resposta:**
```json
[
  {
    "id": 1,
    "name": "Fechar Garagem",
    "description": "Fecha portão e desliga luzes",
    "is_active": true,
    "steps": [
      {
        "command": "relay_off",
        "device_uuid": "esp32-001",
        "channel": 1,
        "delay_ms": 0
      },
      {
        "command": "relay_off", 
        "device_uuid": "esp32-001",
        "channel": 2,
        "delay_ms": 2000
      }
    ]
  }
]
```

---

### `POST /api/macros/{macro_id}/execute`

Executa uma macro específica.

**Resposta:**
```json
{
  "success": true,
  "macro_id": 1,
  "macro_name": "Fechar Garagem",
  "execution_id": "exec_67890",
  "steps_count": 2,
  "estimated_duration_ms": 2000
}
```

---

### `GET /api/macros/execution/{execution_id}/status`

Verifica status de execução de uma macro.

**Resposta:**
```json
{
  "execution_id": "exec_67890",
  "macro_id": 1,
  "status": "completed",
  "progress": 100,
  "current_step": 2,
  "total_steps": 2,
  "started_at": "2025-01-22T10:00:00Z",
  "completed_at": "2025-01-22T10:00:02Z",
  "errors": []
}
```

## 📡 Comandos MQTT Suportados

### Comandos de Relé
```json
{
  "command": "relay_toggle",
  "channel": 1,
  "timestamp": "2025-01-22T10:00:00Z"
}

{
  "command": "relay_set", 
  "channel": 2,
  "state": true,
  "duration": 3000
}

{
  "command": "relay_pulse",
  "channel": 3,
  "duration": 500
}
```

### Comandos de Sistema
```json
{
  "command": "restart",
  "delay": 5000
}

{
  "command": "update_config",
  "config_url": "https://api.autocore.com/config/esp32-001"
}

{
  "command": "set_brightness",
  "level": 75
}
```

### Comandos de Display
```json
{
  "command": "show_message",
  "message": "Sistema atualizado!",
  "duration": 3000
}

{
  "command": "change_screen",
  "screen_id": 2
}

{
  "command": "update_theme",
  "theme_id": 1
}
```

## 🔄 Fluxo de Comando

1. **Envio**: API publica comando via MQTT
2. **Recebimento**: Dispositivo recebe e processa
3. **Execução**: Comando é executado no hardware
4. **Resposta**: Dispositivo confirma via MQTT
5. **Log**: Sistema registra resultado

### Tópicos MQTT
- **Comando**: `autocore/devices/{uuid}/command`
- **Resposta**: `autocore/devices/{uuid}/response`
- **Status**: `autocore/devices/{uuid}/status`

## ⏱️ Timeouts e Retry

### Configurações Padrão
- **Timeout de Comando**: 10 segundos
- **Retry Automático**: 3 tentativas
- **Intervalo de Retry**: 2 segundos

### QoS MQTT
- **Comandos Críticos**: QoS 2 (exactly once)
- **Status Updates**: QoS 1 (at least once) 
- **Telemetria**: QoS 0 (at most once)

## 🛡️ Proteções e Limites

### Rate Limiting
- **Por dispositivo**: 10 comandos/minuto
- **Por usuário**: 100 comandos/minuto
- **Macros**: 5 execuções/minuto

### Proteção de Relés
```json
{
  "protection_mode": "timeout",
  "max_activation_time": 30000,
  "cooldown_time": 5000,
  "allow_in_macro": true
}
```

### Validações
- UUID do dispositivo deve existir
- Canal deve estar ativo
- Dispositivo deve estar online
- Comando deve ser válido para o tipo de dispositivo

## 📊 Status de Resposta

### Sucesso
- `200` - Comando executado
- `202` - Comando aceito (execução assíncrona)

### Erros
- `400` - Comando inválido
- `404` - Dispositivo/canal não encontrado
- `408` - Timeout na execução
- `423` - Recurso bloqueado (proteção)
- `429` - Rate limit excedido
- `503` - Dispositivo offline