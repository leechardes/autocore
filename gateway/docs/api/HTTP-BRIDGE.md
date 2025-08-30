# 🌐 HTTP Bridge - AutoCore Gateway

## 📡 Visão Geral

O HTTP Bridge permite integração REST com o AutoCore Gateway, fornecendo endpoints para controle, monitoramento e integração com sistemas externos.

## 🔗 Base URL

```
http://localhost:8080/api/v1
https://gateway.autocore.local/api/v1  # Produção
```

## 🔐 Autenticação

### JWT Token
```bash
# Incluir em todas as requests
curl -H "Authorization: Bearer your_jwt_token" \
     http://localhost:8080/api/v1/devices
```

### API Key (alternativa)
```bash
# Para integrações simples
curl -H "X-API-Key: your_api_key" \
     http://localhost:8080/api/v1/status
```

## 📍 Endpoints

### 1. System Endpoints

#### GET /status
Retorna status geral do Gateway

**Response**:
```json
{
  "status": "online",
  "version": "1.0.0",
  "uptime": 86400,
  "timestamp": "2025-01-27T10:30:00Z",
  "devices_online": 5,
  "messages_processed": 15847,
  "memory_usage": {
    "ram_mb": 45.2,
    "cpu_percent": 12.5
  },
  "mqtt_status": {
    "connected": true,
    "broker": "localhost:1883",
    "subscriptions": 6
  }
}
```

#### GET /health
Health check endpoint (sem autenticação)

**Response**:
```json
{
  "status": "healthy",
  "timestamp": "2025-01-27T10:30:00Z",
  "checks": {
    "database": "ok",
    "mqtt": "ok",
    "memory": "ok"
  }
}
```

#### GET /metrics
Métricas detalhadas (Prometheus format)

**Response**:
```
# HELP autocore_devices_online Number of online devices
# TYPE autocore_devices_online gauge
autocore_devices_online 5

# HELP autocore_messages_processed_total Total messages processed
# TYPE autocore_messages_processed_total counter
autocore_messages_processed_total 15847

# HELP autocore_memory_usage_mb Memory usage in MB
# TYPE autocore_memory_usage_mb gauge
autocore_memory_usage_mb 45.2
```

### 2. Device Management

#### GET /devices
Lista todos os dispositivos

**Parameters**:
- `online_only`: boolean (opcional)
- `device_type`: string (opcional)
- `limit`: int (default: 50)
- `offset`: int (default: 0)

**Response**:
```json
{
  "devices": [
    {
      "uuid": "esp32-display-001",
      "device_type": "display_small",
      "status": "online",
      "ip_address": "192.168.1.100",
      "last_seen": "2025-01-27T10:30:00Z",
      "capabilities": ["relay", "display", "can_bus"],
      "firmware_version": "1.2.0",
      "uptime": 86400
    }
  ],
  "total": 5,
  "online": 5,
  "offline": 0
}
```

#### GET /devices/{device_uuid}
Detalhes de um dispositivo específico

**Response**:
```json
{
  "uuid": "esp32-display-001",
  "device_type": "display_small",
  "status": "online",
  "ip_address": "192.168.1.100",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "last_seen": "2025-01-27T10:30:00Z",
  "first_seen": "2025-01-20T08:15:30Z",
  "capabilities": ["relay", "display", "can_bus"],
  "firmware_version": "1.2.0",
  "hardware_revision": "v2.1",
  "uptime": 86400,
  "relay_count": 4,
  "current_status": {
    "free_memory": 45312,
    "cpu_temperature": 42.5,
    "wifi_signal": -58,
    "battery_level": 87.2
  }
}
```

#### POST /devices/{device_uuid}/commands
Envia comando para dispositivo

**Body**:
```json
{
  "command_type": "relay_control",
  "parameters": {
    "relay_id": 1,
    "state": true,
    "duration": 5000
  },
  "timeout": 30
}
```

**Response**:
```json
{
  "command_id": "cmd_12345",
  "device_uuid": "esp32-display-001",
  "command_type": "relay_control",
  "status": "sent",
  "timestamp": "2025-01-27T10:30:00Z",
  "estimated_completion": "2025-01-27T10:30:05Z"
}
```

#### GET /devices/{device_uuid}/commands/{command_id}
Status de um comando específico

**Response**:
```json
{
  "command_id": "cmd_12345",
  "device_uuid": "esp32-display-001",
  "command_type": "relay_control",
  "status": "completed",
  "sent_at": "2025-01-27T10:30:00Z",
  "completed_at": "2025-01-27T10:30:02Z",
  "execution_time": 2.3,
  "success": true,
  "result": {
    "relay_id": 1,
    "previous_state": false,
    "new_state": true
  }
}
```

### 3. Telemetry

#### GET /telemetry
Query de dados de telemetria

**Parameters**:
- `device_uuid`: string (obrigatório)
- `start_time`: ISO timestamp (obrigatório)
- `end_time`: ISO timestamp (obrigatório)
- `data_types`: string[] (opcional, ex: ["can_data", "gps"])
- `limit`: int (default: 1000)

**Response**:
```json
{
  "device_uuid": "esp32-can-001",
  "start_time": "2025-01-27T10:00:00Z",
  "end_time": "2025-01-27T11:00:00Z",
  "data_points": [
    {
      "timestamp": "2025-01-27T10:30:00Z",
      "can_data": {
        "RPM": {"value": 2500, "unit": "rpm"},
        "TPS": {"value": 45.2, "unit": "%"},
        "ECT": {"value": 85.7, "unit": "°C"}
      },
      "gps": {
        "latitude": -23.5505,
        "longitude": -46.6333,
        "speed": 65.4
      }
    }
  ],
  "total_points": 1847,
  "truncated": false
}
```

