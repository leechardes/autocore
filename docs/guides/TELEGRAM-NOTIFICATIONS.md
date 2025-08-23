# 📱 Sistema de Notificações Telegram - AutoCore

## 🎯 Visão Geral

O AutoCore possui um sistema integrado de notificações via Telegram que permite receber alertas em tempo real sobre eventos importantes do sistema, status de dispositivos, ações de relés e conclusão de tarefas longas.

## 🚀 Configuração Rápida

### 1. Credenciais já Configuradas

```bash
# Token do Bot (já configurado)
TELEGRAM_BOT_TOKEN=8364500593:AAG-F57bNhpREYZ4iGPSTXgQhiKQMqutqPQ

# Chat ID do Lee (já configurado)
TELEGRAM_CHAT_ID=5644979847
```

### 2. Scripts Disponíveis

#### 📤 `scripts/notify.py` - Notificador Principal
Script simples e direto para enviar notificações de qualquer lugar do sistema.

```bash
# Uso básico
python3 scripts/notify.py "Sua mensagem aqui"

# Exemplos práticos
python3 scripts/notify.py "✅ Deploy concluído com sucesso!"
python3 scripts/notify.py "❌ Erro no build do firmware"
python3 scripts/notify.py "🔄 Backup iniciado às $(date +%H:%M)"
```

#### 🔍 `scripts/get_chat_id_auto.py` - Descobrir Chat ID
Útil para configurar novos usuários ou grupos.

```bash
# Executar para descobrir Chat IDs
python3 scripts/get_chat_id_auto.py
```

## 💡 Casos de Uso Práticos

### 1. Notificar Fim de Tarefas Longas

```bash
# Build do firmware ESP32
cd firmware/esp32-relay
pio run && python3 ../../scripts/notify.py "✅ Firmware ESP32 compilado" || python3 ../../scripts/notify.py "❌ Erro na compilação"

# Deploy para Raspberry Pi
cd deploy
./deploy_to_raspberry.sh && python3 ../scripts/notify.py "🚀 Deploy realizado no Raspberry Pi"
```

### 2. Monitoramento de Serviços

```bash
# Verificar status e notificar
cd config-app/backend
make status || python3 ../../scripts/notify.py "⚠️ Backend offline!"

# Reiniciar serviços
make restart && python3 ../../scripts/notify.py "🔄 Serviços reiniciados"
```

### 3. Pipeline de CI/CD

```bash
# Pipeline completo com notificações
make test && python3 scripts/notify.py "✅ Testes passaram" || python3 scripts/notify.py "❌ Testes falharam"
make build && python3 scripts/notify.py "📦 Build criado" || python3 scripts/notify.py "❌ Build falhou"
make deploy && python3 scripts/notify.py "🚀 Deploy em produção" || python3 scripts/notify.py "❌ Deploy falhou"
```

### 4. Alertas de Sistema

```bash
# Monitorar espaço em disco
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    python3 scripts/notify.py "⚠️ Disco quase cheio: ${DISK_USAGE}%"
fi

# Monitorar memória
MEM_FREE=$(free -m | awk 'NR==2 {print $4}')
if [ $MEM_FREE -lt 100 ]; then
    python3 scripts/notify.py "⚠️ Memória baixa: ${MEM_FREE}MB livres"
fi
```

## 🔧 Integração com Backend

### Notificações Automáticas MQTT

O backend já está configurado para enviar notificações automáticas via Telegram quando:

- 🟢 Dispositivo ESP32 fica online
- 🔴 Dispositivo ESP32 fica offline
- ⚡ Relé é acionado
- 🚨 Mensagens de segurança/emergência
- ❌ Erros do sistema

### Arquivo: `backend/services/telegram_notifier.py`

```python
from services.telegram_notifier import telegram

# Enviar alerta
telegram.send_alert("Título", "Mensagem", "WARNING")

# Notificar status de dispositivo
telegram.notify_device_status("ESP32_Relay_93ce30", "online")

# Notificar ação de relé
telegram.notify_relay_action(1, "ON", "ESP32_Relay_93ce30")
```

