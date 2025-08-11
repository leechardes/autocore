# 🔌 Implementação MQTT - ESP32 Relay

## ✅ Status: IMPLEMENTADO

### 📋 Funcionalidades Implementadas

#### 1. **Auto-Registro com Backend**
- Registro automático ao conectar WiFi
- POST para `/api/devices/register`
- Recebe credenciais MQTT do backend
- Salva configuração persistente

#### 2. **Cliente MQTT**
- Conexão automática com credenciais
- Reconexão em caso de falha (até 5 tentativas)
- Thread separada (não bloqueia HTTP)
- Publicação de status a cada 30 segundos

#### 3. **Comandos Suportados**
```json
// Ligar relé
{"command": "relay_on", "channel": 0}

// Desligar relé  
{"command": "relay_off", "channel": 0}

// Solicitar status
{"command": "get_status"}

// Reiniciar
{"command": "reboot"}
```

#### 4. **Controle de Relés**
- 16 canais mapeados para GPIOs
- Estados salvos em config.json
- Controle real de pinos GPIO

#### 5. **Telemetria**
```json
{
  "uuid": "esp32_relay_93ce30",
  "status": "online",
  "uptime": 3600,
  "wifi_rssi": -45,
  "free_memory": 45000,
  "relay_states": [0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1]
}
```

### 📡 Tópicos MQTT

- **Status**: `autocore/devices/{device_id}/status`
- **Comandos**: `autocore/devices/{device_id}/command`

### 🛡️ Tratamento de Erros

- MQTT indisponível → Sistema funciona só com HTTP
- Backend offline → Usa config MQTT padrão
- Falha de conexão → Reconexão automática
- Thread falha → Continua servidor HTTP

### 📦 Deploy

```bash
# Upload para ESP32
make deploy

# Monitor serial
make monitor
```

### 🧪 Teste com Mosquitto

```bash
# Subscrever status
mosquitto_sub -h 192.168.1.100 -t "autocore/devices/+/status" -v

# Enviar comando
mosquitto_pub -h 192.168.1.100 \
  -t "autocore/devices/esp32_relay_93ce30/command" \
  -m '{"command":"relay_on","channel":0}'
```

## 🎯 Integração Completa

O ESP32 agora:
1. **Auto-configura** via web
2. **Auto-registra** com backend
3. **Conecta MQTT** automaticamente
4. **Controla relés** remotamente
5. **Envia telemetria** em tempo real

---
**Versão**: 2.0.0  
**Data**: 11/08/2025