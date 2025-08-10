# 🚗 AutoCore ESP32 Display Firmware

Firmware completo para displays touch do sistema AutoCore - Interface gráfica avançada com LVGL para controle e monitoramento de sistemas veiculares.

## 📋 Visão Geral

O **AutoCore ESP32 Display** é um firmware profissional desenvolvido para criar interfaces touch modernas em sistemas veiculares embarcados. Utiliza LVGL para renderização gráfica e oferece configuração dinâmica via MQTT.

### 🎯 Características Principais

- **🖥️ Display Touch 320x240** - Interface LVGL otimizada para displays ILI9341/ST7789
- **🌐 Configuração Web Moderna** - Interface shadcn/ui-inspired para configuração inicial
- **📡 Comunicação MQTT** - Integração completa com ecossistema AutoCore
- **⚡ Renderização Dinâmica** - Botões e telas configurados pelo backend
- **🔒 Sistema de Segurança** - Watchdog, heartbeat e proteções avançadas
- **📱 Interface Responsiva** - Navigation bar touch + botões físicos opcionais

## 🛠️ Hardware Suportado

### Display Touch
- **Controlador**: ILI9341, ST7789 ou compatível
- **Resolução**: 320x240 pixels
- **Interface**: SPI (até 40MHz)
- **Touch**: XPT2046, FT6236 ou compatível

### ESP32
- **MCU**: ESP32-WROOM-32D ou superior
- **Flash**: Mínimo 4MB
- **RAM**: 520KB (PSRAM recomendado)
- **CPU**: 240MHz dual-core

### Conexões Recomendadas

```
Display SPI:
  TFT_CS   = GPIO 15
  TFT_DC   = GPIO 2
  TFT_RST  = GPIO 4
  TFT_MOSI = GPIO 23
  TFT_CLK  = GPIO 18
  TFT_MISO = GPIO 19

Touch SPI:
  TOUCH_CS  = GPIO 5
  TOUCH_IRQ = GPIO 27

Botões (Opcional):
  BTN_PREV   = GPIO 32
  BTN_SELECT = GPIO 33
  BTN_NEXT   = GPIO 25
  
Sistema:
  EMERGENCY_STOP = GPIO 0
```

## 🚀 Instalação e Configuração

### 1. Ambiente de Desenvolvimento

```bash
# Instalar PlatformIO
pip install platformio

# Clonar o projeto
git clone https://github.com/leechardes/autocore
cd autocore/firmware/esp32-display

# Compilar o projeto
pio build

# Upload do firmware
pio run --target upload

# Upload dos arquivos web (SPIFFS)
pio run --target uploadfs

# Monitor serial
pio device monitor
```

### 2. Configuração Inicial

#### Modo Access Point (Primeira Inicialização)

Quando não configurado, o ESP32 criará um Access Point:

- **SSID**: `ESP32_Display_XXXX` (baseado no MAC)
- **IP**: `192.168.4.1`
- **Senha**: `autocore123`

#### Interface Web de Configuração

Acesse `http://192.168.4.1` e configure:

1. **📱 Básico**
   - Nome do dispositivo
   - UUID (gerado automaticamente)

2. **🌐 Rede**
   - SSID da rede WiFi
   - Senha da rede
   - Scan automático de redes disponíveis

3. **🔗 Backend**
   - IP do servidor AutoCore
   - Porta (padrão: 8000)
   - Chave de API (opcional)

4. **⚙️ Avançado**
   - Timeout da tela
   - Brilho do display
   - Modo debug
   - Servidor NTP

### 3. Integração com Backend

O display busca sua configuração completa do backend AutoCore:

```
GET http://{backend_ip}:{port}/api/config/generate/{display_uuid}
```

