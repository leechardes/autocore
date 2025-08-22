# Schemas de Request

Estruturas de dados para requisições enviadas à API Config-App.

## 📋 Schemas de Dispositivos

### DeviceBase
Schema base para criação de dispositivos.

```json
{
  "type": "object",
  "required": ["uuid", "name", "type"],
  "properties": {
    "uuid": {
      "type": "string",
      "description": "UUID único do dispositivo",
      "pattern": "^[a-zA-Z0-9_-]+$",
      "minLength": 3,
      "maxLength": 50,
      "example": "esp32-display-001"
    },
    "name": {
      "type": "string", 
      "description": "Nome amigável do dispositivo",
      "minLength": 1,
      "maxLength": 100,
      "example": "Display da Sala"
    },
    "type": {
      "type": "string",
      "description": "Tipo do dispositivo",
      "enum": ["esp32_display", "esp32_relay", "hmi_display", "gateway"],
      "example": "esp32_display"
    },
    "mac_address": {
      "type": "string",
      "description": "Endereço MAC do dispositivo",
      "pattern": "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$",
      "example": "AA:BB:CC:DD:EE:FF"
    },
    "ip_address": {
      "type": "string",
      "description": "Endereço IP atual",
      "format": "ipv4",
      "example": "192.168.1.100"
    },
    "firmware_version": {
      "type": "string",
      "description": "Versão do firmware",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "example": "1.2.3"
    },
    "hardware_version": {
      "type": "string",
      "description": "Versão do hardware",
      "example": "v2.1"
    }
  }
}
```

### DeviceUpdate
Schema para atualização de dispositivos.

```json
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100
    },
    "type": {
      "type": "string",
      "enum": ["esp32_display", "esp32_relay", "hmi_display", "gateway"]
    },
    "ip_address": {
      "type": "string",
      "format": "ipv4"
    },
    "mac_address": {
      "type": "string",
      "pattern": "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"
    },
    "location": {
      "type": "string",
      "maxLength": 200,
      "example": "Sala de Controle"
    },
    "is_active": {
      "type": "boolean"
    },
    "configuration": {
      "type": "object",
      "description": "Configurações específicas do dispositivo",
      "example": {
        "theme": "dark",
        "brightness": 75,
        "sleep_timeout": 300
      }
    },
    "capabilities": {
      "type": "object",
      "description": "Capacidades do dispositivo",
      "example": {
        "has_touch": true,
        "resolution": "320x240",
        "memory_mb": 4
      }
    }
  }
}
```

## 🖥️ Schemas de Telas

### ScreenCreate
Schema para criação de telas.

```json
{
  "type": "object", 
  "required": ["name", "title", "screen_type"],
  "properties": {
    "name": {
      "type": "string",
      "description": "Nome único da tela",
      "pattern": "^[a-zA-Z0-9_-]+$",
      "minLength": 1,
      "maxLength": 50,
      "example": "main_dashboard"
    },
    "title": {
      "type": "string",
      "description": "Título exibido na tela",
      "minLength": 1,
      "maxLength": 100,
      "example": "Dashboard Principal"
    },
    "icon": {
      "type": "string",
      "description": "Nome do ícone",
      "maxLength": 50,
      "example": "home"
    },
    "screen_type": {
      "type": "string",
      "description": "Tipo da tela",
      "enum": ["dashboard", "control", "monitoring", "settings", "navigation"],
      "example": "dashboard"
    },
    "parent_id": {
      "type": "integer",
      "description": "ID da tela pai (para navegação hierárquica)",
      "nullable": true
    },
    "position": {
      "type": "integer",
      "description": "Posição na ordem de exibição",
      "minimum": 1,
      "maximum": 100,
      "example": 1
    },
    "columns_mobile": {
      "type": "integer",
      "description": "Colunas para dispositivos móveis",
      "minimum": 1,
      "maximum": 2,
      "default": 2
    },
    "columns_display_small": {
      "type": "integer", 
      "description": "Colunas para displays pequenos (ESP32)",
      "minimum": 1,
      "maximum": 3,
      "default": 2
    },
    "columns_display_large": {
      "type": "integer",
      "description": "Colunas para displays grandes",
      "minimum": 2,
      "maximum": 4,
      "default": 3
    },
    "columns_web": {
      "type": "integer",
      "description": "Colunas para interface web",
      "minimum": 3,
      "maximum": 6,
      "default": 4
    },
    "is_visible": {
      "type": "boolean",
      "description": "Se a tela está visível",
      "default": true
    },
    "show_on_mobile": {
      "type": "boolean",
      "default": true
    },
    "show_on_display_small": {
      "type": "boolean",
      "default": true
    },
    "show_on_display_large": {
      "type": "boolean",
      "default": true
    },
    "show_on_web": {
      "type": "boolean",
      "default": true
    },
    "show_on_controls": {
      "type": "boolean",
      "description": "Mostrar no painel de controles",
      "default": false
    },
    "required_permission": {
      "type": "string",
      "description": "Permissão necessária para acessar",
      "nullable": true,
      "example": "admin"
    }
  }
}
```

