/**
 * @file ButtonStateManager.cpp
 * @brief Implementação do gerenciador de estado dos botões
 */

#include "communication/ButtonStateManager.h"
#include "NavButton.h"
#include "ui/ScreenManager.h"
#include "core/Logger.h"

extern Logger* logger;

ButtonStateManager* ButtonStateManager::instance = nullptr;

ButtonStateManager::ButtonStateManager(MQTTClient* mqtt, ScreenManager* screen) 
    : mqttClient(mqtt), screenManager(screen) {
    instance = this;
}

void ButtonStateManager::begin() {
    logger->info("Iniciando ButtonStateManager");
    
    // Inscrever nos tópicos de status
    if (mqttClient && mqttClient->isConnected()) {
        // Callback vazio - o processamento é feito em MQTTClient::messageReceived
        auto emptyCallback = [](const String& topic, const String& payload) {
            // Processamento já é feito em MQTTClient::messageReceived
        };
        
        // Status de canais individuais
        mqttClient->subscribe("autocore/devices/+/relays/status", 0, emptyCallback);
        logger->info("Inscrito em: autocore/devices/+/relays/status");
        
        // Status geral das placas
        mqttClient->subscribe("autocore/devices/+/status", 0, emptyCallback);
        logger->info("Inscrito em: autocore/devices/+/status");
        
        // Status do controlador 4x4
        mqttClient->subscribe("autocore/devices/4x4_controller/status", 0, emptyCallback);
        logger->info("Inscrito em: autocore/devices/4x4_controller/status");
        
        // Status de presets
        mqttClient->subscribe("autocore/devices/+/presets/status", 0, emptyCallback);
        logger->info("Inscrito em: autocore/devices/+/presets/status");
    }
    
    logger->info("ButtonStateManager pronto para receber status via MQTTClient");
}

String ButtonStateManager::makeButtonId(NavButton* button) {
    if (!button) return "";
    
    String id = "";
    
    switch (button->getButtonType()) {
        case NavButton::TYPE_RELAY:
            // Para relés: board_id:channel
            id = button->getDeviceId() + ":" + String(button->getChannel());
            break;
            
        case NavButton::TYPE_MODE:
            // Para modos: mode:value
            id = "mode:" + button->getModeValue();
            break;
            
        case NavButton::TYPE_ACTION:
            // Para ações/presets: action:preset_name
            if (button->getActionType() == "preset") {
                id = "preset:" + button->getPreset();
            } else {
                id = "action:" + button->getId();
            }
            break;
            
        default:
            // Usar ID do botão
            id = button->getId();
            break;
    }
    
    return id;
}

void ButtonStateManager::registerButton(NavButton* button) {
    if (!button) return;
    
    String buttonId = makeButtonId(button);
    if (buttonId.isEmpty()) return;
    
    buttonCallbacks[buttonId] = button;
    logger->debug("Botão registrado: " + buttonId);
    
    // Se já temos estado para este botão, atualizar imediatamente
    if (buttonStates.find(buttonId) != buttonStates.end()) {
        notifyButton(buttonId);
    }
}

void ButtonStateManager::unregisterButton(const String& buttonId) {
    buttonCallbacks.erase(buttonId);
    logger->debug("Botão removido: " + buttonId);
}

void ButtonStateManager::processRelayStatus(const String& boardId, int channel, 
                                           const String& state, const String& source) {
    String buttonId = boardId + ":" + String(channel);
    bool active = (state == "ON");
    
    updateButtonState(buttonId, active, state, source);
}

void ButtonStateManager::processModeStatus(const String& mode, bool active, const String& source) {
    String buttonId = "mode:" + mode;
    updateButtonState(buttonId, active, active ? "ACTIVE" : "INACTIVE", source);
}

void ButtonStateManager::processPresetStatus(const String& preset, bool active, const String& source) {
    String buttonId = "preset:" + preset;
    updateButtonState(buttonId, active, active ? "ACTIVE" : "INACTIVE", source);
}

void ButtonStateManager::processGenericStatus(const String& buttonId, bool active, 
                                             const String& value, const String& source) {
    updateButtonState(buttonId, active, value, source);
}

