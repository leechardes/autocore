# 📡 Protocolos de Comunicação

## 🎯 Visão Geral

Esta pasta contém documentação sobre os protocolos de comunicação utilizados pelo ESP32-Display.

## 📁 Conteúdo

### MQTT
- **MQTT-PROTOCOL.md** - Especificação completa do protocolo MQTT
- Tópicos de comando e telemetria
- Estrutura de payloads JSON
- QoS e retenção de mensagens

### HTTP/API
- Comunicação com backend via REST API
- Endpoints para configuração e status
- Autenticação e headers

### WebSocket
- Comunicação em tempo real
- Push de atualizações de status
- Notificações do sistema

## 🔧 Implementação

Os protocolos são implementados através das seguintes classes:
- `MQTTClient` - Comunicação MQTT
- `ScreenApiClient` - Comunicação HTTP
- `StatusReporter` - Relatórios de status

## 📖 Documentação Relacionada

- [MQTT Protocol](../communication/MQTT-PROTOCOL.md)
- [API Reference](../API-REFERENCE.md)
- [Networking](../networking/)