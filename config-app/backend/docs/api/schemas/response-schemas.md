# Schemas de Response

Estruturas de dados retornadas pela API Config-App.

## 📋 Schemas de Dispositivos

### DeviceResponse
Resposta completa com dados do dispositivo.

```json
{
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "description": "ID único do dispositivo",
      "example": 1
    },
    "uuid": {
      "type": "string",
      "description": "UUID único do dispositivo",
      "example": "esp32-display-001"
    },
    "name": {
      "type": "string",
      "description": "Nome amigável do dispositivo", 
      "example": "Display Principal"
    },
    "type": {
      "type": "string",
      "description": "Tipo do dispositivo",
      "example": "esp32_display"
    },
    "mac_address": {
      "type": "string",
      "description": "Endereço MAC",
      "example": "AA:BB:CC:DD:EE:FF",
      "nullable": true
    },
    "ip_address": {
      "type": "string",
      "description": "Endereço IP atual",
      "example": "192.168.1.100",
      "nullable": true
    },
    "firmware_version": {
      "type": "string",
      "description": "Versão do firmware",
      "example": "1.2.3",
      "nullable": true
    },
    "hardware_version": {
      "type": "string",
      "description": "Versão do hardware",
      "example": "v2.1",
      "nullable": true
    },
    "status": {
      "type": "string",
      "description": "Status atual do dispositivo",
      "enum": ["online", "offline", "error", "updating"],
      "example": "online"
    },
    "last_seen": {
      "type": "string",
      "format": "date-time",
      "description": "Última vez visto online",
      "example": "2025-01-22T10:00:00Z",
      "nullable": true
    },
    "location": {
      "type": "string",
      "description": "Localização física do dispositivo",
      "example": "Sala de Controle",
      "nullable": true
    },
    "configuration_json": {
      "type": "string",
      "description": "Configurações em formato JSON",
      "example": "{\"location\":\"Sala\",\"theme\":\"dark\"}",
      "nullable": true
    },
    "capabilities_json": {
      "type": "string", 
      "description": "Capacidades em formato JSON",
      "example": "{\"has_touch\":true,\"resolution\":\"320x240\"}",
      "nullable": true
    },
    "is_active": {
      "type": "boolean",
      "description": "Se o dispositivo está ativo",
      "example": true
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "description": "Data de criação",
      "example": "2025-01-20T08:00:00Z"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "description": "Última atualização",
      "example": "2025-01-22T10:00:00Z"
    }
  },
  "required": ["id", "uuid", "name", "type", "status", "is_active", "created_at", "updated_at"]
}
```

