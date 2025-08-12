/**
 * @file StatusReporter.cpp
 * @brief Implementation of status reporter
 */

#include "communication/StatusReporter.h"
#include "core/Logger.h"
#include <ArduinoJson.h>

extern Logger* logger;

StatusReporter::StatusReporter(MQTTClient* mqtt, const String& id) 
    : mqttClient(mqtt), deviceId(id), bootTime(millis()), lastHeartbeat(0) {
    
    statusTopic = "autotech/" + deviceId + "/status";
}

void StatusReporter::sendHeartbeat() {
    JsonDocument doc;
    doc["device_id"] = deviceId;
    doc["type"] = "heartbeat";
    doc["uptime"] = getUptime();
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(statusTopic, payload);
    lastHeartbeat = millis();
}

void StatusReporter::sendStatus(const String& currentScreen, int backlight, int wifiRssi) {
    JsonDocument doc;
    doc["device_id"] = deviceId;
    doc["type"] = "status";
    doc["current_screen"] = currentScreen;
    doc["backlight"] = backlight;
    doc["wifi_rssi"] = wifiRssi;
    doc["uptime"] = getUptime();
    doc["free_heap"] = getFreeHeap();
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    if (mqttClient->publish(statusTopic, payload)) {
        logger->debug("Status report sent");
    }
}

void StatusReporter::sendError(const String& error, const String& context) {
    JsonDocument doc;
    doc["device_id"] = deviceId;
    doc["type"] = "error";
    doc["error"] = error;
    if (context.length() > 0) {
        doc["context"] = context;
    }
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    String errorTopic = "autotech/" + deviceId + "/error";
    mqttClient->publish(errorTopic, payload);
    
    logger->error("Error reported: " + error);
}

void StatusReporter::sendEvent(const String& event, const String& data) {
    JsonDocument doc;
    doc["device_id"] = deviceId;
    doc["type"] = "event";
    doc["event"] = event;
    if (data.length() > 0) {
        doc["data"] = data;
    }
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    String eventTopic = "autotech/" + deviceId + "/event";
    mqttClient->publish(eventTopic, payload);
}

void StatusReporter::sendButtonPress(const String& button) {
    JsonDocument doc;
    doc["device_id"] = deviceId;
    doc["type"] = "button_press";
    doc["button"] = button;
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    String buttonTopic = "autotech/" + deviceId + "/button";
    mqttClient->publish(buttonTopic, payload);
    
    logger->debug("Button press reported: " + button);
}

void StatusReporter::sendNavigation(const String& from, const String& to) {
    JsonDocument doc;
    doc["device_id"] = deviceId;
    doc["type"] = "navigation";
    doc["from_screen"] = from;
    doc["to_screen"] = to;
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    sendEvent("navigation", payload);
}

void StatusReporter::sendSystemMetrics() {
    JsonDocument doc;
    doc["device_id"] = deviceId;
    doc["type"] = "metrics";
    
    JsonObject metrics = doc["metrics"].to<JsonObject>();
    metrics["free_heap"] = getFreeHeap();
    metrics["heap_fragmentation"] = 100 - (100 * ESP.getFreeHeap() / ESP.getHeapSize());
    metrics["cpu_freq"] = ESP.getCpuFreqMHz();
    metrics["flash_size"] = ESP.getFlashChipSize();
    metrics["flash_speed"] = ESP.getFlashChipSpeed() / 1000000;
    metrics["sdk_version"] = ESP.getSdkVersion();
    
    doc["uptime"] = getUptime();
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    String metricsTopic = "autotech/" + deviceId + "/metrics";
    mqttClient->publish(metricsTopic, payload);
}

String StatusReporter::getUptime() {
    unsigned long uptimeMs = millis() - bootTime;
    unsigned long seconds = uptimeMs / 1000;
    unsigned long minutes = seconds / 60;
    unsigned long hours = minutes / 60;
    unsigned long days = hours / 24;
    
    char buffer[32];
    if (days > 0) {
        sprintf(buffer, "%lud %02lu:%02lu:%02lu", days, hours % 24, minutes % 60, seconds % 60);
    } else {
        sprintf(buffer, "%02lu:%02lu:%02lu", hours, minutes % 60, seconds % 60);
    }
    
    return String(buffer);
}

int StatusReporter::getFreeHeap() {
    return ESP.getFreeHeap();
}

float StatusReporter::getCpuUsage() {
    // Simple approximation based on loop time
    static unsigned long lastCheck = 0;
    static unsigned long lastIdleTime = 0;
    
    unsigned long now = millis();
    unsigned long elapsed = now - lastCheck;
    
    if (elapsed > 1000) {
        // Calculate approximate CPU usage
        float usage = 100.0 - ((float)lastIdleTime / elapsed * 100.0);
        lastCheck = now;
        lastIdleTime = 0;
        return usage;
    }
    
    return 0.0;
}