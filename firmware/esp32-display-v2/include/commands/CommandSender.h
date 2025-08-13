/**
 * @file CommandSender.h
 * @brief Gerenciador de envio de comandos MQTT v2.2.0 compliant
 */

#ifndef COMMAND_SENDER_H
#define COMMAND_SENDER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include "core/MQTTClient.h"
#include "core/MQTTProtocol.h"
#include "core/Logger.h"
#include "NavButton.h"
#include "../models/DeviceModels.h"

class CommandSender {
private:
    MQTTClient* mqttClient;
    Logger* logger;
    String deviceId;  // ID deste display
    unsigned long commandCounter;
    
    // Heartbeat management for momentary buttons
    uint32_t heartbeatSequence[MAX_CHANNELS];
    unsigned long lastHeartbeat[MAX_CHANNELS];
    bool heartbeatActive[MAX_CHANNELS];
    String heartbeatTargetDevice[MAX_CHANNELS];
    
    String generateRequestId();
    String getCurrentTimestamp();
    
public:
    CommandSender(MQTTClient* mqtt, Logger* log, const String& devId);
    
    // Enviar comando baseado no botão
    bool sendCommand(NavButton* button);
    
    // Comandos específicos v2.2.0 compliant
    bool sendRelayCommand(const String& targetUuid, int channel, const String& state, const String& functionType = "toggle");
    bool sendPresetCommand(const String& preset);
    bool sendModeCommand(const String& mode);
    bool sendActionCommand(const String& action, JsonObject& params);
    
    // Heartbeat management for momentary buttons
    void startHeartbeat(const String& targetUuid, int channel);
    void stopHeartbeat(int channel);
    void sendHeartbeat(const String& targetUuid, int channel);
    void processHeartbeats();
    
    // Display events
    void sendDisplayEvent(const String& eventType, const JsonObject& eventData);
};

#endif // COMMAND_SENDER_H