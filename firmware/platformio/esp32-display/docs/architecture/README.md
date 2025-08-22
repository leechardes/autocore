# Architecture - Arquitetura do Sistema

Este diretório contém toda a documentação sobre a arquitetura e componentes principais do firmware ESP32.

## 🏗️ Visão Geral da Arquitetura

### Estrutura em Camadas
```
┌─────────────────────────────────────┐
│           User Interface            │ <- LVGL UI, NavButtons, Screens
├─────────────────────────────────────┤
│        Application Layer            │ <- Business Logic, Controllers
├─────────────────────────────────────┤
│       Communication Layer          │ <- MQTT, HTTP, WebSocket
├─────────────────────────────────────┤
│         Hardware Layer             │ <- Display, Touch, GPIO
└─────────────────────────────────────┘
```

### Principais Subsistemas
- **UI System**: Interface LVGL e componentes visuais
- **Communication**: MQTT, API REST, WebSocket
- **Device Control**: Controle de relays e dispositivos
- **Configuration**: Gerenciamento de configurações
- **Networking**: WiFi, conectividade e OTA

## 📋 Documentação Disponível

- [`system-architecture.md`](system-architecture.md) - Arquitetura geral do sistema
- [`memory-layout.md`](memory-layout.md) - Layout de memória e heap
- [`task-scheduling.md`](task-scheduling.md) - Agendamento de tarefas FreeRTOS
- [`event-system.md`](event-system.md) - Sistema de eventos e callbacks
- [`state-machine.md`](state-machine.md) - Máquinas de estado principais

## 🧩 Componentes Principais

### Core Components
- **MQTTClient**: Cliente MQTT com protocolo v2.2.0
- **ConfigManager**: Gerenciamento de configurações NVS
- **Logger**: Sistema de logging com níveis
- **DeviceRegistration**: Registro e credenciais dinâmicas

### UI Components
- **ScreenManager**: Gerenciamento de telas
- **ScreenFactory**: Factory para criação dinâmica
- **NavButton**: Botões interativos inteligentes
- **TouchHandler**: Processamento de entrada touch

### Communication Components
- **CommandSender**: Envio de comandos MQTT
- **StatusReporter**: Relatórios de status
- **ButtonStateManager**: Sincronização de estados
- **ScreenApiClient**: Cliente API REST

### Utility Components
- **DeviceUtils**: Utilitários de dispositivo
- **StringUtils**: Manipulação de strings
- **IconManager**: Gerenciamento de ícones
- **DataBinder**: Vinculação de dados

## 🔄 Fluxo de Dados

### Startup Flow
1. **Hardware Init**: Display, Touch, WiFi
2. **Configuration Load**: NVS → ConfigManager
3. **Network Setup**: WiFi → Device Registration
4. **MQTT Connect**: Credenciais → MQTTClient
5. **UI Initialize**: Screens → LVGL → TouchHandler
6. **Ready State**: Sistema operacional

### Command Flow
1. **Touch Event**: TouchHandler → NavButton
2. **Command Generation**: NavButton → CommandSender
3. **MQTT Publish**: CommandSender → MQTTClient
4. **Response Handling**: MQTTClient → ButtonStateManager
5. **UI Update**: ButtonStateManager → NavButton

### Configuration Flow
1. **Config Request**: HTTP API → ScreenApiClient
2. **JSON Processing**: ScreenApiClient → ConfigManager
3. **Screen Creation**: ConfigManager → ScreenFactory
4. **UI Rebuild**: ScreenFactory → ScreenManager

## 🎯 Design Patterns

### Factory Pattern
```cpp
// ScreenFactory cria componentes dinamicamente
std::unique_ptr<ScreenBase> screen = ScreenFactory::createScreen(config);
NavButton* button = ScreenFactory::createRelayItem(parent, config);
```

### Observer Pattern
```cpp
// ButtonStateManager observa mudanças MQTT
void ButtonStateManager::handleMQTTMessage(const String& topic, JsonDocument& payload);

// DataBinder observa mudanças de dados
void DataBinder::updateBoundWidgets(const String& dataPath, const String& newValue);
```

### Singleton Pattern
```cpp
// Logger como singleton global
Logger* logger = Logger::getInstance();

// ConfigManager para configuração global
ConfigManager* configManager = ConfigManager::getInstance();
```

### Command Pattern
```cpp
// CommandSender encapsula comandos
bool CommandSender::sendRelayCommand(const String& targetUuid, int channel, 
                                   const String& state, const String& functionType);
```

