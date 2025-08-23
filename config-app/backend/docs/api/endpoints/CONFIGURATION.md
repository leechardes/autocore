# Endpoints - Configuração

Sistema de geração e distribuição de configurações completas para dispositivos ESP32 e interfaces.

## 📋 Visão Geral

Os endpoints de configuração permitem:
- Gerar configurações completas para dispositivos específicos
- Obter configurações de preview para desenvolvimento
- Configurações otimizadas por tipo de dispositivo
- Suporte a modo preview para interfaces web

## 🔧 Endpoints de Configuração

### `GET /api/config/full/{device_uuid}`

Retorna configuração completa para um dispositivo ESP32 específico.

**Parâmetros de Path:**
- `device_uuid` (string): UUID do dispositivo (ou "preview" para modo de demonstração)

**Parâmetros de Query:**
- `preview` (boolean, opcional): Força modo preview (padrão: false)

**Resposta:**
```json
{
  "version": "2.0.0",
  "protocol_version": "2.2.0",
  "timestamp": "2025-01-22T10:15:30.123Z",
  "device": {
    "id": 1,
    "uuid": "esp32-display-001",
    "type": "esp32_display",
    "name": "Display Principal",
    "status": "online",
    "ip_address": "192.168.1.100",
    "mac_address": "AA:BB:CC:DD:EE:FF"
  },
  "system": {
    "name": "AutoCore System",
    "language": "pt-BR"
  },
  "screens": [
    {
      "id": 1,
      "name": "main_dashboard",
      "title": "Dashboard Principal",
      "icon": "home",
      "screen_type": "dashboard",
      "position": 1,
      "columns_display_small": 2,
      "columns_display_large": 3,
      "is_visible": true,
      "show_on_display_small": true,
      "show_on_display_large": true,
      "items": [
        {
          "id": 1,
          "item_type": "button",
          "name": "luz_principal",
          "label": "Luz Principal",
          "icon": "lightbulb",
          "position": 1,
          "action_type": "relay_toggle",
          "relay_board_id": 1,
          "relay_channel_id": 1,
          "relay_board": {
            "id": 1,
            "device_id": 2,
            "device_uuid": "esp32-relay-001",
            "device_name": "Relé Principal",
            "device_ip": "192.168.1.101",
            "total_channels": 16,
            "board_model": "ESP32-RELAY-16CH"
          },
          "relay_channel": {
            "id": 1,
            "channel_number": 1,
            "name": "Luz Principal",
            "description": "Controla iluminação da sala principal",
            "function_type": "toggle",
            "icon": "lightbulb",
            "color": "#FFA500",
            "protection_mode": "none"
          }
        },
        {
          "id": 2,
          "item_type": "gauge",
          "name": "temperatura_motor",
          "label": "Temperatura Motor",
          "icon": "thermometer",
          "position": 2,
          "display_format": "gauge",
          "value_source": "telemetry.engine_temp",
          "unit": "°C",
          "min_value": 0,
          "max_value": 120,
          "color_ranges": [
            {"min": 0, "max": 80, "color": "#4CAF50"},
            {"min": 80, "max": 100, "color": "#FF9800"},
            {"min": 100, "max": 120, "color": "#F44336"}
          ]
        }
      ]
    }
  ],
  "devices": [
    {
      "id": 1,
      "uuid": "esp32-display-001",
      "name": "Display Principal",
      "type": "esp32_display",
      "status": "online",
      "ip_address": "192.168.1.100",
      "is_active": true
    },
    {
      "id": 2,
      "uuid": "esp32-relay-001", 
      "name": "Relé Principal",
      "type": "esp32_relay",
      "status": "online",
      "ip_address": "192.168.1.101",
      "is_active": true
    }
  ],
  "relay_boards": [
    {
      "id": 1,
      "device_id": 2,
      "total_channels": 16,
      "board_model": "ESP32-RELAY-16CH",
      "is_active": true
    }
  ],
  "theme": {
    "id": 1,
    "name": "default_dark",
    "primary_color": "#1976D2",
    "secondary_color": "#424242",
    "background_color": "#121212",
    "surface_color": "#1E1E1E",
    "text_primary": "#FFFFFF",
    "text_secondary": "#AAAAAA",
    "error_color": "#F44336",
    "warning_color": "#FF9800",
    "success_color": "#4CAF50",
    "info_color": "#2196F3"
  },
  "telemetry": {
    "engine_temp": "89.5",
    "rpm": "3250",
    "speed": "45.8",
    "oil_pressure": "4.2",
    "battery_voltage": "13.8"
  }
}
```