### DeviceListResponse
Lista simplificada de dispositivos.

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id": {"type": "integer"},
      "uuid": {"type": "string"},
      "name": {"type": "string"},
      "type": {"type": "string"},
      "status": {"type": "string"},
      "ip_address": {"type": "string", "nullable": true},
      "is_active": {"type": "boolean"}
    }
  }
}
```

## 🖥️ Schemas de Telas

### ScreenResponse
Resposta com dados completos de uma tela.

```json
{
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "example": 1
    },
    "name": {
      "type": "string",
      "example": "main_dashboard"
    },
    "title": {
      "type": "string",
      "example": "Dashboard Principal"
    },
    "icon": {
      "type": "string",
      "example": "home",
      "nullable": true
    },
    "screen_type": {
      "type": "string",
      "enum": ["dashboard", "control", "monitoring", "settings", "navigation"],
      "example": "dashboard"
    },
    "parent_id": {
      "type": "integer",
      "description": "ID da tela pai",
      "nullable": true
    },
    "position": {
      "type": "integer",
      "description": "Ordem de exibição",
      "example": 1
    },
    "columns_mobile": {
      "type": "integer",
      "example": 2
    },
    "columns_display_small": {
      "type": "integer",
      "example": 2
    },
    "columns_display_large": {
      "type": "integer", 
      "example": 3
    },
    "columns_web": {
      "type": "integer",
      "example": 4
    },
    "is_visible": {
      "type": "boolean",
      "example": true
    },
    "show_on_mobile": {
      "type": "boolean",
      "example": true
    },
    "show_on_display_small": {
      "type": "boolean",
      "example": true
    },
    "show_on_display_large": {
      "type": "boolean",
      "example": true
    },
    "show_on_web": {
      "type": "boolean",
      "example": true
    },
    "show_on_controls": {
      "type": "boolean",
      "example": false
    },
    "required_permission": {
      "type": "string",
      "nullable": true,
      "example": "admin"
    },
    "items_count": {
      "type": "integer",
      "description": "Número de itens ativos na tela",
      "example": 6
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2025-01-20T08:00:00Z"
    }
  }
}
```

### ScreenItemResponse
Resposta com dados de item de tela.

```json
{
  "type": "object", 
  "properties": {
    "id": {
      "type": "integer",
      "example": 1
    },
    "screen_id": {
      "type": "integer",
      "example": 1
    },
    "item_type": {
      "type": "string",
      "enum": ["button", "gauge", "display", "navigation", "separator"],
      "example": "button"
    },
    "name": {
      "type": "string",
      "example": "luz_sala"
    },
    "label": {
      "type": "string",
      "example": "Luz da Sala"
    },
    "icon": {
      "type": "string",
      "example": "lightbulb",
      "nullable": true
    },
    "position": {
      "type": "integer",
      "example": 1
    },
    "size_mobile": {
      "type": "string",
      "enum": ["small", "normal", "large", "wide"],
      "example": "normal"
    },
    "size_display_small": {
      "type": "string",
      "enum": ["small", "normal", "large", "wide"],
      "example": "normal"
    },
    "size_display_large": {
      "type": "string",
      "enum": ["small", "normal", "large", "wide"],
      "example": "large"
    },
    "size_web": {
      "type": "string",
      "enum": ["small", "normal", "large", "wide"],
      "example": "normal"
    },
    "action_type": {
      "type": "string",
      "enum": ["none", "relay_toggle", "relay_on", "relay_off", "navigate", "macro", "custom"],
      "example": "relay_toggle"
    },
    "action_target": {
      "type": "string",
      "example": "channel_1",
      "nullable": true
    },
    "action_payload": {
      "type": "string",
      "description": "Dados adicionais em JSON",
      "nullable": true
    },
    "relay_board_id": {
      "type": "integer",
      "nullable": true
    },
    "relay_channel_id": {
      "type": "integer",
      "nullable": true
    },
    "data_source": {
      "type": "string",
      "example": "telemetry",
      "nullable": true
    },
    "data_path": {
      "type": "string",
      "example": "engine.temp",
      "nullable": true
    },
    "data_format": {
      "type": "string", 
      "example": "##0.0",
      "nullable": true
    },
    "data_unit": {
      "type": "string",
      "example": "°C",
      "nullable": true
    },
    "is_active": {
      "type": "boolean",
      "example": true
    }
  }
}
```

## ⚡ Schemas de Relés

### RelayBoardResponse
Resposta com dados de placa de relé.

```json
{
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "example": 1
    },
    "device_id": {
      "type": "integer",
      "description": "ID do dispositivo ESP32",
      "example": 2
    },
    "name": {
      "type": "string", 
      "description": "Nome da placa",
      "example": "Placa da Garagem"
    },
    "total_channels": {
      "type": "integer",
      "example": 16
    },
    "board_model": {
      "type": "string",
      "example": "16CH_5V"
    },
    "is_active": {
      "type": "boolean",
      "example": true
    }
  }
}
```

### RelayChannelResponse
Resposta com dados de canal de relé.

```json
{
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "example": 1
    },
    "board_id": {
      "type": "integer",
      "example": 1
    },
    "channel_number": {
      "type": "integer",
      "description": "Número do canal na placa",
      "example": 1
    },
    "name": {
      "type": "string",
      "example": "Luz Principal"
    },
    "description": {
      "type": "string",
      "example": "Iluminação principal da área",
      "nullable": true
    },
    "function_type": {
      "type": "string",
      "enum": ["toggle", "on", "off", "momentary", "pulse"],
      "example": "toggle"
    },
    "icon": {
      "type": "string",
      "example": "lightbulb",
      "nullable": true
    },
    "color": {
      "type": "string",
      "description": "Cor em hexadecimal",
      "example": "#FFD700",
      "nullable": true
    },
    "protection_mode": {
      "type": "string",
      "enum": ["none", "timeout", "cooldown", "schedule"],
      "example": "none"
    },
    "max_activation_time": {
      "type": "integer",
      "description": "Tempo máximo ativado em ms",
      "nullable": true
    },
    "allow_in_macro": {
      "type": "boolean",
      "example": true
    },
    "is_active": {
      "type": "boolean",
      "example": true
    }
  }
}
```

## 🎨 Schemas de Temas

### ThemeResponse
Resposta com dados completos de tema.

```json
{
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "example": 1
    },
    "name": {
      "type": "string",
      "example": "default_dark"
    },
    "description": {
      "type": "string",
      "example": "Tema escuro padrão",
      "nullable": true
    },
    "primary_color": {
      "type": "string",
      "example": "#1976D2"
    },
    "secondary_color": {
      "type": "string",
      "example": "#424242"
    },
    "background_color": {
      "type": "string", 
      "example": "#121212"
    },
    "surface_color": {
      "type": "string",
      "example": "#1E1E1E"
    },
    "text_primary": {
      "type": "string",
      "example": "#FFFFFF"
    },
    "text_secondary": {
      "type": "string",
      "example": "#AAAAAA"
    },
    "error_color": {
      "type": "string",
      "example": "#F44336"
    },
    "warning_color": {
      "type": "string",
      "example": "#FF9800"
    },
    "success_color": {
      "type": "string", 
      "example": "#4CAF50"
    },
    "info_color": {
      "type": "string",
      "example": "#2196F3"
    },
    "is_default": {
      "type": "boolean",
      "example": true
    }
  }
}
```

## 📊 Schemas de Status

### StatusResponse
Resposta com status geral do sistema.

```json
{
  "type": "object",
  "properties": {
    "status": {
      "type": "string",
      "enum": ["online", "degraded", "offline"],
      "example": "online"
    },
    "version": {
      "type": "string",
      "example": "2.0.0"
    },
    "database": {
      "type": "string",
      "enum": ["connected", "disconnected", "error"],
      "example": "connected"
    },
    "devices_online": {
      "type": "integer",
      "description": "Número de dispositivos online",
      "example": 3
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "example": "2025-01-22T10:00:00Z"
    }
  }
}
```

### HealthResponse
Resposta do health check.

```json
{
  "type": "object",
  "properties": {
    "status": {
      "type": "string",
      "enum": ["healthy", "unhealthy"],
      "example": "healthy"
    },
    "service": {
      "type": "string",
      "example": "AutoCore Config API"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "example": "2025-01-22T10:00:00Z"
    }
  }
}
```

## 📡 Schemas MQTT

### MQTTConfigResponse
Configurações MQTT para dispositivos.

```json
{
  "type": "object",
  "properties": {
    "broker": {
      "type": "string",
      "description": "IP do broker MQTT",
      "example": "10.0.10.100"
    },
    "port": {
      "type": "integer",
      "example": 1883
    },
    "username": {
      "type": "string",
      "nullable": true
    },
    "password": {
      "type": "string", 
      "nullable": true
    },
    "topic_prefix": {
      "type": "string",
      "example": "autocore"
    }
  }
}
```

### MQTTPublishResponse
Resposta de publicação MQTT.

```json
{
  "type": "object",
  "properties": {
    "success": {
      "type": "boolean",
      "example": true
    },
    "message": {
      "type": "string",
      "example": "Comando enviado com sucesso"
    },
    "topic": {
      "type": "string",
      "example": "autocore/devices/esp32-001/command"
    },
    "message_id": {
      "type": "string",
      "example": "msg_12345"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "example": "2025-01-22T10:00:00Z"
    }
  }
}
```

## 📈 Schemas de Telemetria

### TelemetryResponse
Dados de telemetria de um dispositivo.

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id": {
        "type": "integer",
        "example": 1
      },
      "timestamp": {
        "type": "string",
        "format": "date-time",
        "example": "2025-01-22T10:00:00Z"
      },
      "data_type": {
        "type": "string",
        "example": "sensor"
      },
      "data_key": {
        "type": "string",
        "example": "engine_temp"
      },
      "data_value": {
        "type": "string",
        "example": "89.5"
      },
      "unit": {
        "type": "string",
        "example": "°C",
        "nullable": true
      }
    }
  }
}
```

