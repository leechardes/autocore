#ifndef NAV_BUTTON_H
#define NAV_BUTTON_H

#include <lvgl.h>
#include <Arduino.h>
#include <functional>

class NavButton {
public:
    enum ButtonType {
        TYPE_NAVIGATION,
        TYPE_RELAY,
        TYPE_ACTION,
        TYPE_MODE,
        TYPE_DISPLAY,
        TYPE_SWITCH,    // Novo: Para switches nativos LVGL
        TYPE_GAUGE      // Novo: Para gauges/meters
    };

private:
    lv_obj_t* button;
    lv_obj_t* icon;
    lv_obj_t* label;
    String id;
    String target;
    bool isOn = false;
    std::function<void(NavButton*)> clickCallback;
    
    // Configurações para comandos
    ButtonType buttonType = TYPE_NAVIGATION;
    String deviceId;        // Device alvo (ex: "relay_board_1")
    int channel = 0;        // Canal do relé
    String mode;            // "toggle" ou "momentary"
    String actionType;      // Para botões de ação
    String preset;          // Para presets
    String modeValue;       // Para modos 4x4
    
    // For momentary buttons
    bool isPressed = false;          // Estado atual do botão momentâneo
    unsigned long pressStartTime = 0; // Quando o botão foi pressionado
    String targetDevice;             // UUID do dispositivo alvo
    String functionType = "toggle";  // "toggle" ou "momentary"
    
    // Para display items
    String dataSource;      // Fonte dos dados (can, sensors, etc)
    String dataPath;        // Caminho dos dados
    String dataUnit;        // Unidade dos dados
    
    // Para widgets nativos LVGL (switches, gauges)
    lv_obj_t* lvglWidget = nullptr;  // Widget LVGL nativo (switch, meter, etc)
    lv_obj_t* valueLabel = nullptr;  // Label para exibir valores (displays, gauges)
    
    // Controle de debounce para comandos
    unsigned long lastCommandTime = 0;
    static const unsigned long COMMAND_DEBOUNCE_MS = 800; // 800ms entre comandos para evitar múltiplos
    
    void createLayout(const String& text, const String& iconId);
    void applyTheme();
    
public:
    NavButton(lv_obj_t* parent, const String& text, const String& iconId, const String& buttonId = "");
    ~NavButton();
    
    void setTarget(const String& targetScreen) { target = targetScreen; }
    String getTarget() const { return target; }
    
    void setId(const String& buttonId) { id = buttonId; }
    String getId() const { return id; }
    
    void setClickCallback(std::function<void(NavButton*)> callback) {
        Serial.printf("[NavButton] setClickCallback called for button: %s\n", id.c_str());
        clickCallback = callback;
        Serial.printf("[NavButton] Callback set successfully! Has callback: %s\n", 
                     clickCallback ? "YES" : "NO");
    }
    
    void setState(bool on);
    bool getState() const { return isOn; }
    
    lv_obj_t* getObject() { return button; }
    
    void updateStyle();
    
    // Configuração de tipo e dados
    void setButtonType(ButtonType type) { buttonType = type; }
    ButtonType getButtonType() const { return buttonType; }
    
    // Configuração para relés
    void setRelayConfig(const String& device, int ch, const String& m) {
        deviceId = device;
        channel = ch;
        mode = m;
        functionType = m;  // Garantir que functionType também é setado
    }
    
    // Configuração para ações/presets
    void setActionConfig(const String& action, const String& p) {
        actionType = action;
        preset = p;
    }
    
    // Configuração para modos
    void setModeConfig(const String& m) {
        modeValue = m;
    }
    
    // Configuração para display items
    void setDisplayConfig(const String& source, const String& path, const String& unit) {
        dataSource = source;
        dataPath = path;
        dataUnit = unit;
    }
    
    // Configuração para botões momentâneos
    void setMomentaryConfig(const String& device, int ch, const String& funcType) {
        targetDevice = device;
        channel = ch;
        functionType = funcType;
        mode = funcType; // Backward compatibility
    }
    
    // Getters
    String getDeviceId() const { return deviceId; }
    int getChannel() const { return channel; }
    String getMode() const { return mode; }
    String getActionType() const { return actionType; }
    String getPreset() const { return preset; }
    String getModeValue() const { return modeValue; }
    String getDataSource() const { return dataSource; }
    String getDataPath() const { return dataPath; }
    String getDataUnit() const { return dataUnit; }
    
    // Momentary button getters
    String getTargetDevice() const { return targetDevice; }
    String getFunctionType() const { return functionType; }
    bool getIsPressed() const { return isPressed; }
    unsigned long getPressStartTime() const { return pressStartTime; }
    
    // Momentary button setters
    void setPressed(bool pressed) { 
        isPressed = pressed; 
        if (pressed) {
            pressStartTime = millis();
        } else {
            pressStartTime = 0;
        }
    }
    
    // Controle de debounce
    bool canSendCommand() {
        unsigned long now = millis();
        if (now - lastCommandTime >= COMMAND_DEBOUNCE_MS) {
            lastCommandTime = now;
            return true;
        }
        return false;
    }
    
    // Novos métodos para widgets LVGL nativos
    void setLVGLObject(lv_obj_t* obj) { lvglWidget = obj; }
    lv_obj_t* getLVGLObject() { return lvglWidget; }
    
    void setValueLabel(lv_obj_t* label) { valueLabel = label; }
    lv_obj_t* getValueLabel() { return valueLabel; }
};

// Forward declarations for debug functions
enum NavButtonColorIndex {
    NAVBUTTON_COLOR_IDX_BUTTON = 0,
    NAVBUTTON_COLOR_IDX_ICON = 1,
    NAVBUTTON_COLOR_IDX_LABEL = 2
};

// Debug function declaration
void applyNavButtonDebugBorder(lv_obj_t* obj, NavButtonColorIndex colorIndex, const String& elementType,
                               const String& name, const String& label, const String& icon, const String& sizeConfig);

#endif