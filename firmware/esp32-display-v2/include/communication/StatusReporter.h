/**
 * @file StatusReporter.h
 * @brief Reporta status do dispositivo via MQTT
 */

#ifndef STATUS_REPORTER_H
#define STATUS_REPORTER_H

#include <Arduino.h>
#include "core/MQTTClient.h"

class StatusReporter {
private:
    MQTTClient* mqttClient;
    String deviceId;
    String statusTopic;
    
    // Runtime stats
    unsigned long bootTime;
    unsigned long lastHeartbeat;
    
public:
    StatusReporter(MQTTClient* mqtt, const String& deviceId);
    
    // Send different types of status
    void sendHeartbeat();
    void sendStatus(const String& currentScreen, int backlight, int wifiRssi);
    void sendError(const String& error, const String& context = "");
    void sendEvent(const String& event, const String& data = "");
    
    // Button events
    void sendButtonPress(const String& button);
    void sendNavigation(const String& from, const String& to);
    
    // System metrics
    void sendSystemMetrics();
    
private:
    String getUptime();
    int getFreeHeap();
    float getCpuUsage();
};

#endif // STATUS_REPORTER_H