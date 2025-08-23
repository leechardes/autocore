# Endpoints - MQTT

Sistema de monitoramento e comunicação MQTT para dispositivos ESP32 e integração em tempo real.

## 📋 Visão Geral

Os endpoints de MQTT permitem:
- Obter configurações MQTT para dispositivos ESP32
- Monitorar status da conexão MQTT
- Gerenciar tópicos e subscriptions
- WebSocket para streaming de mensagens em tempo real
- Controle de histórico de mensagens

## 📡 Endpoints de MQTT

### `GET /api/mqtt/config`

Retorna configurações MQTT para dispositivos ESP32.

**Resposta:**
```json
{
  "broker": "10.0.10.100",
  "port": 1883,
  "username": null,
  "password": null,
  "topic_prefix": "autocore",
  "keepalive": 60,
  "qos": 1,
  "retain": false,
  "client_id_pattern": "autocore-{device_uuid}",
  "auto_reconnect": true,
  "max_reconnect_attempts": 5,
  "reconnect_interval": 5000
}
```

**Códigos de Status:**
- `200` - Configuração retornada com sucesso
- `500` - Erro interno do servidor

---

### `GET /api/mqtt/status`

Retorna status atual da conexão MQTT e estatísticas.

**Resposta:**
```json
{
  "connection": {
    "status": "connected",
    "broker": "10.0.10.100:1883",
    "client_id": "config-app-monitor",
    "connected_since": "2025-01-22T08:00:00Z",
    "last_heartbeat": "2025-01-22T10:15:30Z"
  },
  "statistics": {
    "messages_received": 15678,
    "messages_sent": 3421,
    "bytes_received": 2456789,
    "bytes_sent": 678912,
    "connection_uptime": "02:15:30",
    "reconnection_count": 2,
    "last_reconnection": "2025-01-22T09:45:12Z"
  },
  "subscriptions": [
    "autocore/devices/+/announce",
    "autocore/devices/+/status", 
    "autocore/devices/+/telemetry",
    "autocore/devices/+/response",
    "autocore/gateway/status",
    "autocore/discovery/+"
  ],
  "active_devices": [
    {
      "uuid": "esp32-relay-001",
      "last_seen": "2025-01-22T10:15:25Z",
      "status": "online",
      "message_count": 234
    },
    {
      "uuid": "esp32-display-001", 
      "last_seen": "2025-01-22T10:15:28Z",
      "status": "online",
      "message_count": 89
    }
  ]
}
```

**Códigos de Status:**
- `200` - Status retornado com sucesso
- `503` - MQTT desconectado
- `500` - Erro interno do servidor

---

### `GET /api/mqtt/topics`

Lista todos os tópicos MQTT do sistema AutoCore.

**Resposta:**
```json
{
  "subscriptions": [
    "autocore/devices/+/announce",
    "autocore/devices/+/status",
    "autocore/devices/+/telemetry",
    "autocore/devices/+/response",
    "autocore/gateway/status",
    "autocore/discovery/+"
  ],
  "device_topics": {
    "announce": "autocore/devices/{device_uuid}/announce",
    "status": "autocore/devices/{device_uuid}/status",
    "telemetry": "autocore/devices/{device_uuid}/telemetry",
    "command": "autocore/devices/{device_uuid}/command",
    "response": "autocore/devices/{device_uuid}/response",
    "relay_status": "autocore/devices/{device_uuid}/relay/status",
    "config_request": "autocore/devices/{device_uuid}/config/request",
    "config_response": "autocore/devices/{device_uuid}/config/response"
  },
  "system_topics": {
    "gateway_status": "autocore/gateway/status",
    "discovery": "autocore/discovery/+",
    "broadcast": "autocore/system/broadcast",
    "alerts": "autocore/system/alerts",
    "maintenance": "autocore/system/maintenance"
  },
  "wildcard_patterns": {
    "all_devices": "autocore/devices/+/+",
    "all_system": "autocore/system/+",
    "all_gateway": "autocore/gateway/+",
    "device_specific": "autocore/devices/{device_uuid}/+"
  }
}
```

**Códigos de Status:**
- `200` - Tópicos retornados com sucesso
- `500` - Erro interno do servidor

---

### `POST /api/mqtt/clear`

Limpa o histórico de mensagens MQTT armazenado em memória.