**Resposta Esperada:**
```json
{
  "device": {
    "uuid": "display-touch-001",
    "name": "Display Principal",
    "type": "display_touch"
  },
  "mqtt": {
    "broker": "localhost",
    "port": 1883,
    "username": "autocore",
    "password": "mqtt_password"
  },
  "screens": [
    {
      "id": "dashboard",
      "title": "Principal",
      "layout": {
        "type": "grid",
        "cols": 3,
        "rows": 2,
        "spacing": 4
      },
      "buttons": [
        {
          "id": "btn_headlight",
          "label": "Farol",
          "icon": "💡",
          "type": "toggle",
          "position": {"col": 0, "row": 0},
          "action": {
            "type": "relay",
            "channel": 1
          }
        }
      ]
    }
  ],
  "theme": {
    "colors": {
      "primary": "#007AFF",
      "secondary": "#32D74B",
      "warning": "#FF9500",
      "danger": "#FF3B30"
    }
  }
}
```

## 🎨 Sistema de Interface

### Arquitetura LVGL

```
Display Layout (320x240px)
├── Status Bar (320x20px)    - WiFi, MQTT, Nome, Bateria, Relógio
├── Content Area (320x180px) - Botões dinâmicos configurados
└── Navigation Bar (320x40px) - [◀ Prev] [🏠 Home] [▶ Next]
```

### Tipos de Botões Suportados

#### 1. Toggle Button
```json
{
  "type": "toggle",
  "action": {"type": "relay", "channel": 1},
  "style": {
    "color_active": "#007AFF",
    "color_inactive": "#2C2C2E"
  }
}
```

#### 2. Momentary Button
```json
{
  "type": "momentary",
  "action": {
    "type": "relay", 
    "channel": 2,
    "requires_heartbeat": true,
    "heartbeat_interval": 500,
    "timeout": 1000
  },
  "protection": {
    "type": "confirmation",
    "message": "Segurar para ação"
  }
}
```

#### 3. Switch Control
```json
{
  "type": "switch",
  "action": {"type": "relay", "channel": 3},
  "style": "ios_style"
}
```

#### 4. Navigation Button
```json
{
  "type": "navigation",
  "action": {
    "type": "screen",
    "target": "lighting_screen"
  }
}
```

### Layouts Suportados

#### Grid Layout
```json
{
  "layout": {
    "type": "grid",
    "cols": 3,
    "rows": 2,
    "spacing": 4
  }
}
```

#### List Layout
```json
{
  "layout": {
    "type": "list",
    "item_height": 44,
    "spacing": 2
  }
}
```

#### Custom Layout
```json
{
  "layout": {
    "type": "custom"
  },
  "buttons": [
    {
      "position": {"x": 10, "y": 30},
      "size": {"width": 80, "height": 40}
    }
  ]
}
```

## 📡 Comunicação MQTT

### Tópicos do Dispositivo

```bash
# Configuração
autocore/display/{uuid}/config

# Eventos de interação
autocore/display/{uuid}/events

# Heartbeat do sistema
autocore/display/{uuid}/heartbeat

# Telemetria
autocore/display/{uuid}/telemetry

# Comandos remotos
autocore/display/{uuid}/commands

# Status do dispositivo
autocore/display/{uuid}/status
```

### Tópicos de Subscrição

```bash
# Estados dos relés
autocore/relays/+/state

# Dados CAN
autocore/can/data

# Broadcast do sistema
autocore/system/broadcast
```

### Exemplos de Mensagens

#### Event de Botão
```json
{
  "event": "button_interaction",
  "data": {
    "type": "button_press",
    "button_id": "btn_headlight",
    "screen_id": "dashboard"
  },
  "timestamp": 1234567890,
  "device_uuid": "display-001"
}
```

#### Heartbeat
```json
{
  "device_uuid": "display-001",
  "timestamp": 1234567890,
  "uptime": 3600,
  "state": "running",
  "free_memory": 45678,
  "wifi_signal": -45
}
```

#### Telemetria
```json
{
  "device_uuid": "display-001",
  "timestamp": 1234567890,
  "display_ready": true,
  "current_screen": "dashboard",
  "user_interactions": 15,
  "screen_timeout_events": 3,
  "brightness": 80
}
```

## 🔒 Sistema de Segurança

### Watchdog Monitoring

```cpp
// Tasks monitoradas automaticamente
watchdog.addTask("main_loop", 10000);      // 10s max
watchdog.addTask("wifi_check", 30000);     // 30s max  
watchdog.addTask("mqtt_loop", 15000);      // 15s max
watchdog.addTask("display_update", 5000);  // 5s max
```