void ButtonStateManager::updateButtonState(const String& buttonId, bool active, 
                                          const String& value, const String& source) {
    // Atualizar estado
    ButtonState& state = buttonStates[buttonId];
    
    // Verificar se mudou
    bool changed = (state.isActive != active) || (state.currentValue != value);
    
    state.isActive = active;
    state.currentValue = value;
    state.lastUpdate = millis();
    state.lastSource = source;
    
    if (changed) {
        logger->info("Estado do botão " + buttonId + " atualizado: " + 
                    (active ? "ATIVO" : "INATIVO") + " (" + source + ")");
        
        // Notificar botão se registrado
        notifyButton(buttonId);
    }
}

void ButtonStateManager::notifyButton(const String& buttonId) {
    auto it = buttonCallbacks.find(buttonId);
    if (it != buttonCallbacks.end() && it->second) {
        NavButton* button = it->second;
        ButtonState& state = buttonStates[buttonId];
        
        // Atualizar estado visual do botão
        button->setState(state.isActive);
        
        logger->debug("Botão " + buttonId + " notificado");
    }
}

ButtonState ButtonStateManager::getButtonState(const String& buttonId) {
    auto it = buttonStates.find(buttonId);
    if (it != buttonStates.end()) {
        return it->second;
    }
    
    // Retornar estado padrão
    ButtonState defaultState;
    defaultState.isActive = false;
    defaultState.currentValue = "";
    defaultState.lastUpdate = 0;
    defaultState.lastSource = "";
    return defaultState;
}

bool ButtonStateManager::isButtonActive(const String& buttonId) {
    auto it = buttonStates.find(buttonId);
    if (it != buttonStates.end()) {
        return it->second.isActive;
    }
    return false;
}

void ButtonStateManager::handleMQTTMessage(const String& topic, JsonDocument& payload) {
    // Parse do tópico para determinar tipo
    if (topic.indexOf("/relays/") > 0 && topic.endsWith("/status")) {
        // Status de relé específico: autocore/devices/{uuid}/relays/status
        int devicesPos = topic.indexOf("/devices/");
        int relaysPos = topic.indexOf("/relays/");
        String deviceId = topic.substring(devicesPos + 9, relaysPos); // Skip "/devices/"
        
        // Extraír informações do payload (agora contém canal/relé)
        int channel = payload["channel"] | payload["relay_id"] | 0;
        String state = payload["state"].as<String>();
        String source = payload["device_id"] | payload["source"] | "unknown";
        
        processRelayStatus(deviceId, channel, state, source);
        
    } else if (topic.indexOf("/4x4_controller/status") > 0) {
        // Status de modo 4x4
        String mode = payload["mode"].as<String>();
        String source = payload["device_id"] | "unknown";
        
        // Atualizar todos os botões de modo
        processModeStatus("4x4", mode == "4x4", source);
        processModeStatus("4x2", mode == "4x2", source);
        processModeStatus("4x4_low", mode == "4x4_low", source);
        
    } else if (topic.indexOf("/preset/") > 0 && topic.endsWith("/status")) {
        // Status de preset
        int presetStart = topic.indexOf("/preset/") + 8;
        int presetEnd = topic.lastIndexOf("/status");
        String preset = topic.substring(presetStart, presetEnd);
        
        bool active = payload["active"] | false;
        String source = payload["device_id"] | "unknown";
        
        processPresetStatus(preset, active, source);
        
    } else if (topic.endsWith("/status")) {
        // Status genérico de placa com múltiplos canais
        String boardId = topic.substring(9, topic.lastIndexOf("/status"));
        
        // Processar canais se existirem
        if (payload["channels"].is<JsonObject>()) {
            JsonObject channels = payload["channels"];
            String source = payload["device_id"] | "unknown";
            
            for (JsonPair kv : channels) {
                int channel = String(kv.key().c_str()).toInt();
                JsonObject chInfo = kv.value();
                String state = chInfo["state"].as<String>();
                
                processRelayStatus(boardId, channel, state, source);
            }
        }
    }
}