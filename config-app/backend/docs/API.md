# 📡 AutoCore Config App - API Reference

<div align="center">

![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![OpenAPI](https://img.shields.io/badge/OpenAPI-6BA539?style=for-the-badge&logo=openapi-initiative&logoColor=white)

**Documentação Completa da API REST**

[Base URL](http://raspberrypi.local:8000) • [Interactive Docs](http://raspberrypi.local:8000/docs) • [ReDoc](http://raspberrypi.local:8000/redoc)

</div>

---

## 📋 Visão Geral

A API do AutoCore Config App oferece endpoints RESTful para controle completo do sistema AutoCore. Todos os endpoints seguem padrões HTTP, retornam JSON e incluem códigos de status apropriados.

### Base URL
```
http://raspberrypi.local:8000/api/v1
```

### Autenticação
```http
Authorization: Bearer <JWT_TOKEN>
```

## 🔐 Autenticação

### POST /auth/login
Autentica usuário e retorna JWT token.

**Request:**
```json
{
  "username": "admin",
  "password": "secure-password"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_type": "bearer",
    "expires_in": 86400,
    "user": {
      "id": 1,
      "username": "admin",
      "full_name": "Administrador",
      "role": "admin"
    }
  }
}
```

### POST /auth/refresh
Renova token de acesso usando refresh token.

**Request:**
```json
{
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### POST /auth/logout
Invalida tokens do usuário.

---

## 🖥️ Dispositivos

### GET /devices
Lista todos os dispositivos conectados.

**Query Parameters:**
- `type` (optional): Filtrar por tipo de dispositivo
- `status` (optional): Filtrar por status (online, offline, error)
- `page` (optional): Número da página (default: 1)
- `per_page` (optional): Itens por página (default: 20)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "uuid": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Display Principal",
      "type": "esp32_display",
      "mac_address": "AA:BB:CC:DD:EE:FF",
      "ip_address": "192.168.1.100",
      "firmware_version": "1.2.3",
      "hardware_version": "2.1",
      "status": "online",
      "last_seen": "2025-01-18T10:30:00Z",
      "configuration": {
        "brightness": 80,
        "sleep_timeout": 300,
        "orientation": "landscape"
      },
      "capabilities": {
        "touch": true,
        "wifi": true,
        "bluetooth": false
      },
      "is_active": true,
      "created_at": "2025-01-15T08:00:00Z",
      "updated_at": "2025-01-18T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 5,
    "pages": 1
  }
}
```

### POST /devices
Registra novo dispositivo no sistema.

**Request:**
```json
{
  "name": "Novo Display",
  "type": "esp32_display",
  "mac_address": "FF:EE:DD:CC:BB:AA",
  "ip_address": "192.168.1.101",
  "configuration": {
    "brightness": 70,
    "sleep_timeout": 300
  }
}
```

### GET /devices/{device_id}
Obtém detalhes de um dispositivo específico.

### PUT /devices/{device_id}
Atualiza configuração de um dispositivo.

### DELETE /devices/{device_id}
Remove dispositivo do sistema.

### POST /devices/{device_id}/reboot
Reinicia dispositivo remotamente.

---

## ⚡ Relés

### GET /relays
Lista todas as placas de relés e seus canais.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "device_id": 2,
      "name": "Placa Principal",
      "total_channels": 16,
      "board_model": "ESP32-RELAY-16",
      "location": "Compartimento Motor",
      "channels": [
        {
          "id": 1,
          "channel_number": 1,
          "name": "Farol Principal",
          "description": "Farol alto/baixo",
          "function_type": "toggle",
          "current_state": false,
          "icon": "headlights",
          "color": "#3B82F6",
          "protection_mode": "none",
          "is_active": true
        },
        {
          "id": 2,
          "channel_number": 2,
          "name": "Buzina",
          "description": "Buzina do veículo",
          "function_type": "momentary",
          "current_state": false,
          "icon": "horn",
          "color": "#EF4444",
          "protection_mode": "confirm",
          "max_activation_time": 5,
          "is_active": true
        }
      ]
    }
  ]
}
```

### POST /relays/boards
Adiciona nova placa de relés.

**Request:**
```json
{
  "device_id": 2,
  "name": "Placa Auxiliar",
  "total_channels": 8,
  "board_model": "ESP32-RELAY-8",
  "location": "Painel"
}
```

### POST /relays/channels
Configura canal de relé.

**Request:**
```json
{
  "board_id": 1,
  "channel_number": 3,
  "name": "Pisca Alerta",
  "description": "Pisca-pisca de emergência",
  "function_type": "toggle",
  "icon": "warning-triangle",
  "color": "#F59E0B",
  "protection_mode": "confirm"
}
```

### POST /relays/channels/{channel_id}/toggle
Alterna estado de um relé.

**Request:**
```json
{
  "duration": 5,  // Opcional: tempo em segundos para relés momentâneos
  "force": false  // Força ação mesmo com proteção
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "channel_id": 1,
    "previous_state": false,
    "current_state": true,
    "timestamp": "2025-01-18T10:30:00Z"
  }
}
```

### GET /relays/channels/{channel_id}/status
Obtém status atual de um relé.

---

## 📱 Telas e Interface

### GET /screens
Lista todas as telas configuradas.

**Query Parameters:**
- `device_type` (optional): Filtrar por tipo de dispositivo
- `parent_id` (optional): Filtrar telas filhas

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "dashboard",
      "title": "Dashboard Principal",
      "icon": "dashboard",
      "screen_type": "dashboard",
      "parent_id": null,
      "position": 1,
      "columns_mobile": 2,
      "columns_display_small": 2,
      "columns_display_large": 4,
      "columns_web": 4,
      "show_on_mobile": true,
      "show_on_display_small": true,
      "show_on_display_large": true,
      "show_on_web": true,
      "items": [
        {
          "id": 1,
          "item_type": "button",
          "name": "toggle_headlights",
          "label": "Faróis",
          "icon": "headlights",
          "position": 1,
          "size_mobile": "normal",
          "size_display_small": "normal",
          "action_type": "relay",
          "action_target": "1",
          "behavior_type": "toggle",
          "color_active": "#3B82F6",
          "color_inactive": "#6B7280"
        }
      ]
    }
  ]
}
```

