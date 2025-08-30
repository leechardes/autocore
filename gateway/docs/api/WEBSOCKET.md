# 🔌 WebSocket API - AutoCore Gateway

## 📡 Visão Geral

O Gateway expõe uma interface WebSocket para comunicação em tempo real com aplicações client (Config App, Dashboard, etc).

## 🔗 Conexão

### Endpoint
```
ws://localhost:8080/ws
wss://gateway.autocore.local/ws  # Produção com TLS
```

### Handshake
```javascript
const ws = new WebSocket('ws://localhost:8080/ws');

// Autenticação (opcional)
ws.send(JSON.stringify({
  type: 'auth',
  token: 'jwt_token_here'
}));
```

## 📨 Formato de Mensagens

### Estrutura Base
```json
{
  "type": "message_type",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": { ... },
  "id": "msg_12345"  // opcional
}
```

## 📤 Mensagens do Gateway (Server → Client)

### 1. Device Events

#### Device Connected
```json
{
  "type": "device_connected",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "device_uuid": "esp32-display-001",
    "device_type": "display_small",
    "ip_address": "192.168.1.100",
    "capabilities": ["relay", "display", "can_bus"]
  }
}
```

#### Device Disconnected
```json
{
  "type": "device_disconnected",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "device_uuid": "esp32-display-001",
    "last_seen": "2025-01-27T10:29:45Z",
    "reason": "timeout"
  }
}
```

#### Device Status Update
```json
{
  "type": "device_status",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "device_uuid": "esp32-display-001",
    "status": "online",
    "uptime": 86400,
    "memory_free": 45312,
    "cpu_temperature": 42.5,
    "wifi_signal": -58
  }
}
```

### 2. Telemetry Streaming

#### Real-time Telemetry
```json
{
  "type": "telemetry",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "device_uuid": "esp32-can-001",
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
}
```

### 3. Relay Events

#### Relay State Changed
```json
{
  "type": "relay_changed",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "device_uuid": "esp32-relay-001",
    "relay_id": 1,
    "previous_state": false,
    "new_state": true,
    "triggered_by": "manual",
    "command_id": "cmd_12345"
  }
}
```

### 4. System Events

#### Gateway Status
```json
{
  "type": "gateway_status",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "status": "online",
    "uptime": 86400,
    "devices_online": 5,
    "messages_processed": 15847,
    "memory_usage": {
      "ram_mb": 45.2,
      "cpu_percent": 12.5
    }
  }
}
```

#### System Alert
```json
{
  "type": "alert",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "level": "warning",  // info, warning, error, critical
    "source": "device_manager",
    "message": "Dispositivo esp32-001 offline há mais de 5 minutos",
    "device_uuid": "esp32-001"
  }
}
```

## 📥 Mensagens do Client (Client → Server)

### 1. Subscriptions

#### Subscribe to Device
```json
{
  "type": "subscribe",
  "data": {
    "filter": "device",
    "device_uuid": "esp32-display-001"
  }
}
```

#### Subscribe to Telemetry
```json
{
  "type": "subscribe",
  "data": {
    "filter": "telemetry",
    "device_uuids": ["esp32-can-001", "esp32-sensor-002"],
    "data_types": ["can_data", "gps"]  // opcional
  }
}
```

#### Unsubscribe
```json
{
  "type": "unsubscribe",
  "data": {
    "filter": "device",
    "device_uuid": "esp32-display-001"
  }
}
```

### 2. Device Control

#### Send Command
```json
{
  "type": "command",
  "data": {
    "device_uuid": "esp32-relay-001",
    "command_type": "relay_control",
    "parameters": {
      "relay_id": 1,
      "state": true,
      "duration": 5000
    }
  }
}
```

### 3. System Commands

#### Request Gateway Status
```json
{
  "type": "get_status",
  "data": {}
}
```

#### Request Device List
```json
{
  "type": "get_devices",
  "data": {
    "online_only": true  // opcional
  }
}
```

## 🔄 Connection Management

### Connection Events