**Resposta:**
```json
{
  "success": true,
  "message": "Histórico limpo",
  "previous_count": 1567,
  "cleared_at": "2025-01-22T10:15:30Z"
}
```

**Códigos de Status:**
- `200` - Histórico limpo com sucesso
- `500` - Erro interno do servidor

---

### `WebSocket /ws/mqtt`

WebSocket para streaming de mensagens MQTT em tempo real.

**Conexão:**
```javascript
const ws = new WebSocket('ws://localhost:8081/ws/mqtt');

ws.onopen = function(event) {
    console.log('Conectado ao monitor MQTT');
};

ws.onmessage = function(event) {
    const message = JSON.parse(event.data);
    handleMqttMessage(message);
};
```

**Mensagens Recebidas:**
```json
{
  "type": "mqtt_message",
  "data": {
    "topic": "autocore/devices/esp32-relay-001/status",
    "payload": {
      "status": "online",
      "ip_address": "192.168.1.101",
      "uptime": 3600,
      "free_memory": 128000
    },
    "timestamp": "2025-01-22T10:15:30.123Z",
    "qos": 1,
    "retain": false,
    "device_uuid": "esp32-relay-001"
  }
}
```

**Comandos de Publicação:**
```javascript
// Enviar comando via WebSocket
ws.send('PUBLISH:autocore/devices/esp32-relay-001/command:{"action":"toggle","channel":1}');

// Resposta recebida
{
  "type": "publish_result",
  "data": {
    "success": true,
    "topic": "autocore/devices/esp32-relay-001/command"
  }
}
```

## 🔗 Estrutura de Tópicos

### Device Topics (Por Dispositivo)

#### `autocore/devices/{device_uuid}/announce`
Dispositivo anuncia sua presença ao conectar:
```json
{
  "device_uuid": "esp32-relay-001",
  "device_type": "esp32_relay",
  "firmware_version": "2.1.0",
  "hardware_version": "v1.5",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "ip_address": "192.168.1.101",
  "capabilities": {
    "relay_channels": 16,
    "has_display": false,
    "has_sensors": true
  },
  "timestamp": "2025-01-22T10:00:00Z"
}
```

#### `autocore/devices/{device_uuid}/status`
Status periódico do dispositivo (heartbeat):
```json
{
  "status": "online",
  "uptime": 3600,
  "free_memory": 128000,
  "cpu_usage": 15.5,
  "wifi_rssi": -45,
  "temperature": 42.3,
  "timestamp": "2025-01-22T10:15:30Z"
}
```

#### `autocore/devices/{device_uuid}/telemetry`
Dados de telemetria em tempo real:
```json
{
  "data": {
    "rpm": 3250,
    "engine_temp": 89.5,
    "oil_pressure": 4.2,
    "speed": 45.8
  },
  "timestamp": "2025-01-22T10:15:30.123Z",
  "source": "can_bus"
}
```

#### `autocore/devices/{device_uuid}/command`
Comandos enviados para o dispositivo:
```json
{
  "command_id": "cmd_12345",
  "action": "relay_toggle",
  "parameters": {
    "channel": 1,
    "duration": 1000
  },
  "timestamp": "2025-01-22T10:15:30Z",
  "source": "config-app"
}
```

#### `autocore/devices/{device_uuid}/response`
Resposta do dispositivo aos comandos:
```json
{
  "command_id": "cmd_12345",
  "status": "success",
  "result": {
    "channel": 1,
    "new_state": "on",
    "execution_time": 150
  },
  "timestamp": "2025-01-22T10:15:30.275Z"
}
```

#### `autocore/devices/{device_uuid}/relay/status`
Status específico dos relés:
```json
{
  "board_id": 1,
  "channels": [
    {"channel": 1, "state": "on", "last_changed": "2025-01-22T10:15:30Z"},
    {"channel": 2, "state": "off", "last_changed": "2025-01-22T09:30:15Z"}
  ],
  "timestamp": "2025-01-22T10:15:31Z"
}
```

### System Topics (Globais)

#### `autocore/gateway/status`
Status do gateway principal:
```json
{
  "status": "running",
  "version": "2.0.0",
  "connected_devices": 15,
  "active_connections": 23,
  "uptime": "15:30:45",
  "memory_usage": 65.2,
  "cpu_usage": 12.8,
  "timestamp": "2025-01-22T10:15:30Z"
}
```