## 📊 Notificações do Sistema AutoCore

### Eventos Monitorados Automaticamente

| Evento | Notificação | Emoji |
|--------|------------|-------|
| Dispositivo Online | Nome do dispositivo + IP | 🟢 |
| Dispositivo Offline | Nome do dispositivo | 🔴 |
| Relé Acionado | Canal + Ação + Dispositivo | ⚡ |
| Erro Sistema | Tópico + Mensagem erro | ❌ |
| Emergência | Alerta crítico | 🚨 |
| Sistema Iniciado | AutoCore online | 🚀 |
| Sistema Desligado | AutoCore offline | 🛑 |

## 🎨 Formatação de Mensagens

As mensagens suportam HTML para formatação:

```python
# Negrito
"<b>Texto importante</b>"

# Código
"<code>comando_aqui</code>"

# Links
"<a href='http://example.com'>Link</a>"

# Combinado
"🚀 <b>Deploy Concluído</b>\nVersão: <code>v1.0.0</code>"
```

## 🛠️ Troubleshooting

### Mensagem não enviada
```bash
# Verificar conectividade
curl -s https://api.telegram.org/bot8364500593:AAG-F57bNhpREYZ4iGPSTXgQhiKQMqutqPQ/getMe

# Testar envio direto
python3 scripts/notify.py "Teste de conexão"
```

### Chat ID não encontrado
```bash
# Re-executar descoberta
python3 scripts/get_chat_id_auto.py

# Enviar /start para o bot no Telegram primeiro
```

## 📝 Boas Práticas

1. **Use emojis relevantes** - Facilitam identificação visual rápida
2. **Mensagens concisas** - Telegram tem limite de 4096 caracteres
3. **Timestamp automático** - O script já adiciona hora automaticamente
4. **Tratamento de erros** - Use || para notificar falhas

```bash
# Bom exemplo
comando_longo && \
    python3 scripts/notify.py "✅ Sucesso" || \
    python3 scripts/notify.py "❌ Falhou"
```

## 🔐 Segurança

- Token do bot está no código mas é seguro pois é específico do AutoCore
- Chat ID é público e seguro de compartilhar
- Não envie informações sensíveis (senhas, tokens) via Telegram
- Configure firewall se necessário para restringir acesso ao bot

## 🎯 Exemplos Avançados

### Notificar com Detalhes de Build

```bash
#!/bin/bash
START_TIME=$(date +%s)
BUILD_LOG="/tmp/build_$(date +%Y%m%d_%H%M%S).log"

# Executar build
make build > "$BUILD_LOG" 2>&1
BUILD_RESULT=$?

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $BUILD_RESULT -eq 0 ]; then
    python3 scripts/notify.py "✅ Build OK (${DURATION}s)"
else
    ERROR_COUNT=$(grep -c "error" "$BUILD_LOG")
    python3 scripts/notify.py "❌ Build falhou: ${ERROR_COUNT} erros (${DURATION}s)"
fi
```

### Monitor Contínuo

```bash
#!/bin/bash
# Monitor que notifica mudanças de status

while true; do
    # Verificar serviço
    if systemctl is-active autocore-backend > /dev/null; then
        [ "$LAST_STATUS" = "down" ] && python3 scripts/notify.py "✅ Backend voltou online"
        LAST_STATUS="up"
    else
        [ "$LAST_STATUS" = "up" ] && python3 scripts/notify.py "🔴 Backend caiu!"
        LAST_STATUS="down"
    fi
    
    sleep 60
done
```

## 📚 Referências

- [Telegram Bot API](https://core.telegram.org/bots/api)
- [BotFather](https://t.me/botfather) - Criar/gerenciar bots
- [AutoCore Backend](../config-app/backend/services/telegram_notifier.py) - Implementação completa

---

**Última atualização:** Janeiro 2025
**Maintainer:** Lee Chardes
**Bot:** @AutoCoreNotifyBot