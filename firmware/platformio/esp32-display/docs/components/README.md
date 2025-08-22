# Components - Componentes do Sistema

Este diretório contém a documentação detalhada de todos os componentes principais do firmware ESP32.

## 🧩 Visão Geral dos Componentes

### Arquitetura por Camadas
```
Core Components (Núcleo)
├── MQTTClient          # Cliente MQTT principal
├── ConfigManager       # Gerenciamento configurações
├── Logger              # Sistema de logging
└── MQTTProtocol        # Protocolo base MQTT

UI Components (Interface)
├── ScreenManager       # Gerenciamento telas
├── ScreenFactory       # Factory de componentes
├── NavButton           # Botões interativos
├── TouchHandler        # Processamento touch
├── IconManager         # Gerenciamento ícones
└── DataBinder          # Vinculação dados

Communication (Comunicação)
├── CommandSender       # Envio comandos MQTT
├── StatusReporter      # Relatórios status
├── ButtonStateManager  # Sincronização estados
├── ConfigReceiver      # Recepção configurações
└── ScreenApiClient     # Cliente API REST

Network (Rede)
├── DeviceRegistration  # Registro dispositivo
└── WiFi Management     # Gerenciamento WiFi

Utilities (Utilitários)
├── DeviceUtils         # Utilitários dispositivo
├── StringUtils         # Manipulação strings
└── DeviceModels        # Modelos de dados
```

## 📋 Documentação Disponível

- [`screen-factory.md`](screen-factory.md) - Factory de criação dinâmica
- [`command-sender.md`](command-sender.md) - Sistema de envio de comandos
- [`touch-handler.md`](touch-handler.md) - Processamento de entrada touch
- [`device-config.md`](device-config.md) - Configuração de dispositivos
- [`api-client.md`](api-client.md) - Cliente API REST

## 🔧 Core Components

### MQTTClient
**Responsabilidade**: Cliente MQTT com protocolo v2.2.0  
**Arquivo**: `include/core/MQTTClient.h`

```cpp
class MQTTClient {
public:
    bool connect();
    bool isConnected();
    bool publish(const String& topic, const String& payload);
    bool publish(const String& topic, JsonDocument& doc, int qos = 0);
    bool subscribe(const String& topic, int qos, MQTT_CALLBACK_SIGNATURE);
    void loop();
    bool loadDynamicCredentials();
};
```

**Características**:
- Conexão automática com retry
- Credenciais dinâmicas via API
- QoS configurável por tipo de mensagem
- Heartbeat automático para comandos momentários

### ConfigManager
**Responsabilidade**: Gerenciamento de configurações NVS  
**Arquivo**: `include/core/ConfigManager.h`

```cpp
class ConfigManager {
public:
    bool loadConfiguration();
    bool saveConfiguration(JsonDocument& config);
    String getConfigValue(const String& key);
    void setConfigValue(const String& key, const String& value);
    bool hasConfiguration();
};
```

**Características**:
- Armazenamento persistente em NVS
- Backup/restore de configurações
- Validação de integridade
- Merge de configurações múltiplas

### Logger
**Responsabilidade**: Sistema de logging unificado  
**Arquivo**: `include/core/Logger.h`

```cpp
class Logger {
public:
    void error(const String& message);
    void warning(const String& message);
    void info(const String& message);
    void debug(const String& message);
    void setLevel(LogLevel level);
    void enableRemoteLogging(bool enable);
};
```

**Características**:
- Múltiplos níveis de log
- Saída para Serial/MQTT/File
- Timestamp automático
- Filtragem por nível

## 🎨 UI Components

### ScreenFactory
**Responsabilidade**: Criação dinâmica de telas e componentes  
**Arquivo**: `include/ui/ScreenFactory.h`