### POST /screens
Cria nova tela.

**Request:**
```json
{
  "name": "controls",
  "title": "Controles",
  "icon": "settings",
  "screen_type": "control",
  "parent_id": null,
  "columns_mobile": 2,
  "columns_display_small": 2,
  "required_permission": "operator"
}
```

### POST /screens/{screen_id}/items
Adiciona item à tela.

**Request:**
```json
{
  "item_type": "button",
  "name": "engine_start",
  "label": "Partida",
  "icon": "power",
  "position": 1,
  "action_type": "can_command",
  "action_target": "engine_start_command",
  "behavior_type": "momentary",
  "confirm_action": true,
  "confirm_message": "Confirma partida do motor?",
  "color_active": "#10B981"
}
```

### GET /screens/{screen_id}/layout/{device_type}
Obtém layout otimizado para tipo de dispositivo específico.

**Device Types:**
- `mobile` - App Flutter
- `display_small` - Display 2.8"
- `display_large` - Multimídia
- `web` - Dashboard Streamlit
- `controls` - Controles do volante

---

## 🚗 CAN Bus

### GET /can/signals
Lista sinais CAN configurados.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "signal_name": "engine_rpm",
      "can_id": "0x200",
      "start_bit": 0,
      "length_bits": 16,
      "byte_order": "little_endian",
      "data_type": "uint16",
      "scale_factor": 1.0,
      "offset": 0.0,
      "unit": "RPM",
      "min_value": 0,
      "max_value": 8000,
      "description": "Rotação do motor",
      "category": "engine",
      "current_value": 2500,
      "last_update": "2025-01-18T10:30:00Z"
    }
  ]
}
```

### POST /can/commands/{command_name}
Executa comando CAN.

**Request:**
```json
{
  "parameters": {
    "target_rpm": 1000
  },
  "confirm": true
}
```

### GET /can/telemetry
Obtém telemetria em tempo real via WebSocket.

**WebSocket URL:** `ws://raspberrypi.local:8000/ws/can/telemetry`

**Message Format:**
```json
{
  "timestamp": "2025-01-18T10:30:00Z",
  "signals": {
    "engine_rpm": 2500,
    "coolant_temp": 85.5,
    "oil_pressure": 4.2,
    "battery_voltage": 13.8
  }
}
```

---

## 📨 MQTT

### GET /mqtt/topics
Lista tópicos MQTT configurados.

### POST /mqtt/publish
Publica mensagem em tópico MQTT.

**Request:**
```json
{
  "topic": "autocore/devices/display1/command",
  "payload": {
    "action": "update_screen",
    "screen_id": 2
  },
  "qos": 1,
  "retained": false
}
```