### Proteções de Botões

#### Confirmação
```json
{
  "protection": {
    "type": "confirmation",
    "message": "Pressione novamente para confirmar"
  }
}
```

#### Heartbeat (Botões Momentâneos)
```json
{
  "action": {
    "requires_heartbeat": true,
    "heartbeat_interval": 500,
    "timeout": 1000
  }
}
```

### Emergency Stop

- GPIO 0 configurado como emergency stop
- Bloqueia todas as ações quando ativado
- Requer liberação manual para voltar ao normal
- Publicação automática de alertas via MQTT

## 🎯 Modos de Operação

### Estados do Sistema

```cpp
enum SystemState {
    BOOTING,              // Inicializando componentes
    CONFIGURING,          // Modo AP para configuração  
    CONNECTING,           // Conectando WiFi e serviços
    INITIALIZING_DISPLAY, // Configurando LVGL e UI
    RUNNING,              // Operação normal
    ERROR_STATE,          // Estado de erro
    RECOVERY,             // Tentando recuperar
    SLEEPING              // Modo de baixo consumo
};
```

### Fluxo de Inicialização

```
1. BOOTING
   ├── Inicializar logger, watchdog
   ├── Carregar configuração (NVS)
   ├── Configurar componentes básicos
   └── → CONFIGURING ou CONNECTING

2. CONFIGURING (se não configurado)
   ├── Iniciar Access Point
   ├── Servidor web de configuração
   ├── Aguardar configuração via web
   └── → CONNECTING

3. CONNECTING
   ├── Conectar WiFi
   ├── Inicializar API client
   ├── Conectar MQTT
   ├── Sincronizar configuração
   └── → INITIALIZING_DISPLAY

4. INITIALIZING_DISPLAY
   ├── Configurar display SPI
   ├── Inicializar LVGL
   ├── Criar screen manager
   ├── Renderizar interface
   └── → RUNNING

5. RUNNING
   ├── Loop principal ativo
   ├── Processar eventos touch
   ├── Atualizar telemetria
   └── Monitorar conectividade
```

## 📊 Performance e Otimização

### Configurações LVGL

```ini
# Buffer otimizado para ESP32
-DLV_MEM_SIZE=65536
-DLV_COLOR_DEPTH=16
-DLV_USE_PERF_MONITOR=1
-DLV_USE_MEM_MONITOR=1

# Display específico
-DTFT_WIDTH=320
-DTFT_HEIGHT=240
-DSPI_FREQUENCY=40000000
```

### Targets de Performance

- **RAM Usage**: < 100KB para UI
- **Response Time**: < 100ms para eventos touch
- **Render Rate**: 30 FPS sustentado
- **Startup Time**: < 5 segundos para interface pronta
- **MQTT Latency**: < 50ms para comandos

### Monitoramento

```cpp
// Métricas coletadas automaticamente
- Loop counter
- Free memory
- WiFi signal strength  
- MQTT message rate
- Display FPS
- Touch response time
```

## 🧪 Modo de Simulação

**FASE 1: SIMULAÇÃO ATIVA**

Todo o firmware está implementado em modo simulação para desenvolvimento e testes:

```cpp
// Todas as ações são logadas mas não executam hardware
LOG_INFO("SIMULADO: Display inicializado (320x240)");
LOG_INFO("SIMULADO: Touch configurado (XPT2046)");
LOG_INFO("SIMULADO: Botão %s pressionado", buttonId.c_str());
LOG_INFO("SIMULADO: Navegação para tela %s", screenId.c_str());
```

### Funcionalidades Simuladas

- ✅ Inicialização do display LVGL
- ✅ Touch controller e eventos
- ✅ Renderização de botões dinâmicos
- ✅ Navigation bar e screen manager
- ✅ Comunicação MQTT completa
- ✅ Sistema de configuração web
- ✅ Watchdog e monitoramento

### Para Ativar Hardware Real

