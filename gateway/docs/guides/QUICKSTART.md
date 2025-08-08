# Guia de Início Rápido - AutoCore Gateway

## 🚀 Setup em 5 Minutos

### Pré-requisitos
- Python 3.9+
- MQTT Broker (Mosquitto recomendado)
- Database AutoCore configurado

### 1. Clone e Configure

```bash
# Já deve estar na pasta gateway/
ls -la  # Verificar estrutura

# Configurar ambiente
make dev
```

### 2. Configure o .env

```bash
# Copiar exemplo (já feito no make dev)
cp .env.example .env

# Editar configurações
nano .env
```

Configurações essenciais:
```env
MQTT_BROKER=localhost  # IP do broker MQTT
MQTT_PORT=1883
DATABASE_PATH=../database/autocore.db  # Path do database
LOG_LEVEL=INFO
```

### 3. Verificar Dependências

```bash
# Verificar tudo
make check

# Deve mostrar:
# ✅ Python 3.9+
# ✅ Ambiente virtual
# ✅ Database encontrado
# ✅ Arquivo .env configurado
```

### 4. Iniciar Gateway

```bash
# Modo interativo (desenvolvimento)
make start

# Ou modo background (produção)
make start-bg
```

### 5. Verificar Status

```bash
# Status do gateway
make status

# Ver logs em tempo real
make logs

# Parar gateway (se em background)
make stop
```

## 📋 Comandos Essenciais

### Desenvolvimento
```bash
make help          # Ver todos comandos
make dev           # Setup completo desenvolvimento
make start         # Iniciar modo interativo
make debug         # Iniciar com debug verbose
make test          # Executar testes
make lint          # Verificar código
```

### Produção
```bash
make start-bg      # Iniciar em background
make stop          # Parar gateway
make status        # Ver status
make logs          # Ver logs
make backup        # Criar backup
```

### Manutenção
```bash
make clean         # Limpar temporários
make upgrade       # Atualizar dependências
make check         # Verificar configuração
```

## 🔧 Configuração MQTT

### Broker Local (Mosquitto)

```bash
# Ubuntu/Debian
sudo apt-get install mosquitto mosquitto-clients

# Iniciar mosquitto
sudo systemctl start mosquitto
sudo systemctl enable mosquitto

# Testar
mosquitto_pub -h localhost -t test -m "hello"
mosquitto_sub -h localhost -t test
```

### Tópicos do Sistema

O Gateway subscreve automaticamente:
```
autocore/devices/+/announce     # Anúncios
autocore/devices/+/status       # Status  
autocore/devices/+/telemetry    # Dados
autocore/devices/+/response     # Respostas
autocore/devices/+/relay/status # Relés
autocore/discovery/+            # Descoberta
```

## 🐛 Resolução de Problemas

### Gateway não inicia

**Erro: "Database não encontrado"**
```bash
cd ../database
python src/cli/manage.py init
cd ../gateway
```

**Erro: "MQTT connection failed"**
```bash
# Verificar broker
sudo systemctl status mosquitto

# Testar conexão
mosquitto_pub -h localhost -t test -m "test"

# Verificar .env
cat .env | grep MQTT
```

**Erro: "Module not found"**
```bash
# Recriar ambiente
make clean-all
make dev
```

### Gateway conecta mas não recebe mensagens

**Verificar tópicos**
```bash
# Simular dispositivo
mosquitto_pub -h localhost -t "autocore/devices/test-device/announce" -m '{
  "device_type": "test",
  "firmware_version": "1.0.0", 
  "capabilities": ["relay"]
}'

# Ver logs
make logs
```

**Verificar formato JSON**
```bash
# Payload deve ser JSON válido
echo '{"test": "message"}' | python -m json.tool
```

### Performance Lenta

**Ajustar buffer de telemetria**
```env
# No .env
TELEMETRY_BATCH_SIZE=50      # Aumentar batch
TELEMETRY_FLUSH_INTERVAL=10  # Aumentar intervalo
```

**Verificar recursos**
```bash
# Monitorar uso
top -p $(cat tmp/gateway.pid)

# Logs de performance
grep "memory_usage" logs/gateway.log
```

## 📊 Monitoramento

### Logs Importantes

```bash
# Inicialização bem sucedida
"🚀 AutoCore Gateway rodando!"

# Dispositivos conectando
"📢 Dispositivo se anunciando: device-uuid"

# Telemetria funcionando  
"📊 Processando telemetria de device-uuid"

# Problemas de conexão
"❌ Erro ao conectar MQTT"
"⚠️ Dispositivo offline: device-uuid"
```

### Métricas

```bash
# No Config App, verificar:
# - Dispositivos Online
# - Mensagens processadas  
# - Última telemetria
# - Status do Gateway
```

### Health Check

```bash
# Status rápido
make status

# Verificação completa
make check

# Logs dos últimos 5 minutos
tail -n 100 logs/gateway.log | grep "$(date '+%H:%M')"
```

## 🔄 Desenvolvimento

### Estrutura do Código

```
src/
├── main.py              # Entry point
├── core/               # Componentes principais
│   ├── config.py       # Configurações
│   ├── mqtt_client.py  # Cliente MQTT
│   ├── message_handler.py # Processamento
│   └── device_manager.py # Dispositivos
└── services/           # Serviços
    └── telemetry_service.py # Telemetria
```

### Modificar Código

```bash
# Editar arquivo
nano src/core/config.py

# Testar mudanças
make start

# Formatar código
make format

# Verificar qualidade
make lint
```

### Debug Avançado

```bash
# Logs mais verbosos
LOG_LEVEL=DEBUG make start

# Python debugger
python -m pdb src/main.py

# Telemetria em tempo real
mosquitto_sub -h localhost -t "autocore/devices/+/telemetry"
```

## 🚀 Próximos Passos

1. **Configurar dispositivos ESP32** para se conectar
2. **Abrir Config App** para interface visual
3. **Configurar telas e relés** via interface
4. **Monitorar telemetria** em tempo real
5. **Configurar automações** (futuro)

## 🆘 Suporte

- **Logs**: `make logs`
- **Documentação**: `docs/`
- **Código**: `src/`
- **Config**: `.env`
- **Issues**: Verificar erros nos logs

---

**🎉 Gateway rodando? Pronto para conectar dispositivos ESP32!**