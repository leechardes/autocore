/**
 * @file CommandSender.cpp
 * @brief Implementação do gerenciador de comandos MQTT v2.2.0 compliant
 */

#include "commands/CommandSender.h"
#include "core/MQTTProtocol.h"
#include "core/Logger.h"

extern Logger* logger;

CommandSender::CommandSender(MQTTClient* mqtt, Logger* log, const String& devId) 
    : mqttClient(mqtt), logger(log), deviceId(devId), commandCounter(0) {
    
    // Initialize heartbeat arrays
    for (int i = 0; i < MAX_CHANNELS; i++) {
        heartbeatSequence[i] = 0;
        lastHeartbeat[i] = 0;
        heartbeatActive[i] = false;
        heartbeatTargetDevice[i] = "";
    }
}

String CommandSender::generateRequestId() {
    commandCounter++;
    return deviceId + "_" + String(millis()) + "_" + String(commandCounter);
}

String CommandSender::getCurrentTimestamp() {
    return MQTTProtocol::getISOTimestamp();
}

bool CommandSender::sendCommand(NavButton* button) {
    if (!mqttClient || !mqttClient->isConnected()) {
        logger->warning("MQTT não conectado, comando não enviado");
        return false;
    }
    
    switch (button->getButtonType()) {
        case NavButton::TYPE_RELAY:
            // Para botões toggle, sempre aplicar debounce rigoroso
            if (button->getMode() == "toggle") {
                if (!button->canSendCommand()) {
                    logger->debug("Comando toggle ignorado devido ao debounce");
                    return false;
                }
                // Toggle state: se está ON, enviar OFF e vice-versa
                return sendRelayCommand(
                    button->getDeviceId(),
                    button->getChannel(),
                    button->getState() ? "OFF" : "ON",  // Toggle
                    "toggle"  // Function type
                );
            } else {
                // Para botões momentary, permitir comandos repetidos mas com debounce menor
                return sendRelayCommand(
                    button->getDeviceId(),
                    button->getChannel(),
                    "ON",  // Momentary sempre ON
                    "momentary"   // Function type
                );
            }
            
        case NavButton::TYPE_ACTION:
            if (button->getActionType() == "preset") {
                return sendPresetCommand(button->getPreset());
            }
            break;
            
        case NavButton::TYPE_MODE:
            return sendModeCommand(button->getModeValue());
            
        default:
            // Navegação é tratada localmente
            break;
    }
    
    return false;
}

bool CommandSender::sendRelayCommand(const String& targetUuid, int channel, 
                                   const String& state, const String& functionType) {
    if (!mqttClient || !mqttClient->isConnected()) {
        logger->warning("MQTT not connected, command not sent");
        return false;
    }
    
    String topic = "autocore/devices/" + targetUuid + "/relays/set";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc); // Adiciona protocol_version, uuid, timestamp
    
    doc["channel"] = channel;
    doc["state"] = (state == "ON" || state == "true" || state == "1");
    doc["function_type"] = functionType;
    doc["user"] = "display_touch";
    doc["source_uuid"] = MQTTProtocol::getDeviceUUID();
    
    String payload;
    serializeJson(doc, payload);
    bool result = mqttClient->publish(topic, payload);
    
    if (result) {
        logger->info("CMD: Sent " + functionType + " command to " + 
                    targetUuid + " ch:" + String(channel) + " state:" + state);
        
        // Se for momentâneo e ON, iniciar heartbeat
        if (functionType == "momentary" && (state == "ON" || state == "true" || state == "1")) {
            startHeartbeat(targetUuid, channel);
        }
    } else {
        logger->error("CMD: Failed to send command to " + targetUuid);
    }
    
    return result;
}

