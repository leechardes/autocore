# 🔧 Firmware ESP32 - AutoCore System

## 📋 Visão Geral

Esta pasta contém todos os firmwares dos dispositivos ESP32 que compõem o sistema AutoCore. Cada firmware é responsável por uma função específica no controle veicular.

## 🎯 Dispositivos

### 📡 esp32-can
**Função:** Interface com barramento CAN Bus (FuelTech)
- Leitura de sinais da ECU
- Tradução de protocolos CAN
- Envio de telemetria via MQTT
- Suporte a múltiplos baudrates (250k, 500k, 1M)

### 🎮 esp32-controls
**Função:** Interface com controles do volante
- Leitura de botões e encoders
- Detecção de gestos
- Feedback háptico
- Comunicação com display principal

### 📺 esp32-display
**Função:** Display touch principal (ILI9341 2.8")
- Interface gráfica LVGL
- Touch screen resistivo/capacitivo
- Múltiplas telas configuráveis
- Indicadores visuais em tempo real

### ⚡ esp32-relay
**Função:** Controle de relés (16 canais)
- Acionamento de cargas
- Proteções configuráveis
- Estados persistentes
- Feedback de status

## 🛠️ Ambiente de Desenvolvimento

### Pré-requisitos
```bash
# PlatformIO (recomendado)
pip install platformio

# OU Arduino IDE 2.0+
# Com as seguintes bibliotecas:
# - ESP32 Board Package
# - PubSubClient (MQTT)
# - ArduinoJson
# - LVGL (para display)
# - MCP2515 (para CAN)
```

### Estrutura Comum
```
esp32-{dispositivo}/
├── src/
│   └── main.cpp           # Código principal
├── include/
│   ├── config.h           # Configurações
│   └── pins.h             # Mapeamento de pinos
├── lib/                   # Bibliotecas customizadas
├── platformio.ini         # Configuração PlatformIO
└── README.md             # Documentação específica
```

## 📍 Pinout Padrão

### Pinos Comuns (Todos os Dispositivos)
| Pino | Função | Descrição |
|------|--------|-----------|
| GPIO 2 | LED Status | LED onboard de status |
| GPIO 21 | I2C SDA | Comunicação I2C |
| GPIO 22 | I2C SCL | Clock I2C |
| GPIO 1 | TX | Serial debug |
| GPIO 3 | RX | Serial debug |

### ESP32-CAN Específico
| Pino | Função | Descrição |
|------|--------|-----------|
| GPIO 5 | CAN CS | Chip Select MCP2515 |
| GPIO 18 | SPI SCK | Clock SPI |
| GPIO 19 | SPI MISO | Master In Slave Out |
| GPIO 23 | SPI MOSI | Master Out Slave In |
| GPIO 15 | CAN INT | Interrupt do MCP2515 |

### ESP32-Display Específico
| Pino | Função | Descrição |
|------|--------|-----------|
| GPIO 15 | TFT CS | Display Chip Select |
| GPIO 4 | TFT RST | Display Reset |
| GPIO 2 | TFT DC | Display Data/Command |
| GPIO 18 | TFT CLK | Display Clock |
| GPIO 23 | TFT MOSI | Display Data |
| GPIO 19 | TFT MISO | Touch Data |
| GPIO 25 | TFT LED | Backlight Control |

### ESP32-Relay Específico
| Pino | Função | Descrição |
|------|--------|-----------|
| GPIO 13-28 | RELAY 1-16 | Saídas de relé |
| GPIO 34-39 | SENSE 1-6 | Entradas de sensoriamento |

### ESP32-Controls Específico
| Pino | Função | Descrição |
|------|--------|-----------|
| GPIO 32-35 | BTN 1-4 | Botões principais |
| GPIO 25-26 | ENC A/B | Encoder rotativo |
| GPIO 27 | ENC BTN | Botão do encoder |
| GPIO 14 | BUZZER | Feedback sonoro |

## 🔨 Compilação e Upload

### Usando PlatformIO
```bash
# Compilar firmware específico
cd firmware/esp32-{dispositivo}
pio run

# Upload via USB
pio run --target upload

# Upload via OTA
pio run --target upload --upload-port [IP_DO_DISPOSITIVO]

# Monitor serial
pio device monitor
```

### Usando Arduino IDE
1. Abra o arquivo `src/main.cpp`
2. Selecione a placa: `ESP32 Dev Module`
3. Configure:
   - Flash Size: 4MB
   - Partition: Default 4MB with OTA
   - Upload Speed: 921600
4. Compile e faça upload

## 📡 Configuração de Rede

### WiFi (config.h)
```cpp
#define WIFI_SSID "AutoCore_AP"
#define WIFI_PASSWORD "autocore123"
#define DEVICE_NAME "ESP32_RELAY_01"
```

### MQTT
```cpp
#define MQTT_SERVER "192.168.4.1"
#define MQTT_PORT 1883
#define MQTT_USER "autocore"
#define MQTT_PASSWORD "autocore"
#define MQTT_CLIENT_ID DEVICE_NAME
```

### Tópicos MQTT Padrão
```
autocore/devices/{device_id}/status    # Status do dispositivo
autocore/devices/{device_id}/command   # Comandos para o dispositivo
autocore/devices/{device_id}/telemetry # Dados de telemetria
autocore/devices/{device_id}/config    # Configuração remota
```

## 🔄 OTA Updates

### Habilitando OTA
1. Certifique-se que a partição suporta OTA (4MB com OTA)
2. Configure credenciais em `config.h`:
```cpp
#define OTA_PASSWORD "autocore_ota"
#define OTA_PORT 3232
```

### Processo de Atualização
```bash
# Via PlatformIO
pio run --target upload --upload-port 192.168.1.100

# Via script Python
python ota_update.py --ip 192.168.1.100 --file firmware.bin
```

## 🐛 Debug e Troubleshooting

### Monitor Serial
```bash
# PlatformIO
pio device monitor -b 115200

# Arduino IDE
Tools > Serial Monitor (115200 baud)
```

### Comandos de Debug via MQTT
```bash
# Status do dispositivo
mosquitto_pub -t "autocore/devices/esp32_relay/command" -m '{"cmd":"status"}'

# Reset do dispositivo
mosquitto_pub -t "autocore/devices/esp32_relay/command" -m '{"cmd":"reset"}'

# Informações de rede
mosquitto_pub -t "autocore/devices/esp32_relay/command" -m '{"cmd":"netinfo"}'
```

### LEDs de Status
- **Piscando rápido (100ms):** Iniciando/Conectando WiFi
- **Piscando devagar (1s):** Conectado WiFi, conectando MQTT
- **Ligado fixo:** Operacional
- **Piscando 3x:** Erro de conexão
- **Piscando 5x:** Erro crítico

## 📊 Protocolo de Comunicação

### Formato de Mensagens (JSON)
```json
// Status
{
  "device_id": "esp32_relay_01",
  "type": "relay",
  "status": "online",
  "uptime": 3600,
  "free_heap": 150000,
  "wifi_rssi": -65,
  "version": "1.0.0"
}

// Comando
{
  "cmd": "relay",
  "channel": 5,
  "state": "on",
  "duration": 1000  // opcional, em ms
}

// Telemetria
{
  "timestamp": 1691419200,
  "channels": [
    {"id": 1, "state": true, "current": 0.5},
    {"id": 2, "state": false, "current": 0.0}
  ]
}
```

## 🔐 Segurança

### Boas Práticas
1. **Sempre use senhas fortes** para WiFi e MQTT
2. **Habilite TLS/SSL** em produção
3. **Implemente rate limiting** para comandos
4. **Valide todos os inputs** recebidos
5. **Use autenticação mútua** quando possível

### Configuração Segura
```cpp
// config_secure.h
#define USE_SSL true
#define MQTT_PORT_SSL 8883
#define VERIFY_CERTIFICATE true
#define CA_CERT "-----BEGIN CERTIFICATE-----..."
```

## 📝 Versionamento

### Formato
`MAJOR.MINOR.PATCH-BUILD`
- **MAJOR:** Mudanças incompatíveis
- **MINOR:** Novas funcionalidades
- **PATCH:** Correções de bugs
- **BUILD:** Número de build automático

### Exemplo
```cpp
#define FIRMWARE_VERSION "1.2.3-456"
```

## 🧪 Testes

### Teste Básico de Conectividade
```bash
# Ping
ping [IP_DO_DISPOSITIVO]

# Teste MQTT
mosquitto_sub -t "autocore/devices/+/status" -v
```

### Teste de Carga
```python
# test_load.py
import paho.mqtt.client as mqtt
import json
import time

def test_relay_speed():
    client = mqtt.Client()
    client.connect("192.168.1.1", 1883)
    
    for i in range(100):
        payload = json.dumps({
            "cmd": "relay",
            "channel": (i % 16) + 1,
            "state": "toggle"
        })
        client.publish("autocore/devices/esp32_relay/command", payload)
        time.sleep(0.1)
```

## 🚀 Deploy em Produção

### Checklist
- [ ] Remover mensagens de debug
- [ ] Habilitar watchdog timer
- [ ] Configurar brown-out detection
- [ ] Implementar fallback para falhas
- [ ] Testar OTA update
- [ ] Validar certificados SSL
- [ ] Documentar versão

### Script de Deploy
```bash
#!/bin/bash
# deploy_all.sh

DEVICES=("192.168.1.100" "192.168.1.101" "192.168.1.102" "192.168.1.103")

for device in "${DEVICES[@]}"; do
    echo "Deploying to $device..."
    pio run --target upload --upload-port $device
    sleep 5
done
```

## 📚 Recursos Adicionais

### Documentação
- [ESP32 Reference](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/)
- [PlatformIO Docs](https://docs.platformio.org/)
- [MQTT Protocol](https://mqtt.org/mqtt-specification/)
- [LVGL Graphics](https://lvgl.io/)

### Bibliotecas Úteis
- [AsyncMQTTClient](https://github.com/marvinroger/async-mqtt-client)
- [ESP32 OTA](https://github.com/espressif/arduino-esp32/tree/master/libraries/Update)
- [TFT_eSPI](https://github.com/Bodmer/TFT_eSPI)
- [ESP32Encoder](https://github.com/madhephaestus/ESP32Encoder)

## 🆘 Suporte

Para dúvidas ou problemas:
1. Verifique a documentação específica de cada firmware
2. Consulte os logs via serial ou MQTT
3. Abra uma issue no repositório
4. Contate: suporte@autocore.com

---

**Última Atualização:** 07 de agosto de 2025  
**Versão da Documentação:** 1.0.0  
**Mantenedor:** Lee Chardes