### ScreenItemCreate
Schema para criação de itens de tela.

```json
{
  "type": "object",
  "required": ["item_type", "name", "label"],
  "properties": {
    "item_type": {
      "type": "string",
      "description": "Tipo do item",
      "enum": ["button", "gauge", "display", "navigation", "separator"],
      "example": "button"
    },
    "name": {
      "type": "string",
      "description": "Nome único do item",
      "pattern": "^[a-zA-Z0-9_-]+$",
      "minLength": 1,
      "maxLength": 50,
      "example": "luz_sala"
    },
    "label": {
      "type": "string",
      "description": "Label exibido no item",
      "minLength": 1,
      "maxLength": 50,
      "example": "Luz da Sala"
    },
    "icon": {
      "type": "string",
      "maxLength": 50,
      "example": "lightbulb"
    },
    "position": {
      "type": "integer",
      "description": "Posição na tela",
      "minimum": 1,
      "example": 1
    },
    "size_mobile": {
      "type": "string",
      "enum": ["small", "normal", "large", "wide"],
      "default": "normal"
    },
    "size_display_small": {
      "type": "string", 
      "enum": ["small", "normal", "large", "wide"],
      "default": "normal"
    },
    "size_display_large": {
      "type": "string",
      "enum": ["small", "normal", "large", "wide"], 
      "default": "normal"
    },
    "size_web": {
      "type": "string",
      "enum": ["small", "normal", "large", "wide"],
      "default": "normal"
    },
    "action_type": {
      "type": "string",
      "description": "Tipo de ação ao clicar",
      "enum": ["none", "relay_toggle", "relay_on", "relay_off", "navigate", "macro", "custom"],
      "default": "none"
    },
    "action_target": {
      "type": "string",
      "description": "Alvo da ação (ID do relé, tela, etc)",
      "nullable": true
    },
    "action_payload": {
      "type": "string",
      "description": "Dados adicionais da ação (JSON)",
      "nullable": true
    },
    "relay_board_id": {
      "type": "integer",
      "description": "ID da placa de relé relacionada",
      "nullable": true
    },
    "relay_channel_id": {
      "type": "integer", 
      "description": "ID do canal de relé relacionado",
      "nullable": true
    },
    "data_source": {
      "type": "string",
      "description": "Fonte dos dados (para gauges/displays)",
      "enum": ["telemetry", "mqtt", "api", "static"],
      "nullable": true
    },
    "data_path": {
      "type": "string",
      "description": "Caminho do dado (ex: engine.temp)",
      "nullable": true
    },
    "data_format": {
      "type": "string",
      "description": "Formato de exibição",
      "nullable": true,
      "example": "##0.0"
    },
    "data_unit": {
      "type": "string",
      "description": "Unidade do valor",
      "nullable": true,
      "example": "°C"
    },
    "is_active": {
      "type": "boolean",
      "default": true
    }
  }
}
```

## ⚡ Schemas de Relés

### RelayBoardCreate
Schema para criação de placas de relé.

```json
{
  "type": "object",
  "required": ["device_id"],
  "properties": {
    "device_id": {
      "type": "integer",
      "description": "ID do dispositivo ESP32",
      "minimum": 1
    },
    "name": {
      "type": "string",
      "description": "Nome da placa",
      "maxLength": 100,
      "example": "Placa da Garagem"
    },
    "total_channels": {
      "type": "integer",
      "description": "Número total de canais",
      "minimum": 1,
      "maximum": 32,
      "default": 16
    },
    "board_model": {
      "type": "string",
      "description": "Modelo da placa",
      "maxLength": 50,
      "example": "16CH_5V"
    }
  }
}
```

### RelayChannelUpdate
Schema para atualização de canais.