**Códigos de Status:**
- `200` - Configuração gerada com sucesso
- `400` - UUID inválido ou parâmetros incorretos
- `404` - Dispositivo não encontrado
- `503` - Erro de conexão com banco de dados
- `500` - Erro interno do servidor

---

### `GET /api/config/full`

Retorna configuração completa em modo preview para desenvolvimento e demonstração.

**Parâmetros de Query:**
- `preview` (boolean, opcional): Sempre true para este endpoint

**Resposta:**
```json
{
  "version": "2.0.0",
  "protocol_version": "2.2.0",
  "timestamp": "2025-01-22T10:15:30.123Z",
  "preview_mode": true,
  "device": {
    "id": 0,
    "uuid": "preview",
    "type": "esp32_display",
    "name": "Preview Display",
    "status": "online",
    "ip_address": "192.168.1.100",
    "mac_address": "AA:BB:CC:DD:EE:FF"
  },
  "system": {
    "name": "AutoCore System - Preview",
    "language": "pt-BR"
  },
  "telemetry": {
    "speed": 45.5,
    "rpm": 3200,
    "engine_temp": 89.5,
    "oil_pressure": 4.2,
    "fuel_level": 75.8,
    "battery_voltage": 13.8,
    "intake_temp": 23.5,
    "boost_pressure": 0.8,
    "lambda": 0.95,
    "tps": 35.2,
    "ethanol": 27.5,
    "gear": 3
  },
  "screens": [ ],
  "devices": [ ],
  "relay_boards": [ ],
  "theme": { }
}
```

---

### `GET /api/config/generate/{device_uuid}`

Gera configuração específica para um dispositivo ESP32 (formato legado).

**Parâmetros de Path:**
- `device_uuid` (string): UUID do dispositivo

**Resposta para ESP32_RELAY:**
```json
{
  "device_uuid": "esp32-relay-001",
  "device_name": "Relé Principal",
  "device_type": "esp32_relay",
  "mqtt": {
    "broker": "192.168.1.100",
    "port": 1883,
    "topic_prefix": "autocore/esp32-relay-001"
  },
  "relay_channels": [
    {
      "number": 1,
      "name": "Luz Principal",
      "type": "toggle",
      "default": false
    },
    {
      "number": 2,
      "name": "Portão Garagem",
      "type": "pulse",
      "default": false
    }
  ]
}
```

**Resposta para ESP32_DISPLAY:**
```json
{
  "device_uuid": "esp32-display-001",
  "device_name": "Display Principal",
  "device_type": "esp32_display",
  "mqtt": {
    "broker": "192.168.1.100",
    "port": 1883,
    "topic_prefix": "autocore/esp32-display-001"
  },
  "screens": [
    {
      "id": 1,
      "name": "main_dashboard",
      "title": "Dashboard Principal",
      "type": "dashboard"
    }
  ]
}
```

**Códigos de Status:**
- `200` - Configuração gerada com sucesso
- `404` - Dispositivo não encontrado
- `500` - Erro interno do servidor

## 🔄 Fluxo de Configuração

### 1. Inicialização do Dispositivo
```cpp
// ESP32 - Obter configuração na inicialização
void setupDevice() {
    // Conectar WiFi
    connectWiFi();
    
    // Obter configuração do servidor
    String config = httpGet("/api/config/full/" + device_uuid);
    
    // Parsear e aplicar configuração
    parseAndApplyConfig(config);
    
    // Conectar MQTT
    connectMQTT();
}
```

### 2. Atualização de Configuração
```cpp
// ESP32 - Verificar atualizações periodicamente
void checkConfigUpdates() {
    String lastUpdate = getStoredConfigTimestamp();
    String serverTime = httpGet("/api/config/timestamp/" + device_uuid);
    
    if (serverTime > lastUpdate) {
        String newConfig = httpGet("/api/config/full/" + device_uuid);
        applyConfigUpdate(newConfig);
        storeConfigTimestamp(serverTime);
    }
}
```

### 3. Preview em Tempo Real
```javascript
// Frontend - Preview para desenvolvimento
async function loadPreviewConfig() {
    const config = await fetch('/api/config/full?preview=true')
        .then(r => r.json());
    
    // Renderizar interface com dados de exemplo
    renderInterface(config);
    
    // Aplicar tema
    applyTheme(config.theme);
    
    // Simular telemetria
    simulateTelemetry(config.telemetry);
}
```

## 📱 Otimizações por Dispositivo

### ESP32 Display Small (320x240)
```json
{
  "display_optimizations": {
    "max_screens": 8,
    "max_items_per_screen": 6,
    "preferred_layout": "grid_2x3",
    "font_size": "medium",
    "icon_size": 32,
    "animation_enabled": false,
    "cache_policy": "aggressive"
  }
}
```

