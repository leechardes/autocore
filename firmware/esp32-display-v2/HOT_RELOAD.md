# 🔄 Hot Reload - Atualização Dinâmica de Configuração

O AutoTech HMI Display v2 suporta **hot reload**, permitindo atualizar a configuração e interface sem reiniciar o dispositivo.

## 🌟 Características

- ✅ Atualização em tempo real via MQTT
- ✅ Sem necessidade de reiniciar
- ✅ Feedback visual (LED verde pisca)
- ✅ Mantém estado atual da navegação
- ✅ Confirmação de recebimento (ACK)
- ✅ Suporte a atualizações direcionadas

## 📡 Como Funciona

### 1. Tópicos MQTT

- **Receber atualizações**: `autocore/config/update`
- **Enviar confirmação**: `autocore/config/update/ack`
- **Config específica**: `autocore/{device_id}/config`

### 2. Formato das Mensagens

#### Atualização Completa
```json
{
  "target": "all",  // ou "hmi_display_1" para específico
  "config": {
    "device_type": "hmi_display",
    "version": "2.0.1",
    "screens": [...],
    "theme": {...}
  },
  "timestamp": 1234567890
}
```

#### Comando de Reload
```json
{
  "target": "all",
  "command": "reload",
  "timestamp": 1234567890
}
```

## 🚀 Usando o Script de Teste

### Instalação
```bash
# Instalar dependências
pip install paho-mqtt

# Executar script
python test_hot_reload.py
```

### Opções do Menu

1. **Atualização Completa** - Envia nova configuração para todos
2. **Atualização Específica** - Atualiza apenas um dispositivo
3. **Comando Reload** - Força recarga da configuração
4. **Atualizar Título** - Exemplo simples de atualização
5. **Adicionar Tela** - Adiciona nova tela dinamicamente
6. **Mudar Tema** - Altera cores do tema

## 📋 Exemplos de Uso

### Via MQTT Client (mosquitto)

```bash
# Enviar atualização para todos os dispositivos
mosquitto_pub -h 10.0.10.100 -t "autocore/config/update" -m '{
  "target": "all",
  "config": {
    "device_type": "hmi_display",
    "version": "2.0.5",
    "screens": [{
      "id": "home",
      "title": "Nova Config",
      "items": []
    }]
  }
}'

# Forçar reload
mosquitto_pub -h 10.0.10.100 -t "autocore/config/update" -m '{
  "target": "hmi_display_1",
  "command": "reload"
}'
```

### Via Node-RED

```javascript
// Function node
msg.payload = {
    target: "all",
    config: {
        device_type: "hmi_display",
        version: "2.0.6",
        screens: [
            {
                id: "home",
                title: "Atualizado via Node-RED",
                items: []
            }
        ]
    }
};
msg.topic = "autocore/config/update";
return msg;
```

### Via Python

```python
import paho.mqtt.client as mqtt
import json

client = mqtt.Client()
client.connect("10.0.10.100", 1883)

# Preparar configuração
config_update = {
    "target": "all",
    "config": {
        "device_type": "hmi_display",
        "version": "2.0.7",
        "screens": [...]
    }
}

# Enviar
client.publish(
    "autocore/config/update", 
    json.dumps(config_update)
)
```

## 🎯 Casos de Uso

### 1. Desenvolvimento Rápido
- Altere a interface sem recompilar
- Teste diferentes layouts rapidamente
- Debug visual em tempo real

### 2. Manutenção Remota
- Atualize múltiplos displays simultaneamente
- Corrija problemas sem acesso físico
- Role updates graduais

### 3. Personalização Dinâmica
- Interfaces diferentes por turno/usuário
- Temas sazonais ou por evento
- A/B testing de interfaces

### 4. Monitoramento
- Adicione/remova indicadores conforme necessário
- Ajuste alarmes e limites
- Reorganize informações por prioridade

## ⚙️ Configuração no Código

### Habilitar Hot Reload (já configurado)

```cpp
// Em main.cpp
configReceiver->enableHotReload([]() {
    logger->info("Hot reload triggered!");
    
    // Reconstrói UI
    screenManager->buildFromConfig(configManager->getConfig());
    
    // Feedback visual
    digitalWrite(LED_G_PIN, LOW);
    delay(100);
    digitalWrite(LED_G_PIN, HIGH);
});
```

### Customizar Comportamento

```cpp
// Adicionar validação extra
configReceiver->enableHotReload([]() {
    if (validateNewConfig()) {
        applyConfig();
    } else {
        rejectConfig();
    }
});
```

## 🔍 Debug e Troubleshooting

### Verificar Recebimento

1. **Serial Monitor** (DEBUG_LEVEL 3)
```
[INFO] ConfigReceiver: Hot reload update received
[INFO] Configuration updated successfully via hot reload!
[INFO] Hot reload triggered! Rebuilding UI...
```

2. **MQTT Monitor**
```bash
# Monitorar ACKs
mosquitto_sub -h 10.0.10.100 -t "autocore/config/update/ack" -v
```

### Problemas Comuns

| Problema | Solução |
|----------|---------|
| Não recebe updates | Verificar conexão MQTT e tópicos |
| UI não atualiza | Verificar estrutura JSON da config |
| LED não pisca | Verificar pinos no DeviceConfig.h |
| Tela fica em branco | Config inválida - verificar logs |

## 🛡️ Segurança

### Boas Práticas

1. **Validar origem** das mensagens
2. **Limitar frequência** de updates
3. **Verificar versão** antes de aplicar
4. **Backup** da última config válida
5. **Timeout** para updates muito grandes

### Exemplo de Validação

```cpp
if (configManager->isNewerVersion(newVersion)) {
    // Aplicar apenas se for versão mais nova
}
```

## 📊 Métricas

O dispositivo reporta via MQTT:
- Confirmação de recebimento (ACK)
- Versão aplicada
- Tempo de aplicação
- Erros de validação

## 🎨 Exemplos Avançados

### Tela com Dados Dinâmicos
```json
{
  "screens": [{
    "id": "monitoring",
    "title": "Monitoramento",
    "items": [
      {
        "type": "gauge",
        "label": "CPU",
        "min": 0,
        "max": 100,
        "value": 45
      },
      {
        "type": "list",
        "label": "Alertas",
        "options": [
          "Sistema OK",
          "Temperatura: 65°C",
          "Memória: 78%"
        ]
      }
    ]
  }]
}
```

### Multi-idioma
```json
{
  "screens": [{
    "id": "home",
    "title": {
      "pt-BR": "Início",
      "en-US": "Home",
      "es-ES": "Inicio"
    }
  }]
}
```

## 💡 Dicas

1. **Teste primeiro** no simulador/gateway
2. **Versionamento** sempre incremental
3. **Mudanças graduais** em produção
4. **Monitorar ACKs** para confirmar aplicação
5. **Documentar** mudanças importantes

---

**Hot Reload** torna o desenvolvimento e manutenção muito mais ágeis! 🚀