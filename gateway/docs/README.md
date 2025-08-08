# 📚 Documentação - AutoCore Gateway

## 🎯 Visão Geral

O AutoCore Gateway é o hub central de comunicação MQTT do sistema AutoCore, responsável por gerenciar a comunicação com dispositivos ESP32 distribuídos no veículo.

## 📖 Guias

### 🚀 Início Rápido
- **[QUICKSTART.md](guides/QUICKSTART.md)** - Setup em 5 minutos

### 🏗️ Arquitetura
- **[OVERVIEW.md](architecture/OVERVIEW.md)** - Visão geral da arquitetura

### 📡 API Reference
- **[MQTT_TOPICS.md](api/MQTT_TOPICS.md)** - Documentação completa de tópicos MQTT

## 🔧 Estrutura do Projeto

```
gateway/
├── src/                     # Código fonte
│   ├── core/               # Componentes principais
│   │   ├── config.py       # Configurações
│   │   ├── mqtt_client.py  # Cliente MQTT
│   │   ├── message_handler.py # Processamento
│   │   └── device_manager.py # Dispositivos
│   ├── services/           # Serviços
│   │   └── telemetry_service.py # Telemetria
│   └── main.py             # Entry point
├── docs/                   # Documentação
├── scripts/                # Scripts auxiliares
├── tests/                  # Testes
├── logs/                   # Logs (criado automaticamente)
├── tmp/                    # Arquivos temporários
├── Makefile               # Automação
├── requirements.txt       # Dependências
├── .env.example          # Template de configuração
└── run.py                # Ponto de entrada
```

## ⚡ Comandos Rápidos

```bash
# Setup completo
make dev

# Iniciar Gateway
make start

# Status e monitoramento
make status
make logs

# Manutenção
make clean
python scripts/maintenance.py full

# Desenvolvimento
make test
make lint
make format
```

## 🎯 Principais Funcionalidades

### ✅ Implementado
- 🔄 **Comunicação MQTT Assíncrona** - Cliente robusto com auto-reconexão
- 📱 **Gerenciamento de Dispositivos** - Discovery, status e comandos
- 📊 **Pipeline de Telemetria** - Coleta e armazenamento de dados de sensores
- 🎛️ **Controle de Relés** - Comando remoto via MQTT
- 💾 **Database Compartilhado** - Integração com SQLite via repositories
- 📝 **Logging Completo** - Sistema de logs estruturado
- 🔧 **Configuração Flexível** - Via variáveis de ambiente

### 🚧 Planejado
- 🚗 **CAN Bus Real** - Integração com dados CAN Bus reais
- 🔐 **Segurança Avançada** - TLS, certificados, ACL
- 📈 **Métricas Avançadas** - Prometheus, Grafana
- 🔄 **Alta Disponibilidade** - Clustering, failover
- 🌐 **Interface Web** - Dashboard de monitoramento

## 🔗 Links Relacionados

### Projetos AutoCore
- **[Config App](../../config-app/)** - Interface web de configuração
- **[Database](../../database/)** - Database compartilhado

### Documentação Técnica
- **[MQTT Protocol](https://mqtt.org/mqtt-specification/)** - Especificação MQTT
- **[ESP32 Docs](https://docs.espressif.com/)** - Documentação ESP32
- **[SQLite Docs](https://www.sqlite.org/docs.html)** - Documentação SQLite

## 🆘 Suporte e Troubleshooting

### 🐛 Problemas Comuns
1. **Gateway não conecta ao broker**
   - Verificar `MQTT_BROKER` e `MQTT_PORT` no `.env`
   - Testar broker: `mosquitto_pub -h localhost -t test -m hello`

2. **Dispositivos não aparecem**
   - Verificar tópicos MQTT corretos nos dispositivos
   - Confirmar UUIDs únicos por dispositivo

3. **Database não encontrado**
   - Executar: `cd ../database && python src/cli/manage.py init`

### 🔍 Debug
```bash
# Logs detalhados
LOG_LEVEL=DEBUG make start

# Verificar status completo
make check
python scripts/maintenance.py status

# Monitorar MQTT
mosquitto_sub -h localhost -t "autocore/devices/+/+"
```

## 📄 Licença

MIT License - Ver LICENSE para detalhes.

---

**🚀 AutoCore Gateway - Conectando seu veículo ao futuro!**