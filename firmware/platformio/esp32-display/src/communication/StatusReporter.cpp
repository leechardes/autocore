/**
 * @file StatusReporter.cpp
 * @brief Implementation of status reporter v2.2.0 compliant
 */

#include "communication/StatusReporter.h"
#include "core/MQTTProtocol.h"
#include "core/Logger.h"
#include <ArduinoJson.h>
#include <WiFi.h>

extern Logger* logger;

StatusReporter::StatusReporter(MQTTClient* mqtt, const String& id) 
    : mqttClient(mqtt), deviceId(id), bootTime(millis()), lastHeartbeat(0),
      touchCounter(0), buttonPressCounter(0), screenViewCounter(0), errorCounter(0) {
    
    // v2.2.0: Status is now handled by MQTTClient itself
    // Telemetry uses standard topic without UUID
}

void StatusReporter::publishTelemetry() {
    // UUID no payload, não no tópico! (v2.2.0)
    String topic = "autocore/telemetry/displays/data";
    
    StaticJsonDocument<1024> doc;
    MQTTProtocol::addProtocolFields(doc);  // Adiciona version, uuid, timestamp
    
    // Informações do display
    JsonObject display = doc["display"].to<JsonObject>();
    display["type"] = "touch_2.4";
    display["backlight"] = 100; // Default backlight level
    display["current_screen"] = "home"; // Default screen
    display["touch_enabled"] = true;
    
    // Métricas do sistema
    JsonObject metrics = doc["metrics"].to<JsonObject>();
    metrics["uptime"] = (millis() - bootTime) / 1000;
    metrics["free_heap"] = ESP.getFreeHeap();
    metrics["wifi_rssi"] = WiFi.RSSI();
    metrics["fps"] = 60; // Default FPS
    metrics["cpu_usage"] = getCpuUsage();
    
    // Estatísticas de uso
    JsonObject stats = doc["usage_stats"].to<JsonObject>();
    stats["touches_today"] = touchCounter;
    stats["buttons_pressed"] = buttonPressCounter;
    stats["screens_viewed"] = screenViewCounter;
    stats["errors_logged"] = errorCounter;
    
    String payload;
    serializeJson(doc, payload);
    mqttClient->publish(topic, payload);
    
    logger->debug("TELEMETRY: Telemetry published");
}

// sendStatus removed - status is now handled by MQTTClient

void StatusReporter::reportError(int code, const String& message, JsonObject* context) {
    String topic = "autocore/errors/" + MQTTProtocol::getDeviceUUID() + "/display";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["error_code"] = code;
    doc["error_type"] = "display_error";
    doc["error_message"] = message;
    doc["device_type"] = "display";
    
    if (context) {
        doc["context"] = *context;
    }
    
    String payload;
    serializeJson(doc, payload);
    mqttClient->publish(topic, payload);
    
    errorCounter++;
    logger->error("STATUS: " + String(code) + ": " + message);
}

void StatusReporter::sendDisplayEvent(const String& eventType, const JsonObject& eventData) {
    String topic = "autocore/devices/" + MQTTProtocol::getDeviceUUID() + "/display/touch";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["event"] = eventType;
    doc["data"] = eventData;
    
    String payload;
    serializeJson(doc, payload);
    mqttClient->publish(topic, payload);
    
    logger->info("STATUS: Display event sent: " + eventType);
}

void StatusReporter::sendButtonPress(const String& buttonId, const String& buttonType) {
    StaticJsonDocument<256> eventDoc;
    eventDoc["button_id"] = buttonId;
    eventDoc["button_type"] = buttonType;
    eventDoc["press_time"] = millis();
    
    sendDisplayEvent("button_press", eventDoc.as<JsonObject>());
    
    buttonPressCounter++;
    logger->debug("STATUS: Button press reported: " + buttonId);
}

void StatusReporter::sendNavigation(const String& from, const String& to) {
    JsonDocument doc;
    MQTTProtocol::addProtocolFields(doc);  // Adiciona version, uuid, timestamp
    doc["device_id"] = deviceId;
    doc["type"] = "navigation";
    doc["from_screen"] = from;
    doc["to_screen"] = to;
    
    String payload;
    serializeJson(doc, payload);
    
    sendEvent("navigation", payload);
}

void StatusReporter::sendSystemMetrics() {
    JsonDocument doc;
    MQTTProtocol::addProtocolFields(doc);  // Adiciona version, uuid, timestamp
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
    
    String payload;
    serializeJson(doc, payload);
    
    String metricsTopic = "autocore/devices/" + MQTTProtocol::getDeviceUUID() + "/metrics";
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

void StatusReporter::sendHeartbeat() {
    String topic = "autocore/devices/" + MQTTProtocol::getDeviceUUID() + "/heartbeat";
    
    StaticJsonDocument<256> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["device_type"] = "display";
    doc["uptime"] = getUptime();
    doc["free_heap"] = getFreeHeap();
    
    String payload;
    serializeJson(doc, payload);
    mqttClient->publish(topic, payload);
    
    lastHeartbeat = millis();
    logger->debug("STATUS: Heartbeat sent");
}

void StatusReporter::sendStatus(const String& currentScreen, int backlight, int wifiRssi) {
    String topic = "autocore/devices/" + MQTTProtocol::getDeviceUUID() + "/status";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["device_type"] = "display";
    doc["current_screen"] = currentScreen;
    doc["backlight"] = backlight;
    doc["wifi_rssi"] = wifiRssi;
    doc["uptime"] = getUptime();
    doc["free_heap"] = getFreeHeap();
    
    String payload;
    serializeJson(doc, payload);
    mqttClient->publish(topic, payload);
    
    logger->debug("STATUS: Status sent");
}

void StatusReporter::sendError(const String& error, const String& context) {
    reportError(1, error);
}

void StatusReporter::sendEvent(const String& event, const String& data) {
    String topic = "autocore/devices/" + MQTTProtocol::getDeviceUUID() + "/events";
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["event"] = event;
    doc["data"] = data;
    
    String payload;
    serializeJson(doc, payload);
    mqttClient->publish(topic, payload);
    
    logger->debug("STATUS: Event sent: " + event);
}

void StatusReporter::sendButtonPress(const String& button) {
    sendButtonPress(button, "momentary");
}