```cpp
class ScreenFactory {
public:
    static std::unique_ptr<ScreenBase> createScreen(JsonObject& config);
    static NavButton* createRelayItem(lv_obj_t* parent, JsonObject& config);
    static NavButton* createActionItem(lv_obj_t* parent, JsonObject& config);
    static NavButton* createSwitchItem(lv_obj_t* parent, JsonObject& config);
    static NavButton* createGaugeItem(lv_obj_t* parent, JsonObject& config);
};
```

**Tipos Suportados**:
- **relay**: Controle de relays
- **action**: Ações e presets
- **navigation**: Navegação entre telas
- **display**: Exibição de dados
- **switch**: Switches nativos LVGL
- **gauge**: Medidores e indicadores

### ScreenManager
**Responsabilidade**: Gerenciamento de telas ativas  
**Arquivo**: `include/ui/ScreenManager.h`

```cpp
class ScreenManager {
public:
    void loadScreen(const String& screenId);
    void navigateToScreen(const String& screenId);
    void setCurrentScreen(ScreenBase* screen);
    ScreenBase* getCurrentScreen();
    void updateAllWidgets();
};
```

**Características**:
- Navegação com histórico
- Transições suaves
- Cleanup automático
- Cache de telas frequentes

### TouchHandler
**Responsabilidade**: Processamento de entrada touch  
**Arquivo**: `include/input/TouchHandler.h`

```cpp
class TouchHandler {
public:
    void init();
    void calibrate();
    static void touchpad_read(lv_indev_drv_t* drv, lv_indev_data_t* data);
private:
    XPT2046_Touchscreen* touchscreen;
    int16_t touch_cal_x1, touch_cal_x2;
    int16_t touch_cal_y1, touch_cal_y2;
};
```

**Características**:
- Calibração automática
- Filtragem de ruído
- Múltiplas orientações
- Debouncing inteligente

## 📡 Communication Components

### CommandSender
**Responsabilidade**: Envio de comandos MQTT  
**Arquivo**: `include/commands/CommandSender.h`

```cpp
class CommandSender {
public:
    bool sendCommand(NavButton* button);
    bool sendRelayCommand(const String& targetUuid, int channel, 
                         const String& state, const String& functionType);
    bool sendPresetCommand(const String& preset);
    bool sendModeCommand(const String& mode);
    void processHeartbeats();
};
```

**Tipos de Comando**:
- **Relay Control**: Toggle e momentary
- **Preset Execution**: Cenários pré-definidos
- **Mode Selection**: Modos de operação
- **System Actions**: Ações de sistema

### ButtonStateManager
**Responsabilidade**: Sincronização de estados via MQTT  
**Arquivo**: `include/communication/ButtonStateManager.h`

```cpp
class ButtonStateManager {
public:
    void subscribeToTopics();
    void registerButton(NavButton* button);
    void handleMQTTMessage(const String& topic, JsonDocument& payload);
    void updateButtonState(const String& deviceId, int channel, bool state);
};
```

**Características**:
- Auto-subscrição em tópicos relevantes
- Sincronização em tempo real
- Cache de estados
- Fallback para API REST

### ScreenApiClient
**Responsabilidade**: Cliente API REST para configurações  
**Arquivo**: `include/network/ScreenApiClient.h`

```cpp
class ScreenApiClient {
public:
    bool loadConfiguration();
    bool requestConfiguration(const String& configType);
    bool sendDeviceStatus();
    String getBaseUrl();
    bool isConfigured();
};
```

**Endpoints Suportados**:
- `/api/v1/devices/{uuid}/config` - Configuração
- `/api/v1/devices/{uuid}/status` - Status
- `/api/v1/devices/register` - Registro
- `/api/v1/icons/mapping` - Ícones

## 🔧 Utility Components

### DeviceUtils
**Responsabilidade**: Utilitários de dispositivo  
**Arquivo**: `include/utils/DeviceUtils.h`

```cpp
class DeviceUtils {
public:
    static String getDeviceUUID();
    static String getMacAddress();
    static String getChipId();
    static float getTemperature();
    static uint32_t getFreeHeap();
    static String getResetReason();
};
```

