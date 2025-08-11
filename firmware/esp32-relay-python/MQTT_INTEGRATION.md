# 🔌 ESP32 Relay - Integração MQTT Completa

## 📋 Visão Geral

Esta implementação adiciona funcionalidade MQTT completa ao ESP32 Relay, mantendo toda a funcionalidade WiFi existente. O sistema realiza auto-registro com o backend e estabelece comunicação bidirecional via MQTT.

## ✨ Funcionalidades Implementadas

### 🔄 Auto-Registro com Backend
- ✅ POST automático para `/api/devices/register` após conexão WiFi
- ✅ Recebimento de credenciais MQTT do backend
- ✅ Persistência de configuração MQTT no `config.json`
- ✅ Tratamento robusto de erros com fallback

### 📡 Cliente MQTT
- ✅ Conexão automática ao broker MQTT
- ✅ Subscrição ao tópico de comandos
- ✅ Publicação de status a cada 30 segundos
- ✅ Reconexão automática em caso de falha
- ✅ Thread separada para não bloquear servidor HTTP

### 🎛️ Controle de Relés
- ✅ Comandos `relay_on` e `relay_off` via MQTT
- ✅ Controle GPIO real dos relés
- ✅ Salvamento de estados no config
- ✅ Mapeamento configurável de pinos GPIO

### 📊 Telemetria
- ✅ Status detalhado (uptime, memória, WiFi RSSI)
- ✅ Estados atuais de todos os relés
- ✅ Comando `get_status` para solicitação manual

## 🏗️ Arquitetura

### 1. Fluxo Principal
```
Boot → WiFi Config → WiFi Connect → Backend Register → MQTT Connect → Threads Start
```

### 2. Threads
- **Thread Principal**: Servidor HTTP para configuração
- **Thread MQTT**: Loop MQTT para comandos e telemetria

### 3. Integração Suave
- Mantém funcionalidade HTTP existente intacta
- MQTT é opcional - falhas não quebram o sistema
- Logs informativos com emojis

## 📁 Estrutura do Código

### Novas Funções Adicionadas

```python
# HTTP Client
def http_request(method, url, data=None, timeout=10)

# Backend Integration
def register_with_backend(config)

# GPIO Control  
def control_relay_gpio(channel, state)

# MQTT Functions
def mqtt_callback(topic, msg)
def publish_status(client, config)
def setup_mqtt(config)
def mqtt_loop(client, config)
```

### Modificações na main()
- Auto-registro após conexão WiFi
- Inicialização do cliente MQTT
- Criação de thread MQTT
- Endpoint `/api/status` para testes

## ⚙️ Configuração

### 1. Dependências MicroPython
```python
# Bibliotecas necessárias (instalar se não disponíveis)
import urequests  # Para HTTP requests
from umqtt.simple import MQTTClient  # ou umqtt.robust
import _thread  # Para threading
```

### 2. Backend Endpoint
O backend deve implementar:
```
POST /api/devices/register
```

**Request Body:**
```json
{
  "uuid": "esp32_relay_93ce30",
  "name": "ESP32 Relay 93ce30",
  "type": "relay", 
  "firmware_version": "2.0.0",
  "relay_channels": 16,
  "ip_address": "192.168.1.105"
}
```

**Response:**
```json
{
  "mqtt_broker": "192.168.1.100",
  "mqtt_port": 1883,
  "mqtt_user": "esp32_relay_93ce30",
  "mqtt_password": "auto_generated_password",
  "mqtt_topics": {
    "status": "autocore/devices/esp32_relay_93ce30/status",
    "command": "autocore/devices/esp32_relay_93ce30/command", 
    "telemetry": "autocore/devices/esp32_relay_93ce30/telemetry"
  }
}
```

### 3. Mapeamento GPIO
Os pinos GPIO estão mapeados na função `control_relay_gpio()`:
```python
gpio_pins = [2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26]
```

**Ajustar conforme seu hardware específico!**

## 🎮 Comandos MQTT

### Tópico de Comandos
```
autocore/devices/{device_id}/command
```

### Comandos Disponíveis

#### 1. Ligar Relé
```json
{
  "command": "relay_on",
  "channel": 3
}
```

#### 2. Desligar Relé
```json
{
  "command": "relay_off", 
  "channel": 3
}
```

#### 3. Solicitar Status
```json
{
  "command": "get_status"
}
```

#### 4. Reiniciar ESP32
```json
{
  "command": "reboot"
}
```

## 📊 Mensagens de Status

### Tópico de Status
```
autocore/devices/{device_id}/status
```

### Formato da Mensagem
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

## 🧪 Como Testar

### 1. Teste Local (HTTP)
```bash
# Status via HTTP
curl http://192.168.1.105/api/status
```