### GET /mqtt/status
Status da conexão MQTT.

**Response:**
```json
{
  "success": true,
  "data": {
    "connected": true,
    "broker": "localhost:1883",
    "uptime": 3600,
    "messages_sent": 1250,
    "messages_received": 890,
    "last_message": "2025-01-18T10:30:00Z"
  }
}
```

---

## 👥 Usuários

### GET /users
Lista usuários do sistema.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "username": "admin",
      "full_name": "Administrador",
      "email": "admin@autocore.com",
      "role": "admin",
      "is_active": true,
      "last_login": "2025-01-18T08:00:00Z",
      "created_at": "2025-01-15T00:00:00Z"
    }
  ]
}
```

### POST /users
Cria novo usuário.

**Request:**
```json
{
  "username": "operator1",
  "password": "secure-password",
  "full_name": "Operador 1",
  "email": "op1@autocore.com",
  "role": "operator",
  "pin_code": "1234"
}
```

---

## 🎨 Temas

### GET /themes
Lista temas disponíveis.

### POST /themes
Cria novo tema personalizado.

**Request:**
```json
{
  "name": "Dark Professional",
  "description": "Tema escuro profissional",
  "primary_color": "#3B82F6",
  "secondary_color": "#6366F1",
  "background_color": "#111827",
  "surface_color": "#1F2937",
  "success_color": "#10B981",
  "warning_color": "#F59E0B",
  "error_color": "#EF4444",
  "info_color": "#06B6D4",
  "text_primary": "#F9FAFB",
  "text_secondary": "#D1D5DB",
  "border_radius": 8,
  "shadow_style": "neumorphic"
}
```

---

## 🤖 Macros e Automação

### GET /macros
Lista macros configuradas.

### POST /macros
Cria nova macro.

**Request:**
```json
{
  "name": "Modo Camping",
  "description": "Liga luzes externas e internas",
  "trigger_type": "manual",
  "action_sequence": [
    {
      "type": "relay",
      "target": "1",
      "action": "on",
      "delay": 0
    },
    {
      "type": "relay",
      "target": "3",
      "action": "on",
      "delay": 1000
    },
    {
      "type": "relay",
      "target": "5",
      "action": "on",
      "delay": 500
    }
  ]
}
```

### POST /macros/{macro_id}/execute
Executa macro.

---

## 📊 Logs e Monitoramento

### GET /logs
Obtém logs do sistema.

**Query Parameters:**
- `event_type`: Tipo de evento (command, status_change, error, etc.)
- `source`: Fonte do evento
- `start_date`: Data inicial (ISO 8601)
- `end_date`: Data final (ISO 8601)
- `level`: Nível do log (info, warning, error)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1001,
      "timestamp": "2025-01-18T10:30:00Z",
      "event_type": "command",
      "source": "550e8400-e29b-41d4-a716-446655440001",
      "target": "relay_channel_1",
      "action": "toggle",
      "payload": {"state": true},
      "user_id": 1,
      "username": "admin",
      "ip_address": "192.168.1.50",
      "status": "success",
      "duration_ms": 45
    }
  ]
}
```

### GET /system/health
Status de saúde do sistema.

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "timestamp": "2025-01-18T10:30:00Z",
    "uptime": 86400,
    "version": "1.0.0",
    "system": {
      "cpu_usage": 15.2,
      "memory_usage": 35.8,
      "memory_total": 512,
      "disk_usage": 45.2,
      "disk_total": 32,
      "temperature": 45.5
    },
    "services": {
      "database": {
        "status": "healthy",
        "response_time": 2.5,
        "connections": 3
      },
      "mqtt": {
        "status": "healthy",
        "connected": true,
        "messages_per_minute": 25
      },
      "can_bus": {
        "status": "connected",
        "signals_received": 150,
        "last_signal": "2025-01-18T10:29:58Z"
      }
    },
    "devices": {
      "total": 5,
      "online": 4,
      "offline": 1,
      "error": 0
    }
  }
}
```

### GET /system/metrics
Métricas detalhadas do sistema.

---

## 🌐 WebSocket Endpoints

### /ws/devices/{device_id}
Status em tempo real de dispositivo específico.

### /ws/relays
Estado de todos os relés.

### /ws/can/telemetry
Dados CAN em tempo real.

### /ws/system/status
Status geral do sistema.

**Exemplo de uso JavaScript:**
```javascript
const ws = new WebSocket('ws://raspberrypi.local:8000/ws/relays');