void CommandSender::startHeartbeat(const String& targetUuid, int channel) {
    if (channel < 1 || channel > MAX_CHANNELS) {
        logger->error("CMD: Invalid channel for heartbeat: " + String(channel));
        return;
    }
    
    int idx = channel - 1;
    heartbeatActive[idx] = true;
    heartbeatSequence[idx] = 0;
    heartbeatTargetDevice[idx] = targetUuid;
    lastHeartbeat[idx] = millis();
    
    logger->info("CMD: Started heartbeat for " + targetUuid + " channel " + String(channel));
}

void CommandSender::stopHeartbeat(int channel) {
    if (channel < 1 || channel > MAX_CHANNELS) return;
    
    int idx = channel - 1;
    heartbeatActive[idx] = false;
    heartbeatTargetDevice[idx] = "";
    
    logger->info("CMD: Stopped heartbeat for channel " + String(channel));
}

void CommandSender::sendHeartbeat(const String& targetUuid, int channel) {
    if (channel < 1 || channel > MAX_CHANNELS) return;
    
    int idx = channel - 1;
    if (!heartbeatActive[idx]) return;
    
    String topic = "autocore/devices/" + targetUuid + "/relays/heartbeat";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["channel"] = channel;
    doc["source_uuid"] = MQTTProtocol::getDeviceUUID();
    doc["target_uuid"] = targetUuid;
    doc["sequence"] = ++heartbeatSequence[idx];
    
    mqttClient->publish(topic, doc, QOS_HEARTBEAT);
    
    lastHeartbeat[idx] = millis();
    
    logger->debug("CMD: Heartbeat sent to " + targetUuid + " ch:" + String(channel) + 
                 " seq:" + String(heartbeatSequence[idx]));
}

void CommandSender::processHeartbeats() {
    unsigned long now = millis();
    
    for (int i = 0; i < MAX_CHANNELS; i++) {
        if (heartbeatActive[i]) {
            if (now - lastHeartbeat[i] >= HEARTBEAT_INTERVAL_MS) {
                sendHeartbeat(heartbeatTargetDevice[i], i + 1);
            }
        }
    }
}

void CommandSender::sendDisplayEvent(const String& eventType, const JsonObject& eventData) {
    String topic = "autocore/devices/" + MQTTProtocol::getDeviceUUID() + "/display/touch";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["event"] = eventType;
    doc["data"] = eventData;
    
    mqttClient->publish(topic, doc, QOS_TELEMETRY);
    
    logger->info("CMD: Display event sent: " + eventType);
}

bool CommandSender::sendPresetCommand(const String& preset) {
    String topic = "autocore/system/commands";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["command_type"] = "preset";
    doc["preset"] = preset;
    doc["user"] = "display_touch";
    doc["source_uuid"] = MQTTProtocol::getDeviceUUID();
    
    logger->info("CMD: Sending preset command: " + preset);
    
    String payload;
    serializeJson(doc, payload);
    return mqttClient->publish(topic, payload);
}

bool CommandSender::sendModeCommand(const String& mode) {
    String topic = "autocore/system/commands";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["command_type"] = "set_mode";
    doc["mode"] = mode;
    doc["user"] = "display_touch";
    doc["source_uuid"] = MQTTProtocol::getDeviceUUID();
    
    logger->info("CMD: Sending mode command: " + mode);
    
    String payload;
    serializeJson(doc, payload);
    return mqttClient->publish(topic, payload);
}

bool CommandSender::sendActionCommand(const String& action, JsonObject& params) {
    String topic = "autocore/system/commands";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["command_type"] = "action";
    doc["action"] = action;
    doc["user"] = "display_touch";
    doc["source_uuid"] = MQTTProtocol::getDeviceUUID();
    
    // Copiar parâmetros
    JsonObject parameters = doc["parameters"].to<JsonObject>();
    for (JsonPair kv : params) {
        parameters[kv.key()] = kv.value();
    }
    
    logger->info("CMD: Sending action command: " + action);
    
    String payload;
    serializeJson(doc, payload);
    return mqttClient->publish(topic, payload);
}

// sendDisplayStatus removed - status is now handled by MQTTClient
// sendRelayCommandV2 removed - replaced by v2.2.0 compliant sendRelayCommand