1. Remover flags `SIMULADO:` dos logs
2. Implementar drivers reais em `src/ui/display_driver.cpp`
3. Configurar pinos SPI no `platformio.ini`
4. Testar em hardware físico

## 🔧 Troubleshooting

### Problemas Comuns

#### Display não inicializa
```bash
# Verificar conexões SPI
# Confirmar tensão de alimentação (3.3V)
# Testar pinos CS, DC, RST

# Log esperado:
[INFO] Display driver inicializado
[INFO] LVGL configurado (320x240)
```

#### Touch não responde
```bash
# Verificar conexão do touch CS/IRQ
# Calibrar coordenadas se necessário
# Testar com finger vs stylus

# Debug touch:
#define TOUCH_DEBUG 1
```

#### WiFi não conecta
```bash
# Verificar SSID/senha
# Força do sinal (min -70dBm)
# Modo de segurança da rede

# Log esperado:
[INFO] WiFi conectado: 192.168.1.100
```

#### MQTT desconecta
```bash
# Verificar broker disponível
# Confirmar credenciais
# Tamanho das mensagens (max 1KB)

# Debug MQTT:
mqttClient.debugEnabled = true;
```

### Logs de Debug

```bash
# Habilitar debug completo
Logger::setLevel(LOG_LEVEL_DEBUG);
watchdog.debugEnabled = true;
mqttClient.debugEnabled = true;

# Monitor serial
pio device monitor --baud 115200
```

### Reset de Fábrica

Via interface web:
```bash
POST /api/factory-reset
```

Via hardware:
```bash
# Segurar GPIO 0 durante boot
# Ou via comando serial
```

## 📚 API Reference

### Endpoints REST

```bash
# Status do sistema
GET /api/status

# Configuração atual
GET /api/config

# Salvar configuração  
POST /api/config

# Redes WiFi disponíveis
GET /api/networks

# Testar conexão backend
POST /api/test-connection

# Reiniciar dispositivo
POST /api/restart

# Reset de fábrica
POST /api/factory-reset
```

### Classes Principais

#### ConfigManager
```cpp
bool begin();
DeviceConfig& getConfig();
bool updateFromJSON(const String& json);
bool save();
```

#### WiFiManager  
```cpp
bool connect(const String& ssid, const String& password);
bool enableAPMode();
String getStateString();
```

#### MQTTClient
```cpp
bool begin(const String& uuid, const String& broker, int port);
bool publishEvent(const String& event, const String& data);
bool sendButtonPress(const String& buttonId);
```

#### WebServer
```cpp
bool begin(int port = 80);
void handleRoot(AsyncWebServerRequest* request);
void sendJSON(AsyncWebServerRequest* request, const String& json);
```

## 🤝 Contribuindo

### Estrutura do Código

```
src/
├── config/         # Gerenciamento de configuração
├── network/        # WiFi, web server, API client  
├── mqtt/          # Cliente e handler MQTT
├── ui/            # Display driver, LVGL, interface
└── utils/         # Logger, watchdog, utilitários
```

### Padrões de Código

- **Logging**: Use macros contextualizadas `LOG_INFO_CTX`
- **Errors**: Sempre retorne bool para success/fail
- **Memory**: Priorize memória estática
- **Async**: Use callbacks para operações não-bloqueantes

### Pull Requests

1. Fork o repositório
2. Crie branch feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para branch (`git push origin feature/nova-funcionalidade`)
5. Abra Pull Request

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

## 👥 Créditos

- **Desenvolvido por**: Lee Chardes
- **Projeto**: AutoCore Automotive Platform
- **Inspiração UI**: shadcn/ui design system
- **LVGL**: Light and Versatile Graphics Library

---

## 🔗 Links Úteis

- 📖 [Documentação LVGL](https://docs.lvgl.io/)
- 🛠️ [PlatformIO Docs](https://docs.platformio.org/)
- 📡 [MQTT.org](https://mqtt.org/)
- 🎨 [shadcn/ui](https://ui.shadcn.com/)

**Status**: ✅ Firmware completo implementado em modo simulação  
**Versão**: 1.0.0  
**Atualizado**: Janeiro 2025