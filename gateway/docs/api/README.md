# 📡 APIs e Protocolos - AutoCore Gateway

## 📋 Visão Geral

O AutoCore Gateway atua como bridge entre múltiplos protocolos, fornecendo interfaces de comunicação unificadas para o ecossistema AutoCore.

## 📁 Documentação de Protocolos

### [MQTT-TOPICS.md](./MQTT-TOPICS.md)
Documentação completa de todos os tópicos MQTT utilizados pelo sistema:
- Estrutura hierárquica de tópicos
- Payloads JSON detalhados
- QoS levels por tipo de mensagem
- Padrões de subscrição
- Segurança e ACLs

### [WEBSOCKET.md](./WEBSOCKET.md)  
Interface WebSocket para comunicação em tempo real:
- Conexão bidirecional
- Eventos de dispositivos
- Streaming de telemetria
- Notificações de status

### [HTTP-BRIDGE.md](./HTTP-BRIDGE.md)
Bridge HTTP/REST para integração com APIs externas:
- Endpoints de controle
- Webhooks de eventos
- Status de saúde
- Métricas de performance

## 🔄 Fluxo de Comunicação

```
ESP32 Devices  ←→  MQTT  ←→  Gateway  ←→  WebSocket/HTTP  ←→  Config App
     ↕                                            ↕
  CAN Bus/Sensores                            Database/UI
```

## 🎯 Protocolos Suportados

### Entrada (Dispositivos → Gateway)
- **MQTT**: Comunicação principal com ESP32s
- **Serial**: Debug e configuração local
- **HTTP**: Health checks e status

### Saída (Gateway → Aplicações)
- **WebSocket**: Streaming em tempo real
- **HTTP/REST**: Integração com APIs
- **Database**: Persistência via SQLAlchemy

## 📊 Características Técnicas

### MQTT
- **Broker**: Mosquitto (recomendado)
- **QoS**: 0, 1, 2 (diferenciado por tipo)
- **Retained**: Mensagens de status
- **LWT**: Last Will Testament para detecção offline

### WebSocket
- **Protocol**: RFC 6455
- **Compression**: Opcional (per-message-deflate)
- **Heartbeat**: Ping/Pong automático
- **Reconnection**: Automática com backoff

### HTTP Bridge
- **Methods**: GET, POST, PUT, DELETE
- **Content-Type**: application/json
- **Authentication**: JWT tokens
- **Rate Limiting**: Por endpoint

## 🔐 Segurança

### MQTT
- Username/password por dispositivo
- TLS encryption (produção)
- Topic ACLs baseadas em UUID
- Certificate pinning (futuro)

### WebSocket/HTTP
- JWT authentication
- CORS configurável  
- Request validation
- SSL/TLS obrigatório (produção)

## 📈 Performance

### Latência
- **MQTT → Gateway**: < 10ms
- **Gateway → WebSocket**: < 5ms  
- **HTTP Bridge**: < 50ms
- **End-to-end**: < 100ms

### Throughput
- **MQTT Messages**: 1000+/seg
- **WebSocket Events**: 500+/seg
- **HTTP Requests**: 100+/seg
- **Telemetry Points**: 10K+/hora

## 🛠️ Configuração

Consulte os arquivos específicos de cada protocolo para detalhes de configuração e exemplos de uso.

---

**Última atualização**: 2025-01-27