# 📚 Services - Gateway AutoCore

## 🎯 Visão Geral

Documentação dos serviços internos do Gateway AutoCore.

## 📖 Serviços Principais

### Core Services
- [MQTT-SERVICE.md](MQTT-SERVICE.md) - Serviço MQTT broker
- [DATABASE-SERVICE.md](DATABASE-SERVICE.md) - Serviço de banco de dados
- [CONFIG-SERVICE.md](CONFIG-SERVICE.md) - Gerenciamento de configurações

### Communication Services
- [WEBSOCKET-SERVICE.md](WEBSOCKET-SERVICE.md) - WebSocket em tempo real
- [HTTP-API-SERVICE.md](HTTP-API-SERVICE.md) - API REST
- [BRIDGE-SERVICE.md](BRIDGE-SERVICE.md) - Bridge MQTT-HTTP

### Processing Services
- [TELEMETRY-SERVICE.md](TELEMETRY-SERVICE.md) - Processamento de telemetria
- [AUTOMATION-SERVICE.md](AUTOMATION-SERVICE.md) - Engine de automação
- [CAN-BRIDGE-SERVICE.md](CAN-BRIDGE-SERVICE.md) - Bridge para CAN bus

### Support Services
- [LOGGER-SERVICE.md](LOGGER-SERVICE.md) - Sistema de logs
- [MONITOR-SERVICE.md](MONITOR-SERVICE.md) - Monitoramento
- [BACKUP-SERVICE.md](BACKUP-SERVICE.md) - Backup automático

## 🏗️ Arquitetura de Serviços

```
Gateway Core
    ├── MQTT Broker (1883, 9001)
    ├── Database (SQLite/PostgreSQL)
    ├── Config Manager
    ├── WebSocket Server (8080)
    ├── HTTP API (8000)
    └── Service Orchestrator
```

## 🔄 Lifecycle

1. **Startup**: Inicialização sequencial
2. **Running**: Processamento paralelo
3. **Shutdown**: Graceful shutdown
4. **Recovery**: Auto-recovery em falhas

---

**Última atualização**: 27/01/2025