## 🎯 Schemas de Configuração

### FullConfigResponse
Configuração completa para dispositivos ESP32.

```json
{
  "type": "object",
  "properties": {
    "version": {
      "type": "string",
      "example": "2.0.0"
    },
    "protocol_version": {
      "type": "string",
      "example": "2.2.0"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "example": "2025-01-22T10:00:00Z"
    },
    "preview_mode": {
      "type": "boolean",
      "description": "Se está em modo preview",
      "example": false
    },
    "device": {
      "$ref": "#/components/schemas/DeviceInfo"
    },
    "system": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string",
          "example": "AutoCore System"
        },
        "language": {
          "type": "string",
          "example": "pt-BR"
        }
      }
    },
    "screens": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/ScreenConfigResponse"
      }
    },
    "devices": {
      "type": "array",
      "description": "Registro de todos os dispositivos",
      "items": {
        "$ref": "#/components/schemas/DeviceRegistry"
      }
    },
    "relay_boards": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/RelayBoardConfig"
      }
    },
    "theme": {
      "$ref": "#/components/schemas/ThemeResponse"
    },
    "telemetry": {
      "type": "object",
      "description": "Dados de telemetria em tempo real",
      "additionalProperties": {
        "type": "string"
      }
    }
  }
}
```

## 🔍 Schemas de Erros