ws.onmessage = function(event) {
  const data = JSON.parse(event.data);
  console.log('Relay states updated:', data);
};
```

---

## ❌ Códigos de Erro

### HTTP Status Codes

| Code | Status | Descrição |
|------|--------|-----------|
| 200 | OK | Operação realizada com sucesso |
| 201 | Created | Recurso criado com sucesso |
| 204 | No Content | Operação realizada, sem conteúdo |
| 400 | Bad Request | Dados inválidos na requisição |
| 401 | Unauthorized | Token de autenticação inválido |
| 403 | Forbidden | Permissões insuficientes |
| 404 | Not Found | Recurso não encontrado |
| 409 | Conflict | Conflito de dados (já existe) |
| 422 | Unprocessable Entity | Erro de validação |
| 429 | Too Many Requests | Rate limit excedido |
| 500 | Internal Server Error | Erro interno do servidor |

### Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Os dados fornecidos são inválidos",
    "details": {
      "field": "email",
      "issue": "Formato de email inválido"
    }
  },
  "timestamp": "2025-01-18T10:30:00Z",
  "request_id": "req_123456789"
}
```

### Códigos de Erro Customizados

| Code | Descrição |
|------|-----------|
| `DEVICE_OFFLINE` | Dispositivo não está online |
| `RELAY_PROTECTED` | Relé protegido requer confirmação |
| `CAN_TIMEOUT` | Timeout na comunicação CAN |
| `MQTT_DISCONNECTED` | Broker MQTT desconectado |
| `VALIDATION_ERROR` | Erro de validação de dados |
| `PERMISSION_DENIED` | Permissão insuficiente |
| `RESOURCE_NOT_FOUND` | Recurso não encontrado |
| `DUPLICATE_RESOURCE` | Recurso já existe |

---

## 📋 Rate Limiting

### Limites por Endpoint

| Endpoint | Limite | Window |
|----------|--------|--------|
| `/auth/login` | 5 requests | 1 minuto |
| `/auth/refresh` | 10 requests | 1 minuto |
| `/relays/*/toggle` | 30 requests | 1 minuto |
| `/can/commands/*` | 10 requests | 1 minuto |
| `GET *` | 100 requests | 1 minuto |
| `POST/PUT/DELETE *` | 60 requests | 1 minuto |

### Headers de Rate Limit

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1642524600
```

---

## 🔧 Configuração de Cliente

### Headers Recomendados

```http
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
Accept: application/json
User-Agent: AutoCore-Client/1.0.0
X-Request-ID: unique-request-id
```

### Exemplo cURL

```bash
# Listar dispositivos
curl -X GET \
  http://raspberrypi.local:8000/api/v1/devices \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -H "Content-Type: application/json"

# Alternar relé
curl -X POST \
  http://raspberrypi.local:8000/api/v1/relays/channels/1/toggle \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -d '{"duration": 5}'
```

### Exemplo Python

```python
import requests

# Configuração
BASE_URL = "http://raspberrypi.local:8000/api/v1"
TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

# Listar dispositivos
response = requests.get(f"{BASE_URL}/devices", headers=headers)
devices = response.json()

# Alternar relé
payload = {"duration": 5}
response = requests.post(
    f"{BASE_URL}/relays/channels/1/toggle", 
    json=payload, 
    headers=headers
)
```

### Exemplo JavaScript/TypeScript

```typescript
class AutoCoreAPI {
  private baseURL = 'http://raspberrypi.local:8000/api/v1';
  private token: string;

  constructor(token: string) {
    this.token = token;
  }

  private async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    if (!response.ok) {
      throw new Error(`API Error: ${response.statusText}`);
    }

    return response.json();
  }

  async getDevices() {
    return this.request('/devices');
  }

  async toggleRelay(channelId: number, duration?: number) {
    return this.request(`/relays/channels/${channelId}/toggle`, {
      method: 'POST',
      body: JSON.stringify({ duration }),
    });
  }
}
```

---

## 📝 Changelog

### v1.0.0 (2025-01-18)
- Initial API release
- Complete device management
- Relay control system
- CAN bus integration
- MQTT messaging
- User management
- Theme system
- Macro automation
- Real-time monitoring

---

<div align="center">

**API desenvolvida com ❤️ para a comunidade automotive**

[↑ Voltar ao topo](#-autocore-config-app---api-reference)

</div>