# 🚀 AutoCore Gateway

Hub central de comunicação MQTT para dispositivos ESP32 do sistema AutoCore.

## ⚡ Início Rápido

```bash
# 1. Setup completo
make dev

# 2. Iniciar Gateway  
make start

# 3. Verificar status
make status
```

## 🏗️ Estrutura Organizada

```
gateway/
├── src/                    # 📁 Código fonte
│   ├── core/              # 🧠 Componentes principais
│   │   ├── config.py      # ⚙️ Configurações
│   │   ├── mqtt_client.py # 📡 Cliente MQTT
│   │   ├── message_handler.py # 📨 Processamento
│   │   └── device_manager.py # 📱 Dispositivos  
│   ├── services/          # 🔧 Serviços
│   │   └── telemetry_service.py # 📊 Telemetria
│   └── main.py           # 🎯 Entry point
├── docs/                  # 📚 Documentação completa
├── scripts/               # 🛠️ Scripts auxiliares  
├── tests/                 # 🧪 Testes
├── Makefile              # 🚀 Automação
├── requirements.txt      # 📦 Dependências
└── run.py               # 🏃 Executor principal
```

## 🎯 Funcionalidades

### ✅ Implementado
- **Comunicação MQTT Assíncrona** - Auto-reconexão, QoS diferenciado
- **Gerenciamento de Dispositivos** - Discovery, status, comandos  
- **Pipeline de Telemetria** - Buffer inteligente, múltiplas fontes
- **Controle de Relés** - Comando remoto via MQTT
- **Database Compartilhado** - SQLite via repositories
- **Logs Estruturados** - Rotação automática, múltiplos níveis
- **Automação Completa** - Makefile com 20+ comandos

## 📖 Documentação

- **[📚 Docs Principais](docs/README.md)** - Índice completo
- **[🚀 Guia Rápido](docs/guides/QUICKSTART.md)** - Setup em 5 minutos  
- **[🏗️ Arquitetura](docs/architecture/OVERVIEW.md)** - Visão técnica
- **[📡 MQTT Topics](docs/api/MQTT_TOPICS.md)** - API completa

## ⚙️ Comandos Make

```bash
# 🛠️ Desenvolvimento
make dev           # Setup completo desenvolvimento
make start         # Iniciar modo interativo
make debug         # Iniciar com logs verbosos
make test          # Executar testes
make lint          # Verificar código

# 🚀 Produção  
make start-bg      # Iniciar em background
make stop          # Parar gateway
make status        # Ver status
make logs          # Monitorar logs

# 🧹 Manutenção
make clean         # Limpar temporários
make backup        # Criar backup
make upgrade       # Atualizar dependências
make check         # Verificar configuração
```

## 🔧 Scripts Auxiliares

```bash
# 🛠️ Manutenção avançada
python scripts/maintenance.py status      # Status detalhado
python scripts/maintenance.py clean       # Limpeza
python scripts/maintenance.py full        # Manutenção completa

# 🚀 Execução direta
python run.py                            # Executar gateway
./scripts/start.sh                       # Script de inicialização
```

## ⚙️ Configuração

### Arquivo .env
```env
# MQTT Broker
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_USERNAME=
MQTT_PASSWORD=

# Database  
DATABASE_PATH=../database/autocore.db

# Performance
TELEMETRY_BATCH_SIZE=10
DEVICE_TIMEOUT=300

# Logging
LOG_LEVEL=INFO
LOG_FILE=/tmp/autocore-gateway.log
```

### Tópicos MQTT
```
autocore/devices/+/announce     # 📢 Anúncios
autocore/devices/+/status       # 📊 Status
autocore/devices/+/telemetry    # 📈 Telemetria  
autocore/devices/+/command      # 🎛️ Comandos
autocore/devices/+/response     # 📋 Respostas
autocore/devices/+/relay/status # 🔌 Relés
```

## 🔍 Monitoramento

### Status em Tempo Real
```bash
make status        # Status rápido
make logs          # Logs ao vivo
python scripts/maintenance.py status --json  # Status JSON
```

### Logs Estruturados
- **Console**: Tempo real durante desenvolvimento  
- **Arquivo**: `/tmp/autocore-gateway.log` com rotação
- **Database**: Events table para auditoria

## 🐛 Troubleshooting

### Problemas Comuns

**Gateway não inicia**
```bash
make check         # Verificar dependências
cat logs/gateway.log # Ver erros
```

**MQTT não conecta**  
```bash
# Testar broker
mosquitto_pub -h localhost -t test -m hello

# Verificar config
grep MQTT .env
```

**Database não encontrado**
```bash
cd ../database && python src/cli/manage.py init
```

## 🏆 Qualidade de Código

- ✅ **Estrutura Modular** - Separação clara de responsabilidades
- ✅ **Async/Await** - Performance otimizada 
- ✅ **Error Handling** - Tratamento robusto de erros
- ✅ **Logging** - Sistema completo de logs
- ✅ **Configuration** - Flexível via environment
- ✅ **Documentation** - Docs detalhadas
- ✅ **Automation** - Makefile + scripts

## 🔗 Integração

### Config App
- Interface web para configuração
- Gerenciamento de dispositivos
- Visualização de telemetria

### Database  
- SQLite compartilhado
- Repository pattern
- Migrations automáticas

### ESP32 Devices
- Firmware padronizado
- MQTT communication
- Auto-discovery

## 📄 Licença

MIT License - Conectando seu veículo ao futuro! 🚗⚡

---

**Made with ❤️ by AutoCore Team**