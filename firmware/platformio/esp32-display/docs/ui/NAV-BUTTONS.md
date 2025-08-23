# NavButton System - Sistema de Botões Interativos

## 🎯 Visão Geral

O sistema NavButton é o componente principal de interação do firmware, fornecendo botões inteligentes e responsivos para controle de dispositivos, navegação e exibição de informações.

## 🏗️ Arquitetura NavButton

### Classe Principal
```cpp
class NavButton {
public:
    enum ButtonType {
        TYPE_NAVIGATION,    // Navegação entre telas
        TYPE_RELAY,         // Controle de relays
        TYPE_ACTION,        // Ações específicas
        TYPE_MODE,          // Seleção de modo
        TYPE_DISPLAY,       // Exibição de dados
        TYPE_SWITCH,        // Switches nativos LVGL
        TYPE_GAUGE          // Medidores/indicadores
    };
    
    // Construtores e métodos principais...
};
```

### Estrutura Interna
```cpp
// Componentes LVGL
lv_obj_t* button;       // Container principal
lv_obj_t* icon;         // Ícone do botão
lv_obj_t* label;        // Texto do botão
lv_obj_t* lvglWidget;   // Widget LVGL nativo (para switches/gauges)
lv_obj_t* valueLabel;   // Label para valores (displays)

// Configuração
String id;              // Identificador único
String target;          // Tela/dispositivo alvo
ButtonType buttonType;  // Tipo do botão
bool isOn;             // Estado atual
```

## 🎛️ Tipos de Botão Detalhados

### 1. Navigation Buttons
**Propósito**: Navegação entre telas da interface

```cpp
// Criação
NavButton* navBtn = new NavButton(parent, "Settings", "settings", "nav_settings");
navBtn->setButtonType(NavButton::TYPE_NAVIGATION);
navBtn->setTarget("settings_screen");

// Callback
navBtn->setClickCallback([](NavButton* btn) {
    screenManager->navigateToScreen(btn->getTarget());
});
```

**Características**:
- Transições suaves entre telas
- Ícones representativos
- Feedback visual durante navegação

### 2. Relay Control Buttons
**Propósito**: Controle de relays e dispositivos externos

```cpp
// Toggle Relay
NavButton* relayBtn = new NavButton(parent, "Sala", "light", "relay_1");
relayBtn->setButtonType(NavButton::TYPE_RELAY);
relayBtn->setRelayConfig("relay_board_1", 1, "toggle");

// Momentary Relay
NavButton* momentaryBtn = new NavButton(parent, "Portão", "gate", "gate_btn");
momentaryBtn->setButtonType(NavButton::TYPE_RELAY);
momentaryBtn->setMomentaryConfig("relay_board_1", 2, "momentary");
```

**Modos de Operação**:
- **Toggle**: Liga/desliga e mantém estado
- **Momentary**: Liga apenas enquanto pressionado

**Heartbeat System**:
```cpp
// Para botões momentários
void startHeartbeat(const String& targetUuid, int channel);
void sendHeartbeat(const String& targetUuid, int channel);
void stopHeartbeat(int channel);

// Configuração
#define HEARTBEAT_INTERVAL_MS 500    // 500ms entre heartbeats
#define HEARTBEAT_TIMEOUT_MS 1000    // Timeout de resposta
```

### 3. Action Buttons
**Propósito**: Execução de ações específicas e presets

```cpp
// Preset Action
NavButton* presetBtn = new NavButton(parent, "Noite", "moon", "night_preset");
presetBtn->setButtonType(NavButton::TYPE_ACTION);
presetBtn->setActionConfig("preset", "living_room_evening");

// System Action
NavButton* actionBtn = new NavButton(parent, "Emergência", "warning", "emergency");
actionBtn->setButtonType(NavButton::TYPE_ACTION);
actionBtn->setActionConfig("action", "emergency_stop");
```

**Tipos de Ação**:
- **Presets**: Cenários pré-configurados
- **System Actions**: Ações de sistema (restart, backup, etc.)
- **Custom Actions**: Ações personalizadas

### 4. Mode Selection Buttons
**Propósito**: Seleção de modos de operação