### ErrorResponse
Resposta padrão de erro.

```json
{
  "type": "object",
  "properties": {
    "detail": {
      "type": "string",
      "description": "Descrição do erro",
      "example": "Dispositivo não encontrado"
    },
    "error_code": {
      "type": "string",
      "example": "DEVICE_NOT_FOUND"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "example": "2025-01-22T10:00:00Z"
    },
    "path": {
      "type": "string",
      "example": "/api/devices/999"
    }
  }
}
```

### ValidationErrorResponse
Erro de validação de dados.

```json
{
  "type": "object",
  "properties": {
    "detail": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "loc": {
            "type": "array",
            "items": {"type": "string"}
          },
          "msg": {
            "type": "string"
          },
          "type": {
            "type": "string"
          }
        }
      }
    }
  }
}
```

## 📋 Códigos de Status HTTP

| Código | Descrição | Uso |
|--------|-----------|-----|
| 200 | OK | Operação bem-sucedida |
| 201 | Created | Recurso criado |
| 202 | Accepted | Requisição aceita (assíncrona) |
| 400 | Bad Request | Dados inválidos |
| 401 | Unauthorized | Autenticação necessária |
| 403 | Forbidden | Acesso negado |
| 404 | Not Found | Recurso não encontrado |
| 409 | Conflict | Conflito (UUID duplicado) |
| 422 | Unprocessable Entity | Erro de validação |
| 429 | Too Many Requests | Rate limit excedido |
| 500 | Internal Server Error | Erro interno |
| 503 | Service Unavailable | Serviço indisponível |