#### `autocore/system/broadcast`
Mensagens broadcast para todos os dispositivos:
```json
{
  "message_type": "config_update",
  "data": {
    "update_available": true,
    "version": "2.1.0",
    "download_url": "https://updates.autocore.com/v2.1.0"
  },
  "timestamp": "2025-01-22T10:00:00Z"
}
```

#### `autocore/system/alerts`
Alertas críticos do sistema:
```json
{
  "alert_level": "critical",
  "alert_type": "device_offline",
  "message": "Dispositivo esp32-relay-001 offline há mais de 5 minutos",
  "device_uuid": "esp32-relay-001",
  "timestamp": "2025-01-22T10:15:30Z",
  "requires_action": true
}
```

#### `autocore/discovery/+`
Descoberta automática de dispositivos:
```json
{
  "discovery_type": "mdns",
  "device_info": {
    "hostname": "esp32-new-device.local",
    "ip_address": "192.168.1.105",
    "mac_address": "CC:DD:EE:FF:AA:BB",
    "services": ["_http._tcp", "_autocore._tcp"]
  },
  "timestamp": "2025-01-22T10:15:30Z"
}
```

## 🔧 Integração ESP32

### Configuração Básica
```cpp
// ESP32 - Configuração MQTT
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

WiFiClient espClient;
PubSubClient client(espClient);

void setupMQTT() {
    // Obter configurações do servidor
    String configUrl = "http://192.168.1.100:8081/api/mqtt/config";
    String config = httpGet(configUrl);
    
    JsonDocument doc;
    deserializeJson(doc, config);
    
    const char* broker = doc["broker"];
    int port = doc["port"];
    
    client.setServer(broker, port);
    client.setCallback(onMqttMessage);
    
    // Conectar
    connectMQTT();
}

void connectMQTT() {
    String clientId = "autocore-" + String(device_uuid);
    
    while (!client.connected()) {
        if (client.connect(clientId.c_str())) {
            Serial.println("MQTT Connected");
            
            // Anunciar presença
            announceDevice();
            
            // Subscrever tópicos
            subscribeTopics();
            
        } else {
            delay(5000);
        }
    }
}
```

### Anúncio de Dispositivo
```cpp
void announceDevice() {
    JsonDocument doc;
    doc["device_uuid"] = device_uuid;
    doc["device_type"] = device_type;
    doc["firmware_version"] = FIRMWARE_VERSION;
    doc["hardware_version"] = HARDWARE_VERSION;
    doc["mac_address"] = WiFi.macAddress();
    doc["ip_address"] = WiFi.localIP().toString();
    doc["timestamp"] = getCurrentTimestamp();
    
    String payload;
    serializeJson(doc, payload);
    
    String topic = "autocore/devices/" + String(device_uuid) + "/announce";
    client.publish(topic.c_str(), payload.c_str(), true); // retain=true
}
```

### Envio de Telemetria
```cpp
void sendTelemetry() {
    JsonDocument doc;
    doc["data"]["rpm"] = readRPM();
    doc["data"]["engine_temp"] = readEngineTemp();
    doc["data"]["oil_pressure"] = readOilPressure();
    doc["timestamp"] = getCurrentTimestamp();
    doc["source"] = "can_bus";
    
    String payload;
    serializeJson(doc, payload);
    
    String topic = "autocore/devices/" + String(device_uuid) + "/telemetry";
    client.publish(topic.c_str(), payload.c_str());
}
```

### Processamento de Comandos
```cpp
void onMqttMessage(char* topic, byte* payload, unsigned int length) {
    String topicStr = String(topic);
    String payloadStr = String((char*)payload, length);
    
    if (topicStr.endsWith("/command")) {
        JsonDocument doc;
        deserializeJson(doc, payloadStr);
        
        String commandId = doc["command_id"];
        String action = doc["action"];
        
        // Executar comando
        JsonDocument response;
        response["command_id"] = commandId;
        
        if (action == "relay_toggle") {
            int channel = doc["parameters"]["channel"];
            bool success = toggleRelay(channel);
            
            response["status"] = success ? "success" : "error";
            response["result"]["channel"] = channel;
            response["result"]["new_state"] = getRelayState(channel) ? "on" : "off";
        }
        
        response["timestamp"] = getCurrentTimestamp();
        
        // Enviar resposta
        String responsePayload;
        serializeJson(response, responsePayload);
        
        String responseTopic = "autocore/devices/" + String(device_uuid) + "/response";
        client.publish(responseTopic.c_str(), responsePayload.c_str());
    }
}
```

