/**
 * @file StatusReporter.h
 * @brief Status reporter v2.2.0 compliant for HMI Display
 */

#ifndef STATUS_REPORTER_H
#define STATUS_REPORTER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include <vector>
#include "core/MQTTClient.h"

class StatusReporter {
private:
    MQTTClient* mqttClient;
    String deviceId;
    
    // Runtime stats
    unsigned long bootTime;
    unsigned long lastHealthStatus;
    unsigned long lastOperationalStatus;
    unsigned long lastPerformanceTelemetry;
    unsigned long lastConfigUpdate;
    unsigned long lastTouchTime;
    unsigned long lastButtonTime;
    
    // Counters
    unsigned long touchCounter;
    unsigned long buttonPressCounter;
    unsigned long screenViewCounter;
    unsigned long errorCounter;
    unsigned long configReloadCount;
    
    // Current state
    String currentScreen;
    int backlight;
    std::vector<String> screenStack;
    
public:
    StatusReporter(MQTTClient* mqtt, const String& deviceId);
    
    // ========== V2.2.0 COMPLIANT METHODS ==========
    
    // Status publishing (intervals enforced internally)
    void publishHealthStatus();         // Every 30 seconds
    void publishOperationalStatus();    // Every 10 seconds  
    void publishPerformanceTelemetry(); // Every 60 seconds
    void publishErrorTelemetry(int code, const String& message, const String& severity = "error");
    
    // Event reporting
    void reportTouchEvent(int x, int y, const String& target);
    void reportButtonPress(const String& buttonId, const String& action);
    void reportScreenChange(const String& fromScreen, const String& toScreen);
    
    // Update method (call from main loop)
    void update();
    
    // State updates
    void updateConfig(unsigned long timestamp);
    void updateBacklight(int level);
    
    // ========== LEGACY METHODS (for compatibility) ==========
    
    void sendHeartbeat();
    void sendStatus(const String& currentScreen, int backlight, int wifiRssi);
    void sendError(const String& error, const String& context = "");
    void sendEvent(const String& event, const String& data = "");
    void sendButtonPress(const String& button);
    void sendButtonPress(const String& buttonId, const String& buttonType);
    void sendNavigation(const String& from, const String& to);
    void sendSystemMetrics();
    void publishTelemetry();
    void reportError(int code, const String& message, JsonObject* context = nullptr);
    void sendDisplayEvent(const String& eventType, const JsonObject& eventData);
    
private:
    String getUptime();
    int getFreeHeap();
    float getCpuUsage();
};

#endif // STATUS_REPORTER_H