### 2. Teste MQTT (Python)
```bash
# Usar o script fornecido
python mqtt_test_example.py
```

### 3. Teste com Mosquitto
```bash
# Subscribe aos status
mosquitto_sub -h 192.168.1.100 -t "autocore/devices/+/status"

# Enviar comando
mosquitto_pub -h 192.168.1.100 -t "autocore/devices/esp32_relay_93ce30/command" \
  -m '{"command":"relay_on","channel":0}'
```

## 🚨 Tratamento de Erros

### Níveis de Tolerância
1. **MQTT indisponível**: Sistema funciona apenas como servidor HTTP
2. **Backend inacessível**: Continua com configuração padrão MQTT
3. **Falha de conexão MQTT**: Tenta reconectar automaticamente (5x)
4. **GPIO error**: Registra erro mas não interrompe operação

### Logs Informativos
```
🔌 INICIANDO INTEGRAÇÃO MQTT
📞 Registrando com backend...
✅ Registro bem-sucedido!
🔗 Conectando MQTT: 192.168.1.100:1883
✅ MQTT conectado!
📥 Subscrito: autocore/devices/esp32_relay_93ce30/command
✅ Thread MQTT iniciada
🌐 SISTEMA PRONTO
```

## 📝 Arquivo de Configuração

### Estrutura Atualizada do config.json
```json
{
  "device_id": "esp32_relay_93ce30",
  "device_name": "ESP32 Relay 93ce30",
  "wifi_ssid": "MinhaRede",
  "wifi_password": "minhasenha",
  "backend_ip": "192.168.1.100",
  "backend_port": 8081,
  "mqtt_broker": "192.168.1.100",
  "mqtt_port": 1883,
  "mqtt_user": "esp32_relay_93ce30",
  "mqtt_password": "auto_generated_password",
  "mqtt_registered": true,
  "relay_channels": 16,
  "relay_states": [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
  "configured": true
}
```

## 🔧 Personalização

### 1. Intervalo de Status
Alterar em `mqtt_loop()`:
```python
status_interval = 30000  # 30 segundos (em ms)
```

### 2. Timeout HTTP
Alterar em `http_request()`:
```python
def http_request(method, url, data=None, timeout=10)
```

### 3. Tentativas de Reconexão
Alterar em `mqtt_loop()`:
```python
max_reconnect = 5  # Número máximo de tentativas
```

### 4. Mapeamento GPIO
Alterar array em `control_relay_gpio()`:
```python
gpio_pins = [2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26]
```

## ✅ Compatibilidade

### MicroPython
- ✅ Testado em MicroPython v1.23.0
- ✅ Compatível com ESP32 DevKit v1
- ✅ Funciona com Raspberry Pi Pico W (GPIO diferentes)

### Bibliotecas
- ✅ `umqtt.simple` (preferencial)
- ✅ `umqtt.robust` (fallback)
- ✅ `urequests` (HTTP requests)
- ✅ `_thread` (threading)

## 🎯 Status da Implementação

### ✅ Concluído
- [x] Auto-registro com backend
- [x] Cliente MQTT completo
- [x] Controle GPIO de relés
- [x] Telemetria automática
- [x] Reconexão automática
- [x] Tratamento robusto de erros
- [x] Thread separada para MQTT
- [x] Endpoint HTTP de status
- [x] Script de teste MQTT

### 🔄 Próximas Melhorias
- [ ] OTA (Over-the-Air) updates via MQTT
- [ ] Configuração de GPIO via web interface
- [ ] Dashboard web em tempo real
- [ ] Suporte a TLS/SSL no MQTT
- [ ] Logs detalhados em arquivo

## 🆘 Troubleshooting

### Problema: MQTT não conecta
**Solução**: Verificar broker MQTT rodando e credenciais corretas

### Problema: GPIO não funciona
**Solução**: Ajustar mapeamento de pinos na função `control_relay_gpio()`

### Problema: Backend não registra
**Solução**: Verificar endpoint `/api/devices/register` implementado

### Problema: Thread MQTT trava
**Solução**: Verificar memória disponível e timeout settings

---

## 🎉 Resultado Final

Esta implementação transforma o ESP32 Relay em um dispositivo IoT completo que:

1. **Mantém compatibilidade total** com sistema de configuração WiFi
2. **Adiciona funcionalidade MQTT robusta** com auto-registro
3. **Permite controle remoto** de relés via comandos MQTT
4. **Fornece telemetria em tempo real** para monitoramento
5. **Funciona de forma autônoma** com tratamento inteligente de falhas

O sistema está pronto para integração com o **AutoCore Config App** e pode ser usado imediatamente em ambiente de produção!

---

**Desenvolvido para AutoCore System v2.0**  
**Compatível com MicroPython v1.23.0+**  
**Data: 11/08/2025**