#### GET /telemetry/latest
Últimos dados de telemetria

**Parameters**:
- `device_uuid`: string (obrigatório)
- `data_types`: string[] (opcional)

**Response**:
```json
{
  "device_uuid": "esp32-can-001",
  "timestamp": "2025-01-27T10:30:00Z",
  "telemetry": {
    "can_data": {
      "RPM": {"value": 2500, "unit": "rpm"},
      "TPS": {"value": 45.2, "unit": "%"},
      "ECT": {"value": 85.7, "unit": "°C"}
    },
    "gps": {
      "latitude": -23.5505,
      "longitude": -46.6333,
      "speed": 65.4
    }
  }
}
```

### 4. WebSocket Integration

#### GET /ws/token
Gera token temporário para WebSocket

**Response**:
```json
{
  "ws_token": "ws_temp_token_12345",
  "expires_at": "2025-01-27T11:30:00Z",
  "ws_url": "ws://localhost:8080/ws?token=ws_temp_token_12345"
}
```

### 5. Webhooks

#### POST /webhooks
Configurar webhook para eventos

**Body**:
```json
{
  "url": "https://your-app.com/webhook",
  "events": ["device_connected", "device_disconnected", "relay_changed"],
  "device_filter": {
    "device_uuids": ["esp32-display-001"],
    "device_types": ["display_small"]
  },
  "secret": "webhook_secret_key"
}
```

**Response**:
```json
{
  "webhook_id": "webhook_123",
  "url": "https://your-app.com/webhook",
  "events": ["device_connected", "device_disconnected", "relay_changed"],
  "status": "active",
  "created_at": "2025-01-27T10:30:00Z"
}
```

#### GET /webhooks
Lista webhooks configurados

#### DELETE /webhooks/{webhook_id}
Remove webhook

## 🔄 Event Webhooks

Quando eventos ocorrem, o Gateway faz POST para URLs configuradas:

### Webhook Payload
```json
{
  "webhook_id": "webhook_123",
  "event_type": "device_connected",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "device_uuid": "esp32-display-001",
    "device_type": "display_small",
    "ip_address": "192.168.1.100"
  },
  "signature": "sha256=hash_of_payload_with_secret"
}
```

### Signature Verification
```python
import hmac
import hashlib

def verify_webhook(payload, signature, secret):
    expected = hmac.new(
        secret.encode(),
        payload.encode(),
        hashlib.sha256
    ).hexdigest()
    return f"sha256={expected}" == signature
```

## 📊 Response Codes

### Success
- `200 OK`: Request bem sucedida
- `201 Created`: Recurso criado
- `204 No Content`: Ação realizada sem retorno

### Client Errors
- `400 Bad Request`: Dados inválidos
- `401 Unauthorized`: Token inválido/ausente
- `403 Forbidden`: Sem permissão
- `404 Not Found`: Recurso não encontrado
- `429 Too Many Requests`: Rate limit excedido

### Server Errors
- `500 Internal Server Error`: Erro interno
- `502 Bad Gateway`: MQTT broker indisponível
- `503 Service Unavailable`: Gateway em manutenção

## 📈 Rate Limiting

### Limits por Endpoint
```
/status        : 60 requests/minute
/devices       : 30 requests/minute  
/devices/{id}  : 100 requests/minute
/commands      : 10 requests/minute
/telemetry     : 20 requests/minute
```

### Headers
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1643275800
```

## 🔧 Configuration

### Environment Variables
```bash
# HTTP Server
HTTP_PORT=8080
HTTP_HOST=0.0.0.0

# Authentication  
JWT_SECRET=your_jwt_secret
API_KEY=your_api_key

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_STORAGE=memory

# CORS
CORS_ORIGINS=http://localhost:3000,https://app.autocore.local
```

### Usage Examples

#### cURL
```bash
# Get device list
curl -H "Authorization: Bearer $TOKEN" \
     "http://localhost:8080/api/v1/devices"

# Send relay command
curl -X POST \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"command_type":"relay_control","parameters":{"relay_id":1,"state":true}}' \
     "http://localhost:8080/api/v1/devices/esp32-001/commands"

# Get telemetry
curl -H "Authorization: Bearer $TOKEN" \
     "http://localhost:8080/api/v1/telemetry?device_uuid=esp32-001&start_time=2025-01-27T10:00:00Z&end_time=2025-01-27T11:00:00Z"
```

#### Python
```python
import requests

class AutoCoreClient:
    def __init__(self, base_url, token):
        self.base_url = base_url
        self.headers = {'Authorization': f'Bearer {token}'}
    
    def get_devices(self, online_only=False):
        params = {'online_only': online_only} if online_only else {}
        response = requests.get(
            f'{self.base_url}/devices',
            headers=self.headers,
            params=params
        )
        return response.json()
    
    def send_command(self, device_uuid, command_type, parameters):
        data = {
            'command_type': command_type,
            'parameters': parameters
        }
        response = requests.post(
            f'{self.base_url}/devices/{device_uuid}/commands',
            headers=self.headers,
            json=data
        )
        return response.json()

# Usage
client = AutoCoreClient('http://localhost:8080/api/v1', 'your_token')
devices = client.get_devices(online_only=True)
```

---

Esta API HTTP permite integração completa com o AutoCore Gateway via REST, fornecendo controle total sobre dispositivos e acesso a dados de telemetria.