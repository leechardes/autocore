# 📚 Protocols - Gateway AutoCore

## 🎯 Visão Geral

Documentação dos protocolos de comunicação suportados pelo Gateway AutoCore.

## 📖 Protocolos Suportados

### MQTT
- [MQTT-PROTOCOL.md](MQTT-PROTOCOL.md) - Protocolo MQTT completo
- [MQTT-QOS.md](MQTT-QOS.md) - Níveis de QoS
- [MQTT-RETAIN.md](MQTT-RETAIN.md) - Mensagens retidas

### WebSocket
- [WEBSOCKET-PROTOCOL.md](WEBSOCKET-PROTOCOL.md) - Protocolo WebSocket
- [WS-EVENTS.md](WS-EVENTS.md) - Eventos em tempo real
- [WS-AUTHENTICATION.md](WS-AUTHENTICATION.md) - Autenticação WS

### HTTP/REST
- [HTTP-API.md](HTTP-API.md) - API REST
- [HTTP-METHODS.md](HTTP-METHODS.md) - Métodos HTTP
- [HTTP-STATUS.md](HTTP-STATUS.md) - Códigos de status

### CAN Bus
- [CAN-PROTOCOL.md](CAN-PROTOCOL.md) - Protocolo CAN
- [CAN-MESSAGES.md](CAN-MESSAGES.md) - Formato de mensagens
- [CAN-BRIDGE.md](CAN-BRIDGE.md) - Bridge CAN-MQTT

## 🔄 Fluxo de Comunicação

```
ESP32 Device
    ↓ MQTT
Gateway Hub
    ↓ Process
Database + Cache
    ↓ Broadcast
All Clients (MQTT/WS/HTTP)
```

## 📊 Comparação de Protocolos

| Protocolo | Use Case | Latência | Throughput |
|-----------|----------|----------|------------|
| MQTT | IoT devices | Low | Medium |
| WebSocket | Real-time UI | Very Low | High |
| HTTP | Config/API | Medium | Low |
| CAN | Vehicle data | Very Low | High |

---

**Última atualização**: 27/01/2025