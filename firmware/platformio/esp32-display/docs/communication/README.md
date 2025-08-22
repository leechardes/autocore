# Communication - Protocolos de Comunicação

Este diretório contém toda a documentação sobre os protocolos de comunicação utilizados pelo firmware ESP32.

## 📡 Protocolos Implementados

### MQTT Protocol v2.2.0
- **Broker**: Mosquitto/HiveMQ compatível
- **QoS Levels**: 0 (telemetria), 1 (comandos/status)
- **Formato**: JSON estruturado
- **Autenticação**: Username/Password + TLS (opcional)

### HTTP REST API
- **Backup/Fallback**: Quando MQTT não disponível
- **Autenticação**: Bearer Token
- **Formato**: JSON REST
- **Endpoints**: Configuração e status

## 📋 Documentação Disponível

- [`mqtt-protocol.md`](mqtt-protocol.md) - Especificação completa MQTT v2.2.0
- [`command-list.md`](command-list.md) - Lista de comandos disponíveis
- [`json-schemas.md`](json-schemas.md) - Schemas JSON para validação
- [`websocket-api.md`](websocket-api.md) - API WebSocket para tempo real
- [`error-codes.md`](error-codes.md) - Códigos de erro e troubleshooting

## 🔗 Tópicos MQTT Principais

### Device Control
```
autocore/devices/{device_uuid}/relays/set      # Controle de relays
autocore/devices/{device_uuid}/relays/status   # Status de relays
autocore/devices/{device_uuid}/relays/heartbeat # Heartbeat momentário
```

### System Control
```
autocore/system/control                        # Comandos sistema
autocore/preset/execute                        # Execução de presets
autocore/devices/{uuid}/config/update          # Atualização configuração
```

### Telemetry & Status
```
autocore/devices/{uuid}/telemetry/touch        # Eventos touch
autocore/devices/{uuid}/status                 # Status geral
autocore/devices/{uuid}/telemetry/system       # Métricas sistema
```

## ⚙️ Configuração

### Credenciais MQTT
```cpp
// Em DeviceConfig.h
#define MQTT_BROKER "your-broker.com"
#define MQTT_PORT 1883
#define MQTT_USER "username"
#define MQTT_PASSWORD "password"
```

### QoS Configuration
```cpp
#define QOS_TELEMETRY    0  // Fire and forget
#define QOS_COMMANDS     1  // At least once  
#define QOS_HEARTBEAT    1  // At least once
#define QOS_STATUS       1  // At least once
```

## 🔒 Segurança

- TLS 1.2+ para conexões seguras
- Autenticação por device UUID
- Validação de protocol_version
- Rate limiting (100 msg/sec)
- Timeout de comandos (30s)