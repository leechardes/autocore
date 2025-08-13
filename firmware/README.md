# 🔧 Firmware ESP32 - AutoCore System

## 📋 Visão Geral

Esta pasta contém todos os firmwares dos dispositivos ESP32 que compõem o sistema AutoCore, organizados por tecnologia/framework.

## 📂 Estrutura Organizacional

```
firmware/
├── esp-idf/          # Projetos usando ESP-IDF (alta performance)
│   └── esp32-relay   # Controlador de relés principal
├── platformio/       # Projetos usando PlatformIO
│   └── esp32-display # Interface touchscreen
├── arduino/          # Projetos usando Arduino framework
│   └── (vazio)       # Projetos migrados para outras tecnologias
└── planning/         # Documentação e planejamento
    ├── esp32-can     # Interface CAN Bus (futuro)
    └── esp32-controls # Controles físicos (futuro)
```

## 🚀 Projetos Ativos

### ⚡ esp32-relay (ESP-IDF)
**Controlador de relés automotivos de alta performance**
- **Status:** ✅ **Produção** - v2.2.0
- **Localização:** `esp-idf/esp32-relay/`
- **Framework:** ESP-IDF v5.0
- **Hardware:** ESP32 + 16/32 relés
- **Features:** 
  - MQTT v2.2.0 com protocol_version
  - Sistema de heartbeat para relés momentâneos
  - Registro HTTP inteligente com backend
  - Boot time < 1 segundo
  - Latência MQTT < 50ms

### 📺 esp32-display (PlatformIO)
**Interface de display touchscreen para controle e visualização**
- **Status:** 🚧 **Desenvolvimento**
- **Localização:** `platformio/esp32-display/`
- **Framework:** PlatformIO (Arduino core)
- **Hardware:** ESP32 + ILI9341/ST7789 + XPT2046
- **Features:**
  - Hot reload para desenvolvimento rápido
  - MQTT integration
  - Interface touch responsiva
  - Múltiplas telas configuráveis

## 📋 Projetos em Planejamento

### 📡 esp32-can
**Interface com barramento CAN Bus (FuelTech)**
- **Status:** 📋 **Planejamento**
- **Localização:** `planning/esp32-can/`
- **Framework:** ESP-IDF (previsto)
- **Hardware:** ESP32 + MCP2515/TJA1050
- **Features planejadas:**
  - Leitura de sinais da ECU
  - Tradução de protocolos CAN
  - Telemetria via MQTT
  - Suporte a múltiplos baudrates

### 🎛️ esp32-controls
**Interface com controles físicos**
- **Status:** 📋 **Planejamento**
- **Localização:** `planning/esp32-controls/`
- **Framework:** PlatformIO (previsto)
- **Hardware:** ESP32 + Botões + Encoders + LEDs
- **Features planejadas:**
  - Leitura de botões e encoders
  - Detecção de gestos
  - Feedback háptico
  - LED indicators

## 🛠️ Desenvolvimento por Framework

### ESP-IDF Projects
```bash
# Ativar ambiente ESP-IDF
source /path/to/esp-idf/export.sh

# Compilar e gravar
cd esp-idf/esp32-relay
make build flash monitor
```

### PlatformIO Projects
```bash
# Instalar PlatformIO
pip install platformio

# Compilar e gravar
cd platformio/esp32-display
pio run -t upload
pio device monitor
```

### Arduino Projects
```bash
# Usar Arduino IDE ou CLI
arduino-cli compile --fqbn esp32:esp32:esp32
arduino-cli upload -p /dev/ttyUSB0
```

## 📡 Protocolo MQTT AutoCore v2.2.0

Todos os firmwares seguem o protocolo MQTT v2.2.0:

```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-relay-001",
  "timestamp": "2025-08-13T10:30:00Z",
  "message_type": "status",
  "data": {}
}
```

### Tópicos Padrão
```
autocore/devices/{uuid}/status     # Status do dispositivo
autocore/devices/{uuid}/announce   # Descoberta
autocore/devices/{uuid}/telemetry  # Dados de telemetria
autocore/devices/{uuid}/commands   # Comandos
autocore/devices/{uuid}/relays/set # Comandos de relé específicos
```

## 🔄 Migração de Projetos

### Processo de Evolução
1. **planning/** → Especificação e documentação
2. **arduino/** → Prototipagem rápida (se necessário)
3. **platformio/** → Desenvolvimento com bibliotecas
4. **esp-idf/** → Produção com máxima performance

### Histórico de Migrações
- `esp32-relay`: Arduino → ESP-IDF (performance crítica)
- `esp32-display`: Arduino → PlatformIO (bibliotecas gráficas)

## 📊 Comparação de Frameworks

| Aspecto | ESP-IDF | PlatformIO | Arduino |
|---------|---------|------------|---------|
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Controle Hardware** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Facilidade** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Bibliotecas** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Profissional** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |

## 🔐 Segurança

### Práticas Implementadas
- ✅ Heartbeat obrigatório para relés momentâneos
- ✅ Validação de protocol_version em mensagens MQTT
- ✅ Timeouts em todas operações de rede
- ✅ Rate limiting em comandos
- ✅ Watchdog timer habilitado

### Em Desenvolvimento
- 🚧 TLS/SSL para MQTT
- 🚧 Autenticação mútua
- 🚧 Criptografia de payloads sensíveis

## 📝 Versionamento

Formato: `MAJOR.MINOR.PATCH`
- **MAJOR:** Mudanças incompatíveis de protocolo
- **MINOR:** Novas funcionalidades
- **PATCH:** Correções de bugs

Exemplo: `2.2.0` = Protocolo v2, Feature set 2, sem patches

## 🧪 Testes

### Teste de Integração
```bash
# Verificar MQTT
mosquitto_sub -h localhost -t "autocore/devices/+/status" -v

# Enviar comando de teste
mosquitto_pub -h localhost -t "autocore/devices/esp32-relay-001/relays/set" \
  -m '{"protocol_version":"2.2.0","channel":1,"state":true}'
```

## 📚 Documentação

Cada projeto contém:
- `README.md` - Documentação específica
- `CLAUDE.md` - Instruções para assistente AI
- Esquemáticos e diagramas de hardware
- Guias de configuração

## 🆘 Suporte

Para problemas ou dúvidas:
1. Consulte a documentação específica do projeto
2. Verifique os logs via serial ou MQTT
3. Abra uma issue no GitHub
4. Entre em contato com a equipe de desenvolvimento

---

**Última Atualização:** 13 de Agosto de 2025  
**Versão da Documentação:** 2.0.0  
**Mantenedor:** Lee Chardes