### ESP32 Display Large (480x320)
```json
{
  "display_optimizations": {
    "max_screens": 12,
    "max_items_per_screen": 9,
    "preferred_layout": "grid_3x3",
    "font_size": "large",
    "icon_size": 48,
    "animation_enabled": true,
    "cache_policy": "moderate"
  }
}
```

### Web Interface
```json
{
  "web_optimizations": {
    "max_screens": "unlimited",
    "max_items_per_screen": "unlimited",
    "responsive_breakpoints": true,
    "progressive_loading": true,
    "real_time_updates": true,
    "advanced_animations": true
  }
}
```

## 🎯 Campos Específicos por Item Type

### Button Items
```json
{
  "item_type": "button",
  "action_config": {
    "action_type": "relay_toggle",
    "confirmation_required": false,
    "protection_mode": "none",
    "visual_feedback": true,
    "haptic_feedback": true,
    "sound_feedback": false
  }
}
```

### Gauge Items
```json
{
  "item_type": "gauge",
  "gauge_config": {
    "display_format": "circular",
    "show_value": true,
    "show_unit": true,
    "animated_needle": true,
    "update_interval": 1000,
    "smoothing_factor": 0.3,
    "alert_thresholds": [
      {"value": 80, "color": "#FF9800"},
      {"value": 100, "color": "#F44336"}
    ]
  }
}
```

### Display Items
```json
{
  "item_type": "display",
  "display_config": {
    "format_string": "##0.0",
    "prefix": "",
    "suffix": " km/h",
    "decimal_places": 1,
    "show_trend": true,
    "trend_period": 300,
    "color_coding": true
  }
}
```

## 🔧 Configuração de Sistema

### MQTT Settings
```json
{
  "mqtt": {
    "broker": "10.0.10.100",
    "port": 1883,
    "username": null,
    "password": null,
    "topic_prefix": "autocore",
    "keepalive": 60,
    "qos": 1,
    "retain": false,
    "auto_reconnect": true,
    "max_reconnect_attempts": 5
  }
}
```

### Network Settings
```json
{
  "network": {
    "wifi_ssid": "AutoCore_WiFi",
    "wifi_password": "encrypted_password_hash",
    "fallback_ap_mode": true,
    "ap_ssid": "AutoCore_Setup",
    "static_ip": null,
    "gateway": "192.168.1.1",
    "dns_primary": "8.8.8.8",
    "dns_secondary": "8.8.4.4"
  }
}
```

### Hardware Settings
```json
{
  "hardware": {
    "display": {
      "rotation": 0,
      "brightness": 75,
      "sleep_timeout": 300,
      "screensaver_enabled": true
    },
    "touch": {
      "calibration": [240, 160, 320, 240],
      "sensitivity": 100,
      "debounce_ms": 50
    },
    "gpio": {
      "available_pins": [2, 4, 5, 12, 13, 14, 15, 16],
      "reserved_pins": [0, 1, 3],
      "pwm_frequency": 5000
    }
  }
}
```

## 📊 Modo Preview

### Dados Simulados
O modo preview inclui dados simulados realísticos:

```json
{
  "preview_telemetry": {
    "speed": 45.5,
    "rpm": 3200,
    "engine_temp": 89.5,
    "oil_pressure": 4.2,
    "fuel_level": 75.8,
    "battery_voltage": 13.8,
    "intake_temp": 23.5,
    "boost_pressure": 0.8,
    "lambda": 0.95,
    "tps": 35.2,
    "ethanol": 27.5,
    "gear": 3
  }
}
```

### Cenários de Teste
```json
{
  "test_scenarios": {
    "normal_driving": {
      "description": "Condições normais de direção",
      "values": { }
    },
    "high_performance": {
      "description": "Modo esportivo/racing",
      "values": { }
    },
    "eco_mode": {
      "description": "Direção econômica",
      "values": { }
    }
  }
}
```

## ⚠️ Considerações

### Performance
- Configurações são cacheadas no servidor por 5 minutos
- ESP32 deve cachear configuração localmente
- Updates incrementais reduzem transferência de dados

### Versionamento
- `version` indica versão da configuração
- `protocol_version` indica compatibilidade da API
- ESP32 deve verificar compatibilidade antes de aplicar

### Fallback
- Se configuração falhar, ESP32 usa configuração padrão
- Modo offline mantém última configuração válida
- Logs de erro são enviados para monitoramento

### Segurança
- Configurações podem conter dados sensíveis
- HTTPS obrigatório em produção
- Autenticação por certificado para dispositivos