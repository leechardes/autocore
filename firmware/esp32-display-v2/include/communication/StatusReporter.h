/**
 * @file StatusReporter.h
 * @brief Reporta status do dispositivo via MQTT
 */

#ifndef STATUS_REPORTER_H
#define STATUS_REPORTER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include "core/MQTTClient.h"

class StatusReporter {
private:
    MQTTClient* mqttClient;
    String deviceId;
    String statusTopic;
    
    // Runtime stats
    unsigned long bootTime;
    unsigned long lastHeartbeat;
    
    // Counters
    unsigned long touchCounter;
    unsigned long buttonPressCounter;
    unsigned long screenViewCounter;
    unsigned long errorCounter;
    
public:
    StatusReporter(MQTTClient* mqtt, const String& deviceId);
    
    // Send different types of status
    void sendHeartbeat();
    void sendStatus(const String& currentScreen, int backlight, int wifiRssi);
    void sendError(const String& error, const String& context = "");
    void sendEvent(const String& event, const String& data = "");
    
    // Button events
    void sendButtonPress(const String& button);
    void sendButtonPress(const String& buttonId, const String& buttonType);
    void sendNavigation(const String& from, const String& to);
    
    // System metrics
    void sendSystemMetrics();
    
    // Telemetry
    void publishTelemetry();
    
    // Error handling
    void reportError(int code, const String& message, JsonObject* context = nullptr);
    
    // Display events
    void sendDisplayEvent(const String& eventType, const JsonObject& eventData);
    
private:
    String getUptime();
    int getFreeHeap();
    float getCpuUsage();
};

#endif // STATUS_REPORTER_H