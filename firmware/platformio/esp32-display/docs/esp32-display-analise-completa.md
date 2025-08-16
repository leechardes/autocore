# 📺 ESP32-Display - Análise Técnica Completa

## 📋 Índice

- [1. Configurações de Tela](#1-configurações-de-tela)
- [2. Endpoints e Comunicação](#2-endpoints-e-comunicação)
- [3. Processo de Configuração](#3-processo-de-configuração)
- [4. Arquitetura e Fluxo de Dados](#4-arquitetura-e-fluxo-de-dados)
- [5. Interface de Usuário](#5-interface-de-usuário)
- [6. Protocolos e Formatos](#6-protocolos-e-formatos)
- [7. Especificações Técnicas](#7-especificações-técnicas)
- [8. Diagramas de Sistema](#8-diagramas-de-sistema)

---

## 1. Configurações de Tela

### 1.1 Tipo de Display Utilizado

**Hardware**: **ILI9341** TFT Display (ESP32-2432S028R)
- **Driver**: ILI9341_2_DRIVER (driver alternativo mais compatível)
- **Biblioteca**: TFT_eSPI v2.5.0
- **Interface**: SPI (HSPI)

```cpp
// Configurações de build (platformio.ini)
-D ILI9341_2_DRIVER=1           // Driver alternativo ILI9341
-D TFT_INVERSION_ON=1           // Correção para fundo branco ESP32-2432S028R
-D USE_HSPI_PORT                // Usar porta HSPI
```

### 1.2 Pinos de Conexão SPI

```cpp
// Pinos de conexão TFT (DeviceConfig.h)
#define TFT_MISO     12          // Master In Slave Out
#define TFT_MOSI     13          // Master Out Slave In
#define TFT_SCLK     14          // Serial Clock
#define TFT_CS       15          // Chip Select
#define TFT_DC       2           // Data/Command
#define TFT_RST      12          // Reset (compartilhado com MISO)
#define TFT_BL       21          // Backlight
```

### 1.3 Resolução e Orientação

```cpp
// Configurações de display
#define TFT_WIDTH    240         // Largura física
#define TFT_HEIGHT   320         // Altura física
#define SCREEN_WIDTH 320         // Largura após rotação
#define SCREEN_HEIGHT 240        // Altura após rotação

// Orientação (main.cpp)
tft.setRotation(1);              // Landscape (modo paisagem)
```

### 1.4 Bibliotecas de Display

```ini
# Bibliotecas utilizadas (platformio.ini)
lib_deps = 
    bodmer/TFT_eSPI@^2.5.0      # Driver TFT principal
    lvgl/lvgl@^8.3.11           # Framework de interface gráfica
    bblanchon/ArduinoJson@^7.0.2 # Parsing de JSON
```

### 1.5 Configurações de Touch Screen

**Hardware**: **XPT2046** Touch Controller
- **Interface**: SPI separada (VSPI)
- **Biblioteca**: XPT2046_Touchscreen
- **Calibração**: Específica para ESP32-2432S028R

```cpp
// Pinos do Touch Screen (DeviceConfig.h)
#define XPT2046_IRQ  36          // Pino de interrupção
#define XPT2046_MOSI 32          // MOSI do touch (VSPI)
#define XPT2046_MISO 39          // MISO do touch (VSPI)
#define XPT2046_CLK  25          // Clock do touch (VSPI)
#define XPT2046_CS   33          // Chip Select do touch

// Calibração do Touch Screen
#define TOUCH_MIN_X  200         // Valor mínimo X
#define TOUCH_MAX_X  3700        // Valor máximo X
#define TOUCH_MIN_Y  240         // Valor mínimo Y
#define TOUCH_MAX_Y  3800        // Valor máximo Y
```

### 1.6 Configurações de Backlight

**Controle PWM**: Canal 0, frequência 5000Hz, resolução 8 bits

```cpp
// Configuração do Backlight (main.cpp)
pinMode(TFT_BACKLIGHT_PIN, OUTPUT);
ledcSetup(0, 5000, 8);           // Canal 0, 5kHz, 8 bits (0-255)
ledcAttachPin(TFT_BACKLIGHT_PIN, 0);
ledcWrite(0, 128);               // 50% de brilho inicial

// Configurações (DeviceConfig.h)
#define TFT_BACKLIGHT_PIN 21     // Pino do backlight
#define DEFAULT_BACKLIGHT 100    // Backlight padrão (0-100)
```

---

## 2. Endpoints e Comunicação

### 2.1 Protocolo MQTT v2.2.0

**Broker Configuration**:
```cpp
#define MQTT_BROKER "10.0.10.100"           // IP do broker
#define MQTT_PORT 1883                      // Porta do broker
#define MQTT_USER "autocore"                // Usuário MQTT
#define MQTT_PASSWORD "kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr" // Senha
#define MQTT_KEEPALIVE_SECONDS 60           // Keep alive
#define MQTT_BUFFER_SIZE 20480              // Buffer 20KB
```

### 2.2 Estrutura de Tópicos MQTT

```
autocore/
├── discovery/                   # Auto-discovery de dispositivos
│   ├── announce                 # Device announce
│   └── register                 # Device registration
├── gateway/                     # Gateway central
│   └── config/
│       ├── request              # Solicitar configuração
│       ├── response             # Resposta de configuração
│       └── update               # Atualização parcial
├── hmi_display_{id}/           # Dispositivos HMI
│   ├── command/                # Comandos para o dispositivo
│   ├── status/                 # Status do dispositivo
│   │   ├── health              # Status de saúde
│   │   ├── operational         # Status operacional
│   │   └── lwt                 # Last Will Testament
│   ├── config/                 # Configuração
│   │   └── ack                 # Acknowledgment de config
│   └── telemetry/              # Telemetria
│       ├── performance         # Métricas de performance
│       └── errors              # Relatório de erros
├── system/                     # Controle de sistema
│   ├── ping                    # System ping
│   └── emergency_stop          # Parada de emergência
└── preset/                     # Sistema de presets
    ├── execute                 # Executar preset
    ├── status                  # Status de execução
    └── define                  # Definir preset
```

### 2.3 API REST (Sistema Híbrido)

**Base Configuration**:
```cpp
#define API_SERVER "10.0.10.100"            // Servidor API
#define API_PORT 8081                       // Porta API
#define API_PROTOCOL "http"                 // Protocolo
#define API_BASE_PATH "/api"                // Path base
#define API_TIMEOUT 10000                   // Timeout (ms)
#define API_RETRY_COUNT 3                   // Tentativas
#define API_RETRY_DELAY 2000               // Delay entre tentativas
#define API_CACHE_TTL 300000               // TTL do cache (5 min)
```

**Endpoints Disponíveis**:
```
GET /api/screens                 # Lista de telas
GET /api/screens/{id}/items      # Itens de uma tela
GET /api/devices                 # Lista de dispositivos
GET /api/relay-boards           # Lista de relay boards
GET /api/config/full            # Configuração completa
```

### 2.4 Mensagens MQTT - Formatos JSON

#### Configuration Request
```json
{
  "device_id": "esp32-display-001",
  "config_version": "1.9.5",
  "request_type": "full_config",
  "timestamp": "2025-01-01T12:00:00Z"
}
```

#### Configuration Response
```json
{
  "version": "2.0.0",
  "target_device": "esp32-display-001",
  "protocol_version": "2.2.0",
  "timestamp": "2025-01-01T12:00:01Z",
  "system": {
    "name": "Veículo Principal",
    "language": "pt-BR",
    "theme": "dark_blue",
    "timeout_screen": 30,
    "brightness": 80
  },
  "screens": {
    "home": {
      "type": "menu",
      "title": "Menu Principal",
      "layout": "grid_2x3",
      "items": [
        {
          "id": "luz_alta",
          "type": "relay",
          "label": "Farol Alto",
          "icon": "light_high",
          "device": "relay_board_1",
          "channel": 1,
          "mode": "toggle"
        }
      ]
    }
  }
}
```

#### Status Report
```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-001",
  "timestamp": "2025-01-01T12:00:00Z",
  "status": "healthy",
  "uptime": 15432,
  "free_heap": 180000,
  "current_screen": "home",
  "wifi_rssi": -65,
  "temperature": 45.2
}
```

### 2.5 Configuração de Tela Dinâmica (Somente Leitura)

O ESP32-display é um **dispositivo de exibição puro** que apenas consome configurações fornecidas pelo gateway/API. O display **não possui capacidade de criar, modificar ou deletar configurações** - ele apenas recebe, interpreta e exibe as telas conforme definido pelo sistema central.

#### 2.5.1 Estrutura de Configuração de Telas

```json
{
  "screens": {
    "screen_id": {                       // ID único da tela
      "type": "menu|control|settings",   // Tipo da tela
      "title": "Título da Tela",        // Título exibido
      "layout": "grid_2x3|list|form",   // Layout da tela
      "background": "#1E3A5F",           // Cor de fundo (opcional)
      "items": [                        // Array de itens da tela
        {
          "id": "item_unique_id",       // ID único do item
          "type": "relay|preset|navigation|label|status|slider",
          "position": {"x": 0, "y": 0}, // Posição no grid (se aplicável)
          "size": {"width": 1, "height": 1}, // Tamanho no grid
          "label": "Texto do Item",
          "icon": "icon_name",          // Nome do ícone (opcional)
          "style": {                    // Estilo customizado (opcional)
            "background": "#2196F3",
            "text_color": "#FFFFFF",
            "border_radius": 8
          },
          "action": {                   // Ação ao clicar/tocar
            "type": "command|navigation|preset",
            "target": "device_id|screen_id|preset_id",
            "params": {}               // Parâmetros adicionais
          }
        }
      ]
    }
  }
}
```

#### 2.5.2 Endpoints de Consumo de Configuração

**Endpoints REST (Somente Leitura):**

```
GET  /api/config/full                  # Configuração completa do dispositivo (CRIAR)
GET  /api/screens                      # Lista todas as telas disponíveis (IMPLEMENTADO)
GET  /api/screens/{screen_id}          # Detalhes de uma tela específica (CRIAR)
GET  /api/screens/{screen_id}/items    # Itens de uma tela específica (IMPLEMENTADO)
GET  /api/devices                      # Lista de dispositivos (IMPLEMENTADO)
GET  /api/relays/boards                # Lista de placas de relé (IMPLEMENTADO)
GET  /api/layouts                      # Layouts disponíveis para renderização (CRIAR)
GET  /api/icons                        # Ícones disponíveis para exibição (CRIAR)
GET  /api/themes                       # Temas disponíveis para aplicação (CRIAR)
```

**Status de Implementação:**
- ✅ **IMPLEMENTADOS (4)**: `/screens`, `/screens/{id}/items`, `/devices`, `/relays/boards`
- ❌ **A CRIAR (5)**: `/config/full`, `/screens/{id}`, `/layouts`, `/icons`, `/themes`

**Nota:** O display **apenas consome (GET)** estas configurações. Toda criação, modificação ou deleção de configurações é feita através do gateway/sistema administrativo, nunca pelo display.

**Tópicos MQTT para Consumo:**

```
# Display solicita configuração (somente leitura)
autocore/hmi_display_{id}/config/request
{
  "device_id": "esp32-display-001",
  "request_type": "full_config",  // Sempre solicita config completa
  "current_version": "1.9.5"      // Versão atual (para comparação)
}

# Gateway envia configuração para o display
autocore/hmi_display_{id}/config/response
{
  "screens": [...],                // Array de configurações de tela
  "version": "2.0.0",              // Versão da configuração
  "timestamp": "2025-01-01T12:00:00Z"
}

# Gateway notifica mudança (display apenas recebe e aplica)
autocore/hmi_display_{id}/config/update
{
  "type": "hot_reload",            // Tipo de atualização
  "screens": [...],                // Nova configuração completa
  "timestamp": "2025-01-01T12:00:00Z"
}

# Display confirma recebimento (não modifica, apenas confirma)
autocore/hmi_display_{id}/config/ack
{
  "device_id": "esp32-display-001",
  "config_version": "2.0.0",
  "status": "applied",             // applied ou error
  "timestamp": "2025-01-01T12:00:00Z"
}
```

#### 2.5.3 Exemplo de Configuração Recebida pelo Display

O display recebe esta configuração pronta do gateway e apenas a renderiza:

```json
{
  "version": "2.0.0",
  "read_only": true,  // Display não pode alterar
  "screens": {
    "home": {
      "type": "menu",
      "title": "AutoCore Control",
      "layout": "grid_2x3",
      "background": "#1E3A5F",
      "items": [
        {
          "id": "btn_lights",
          "type": "navigation",
          "position": {"x": 0, "y": 0},
          "label": "Iluminação",
          "icon": "light_bulb",
          "style": {
            "background": "#4CAF50",
            "text_color": "#FFFFFF"
          },
          "action": {
            "type": "navigation",
            "target": "lighting_screen"
          }
        },
        {
          "id": "btn_relay_1",
          "type": "relay",
          "position": {"x": 1, "y": 0},
          "label": "Farol Alto",
          "icon": "high_beam",
          "style": {
            "background": "#2196F3"
          },
          "action": {
            "type": "command",
            "target": "relay_board_1",
            "params": {
              "channel": 1,
              "mode": "toggle"
            }
          }
        }
      ]
    },
    "lighting_screen": {
      "type": "control",
      "title": "Controle de Iluminação",
      "layout": "list",
      "items": [
        {
          "id": "light_1",
          "type": "relay",
          "label": "Luz Dianteira",
          "device": "relay_board_1",
          "channel": 1,
          "mode": "toggle",
          "feedback": true
        },
        {
          "id": "light_brightness",
          "type": "slider",
          "label": "Intensidade",
          "min": 0,
          "max": 100,
          "value": 50,
          "unit": "%",
          "action": {
            "type": "command",
            "target": "pwm_controller",
            "params": {
              "channel": 1
            }
          }
        }
      ]
    }
  }
}
```

#### 2.5.4 Sistema de Renderização de UI (Somente Exibição)

```cpp
// ScreenFactory - Renderiza telas baseado em configuração recebida
// O display APENAS renderiza, não cria ou modifica configurações
class ScreenFactory {
public:
    // Recebe configuração e renderiza na tela
    static std::unique_ptr<ScreenBase> renderScreenFromConfig(
        const JsonObject& screenConfig) {
        
        // Apenas interpreta e exibe a configuração recebida
        String type = screenConfig["type"];
        String layout = screenConfig["layout"];
        
        if (type == "menu") {
            return renderMenuScreen(screenConfig, layout);
        } else if (type == "control") {
            return renderControlScreen(screenConfig, layout);
        } else if (type == "settings") {
            return renderSettingsScreen(screenConfig, layout);
        }
        return nullptr;
    }

private:
    // Renderiza item baseado na configuração (não edita, apenas exibe)
    static void renderItemFromConfig(
        lv_obj_t* parent, 
        const JsonObject& itemConfig) {
        
        String itemType = itemConfig["type"];
        
        // Cria elementos visuais baseados na config recebida
        if (itemType == "relay") {
            renderRelayButton(parent, itemConfig);
        } else if (itemType == "slider") {
            renderSlider(parent, itemConfig);
        } else if (itemType == "label") {
            renderLabel(parent, itemConfig);
        }
        // O display apenas exibe, não salva alterações
    }
};
```

#### 2.5.5 Fluxo de Recepção e Renderização (Display Read-Only)

```mermaid
sequenceDiagram
    participant G as Gateway/API
    participant M as MQTT Broker
    participant D as Display (Read-Only)
    participant U as UI Renderer
    participant S as Screen
    
    Note over D: Display apenas consome configurações
    
    G->>M: Publish new configuration
    M->>D: Deliver config (display apenas recebe)
    D->>D: Parse JSON (somente leitura)
    D->>U: Render received config
    U->>S: Clear current screen
    U->>S: Render new screen from config
    S->>S: Display LVGL objects
    S->>S: Setup event handlers (ações, não edição)
    U->>D: Rendering complete
    D->>M: ACK receipt only (não modifica)
    
    Note over D: Display envia comandos mas nunca altera configs
```

### 2.6 Configurações de Rede

```cpp
// WiFi Configuration (DeviceConfig.h)
#define WIFI_SSID "Lee"                     // Nome da rede WiFi
#define WIFI_PASSWORD "lee159753"           // Senha WiFi
#define WIFI_TIMEOUT 30000                  // Timeout conexão (ms)
#define WIFI_RETRY_DELAY 5000              // Delay entre tentativas
```

---

## 3. Processo de Configuração

### 3.1 Fluxo de Inicialização do Display

```mermaid
sequenceDiagram
    participant M as Main
    participant D as Display
    participant L as LVGL
    participant T as Touch
    participant B as Backlight
    
    M->>D: tft.init()
    M->>D: tft.setRotation(1)
    M->>D: tft.fillScreen(BLACK)
    M->>B: pinMode(BACKLIGHT, OUTPUT)
    M->>B: ledcSetup(0, 5000, 8)
    M->>B: ledcAttachPin(21, 0)
    M->>B: ledcWrite(0, 128)
    M->>L: lv_init()
    M->>L: lv_disp_draw_buf_init()
    M->>L: lv_disp_drv_register()
    M->>T: touchHandler.begin()
    M->>L: lv_indev_drv_register()
```

### 3.2 Processo de Configuração Inicial

```mermaid
sequenceDiagram
    participant D as Device
    participant G as Gateway
    participant A as API
    participant M as MQTT
    
    D->>G: Device Announce (MQTT)
    G->>D: Registration Response
    D->>A: GET /api/config/full
    alt API Available
        A->>D: Configuration JSON
        D->>D: Build UI from Config
        D->>M: Config ACK (MQTT)
    else API Failed
        D->>M: Config Request (MQTT)
        G->>M: Config Response (MQTT)
        D->>D: Build UI from Config
        D->>M: Config ACK (MQTT)
    end
```

### 3.3 Sistema Hot Reload

```cpp
// Hot Reload Implementation (main.cpp)
configReceiver->enableHotReload([]() {
    logger->info("Hot reload triggered! Rebuilding UI...");
    
    if (screenManager && configManager->hasConfig()) {
        screenManager->buildFromConfig(configManager->getConfig());
        
        if (navigator) {
            String currentScreen = navigator->getCurrentScreen();
            navigator->navigateToScreen(currentScreen);
        }
        
        // Visual feedback - flash green LED
        digitalWrite(LED_G_PIN, LOW);
        delay(100);
        digitalWrite(LED_G_PIN, HIGH);
    }
});
```

### 3.4 Parâmetros Configuráveis

```cpp
// Behavior Configuration (DeviceConfig.h)
#define CONFIG_REQUEST_INTERVAL 10000       // Intervalo entre requests de config
#define STATUS_REPORT_INTERVAL 30000        // Intervalo de relatório de status
#define HEARTBEAT_INTERVAL 60000            // Intervalo de heartbeat
#define BUTTON_DEBOUNCE_DELAY 50           // Debounce dos botões
#define BUTTON_LONG_PRESS_TIME 1000        // Tempo para long press

// Memory Configuration
#define JSON_DOCUMENT_SIZE 20480           // Tamanho do documento JSON (20KB)
#define MAX_SCREENS 20                     // Número máximo de telas
#define MAX_ITEMS_PER_SCREEN 50           // Máximo de itens por tela

// LVGL Configuration
#define LVGL_TICK_PERIOD 5                 // Período do tick LVGL (ms)
#define LVGL_BUFFER_SIZE (SCREEN_WIDTH * 10) // Buffer LVGL
```

### 3.5 Armazenamento de Configurações

**Método de Armazenamento**: RAM + MQTT Retained Messages
- **Configurações locais**: Armazenadas na RAM durante execução
- **Persistência**: Via MQTT retained messages no broker
- **Backup**: Não utiliza EEPROM/SPIFFS local
- **Sincronização**: Automática via MQTT ao reiniciar

**Vantagens do Método**:
- Configuração centralizada no gateway
- Sincronização automática entre dispositivos
- Backup automático no broker MQTT
- Hot reload sem perda de estado

---

## 4. Arquitetura e Fluxo de Dados

### 4.1 Estrutura Principal do Código

```
src/
├── main.cpp                     # Ponto de entrada principal
├── core/                        # Componentes principais
│   ├── ConfigManager.cpp        # Gerenciamento de configuração
│   ├── Logger.cpp               # Sistema de logging
│   ├── MQTTClient.cpp          # Cliente MQTT otimizado
│   └── MQTTProtocol.cpp        # Protocolo MQTT v2.2.0
├── ui/                          # Interface de usuário
│   ├── ScreenManager.cpp        # Gerenciador de telas
│   └── ScreenFactory.cpp       # Factory de telas
├── communication/               # Comunicação
│   ├── ConfigReceiver.cpp       # Recepção de configurações
│   ├── StatusReporter.cpp       # Relatório de status
│   └── ButtonStateManager.cpp   # Estado dos botões
├── navigation/                  # Sistema de navegação
│   ├── Navigator.cpp            # Navegação entre telas
│   └── ButtonHandler.cpp       # Tratamento de botões
├── input/                       # Entrada de dados
│   └── TouchHandler.cpp         # Tratamento do touch
├── network/                     # Rede e API
│   └── ScreenApiClient.cpp     # Cliente API REST
└── commands/                    # Sistema de comandos
    └── CommandSender.cpp        # Envio de comandos
```

### 4.2 Classes/Módulos Principais

#### ConfigManager
```cpp
class ConfigManager {
private:
    JsonDocument config;         // Configuração atual
    String configVersion;        // Versão da configuração
    bool hasValidConfig;         // Flag de configuração válida
    
public:
    bool hasConfig();           // Verifica se tem configuração
    JsonDocument& getConfig();  // Retorna configuração
    void setConfig(JsonDocument& newConfig); // Define nova configuração
    String getVersion();        // Retorna versão atual
};
```

#### ScreenManager
```cpp
class ScreenManager {
private:
    std::map<String, std::unique_ptr<ScreenBase>> screens; // Telas criadas
    ScreenBase* currentScreen;                            // Tela atual
    String currentScreenId;                               // ID da tela atual
    
public:
    bool showScreen(const String& screenId);             // Mostra tela
    void buildFromConfig(JsonDocument& config);          // Constrói da config
    void navigateTo(const String& screenId);            // Navega para tela
};
```

#### MQTTClient (Otimizado)
```cpp
class MQTTClient {
private:
    PubSubClient client;         // Cliente MQTT interno
    String deviceId;             // ID do dispositivo
    String broker;               // Endereço do broker
    int port;                    // Porta do broker
    
public:
    bool connect();              // Conecta ao broker
    bool publish(String topic, String payload, bool retained = false);
    bool subscribe(String topic);
    void loop();                 // Loop de processamento
};
```

### 4.3 Fluxo de Dados - Desde Recepção até Exibição

```mermaid
flowchart TD
    A[MQTT Message Received] --> B{Message Type?}
    B -->|Config| C[ConfigReceiver]
    B -->|Command| D[CommandHandler]
    B -->|Status| E[StatusProcessor]
    
    C --> F[Parse JSON Config]
    F --> G{Valid Config?}
    G -->|Yes| H[ConfigManager.setConfig]
    G -->|No| I[Log Error]
    
    H --> J[Trigger Hot Reload]
    J --> K[ScreenManager.buildFromConfig]
    K --> L[ScreenFactory.createScreen]
    L --> M[Parse Screen Items]
    M --> N[Create LVGL Objects]
    N --> O[Setup Event Handlers]
    O --> P[Navigator.navigateToScreen]
    P --> Q[Display Updated UI]
```

### 4.4 Sistema de Filas/Buffers

```cpp
// MQTT Buffer Configuration
#define MQTT_BUFFER_SIZE 20480              // 20KB para mensagens grandes
#define MQTT_MAX_PACKET_SIZE 20480          // Tamanho máximo do pacote

// LVGL Buffer Configuration  
static lv_color_t buf[screenWidth * 10];    // Buffer de 10 linhas
#define LVGL_BUFFER_SIZE (SCREEN_WIDTH * 10)

// JSON Processing Buffer
#define JSON_DOCUMENT_SIZE 20480            // 20KB para documentos JSON
```

### 4.5 Gerenciamento de Memória

```cpp
// Memory Settings (lv_conf.h)
#define LV_MEM_SIZE (64U * 1024U)          // 64KB para LVGL
#define LV_MEM_BUF_MAX_NUM 16              // 16 buffers intermediários

// Heap Monitoring (DeviceModels.h)
struct HealthStatus {
    uint32_t freeHeap;                     // Heap livre atual
    uint32_t minFreeHeap;                  // Menor heap registrado
    float heapFragmentation;               // Fragmentação do heap
    uint32_t maxBlockSize;                 // Maior bloco disponível
};
```

---

## 5. Interface de Usuário

### 5.1 Framework LVGL v8.3.11

**Configurações Principais**:
```cpp
// Color and Display (lv_conf.h)
#define LV_COLOR_DEPTH 16                  // RGB565 (16 bits por pixel)
#define LV_COLOR_16_SWAP 0                 // Sem swap de bytes
#define LV_DISP_DEF_REFR_PERIOD 30        // Refresh a cada 30ms
#define LV_INDEV_DEF_READ_PERIOD 30       // Leitura de input a cada 30ms

// Fonts
#define LV_FONT_MONTSERRAT_10 1           // Fonte 10px
#define LV_FONT_MONTSERRAT_12 1           // Fonte 12px
#define LV_FONT_MONTSERRAT_14 1           // Fonte 14px (padrão)
#define LV_FONT_MONTSERRAT_16 1           // Fonte 16px
#define LV_FONT_MONTSERRAT_20 1           // Fonte 20px
#define LV_FONT_DEFAULT &lv_font_montserrat_14 // Fonte padrão
```

### 5.2 Telas/Páginas Disponíveis

O display renderiza diferentes tipos de tela conforme recebido na configuração do gateway:

#### Tipos de Tela Suportados:
```json
{
  "screens": {
    "home": {
      "type": "menu",              // Tela tipo menu
      "layout": "grid_2x3"         // Layout em grid 2x3
    },
    "lighting": {
      "type": "control",           // Tela de controle
      "layout": "list"             // Layout em lista
    },
    "settings": {
      "type": "settings",          // Tela de configurações
      "layout": "form"             // Layout tipo formulário
    }
  }
}
```

#### Layouts Suportados:
- **grid_2x2**: Grid 2x2 (4 itens)
- **grid_2x3**: Grid 2x3 (6 itens)
- **grid_3x2**: Grid 3x2 (6 itens)
- **list**: Lista vertical
- **form**: Formulário com campos

### 5.3 Elementos UI Disponíveis

```json
{
  "items": [
    {
      "type": "relay",             // Botão de relé
      "mode": "toggle"             // toggle/momentary
    },
    {
      "type": "preset",            // Botão de preset
      "preset_id": "camping_mode"
    },
    {
      "type": "navigation",        // Botão de navegação
      "target_screen": "settings"
    },
    {
      "type": "label",             // Texto estático
      "text": "Status: OK"
    },
    {
      "type": "status",            // Status dinâmico
      "source": "sensor_temp_01"
    },
    {
      "type": "slider",            // Controle deslizante
      "min": 0, "max": 100
    }
  ]
}
```

### 5.4 Sistema de Navegação

```cpp
// Navigation System
class Navigator {
private:
    ScreenManager* screenManager;
    String currentScreen;
    std::vector<String> screenHistory; // Histórico de navegação
    
public:
    void navigateToScreen(const String& screenId);
    void navigatePrevious();        // Volta para tela anterior
    void navigateNext();            // Próxima tela (se aplicável)
    void navigateHome();            // Volta ao menu principal
    void select();                  // Seleciona item atual
};

// Button Navigation
void setupButtonCallbacks() {
    buttonHandler->onPrevious([](){ navigator->navigatePrevious(); });
    buttonHandler->onSelect([](){ navigator->select(); });
    buttonHandler->onNext([](){ navigator->navigateNext(); });
}
```

### 5.5 Controle de Input

#### Botões Físicos
```cpp
// Physical Buttons (DeviceConfig.h)
#define BTN_PREV_PIN 35            // Botão Previous/Anterior
#define BTN_SELECT_PIN 0           // Botão Select/OK (BOOT button)
#define BTN_NEXT_PIN 34            // Botão Next/Próximo

// Button Configuration
#define BUTTON_DEBOUNCE_DELAY 50   // Debounce 50ms
#define BUTTON_LONG_PRESS_TIME 1000 // Long press 1 segundo
```

#### Touch Screen
```cpp
// Touch Input (TouchHandler.h)
#define MIN_PRESSURE 200           // Pressão mínima para toque
#define DEBOUNCE_TIME 50          // Debounce do touch
#define DEBUG_INTERVAL 500        // Intervalo de debug do touch

// Touch Calibration
void TouchHandler::setCalibration(uint16_t minX, uint16_t maxX, 
                                 uint16_t minY, uint16_t maxY);
```

### 5.6 Atualização de Dados na Tela

```cpp
// Dynamic Data Update - Display apenas atualiza visualização
// Não persiste ou modifica configurações
class ButtonStateManager {
public:
    // Atualiza apenas o estado visual (não salva)
    void updateButtonState(const String& itemId, bool state);
    void updateStatusText(const String& itemId, const String& text);
    void updateProgressBar(const String& itemId, int value);
    void flashLedFeedback(const String& color); // Feedback visual temporário
};

// Status Updates via MQTT - Reporta estado, não modifica config
void StatusReporter::sendStatus(String currentScreen, 
                               int brightness, 
                               int wifiRssi) {
    JsonDocument status;
    status["current_screen"] = currentScreen;  // Tela atual sendo exibida
    status["brightness"] = brightness;          // Brilho atual
    status["wifi_rssi"] = wifiRssi;            // Sinal WiFi
    status["timestamp"] = getISOTimestamp();
    
    // Apenas reporta estado, não altera configurações
    mqttClient->publish("autocore/" + deviceId + "/status/operational", 
                       status.as<String>());
}
```

### 5.7 Sistema de Themes

```cpp
// Theme Configuration (DeviceConfig.h)
// Cores personalizáveis via configuração MQTT
typedef struct {
    lv_color_t primary;     // Cor primária
    lv_color_t secondary;   // Cor secundária  
    lv_color_t accent;      // Cor de destaque
    lv_color_t background;  // Cor de fundo
    lv_color_t text;        // Cor do texto
} theme_colors_t;

// Themes disponíveis:
// - dark_blue (padrão)
// - light_gray
// - high_contrast
// - automotive_orange
```

---

## 6. Protocolos e Formatos

### 6.1 Estrutura das Mensagens MQTT v2.2.0

#### Campos Obrigatórios do Protocolo
```cpp
// Protocol Headers (MQTTProtocol.h)
class MQTTProtocol {
    static void addProtocolFields(JsonDocument& doc) {
        doc["protocol_version"] = "2.2.0";
        doc["uuid"] = getDeviceUUID();
        doc["timestamp"] = getISOTimestamp();
    }
};
```

#### Device Discovery Message
```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-001", 
  "timestamp": "2025-01-01T12:00:00Z",
  "device_id": "esp32-display-001",
  "device_type": "hmi_display",
  "firmware_version": "2.0.0",
  "ip_address": "192.168.4.20",
  "mac_address": "AA:BB:CC:DD:EE:FF",
  "capabilities": [
    "touchscreen",
    "physical_buttons", 
    "status_leds",
    "hot_reload"
  ],
  "uptime": 15432
}
```

#### Relay Command Message
```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-001",
  "timestamp": "2025-01-01T12:00:00Z",
  "channel": 1,
  "state": true,
  "source": "hmi_display_1",
  "user": "touch_interface",
  "validate": true
}
```

#### Error Response Format
```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-001",
  "timestamp": "2025-01-01T12:00:00Z",
  "error": {
    "code": "ERR_001",
    "type": "command_failed",
    "message": "Relay channel 1 failed to activate",
    "details": {
      "channel": 1,
      "reason": "hardware_fault",
      "retry_count": 3
    }
  }
}
```

### 6.2 Formato dos Dados de Sensores

#### Telemetria de Performance
```json
{
  "protocol_version": "2.2.0",
  "uuid": "esp32-display-001",
  "timestamp": "2025-01-01T12:00:00Z",
  "metrics": {
    "screen_transitions": {
      "total": 156,
      "avg_time": 0.8,
      "max_time": 2.1
    },
    "touch_events": {
      "total": 234,
      "avg_response": 30,
      "max_response": 85
    },
    "memory": {
      "heap_fragmentation": 12.5,
      "max_block_size": 65536,
      "allocations_failed": 0
    }
  }
}
```

### 6.3 Sistema de QoS MQTT

```cpp
// QoS Levels (MQTTProtocol.h)
#define QOS_TELEMETRY    0  // Telemetria - fire and forget
#define QOS_COMMANDS     1  // Comandos - garantir entrega  
#define QOS_HEARTBEAT    1  // Heartbeat - garantir entrega
#define QOS_STATUS       1  // Status - garantir entrega
#define QOS_SECURITY     2  // Segurança - exactly once
```

#### Política de Retenção de Mensagens
| Tipo | QoS | Retained | TTL | Razão |
|------|-----|----------|-----|--------|
| Configuration | 1 | Yes | Permanent | Persistência necessária |
| Device Commands | 1 | No | - | Temporal, garantir entrega |
| Status/Health | 0 | No | - | Alto volume, perda aceitável |
| Telemetry | 0 | No | - | Dados temporais |
| Security Events | 2 | Yes | 7 days | Crítico, auditoria |
| Emergency Stop | 2 | No | - | Crítico mas temporal |

### 6.4 Sistema de Logs/Debug

```cpp
// Logger Configuration (Logger.h)
enum LogLevel {
    LOG_ERROR = 0,   // Apenas erros críticos
    LOG_WARNING = 1, // Avisos importantes  
    LOG_INFO = 2,    // Informações gerais
    LOG_DEBUG = 3    // Debug detalhado
};

// Debug Levels (DeviceConfig.h)
#define DEBUG_LEVEL 2    // 0=OFF, 1=ERROR, 2=INFO, 3=DEBUG
#define SERIAL_BAUD_RATE 115200

// Usage Examples
logger->error("Failed to connect to MQTT broker");
logger->warning("WiFi signal weak: " + String(WiFi.RSSI()));
logger->info("Configuration received, version: " + version);
logger->debug("Touch coordinates: X=" + String(x) + " Y=" + String(y));
```

---

## 7. Especificações Técnicas

### 7.1 Hardware Compatível

**Placa Base**: ESP32-2432S028R (CYD - Cheap Yellow Display)
- **MCU**: ESP32-WROOM-32
- **Flash**: 4MB
- **RAM**: 520KB  
- **WiFi**: 802.11 b/g/n
- **Display**: 2.8" ILI9341 320x240 TFT
- **Touch**: XPT2046 resistive touchscreen
- **Alimentação**: 5V via USB ou conector

### 7.2 Consumo de Recursos

```cpp
// Memory Usage
Total Flash: 4MB
├── Firmware: ~1.2MB
├── SPIFFS/LittleFS: ~2.5MB (não usado)
└── OTA Partition: ~1.3MB

Total RAM: 520KB  
├── System: ~80KB
├── WiFi/MQTT: ~40KB
├── LVGL: ~64KB (configurado)
├── JSON Buffers: ~20KB
├── Screens/UI: ~50KB (dinâmico)
└── Free Heap: ~266KB (típico)
```

### 7.3 Performance Benchmarks

```cpp
// Typical Performance Metrics
Screen Transition Time: 0.8s average (max 2.1s)
Touch Response Time: 30ms average (max 85ms)  
MQTT Message Processing: <100ms
Config Hot Reload Time: 1.2s average
UI Refresh Rate: 33fps (30ms refresh period)
WiFi Connection Time: 5-15s
MQTT Connection Time: 2-5s
```

### 7.4 Limitações do Sistema

```cpp
// Configuração Máxima (DeviceConfig.h)
#define MAX_SCREENS 20                // Máximo de telas
#define MAX_ITEMS_PER_SCREEN 50       // Máximo de itens por tela
#define JSON_DOCUMENT_SIZE 20480      // 20KB por configuração
#define MQTT_BUFFER_SIZE 20480        // 20KB por mensagem MQTT

// Limitações Práticas
- Máximo ~15 telas complexas (com muitos itens)
- Configuração JSON não pode exceder 20KB
- Máximo ~200 itens UI total (limitação de memória)
- Touch screen funciona melhor com elementos >40px
```

### 7.5 Configurações de Produção

```cpp
// Production Settings (DeviceConfig.h)
#define DEBUG_LEVEL 1                 // Apenas errors em produção
#define ENABLE_OTA true               // OTA habilitado
#define ENABLE_WEB_CONFIG false       // Web config desabilitado
#define ENABLE_SOUND true             // Som habilitado
#define WIFI_TIMEOUT 30000           // 30s timeout WiFi
#define MQTT_RECONNECT_DELAY 5000    // 5s delay reconnect
#define STATUS_REPORT_INTERVAL 30000  // Status a cada 30s
```

---

## 8. Diagramas de Sistema

### 8.1 Arquitetura de Comunicação

```mermaid
graph TB
    subgraph "ESP32 HMI Display"
        A[ESP32-2432S028R]
        B[ILI9341 Display 320x240]
        C[XPT2046 Touch]
        D[Physical Buttons x3]
        E[RGB Status LEDs]
        F[WiFi 802.11n]
    end
    
    subgraph "Network Layer"
        G[WiFi Router<br/>SSID: Lee]
        H[MQTT Broker<br/>10.0.10.100:1883]
        I[REST API<br/>10.0.10.100:8081]
    end
    
    subgraph "AutoCore Gateway"
        J[Config Manager]
        K[Device Registry] 
        L[Relay Controller]
        M[Preset System]
    end
    
    subgraph "Controlled Devices"
        N[Relay Board 1<br/>16 channels]
        O[Relay Board 2<br/>16 channels]
        P[Sensor Boards]
    end
    
    A --> F
    F --> G
    G --> H
    G --> I
    
    H --> J
    I --> J
    J --> K
    J --> L
    J --> M
    
    L --> N
    L --> O
    L --> P
    
    A -.->|Touch/Button Input| B
    A -.->|Visual Feedback| E
```

### 8.2 Fluxo de Configuração Dinâmica

```mermaid
sequenceDiagram
    participant D as HMI Display
    participant G as Gateway
    participant A as REST API
    participant M as MQTT Broker
    participant R as Relay Boards
    
    Note over D,R: Sistema de Configuração Híbrida (API + MQTT)
    
    D->>A: GET /api/config/full
    alt API Success
        A->>D: Configuration JSON (20KB)
        D->>D: Parse & Build UI
        D->>M: Config ACK (MQTT)
    else API Failed  
        D->>M: Config Request (MQTT)
        G->>M: Config Response (Retained)
        M->>D: Configuration JSON
        D->>D: Parse & Build UI
        D->>M: Config ACK (MQTT)
    end
    
    Note over D,R: Hot Reload Process
    
    G->>M: Updated Config (Retained)
    M->>D: New Configuration
    D->>D: Hot Reload UI (1.2s)
    D->>M: Hot Reload ACK
    D->>D: Flash Green LED (Visual Feedback)
    
    Note over D,R: Device Control Flow
    
    D->>D: User Touch/Button Press
    D->>M: Relay Command (QoS 1)
    M->>R: Forward Command
    R->>M: Command Response
    M->>D: Response Confirmation
    D->>D: Update UI State
```

### 8.3 Arquitetura de Software Interna

```mermaid
classDiagram
    class Main {
        +setup()
        +loop()
        -setupWiFi()
        -setupMQTT()
        -setupDisplay()
        -setupUI()
    }
    
    class ConfigManager {
        -JsonDocument config
        -String configVersion
        +hasConfig() bool
        +getConfig() JsonDocument
        +setConfig() void
    }
    
    class ScreenManager {
        -map screens
        -ScreenBase currentScreen
        +showScreen() bool
        +buildFromConfig() void
        +navigateTo() void
    }
    
    class MQTTClient {
        -PubSubClient client
        -String deviceId
        +connect() bool
        +publish() bool
        +subscribe() bool
        +loop() void
    }
    
    class TouchHandler {
        -XPT2046_Touchscreen touchscreen
        -calibration values
        +begin() bool
        +read() static void
        +setCalibration() void
    }
    
    class Navigator {
        -ScreenManager screenManager
        -String currentScreen
        -vector screenHistory
        +navigateToScreen() void
        +navigatePrevious() void
        +select() void
    }
    
    class ConfigReceiver {
        -MQTTClient mqttClient
        -ConfigManager configManager
        -ScreenApiClient apiClient
        +begin() void
        +loadConfiguration() bool
        +enableHotReload() void
    }
    
    class ScreenApiClient {
        -HTTPClient httpClient
        -String baseUrl
        -String cachedConfig
        +begin() bool
        +loadConfiguration() bool
        +testConnection() bool
    }
    
    Main ||--|| ConfigManager : uses
    Main ||--|| ScreenManager : uses  
    Main ||--|| MQTTClient : uses
    Main ||--|| TouchHandler : uses
    Main ||--|| Navigator : uses
    ConfigReceiver ||--|| ConfigManager : updates
    ConfigReceiver ||--|| MQTTClient : uses
    ConfigReceiver ||--|| ScreenApiClient : uses
    ScreenManager ||--|| Navigator : managed by
    Navigator ||--|| ScreenManager : controls
```

### 8.4 Estados do Sistema

```mermaid
stateDiagram-v2
    [*] --> Initializing
    
    Initializing --> ConnectingWiFi : WiFi Setup
    ConnectingWiFi --> ConnectingMQTT : WiFi OK
    ConnectingWiFi --> Error : WiFi Failed
    
    ConnectingMQTT --> LoadingConfig : MQTT Connected
    ConnectingMQTT --> Error : MQTT Failed
    
    LoadingConfig --> BuildingUI : Config Loaded (API or MQTT)
    LoadingConfig --> WaitingConfig : No Config Available
    
    BuildingUI --> Operational : UI Built Successfully
    BuildingUI --> Error : UI Build Failed
    
    WaitingConfig --> LoadingConfig : Config Received
    WaitingConfig --> Error : Config Timeout
    
    Operational --> HotReload : Config Update Received
    HotReload --> Operational : Reload Complete
    HotReload --> Error : Reload Failed
    
    Operational --> Disconnected : Connection Lost
    Disconnected --> ConnectingMQTT : Reconnection Success
    Disconnected --> Error : Reconnection Failed
    
    Error --> Initializing : System Reset
    
    state Operational {
        [*] --> Home
        Home --> MenuNavigation : User Input
        MenuNavigation --> Home : Home Button
        MenuNavigation --> DeviceControl : Select Item
        DeviceControl --> Home : Back Button
        DeviceControl --> MenuNavigation : Navigation
    }
```

---

## 📊 Resumo da Análise

### 🎯 Filosofia do Display: Dispositivo Read-Only

O ESP32-display foi projetado como um **dispositivo puramente de exibição e controle**, sem capacidade de modificar configurações. Ele:
- **CONSOME** configurações do gateway/API
- **RENDERIZA** interfaces baseadas nestas configurações
- **ENVIA** comandos para outros dispositivos
- **REPORTA** seu status e telemetria
- **NUNCA** cria, modifica ou deleta configurações

### ✅ Pontos Fortes do Sistema

1. **Arquitetura Read-Only**: Display focado apenas em renderização e controle
2. **Configuração Centralizada**: Todas as configurações gerenciadas pelo gateway
3. **Hot Reload**: Recebe e aplica novas configurações sem reinicialização
4. **Protocolo Robusto**: MQTT v2.2.0 para comunicação em tempo real
5. **UI Dinâmica**: Renderiza qualquer interface baseada em JSON recebido
6. **Simplicidade**: Display não precisa de lógica de negócio complexa

### ⚠️ Pontos de Atenção

1. **Dependência Total do Gateway**: Display não funciona sem receber configuração
2. **Sem Autonomia**: Não pode tomar decisões ou criar configurações próprias
3. **Conectividade Crítica**: Requer WiFi/MQTT constantemente para operação
4. **Limitação de Memória**: Configurações recebidas limitadas a 20KB
5. **Sem Persistência Local**: Perde configuração ao reiniciar (precisa solicitar novamente)

### 🎯 Casos de Uso Ideais

- **Painéis de Controle**: Interface de visualização e comando sem lógica própria
- **Displays Remotos**: Terminais que apenas exibem informações centralizadas
- **Interfaces Multi-usuário**: Vários displays idênticos consumindo mesma config
- **Sistemas Gerenciados**: Onde toda inteligência está no servidor/gateway
- **Aplicações IoT**: Dispositivos simples que apenas renderizam e enviam comandos

### 📈 Métricas de Performance

```
Tempo de Boot Completo: ~15-20 segundos
Tempo de Hot Reload: ~1.2 segundos  
Latência de Comando: <200ms
Capacidade Máxima: 20 telas, 50 itens/tela
Consumo de Memória: ~254KB RAM utilizada
Autonomia: Limitada pela fonte de alimentação (5V USB)
```

---

**Versão da Análise**: 1.0  
**Data**: Agosto 2025  
**Firmware Analisado**: AutoCore HMI Display v2.0.0  
**Protocolo**: MQTT v2.2.0