## 📊 Monitoramento em Tempo Real

### Frontend WebSocket
```javascript
class MQTTMonitor {
    constructor() {
        this.ws = null;
        this.messageHistory = [];
        this.deviceStatus = new Map();
        this.connect();
    }

    connect() {
        this.ws = new WebSocket('ws://localhost:8081/ws/mqtt');
        
        this.ws.onopen = () => {
            console.log('Connected to MQTT monitor');
            this.updateConnectionStatus(true);
        };
        
        this.ws.onmessage = (event) => {
            const message = JSON.parse(event.data);
            this.handleMessage(message);
        };
        
        this.ws.onclose = () => {
            console.log('MQTT monitor disconnected');
            this.updateConnectionStatus(false);
            // Reconectar após 5 segundos
            setTimeout(() => this.connect(), 5000);
        };
    }

    handleMessage(message) {
        if (message.type === 'mqtt_message') {
            const data = message.data;
            
            // Adicionar ao histórico
            this.messageHistory.push(data);
            
            // Atualizar interface
            this.updateDeviceStatus(data);
            this.updateMessageLog(data);
            
            // Processar tipos específicos
            if (data.topic.includes('/status')) {
                this.updateDeviceStatusIndicator(data);
            } else if (data.topic.includes('/telemetry')) {
                this.updateTelemetryDisplay(data);
            }
        }
    }

    sendCommand(deviceUuid, command) {
        const topic = `autocore/devices/${deviceUuid}/command`;
        const payload = JSON.stringify(command);
        
        this.ws.send(`PUBLISH:${topic}:${payload}`);
    }
}

// Uso
const monitor = new MQTTMonitor();

// Enviar comando para dispositivo
monitor.sendCommand('esp32-relay-001', {
    command_id: 'cmd_' + Date.now(),
    action: 'relay_toggle',
    parameters: { channel: 1 }
});
```

### Dashboard de Status
```javascript
// Dashboard em tempo real
class DeviceStatusDashboard {
    constructor() {
        this.devices = new Map();
        this.monitor = new MQTTMonitor();
        this.monitor.onDeviceUpdate = (device) => this.updateDevice(device);
    }

    updateDevice(deviceData) {
        const uuid = deviceData.device_uuid;
        const existing = this.devices.get(uuid) || {};
        
        // Atualizar dados
        const updated = {
            ...existing,
            uuid: uuid,
            last_seen: new Date(),
            status: deviceData.payload.status || 'unknown',
            ...deviceData.payload
        };
        
        this.devices.set(uuid, updated);
        this.renderDeviceCard(updated);
    }

    renderDeviceCard(device) {
        const card = document.getElementById(`device-${device.uuid}`);
        if (!card) return;
        
        // Atualizar status visual
        const statusIndicator = card.querySelector('.status-indicator');
        statusIndicator.className = `status-indicator status-${device.status}`;
        
        // Atualizar último visto
        const lastSeen = card.querySelector('.last-seen');
        lastSeen.textContent = `Último: ${device.last_seen.toLocaleTimeString()}`;
        
        // Atualizar telemetria se disponível
        if (device.telemetry) {
            this.updateTelemetryValues(card, device.telemetry);
        }
    }
}
```

## ⚠️ Considerações

### Segurança
- Configurar autenticação MQTT em produção
- Usar TLS para conexões seguras (porta 8883)
- Validar payloads recebidos antes de processar
- Implementar rate limiting para prevenir spam

### Performance
- Controlar frequência de mensagens para não sobrecarregar rede
- Usar QoS apropriado (0, 1, ou 2) conforme necessidade
- Implementar batching para telemetria de alta frequência
- Monitorar uso de memória do buffer de mensagens

### Confiabilidade
- Implementar retry logic para mensagens críticas
- Usar retained messages para status importantes
- Configurar Last Will Testament para detecção de desconexão
- Implementar heartbeat periódico

### Escalabilidade
- Usar tópicos hierárquicos para organização
- Implementar load balancing com múltiplos brokers
- Considerar clustering para alta disponibilidade
- Monitorar crescimento do número de dispositivos