```json
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 50,
      "example": "Luz Principal"
    },
    "description": {
      "type": "string",
      "maxLength": 200,
      "example": "Iluminação principal da área"
    },
    "function_type": {
      "type": "string",
      "enum": ["toggle", "on", "off", "momentary", "pulse"],
      "default": "toggle"
    },
    "icon": {
      "type": "string",
      "maxLength": 50,
      "example": "lightbulb"
    },
    "color": {
      "type": "string",
      "description": "Cor em hexadecimal",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#FFD700"
    },
    "protection_mode": {
      "type": "string",
      "enum": ["none", "timeout", "cooldown", "schedule"],
      "default": "none"
    },
    "max_activation_time": {
      "type": "integer",
      "description": "Tempo máximo ativado (ms)",
      "minimum": 100,
      "maximum": 300000,
      "nullable": true
    },
    "allow_in_macro": {
      "type": "boolean",
      "description": "Permitir em macros",
      "default": true
    }
  }
}
```

## 📡 Schemas MQTT

### MQTTPublishRequest
Schema para publicação de mensagens MQTT.

```json
{
  "type": "object",
  "required": ["topic", "payload"],
  "properties": {
    "topic": {
      "type": "string",
      "description": "Tópico MQTT",
      "minLength": 1,
      "maxLength": 200,
      "example": "autocore/devices/esp32-001/command"
    },
    "payload": {
      "type": "object",
      "description": "Payload da mensagem (JSON)"
    },
    "qos": {
      "type": "integer",
      "description": "Quality of Service",
      "enum": [0, 1, 2],
      "default": 1
    },
    "retain": {
      "type": "boolean",
      "description": "Manter mensagem no broker",
      "default": false
    }
  }
}
```

### RelayCommandRequest
Schema para comandos de relé via MQTT.

```json
{
  "type": "object",
  "required": ["device_uuid", "channel"],
  "properties": {
    "device_uuid": {
      "type": "string",
      "description": "UUID do dispositivo ESP32",
      "example": "esp32-relay-001"
    },
    "channel": {
      "type": "integer",
      "description": "Número do canal",
      "minimum": 1,
      "maximum": 32
    },
    "board_id": {
      "type": "integer",
      "description": "ID da placa (opcional)"
    },
    "state": {
      "type": "boolean",
      "description": "Estado desejado (para comando set)"
    },
    "duration": {
      "type": "integer",
      "description": "Duração em milissegundos (para pulso)",
      "minimum": 100,
      "maximum": 30000
    }
  }
}
```

## 🎨 Schemas de Temas

### ThemeCreate
Schema para criação de temas.

```json
{
  "type": "object",
  "required": ["name", "primary_color", "background_color"],
  "properties": {
    "name": {
      "type": "string",
      "description": "Nome único do tema",
      "minLength": 1,
      "maxLength": 50,
      "example": "tema_escuro"
    },
    "description": {
      "type": "string",
      "maxLength": 200,
      "example": "Tema escuro para displays"
    },
    "primary_color": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#1976D2"
    },
    "secondary_color": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#424242"
    },
    "background_color": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#121212"
    },
    "surface_color": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#1E1E1E"
    },
    "text_primary": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#FFFFFF"
    },
    "text_secondary": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#AAAAAA"
    },
    "error_color": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#F44336"
    },
    "warning_color": {
      "type": "string", 
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#FF9800"
    },
    "success_color": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#4CAF50"
    },
    "info_color": {
      "type": "string",
      "pattern": "^#[0-9A-Fa-f]{6}$",
      "example": "#2196F3"
    },
    "is_default": {
      "type": "boolean",
      "default": false
    }
  }
}
```

## 🔍 Validações Comuns

### Padrões de String
- **UUID**: `^[a-zA-Z0-9_-]+$`
- **MAC Address**: `^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$`
- **Hex Color**: `^#[0-9A-Fa-f]{6}$`
- **Version**: `^\\d+\\.\\d+\\.\\d+$`

### Limites de Tamanho
- **Nome curto**: 1-50 caracteres
- **Nome longo**: 1-100 caracteres
- **Descrição**: Até 200 caracteres
- **UUID**: 3-50 caracteres
- **IP Address**: Formato IPv4 válido

### Enumerações
- **Tipos de Device**: `esp32_display`, `esp32_relay`, `hmi_display`, `gateway`
- **Tipos de Item**: `button`, `gauge`, `display`, `navigation`, `separator`  
- **Tipos de Ação**: `none`, `relay_toggle`, `relay_on`, `relay_off`, `navigate`, `macro`
- **Tamanhos**: `small`, `normal`, `large`, `wide`