#### Connected
```json
{
  "type": "connected",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "session_id": "ws_session_123",
    "gateway_version": "1.0.0"
  }
}
```

#### Heartbeat (Ping/Pong)
```json
// Client → Server
{
  "type": "ping",
  "timestamp": "2025-01-27T10:30:00Z"
}

// Server → Client  
{
  "type": "pong",
  "timestamp": "2025-01-27T10:30:00Z"
}
```

### Error Handling

#### Error Response
```json
{
  "type": "error",
  "timestamp": "2025-01-27T10:30:00Z",
  "data": {
    "code": "DEVICE_NOT_FOUND",
    "message": "Dispositivo esp32-999 não encontrado",
    "request_id": "req_123"  // se aplicável
  }
}
```

## 🛠️ Implementation Example

### JavaScript Client
```javascript
class AutoCoreWebSocket {
  constructor(url) {
    this.ws = new WebSocket(url);
    this.setupEventHandlers();
  }
  
  setupEventHandlers() {
    this.ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      this.handleMessage(message);
    };
    
    this.ws.onopen = () => {
      console.log('Connected to AutoCore Gateway');
      this.subscribeToAll();
    };
  }
  
  subscribeToAll() {
    this.send({
      type: 'subscribe',
      data: { filter: 'all' }
    });
  }
  
  send(message) {
    this.ws.send(JSON.stringify(message));
  }
  
  handleMessage(message) {
    switch(message.type) {
      case 'device_connected':
        console.log('Device connected:', message.data.device_uuid);
        break;
      case 'telemetry':
        this.updateTelemetryDisplay(message.data);
        break;
      case 'relay_changed':
        this.updateRelayStatus(message.data);
        break;
    }
  }
}

// Usage
const gateway = new AutoCoreWebSocket('ws://localhost:8080/ws');
```

### Python Client
```python
import asyncio
import websockets
import json

class AutoCoreWebSocketClient:
    def __init__(self, url):
        self.url = url
        self.ws = None
    
    async def connect(self):
        self.ws = await websockets.connect(self.url)
        
    async def listen(self):
        async for message in self.ws:
            data = json.loads(message)
            await self.handle_message(data)
    
    async def handle_message(self, message):
        msg_type = message.get('type')
        
        if msg_type == 'device_connected':
            print(f"Device connected: {message['data']['device_uuid']}")
        elif msg_type == 'telemetry':
            await self.process_telemetry(message['data'])
    
    async def send(self, message):
        await self.ws.send(json.dumps(message))
    
    async def subscribe_to_device(self, device_uuid):
        await self.send({
            'type': 'subscribe',
            'data': {
                'filter': 'device',
                'device_uuid': device_uuid
            }
        })

# Usage
async def main():
    client = AutoCoreWebSocketClient('ws://localhost:8080/ws')
    await client.connect()
    await client.subscribe_to_device('esp32-display-001')
    await client.listen()

asyncio.run(main())
```

## 📊 Performance

### Connection Limits
- **Max Concurrent**: 100 conexões
- **Max Message Rate**: 10 msgs/seg por conexão
- **Max Message Size**: 64KB
- **Idle Timeout**: 300 segundos

### Optimization
- **Binary Frames**: Para telemetria alta frequência (futuro)
- **Compression**: per-message-deflate disponível
- **Message Filtering**: Reduz bandwidth desnecessário
- **Batch Updates**: Agrupa updates similares

## 🔐 Security

### Authentication
```json
// Após conexão, enviar token
{
  "type": "auth",
  "data": {
    "token": "jwt_token_here"
  }
}

// Resposta
{
  "type": "auth_result",
  "data": {
    "success": true,
    "user_id": "user_123",
    "permissions": ["device_control", "telemetry_read"]
  }
}
```

### Rate Limiting
- **Commands**: 5/minuto
- **Subscriptions**: 10/minuto
- **General**: 60/minuto

---

Esta API WebSocket permite integração em tempo real com o AutoCore Gateway, fornecendo eventos instantâneos e controle bidirecional dos dispositivos.