```cpp
NavButton* modeBtn = new NavButton(parent, "Modo Noite", "moon", "night_mode");
modeBtn->setButtonType(NavButton::TYPE_MODE);
modeBtn->setModeConfig("night_mode");
```

**Modos Comuns**:
- `"normal_mode"` - Operação normal
- `"night_mode"` - Modo noturno
- `"eco_mode"` - Economia de energia
- `"security_mode"` - Modo segurança

### 5. Display Items
**Propósito**: Exibição de informações e dados

```cpp
NavButton* displayBtn = new NavButton(parent, "Temperatura", "thermometer", "temp_display");
displayBtn->setButtonType(NavButton::TYPE_DISPLAY);
displayBtn->setDisplayConfig("sensors", "temperature", "°C");
```

**Fontes de Dados**:
- **sensors**: Sensores conectados
- **can**: Dados CAN bus
- **system**: Métricas do sistema
- **external**: APIs externas

### 6. Native LVGL Widgets

#### Switch Widgets
```cpp
NavButton* switchBtn = ScreenFactory::createSwitchItem(parent, config);
switchBtn->setButtonType(NavButton::TYPE_SWITCH);

// Widget LVGL nativo
lv_obj_t* lvSwitch = switchBtn->getLVGLObject();
lv_obj_add_state(lvSwitch, LV_STATE_CHECKED);  // Ligar switch
```

#### Gauge Widgets
```cpp
NavButton* gaugeBtn = ScreenFactory::createGaugeItem(parent, config);
gaugeBtn->setButtonType(NavButton::TYPE_GAUGE);

// Configuração JSON
{
  "type": "gauge",
  "gauge_type": "circular",
  "min_value": 0,
  "max_value": 100,
  "unit": "%",
  "ranges": [
    {"min": 0, "max": 30, "color": "#4CAF50"},
    {"min": 30, "max": 70, "color": "#FFC107"},
    {"min": 70, "max": 100, "color": "#F44336"}
  ]
}
```

## 🎨 Sistema Visual

### Layout Structure
```cpp
// Estrutura padrão NavButton
Container (button)
├── Icon Container
│   └── Icon (symbol/image)
├── Content Container
│   ├── Label (texto principal)
│   ├── Value Label (para displays)
│   └── LVGL Widget (para switches/gauges)
└── Status Indicator (opcional)
```

### Styling
```cpp
// Estados visuais
LV_STATE_DEFAULT     // Estado normal
LV_STATE_CHECKED     // Estado ligado/ativo
LV_STATE_PRESSED     // Pressionado
LV_STATE_DISABLED    // Desabilitado

// Cores dinâmicas
void updateStyle() {
    if (isOn) {
        lv_obj_set_style_bg_color(button, lv_color_hex(0x4CAF50), LV_STATE_DEFAULT);
    } else {
        lv_obj_set_style_bg_color(button, lv_color_hex(0x757575), LV_STATE_DEFAULT);
    }
}
```

### Icon System
```cpp
// Icon Manager integration
class IconManager {
public:
    static const char* getIcon(const String& iconName);
    static bool loadFromApi(ScreenApiClient* apiClient);
    
    // Ícones comuns
    static const char* ICON_LIGHT;      // "\uF0EB" (lâmpada)
    static const char* ICON_SWITCH;     // "\uF011" (power)
    static const char* ICON_TEMP;       // "\uF2C9" (termômetro)
    static const char* ICON_SETTINGS;   // "\uF013" (engrenagem)
};
```

## 🔧 Sistema de Eventos

### Event Handling
```cpp
// Callback principal
void setClickCallback(std::function<void(NavButton*)> callback) {
    clickCallback = callback;
}

// Event interno LVGL
static void buttonEventHandler(lv_event_t* e) {
    NavButton* navBtn = (NavButton*)lv_event_get_user_data(e);
    lv_event_code_t code = lv_event_get_code(e);
    
    switch (code) {
        case LV_EVENT_PRESSED:
            navBtn->handlePress();
            break;
        case LV_EVENT_RELEASED:
            navBtn->handleRelease();
            break;
        case LV_EVENT_LONG_PRESSED:
            navBtn->handleLongPress();
            break;
    }
}
```