### StringUtils
**Responsabilidade**: Manipulação de strings  
**Arquivo**: `include/utils/StringUtils.h`

```cpp
class StringUtils {
public:
    static String trim(const String& str);
    static String sanitize(const String& str);
    static bool isValidUUID(const String& uuid);
    static String formatBytes(size_t bytes);
    static String htmlDecode(const String& str);
};
```

### IconManager
**Responsabilidade**: Gerenciamento de ícones  
**Arquivo**: `include/ui/IconManager.h`

```cpp
class IconManager {
public:
    static const char* getIcon(const String& iconName);
    static bool loadFromApi(ScreenApiClient* apiClient);
    static bool hasIcon(const String& iconName);
    static void addCustomIcon(const String& name, const char* symbol);
};
```

**Ícones Disponíveis**:
- **light**: Lâmpada (\uF0EB)
- **switch**: Power (\uF011)
- **settings**: Engrenagem (\uF013)
- **thermometer**: Temperatura (\uF2C9)
- **wifi**: WiFi (\uF1EB)

## 🔗 Component Interactions

### Startup Sequence
```
1. Hardware Init
   ├── Display/Touch → TouchHandler::init()
   └── WiFi → Network setup

2. Configuration
   ├── NVS → ConfigManager::loadConfiguration()
   ├── API → ScreenApiClient::loadConfiguration()
   └── MQTT → DeviceRegistration

3. UI Setup
   ├── Screens → ScreenFactory::createScreen()
   ├── Buttons → ScreenFactory::createRelayItem()
   └── Events → TouchHandler + NavButton callbacks

4. Communication
   ├── MQTT → MQTTClient::connect()
   ├── Subscriptions → ButtonStateManager::subscribeToTopics()
   └── Status → StatusReporter::sendStatus()
```

### Command Flow
```
Touch Event → TouchHandler
    ↓
NavButton Callback
    ↓
CommandSender::sendCommand()
    ↓
MQTTClient::publish()
    ↓
MQTT Broker
    ↓
Device Response → ButtonStateManager
    ↓
NavButton::setState()
```

### Configuration Flow
```
API Request → ScreenApiClient
    ↓
JSON Processing → ConfigManager
    ↓
Screen Creation → ScreenFactory
    ↓
UI Update → ScreenManager
    ↓
Event Binding → TouchHandler + NavButton
```

## 🚀 Performance Optimizations

### Memory Management
- **Object Pooling**: NavButton reuse
- **Lazy Loading**: Screens on-demand
- **Memory Pools**: Reduced fragmentation
- **Smart Pointers**: Automatic cleanup

### CPU Optimizations
- **Task Prioritization**: UI > Communication > Background
- **Event Batching**: Multiple LVGL events
- **Caching**: Frequent configurations
- **Debouncing**: Reduced command spam

### Network Optimizations
- **Connection Pooling**: HTTP keep-alive
- **Compression**: GZIP for API calls
- **Caching**: Configuration and icons
- **Fallback**: MQTT → API → Local

## 🔍 Testing Strategy

### Unit Tests
```cpp
// Exemplo: CommandSender tests
void test_relay_command_generation() {
    CommandSender sender(mockMQTT, mockLogger, "test-device");
    bool result = sender.sendRelayCommand("relay-1", 1, "ON", "toggle");
    assert(result == true);
    assert(mockMQTT.lastTopic == "autocore/devices/relay-1/relays/set");
}
```

### Integration Tests
- **MQTT Communication**: End-to-end command flow
- **UI Interactions**: Touch → Command → Response
- **Configuration Loading**: API → Factory → Screen
- **Error Handling**: Network failures, invalid data

### Hardware Tests
- **Touch Calibration**: Accuracy verification
- **Display Performance**: Refresh rate, memory usage
- **WiFi Reliability**: Connection stability
- **Power Management**: Current consumption