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
        mqttClient->subscribe("autotech/+/channel/+/status", emptyCallback);
        logger->info("Inscrito em: autotech/+/channel/+/status");
        
        // Status geral das placas
        mqttClient->subscribe("autotech/+/status", emptyCallback);
        logger->info("Inscrito em: autotech/+/status");
        
        // Status do controlador 4x4
        mqttClient->subscribe("autotech/4x4_controller/status", emptyCallback);
        logger->info("Inscrito em: autotech/4x4_controller/status");
        
        // Status de presets
        mqttClient->subscribe("autotech/preset/+/status", emptyCallback);
        logger->info("Inscrito em: autotech/preset/+/status");
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
    if (topic.indexOf("/channel/") > 0 && topic.endsWith("/status")) {
        // Status de canal específico: autotech/relay_board_1/channel/1/status
        int boardEnd = topic.indexOf("/channel/");
        String boardId = topic.substring(9, boardEnd); // Skip "autotech/"
        
        int channelStart = boardEnd + 9; // Length of "/channel/"
        int channelEnd = topic.lastIndexOf("/status");
        int channel = topic.substring(channelStart, channelEnd).toInt();
        
        String state = payload["state"].as<String>();
        String source = payload["device_id"] | payload["source"] | "unknown";
        
        processRelayStatus(boardId, channel, state, source);
        
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