### Touch States
```cpp
// Para botões momentários
void setPressed(bool pressed) {
    isPressed = pressed;
    if (pressed) {
        pressStartTime = millis();
        // Enviar comando ON
    } else {
        pressStartTime = 0;
        // Enviar comando OFF
    }
}
```

### Debouncing
```cpp
// Controle de debounce
bool canSendCommand() {
    unsigned long now = millis();
    if (now - lastCommandTime >= COMMAND_DEBOUNCE_MS) {
        lastCommandTime = now;
        return true;
    }
    return false;
}

// Configuração
static const unsigned long COMMAND_DEBOUNCE_MS = 800; // 800ms
```

## 📊 Data Binding

### Display Updates
```cpp
// Atualização de dados para display items
void updateDisplayValue(const String& newValue) {
    if (valueLabel) {
        String displayText = newValue;
        if (!dataUnit.isEmpty()) {
            displayText += " " + dataUnit;
        }
        lv_label_set_text(valueLabel, displayText.c_str());
    }
}

// Data binding via DataBinder
DataBinder::bindWidget(this, dataSource, dataPath);
```

### State Synchronization
```cpp
// Sincronização de estado com MQTT
void ButtonStateManager::updateButtonState(const String& deviceId, 
                                          int channel, bool state) {
    for (auto& button : registeredButtons) {
        if (button->getDeviceId() == deviceId && 
            button->getChannel() == channel) {
            button->setState(state);
            button->updateStyle();
        }
    }
}
```

## 🔒 Segurança e Validação

### Input Validation
```cpp
// Validação de configuração
bool validateConfig(JsonObject& config) {
    if (!config["type"].is<String>()) return false;
    if (!config["id"].is<String>()) return false;
    
    String type = config["type"];
    if (type == "relay") {
        if (!config["device_id"].is<String>()) return false;
        if (!config["channel"].is<int>()) return false;
        if (config["channel"] < 1 || config["channel"] > 16) return false;
    }
    
    return true;
}
```

### Access Control
```cpp
// Controle de acesso por tipo
bool hasPermission(ButtonType type, const String& action) {
    switch (type) {
        case TYPE_RELAY:
            return checkRelayPermission(action);
        case TYPE_MODE:
            return checkModePermission(action);
        default:
            return true;
    }
}
```

## 🚀 Performance

### Memory Management
```cpp
// Destructor
NavButton::~NavButton() {
    if (button) {
        lv_obj_del(button);
    }
    // LVGL handles cleanup of child objects
}

// Object pooling para performance
class NavButtonPool {
    static std::vector<NavButton*> availableButtons;
    static NavButton* getButton();
    static void returnButton(NavButton* btn);
};
```

### Optimization Tips
1. **Reutilizar objetos** quando possível
2. **Limitar animações** simultâneas
3. **Cache de ícones** para performance
4. **Debouncing adequado** para evitar spam
5. **Cleanup automático** de objetos não usados

## 🔍 Debug e Troubleshooting

### Debug Features
```cpp
// Debug visual com bordas coloridas
void applyNavButtonDebugBorder(lv_obj_t* obj, NavButtonColorIndex colorIndex, 
                               const String& elementType, const String& name) {
    // Aplicar borda colorida para debug
    lv_color_t debugColor = getDebugColor(colorIndex);
    lv_obj_set_style_border_color(obj, debugColor, LV_STATE_DEFAULT);
    lv_obj_set_style_border_width(obj, 2, LV_STATE_DEFAULT);
}

// Logging detalhado
void logButtonEvent(const String& event, const String& details) {
    logger->debug("[NavButton:" + id + "] " + event + " - " + details);
}
```

### Common Issues
1. **Callback não funciona**: Verificar se foi setado corretamente
2. **Estado não atualiza**: Confirmar sincronização MQTT
3. **Memory leaks**: Verificar destructor e cleanup
4. **Touch não responde**: Verificar calibração touch
5. **Visual artifacts**: Verificar themes e styling