## 🧠 Memory Architecture

### Memory Regions
```cpp
// ESP32 Memory Layout
DRAM:     320KB total
  - Heap: ~200KB available
  - Stack: ~8KB per task
  - LVGL: 64KB dedicated
  - Buffers: ~20KB display

IRAM:     128KB (instruction cache)
Flash:    4MB (program + data)
PSRAM:    Optional (external)
```

### Memory Management
- **LVGL Memory Pool**: 64KB heap dedicado
- **Double Buffering**: 2x 7.6KB buffers
- **NVS Storage**: Configurações persistentes
- **Dynamic Allocation**: Para telas e botões

## ⚡ Task Architecture

### FreeRTOS Tasks
```cpp
// Task principal LVGL
void lvgl_task(void* params) {
    while (1) {
        lv_timer_handler();
        vTaskDelay(pdMS_TO_TICKS(10));
    }
}

// Task MQTT
void mqtt_task(void* params) {
    while (1) {
        mqttClient->loop();
        vTaskDelay(pdMS_TO_TICKS(50));
    }
}

// Task Status Reporter
void status_task(void* params) {
    while (1) {
        statusReporter->sendStatus();
        vTaskDelay(pdMS_TO_TICKS(30000));
    }
}
```

### Task Priorities
- **LVGL UI**: Prioridade 2 (responsividade)
- **MQTT**: Prioridade 1 (comunicação)
- **Status**: Prioridade 0 (background)
- **OTA**: Prioridade 3 (quando ativo)

## 🔒 Security Architecture

### Authentication Layers
1. **Device Registration**: UUID + MAC authentication
2. **MQTT Credentials**: Dynamic username/password
3. **API Tokens**: Bearer token para HTTP
4. **TLS Encryption**: Conexões seguras

### Data Validation
```cpp
// Validação de protocolo MQTT
bool MQTTProtocol::validateProtocolVersion(const JsonDocument& doc);

// Validação de configuração
bool ConfigReceiver::validateConfiguration(JsonDocument& config);

// Sanitização de inputs
String StringUtils::sanitizeInput(const String& input);
```

## 📊 Performance Considerations

### Critical Paths
1. **Touch Response**: <50ms touch → visual feedback
2. **MQTT Commands**: <200ms command → device response
3. **Screen Transitions**: <500ms smooth animations
4. **Heartbeat**: 500ms interval para comandos momentários

### Optimization Strategies
- **Object Pooling**: Reutilização de NavButtons
- **Lazy Loading**: Telas criadas sob demanda
- **Memory Pools**: Redução de fragmentação
- **Event Batching**: Agrupamento de eventos LVGL

## 🔧 Configuration Architecture

### Configuration Sources
1. **Compile Time**: DeviceConfig.h constantes
2. **NVS Storage**: Configurações persistentes
3. **HTTP API**: Configurações dinâmicas
4. **MQTT Messages**: Atualizações remotas

### Configuration Hierarchy
```
DeviceConfig.h (defaults)
    ↓
NVS Storage (persistent)
    ↓
HTTP API (dynamic)
    ↓
MQTT Updates (real-time)
```

## 🚀 Scalability Design

### Modular Architecture
- **Plugin System**: Novos tipos de botão
- **Screen Templates**: Layouts reutilizáveis
- **Device Drivers**: Suporte a novos dispositivos
- **Protocol Extensions**: Novos protocolos de comunicação

### Future Extensions
- **Multi-Display**: Suporte a múltiplos displays
- **Mesh Networking**: ESP-NOW para comunicação local
- **Edge Computing**: Processamento local de dados
- **AI Integration**: Reconhecimento de padrões

## 🔍 Debugging Architecture

### Debug Layers
1. **Hardware Debug**: Serial monitor, GPIO states
2. **LVGL Debug**: Visual borders, object inspector
3. **MQTT Debug**: Packet inspection, topic monitoring
4. **Memory Debug**: Heap tracking, leak detection

### Logging System
```cpp
// Níveis de log
enum LogLevel {
    LOG_ERROR,    // Apenas erros críticos
    LOG_WARNING,  // Avisos importantes
    LOG_INFO,     // Informações gerais
    LOG_DEBUG     // Debug detalhado
};

// Saídas configuráveis
- Serial Monitor
- File System (SPIFFS)
- Remote Logging (MQTT)
- Memory Buffer (circular)
```