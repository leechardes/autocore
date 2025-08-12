/**
 * @file CommandSender.h
 * @brief Gerenciador de envio de comandos MQTT
 */

#ifndef COMMAND_SENDER_H
#define COMMAND_SENDER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include "core/MQTTClient.h"
#include "core/Logger.h"
#include "NavButton.h"
#include "../models/DeviceModels.h"

class CommandSender {
private:
    MQTTClient* mqttClient;
    Logger* logger;
    String deviceId;  // ID deste display
    unsigned long commandCounter;
    
    String generateRequestId();
    String getCurrentTimestamp();
    
public:
    CommandSender(MQTTClient* mqtt, Logger* log, const String& devId);
    
    // Enviar comando baseado no botão
    bool sendCommand(NavButton* button);
    
    // Comandos específicos
    bool sendRelayCommand(const String& targetDevice, int channel, const String& state, bool momentary = false);
    void sendRelayCommandV2(uint8_t relay_board_id, uint8_t channel, bool state, const String& function_type);
    bool sendPresetCommand(const String& preset);
    bool sendModeCommand(const String& mode);
    bool sendActionCommand(const String& action, JsonObject& params);
    
    // Status
    void sendDisplayStatus(const String& currentScreen, int backlight);
};

#endif // COMMAND_SENDER_H