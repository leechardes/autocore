/**
 * @file StatusReporter.cpp
 * @brief Implementation of status reporter v2.2.0 compliant
 */

#include "communication/StatusReporter.h"
#include "core/MQTTProtocol.h"
#include "core/Logger.h"
#include "config/DeviceConfig.h"
#include "utils/DeviceUtils.h"
#include <ArduinoJson.h>
#include <WiFi.h>

extern Logger* logger;

StatusReporter::StatusReporter(MQTTClient* mqtt, const String& id) 
    : mqttClient(mqtt), deviceId(id), bootTime(millis()), 
      lastHealthStatus(0), lastOperationalStatus(0), lastPerformanceTelemetry(0),
      touchCounter(0), buttonPressCounter(0), screenViewCounter(0), errorCounter(0),
      currentScreen("home"), backlight(DEFAULT_BACKLIGHT) {
    
    logger->info("StatusReporter initialized for device: " + deviceId);
}

// ============================================================================
// V2.2.0 COMPLIANT STATUS METHODS
// ============================================================================

void StatusReporter::publishHealthStatus() {
    // Health Status - Published every 30 seconds
    unsigned long now = millis();
    if (now - lastHealthStatus < 30000) return; // 30 seconds interval
    
    // V2.2.0: Usar UUID completo nos tópicos
    String topic = "autocore/devices/" + deviceId + "/status/health";
    
    StaticJsonDocument<512> doc;
    doc["status"] = "healthy";
    doc["uptime"] = (millis() - bootTime) / 1000;
    doc["free_heap"] = ESP.getFreeHeap();
    doc["min_free_heap"] = ESP.getMinFreeHeap();
    doc["cpu_usage"] = getCpuUsage();
    doc["temperature"] = 45.2; // TODO: Read from sensor if available
    doc["wifi_rssi"] = WiFi.RSSI();
    doc["mqtt_queue"] = 0; // TODO: Get from MQTT client
    doc["last_config_update"] = lastConfigUpdate;
    doc["timestamp"] = MQTTProtocol::getTimestamp();
    doc["protocol_version"] = PROTOCOL_VERSION;
    doc["device_id"] = deviceId;
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, false, 0); // QoS 0, no retain
    
    lastHealthStatus = now;
    logger->debug("Health status published");
}

void StatusReporter::publishOperationalStatus() {
    // Operational Status - Published every 10 seconds during operation
    unsigned long now = millis();
    if (now - lastOperationalStatus < 10000) return; // 10 seconds interval
    
    // V2.2.0: Usar UUID completo nos tópicos
    String topic = "autocore/devices/" + deviceId + "/status/operational";
    
    StaticJsonDocument<1024> doc;
    doc["current_screen"] = currentScreen;
    
    JsonArray stack = doc.createNestedArray("screen_stack");
    for (const auto& screen : screenStack) {
        stack.add(screen);
    }
    
    JsonArray items = doc.createNestedArray("active_items");
    // TODO: Get active items from screen manager
    
    JsonObject activity = doc.createNestedObject("user_activity");
    activity["last_touch"] = lastTouchTime;
    activity["last_button"] = lastButtonTime;
    activity["interaction_count"] = touchCounter + buttonPressCounter;
    
    JsonObject display = doc.createNestedObject("display");
    display["brightness"] = backlight;
    display["orientation"] = 1; // Landscape
    display["backlight_timeout"] = 30;
    
    doc["timestamp"] = MQTTProtocol::getTimestamp();
    doc["protocol_version"] = PROTOCOL_VERSION;
    doc["device_id"] = deviceId;
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, false, 0); // QoS 0, no retain
    
    lastOperationalStatus = now;
    logger->debug("Operational status published");
}

void StatusReporter::publishPerformanceTelemetry() {
    // Performance Telemetry - Published every 60 seconds
    unsigned long now = millis();
    if (now - lastPerformanceTelemetry < 60000) return; // 60 seconds interval
    
    // V2.2.0: Usar UUID completo nos tópicos
    String topic = "autocore/devices/" + deviceId + "/telemetry/performance";
    
    StaticJsonDocument<1024> doc;
    
    JsonObject metrics = doc.createNestedObject("metrics");
    
    JsonObject transitions = metrics.createNestedObject("screen_transitions");
    transitions["total"] = screenViewCounter;
    transitions["avg_time"] = 0.8; // TODO: Calculate actual average
    transitions["max_time"] = 2.1; // TODO: Track maximum
    
    JsonObject touch = metrics.createNestedObject("touch_events");
    touch["total"] = touchCounter;
    touch["avg_response"] = 30; // TODO: Calculate actual response time
    touch["max_response"] = 85;
    
    JsonObject config = metrics.createNestedObject("config_reloads");
    config["total"] = configReloadCount;
    config["avg_time"] = 1.2; // TODO: Calculate actual average
    config["last_reload"] = lastConfigUpdate;
    
    JsonObject memory = metrics.createNestedObject("memory");
    memory["heap_fragmentation"] = 100 - (100 * ESP.getFreeHeap() / ESP.getHeapSize());
    memory["max_block_size"] = ESP.getMaxAllocHeap();
    memory["allocations_failed"] = 0; // TODO: Track failed allocations
    
    doc["timestamp"] = MQTTProtocol::getTimestamp();
    doc["protocol_version"] = PROTOCOL_VERSION;
    doc["device_id"] = deviceId;
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, false, 0); // QoS 0, no retain
    
    lastPerformanceTelemetry = now;
    logger->debug("Performance telemetry published");
}

void StatusReporter::publishErrorTelemetry(int code, const String& message, const String& severity) {
    String topic = "autocore/devices/" + deviceId + "/telemetry/errors";
    
    StaticJsonDocument<512> doc;
    
    JsonArray errors = doc.createNestedArray("errors");
    JsonObject error = errors.createNestedObject();
    error["code"] = "ERR_" + String(code);
    error["message"] = message;
    error["timestamp"] = MQTTProtocol::getTimestamp();
    error["severity"] = severity;
    error["count"] = 1;
    
    JsonObject counts = doc.createNestedObject("error_counts");
    counts["total_errors"] = ++errorCounter;
    counts["critical_errors"] = severity == "critical" ? 1 : 0;
    counts["warnings"] = severity == "warning" ? 1 : 0;
    counts["info"] = severity == "info" ? 1 : 0;
    
    doc["timestamp"] = MQTTProtocol::getTimestamp();
    doc["protocol_version"] = PROTOCOL_VERSION;
    doc["device_id"] = deviceId;
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, false, 1); // QoS 1 for errors
    
    logger->error("Error telemetry: " + message);
}

// ============================================================================
// EVENT REPORTING METHODS
// ============================================================================

void StatusReporter::reportTouchEvent(int x, int y, const String& target) {
    String topic = "autocore/devices/" + deviceId + "/telemetry/touch";
    
    StaticJsonDocument<256> doc;
    doc["event"] = "touch";
    doc["x"] = x;
    doc["y"] = y;
    doc["target"] = target;
    doc["timestamp"] = MQTTProtocol::getTimestamp();
    doc["device_id"] = deviceId;
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, false, 0);
    
    touchCounter++;
    lastTouchTime = millis() / 1000;
}

void StatusReporter::reportButtonPress(const String& buttonId, const String& action) {
    String topic = "autocore/devices/" + deviceId + "/telemetry/button";
    
    StaticJsonDocument<256> doc;
    doc["event"] = "button_press";
    doc["button_id"] = buttonId;
    doc["action"] = action;
    doc["timestamp"] = MQTTProtocol::getTimestamp();
    doc["device_id"] = deviceId;
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, false, 0);
    
    buttonPressCounter++;
    lastButtonTime = millis() / 1000;
}

void StatusReporter::reportScreenChange(const String& fromScreen, const String& toScreen) {
    currentScreen = toScreen;
    
    // Update screen stack
    if (screenStack.size() > 10) {
        screenStack.erase(screenStack.begin());
    }
    screenStack.push_back(toScreen);
    
    String topic = "autocore/devices/" + deviceId + "/telemetry/navigation";
    
    StaticJsonDocument<256> doc;
    doc["event"] = "screen_change";
    doc["from"] = fromScreen;
    doc["to"] = toScreen;
    doc["timestamp"] = MQTTProtocol::getTimestamp();
    doc["device_id"] = deviceId;
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, false, 0);
    
    screenViewCounter++;
}

// ============================================================================
// PERIODIC UPDATE METHOD
// ============================================================================

void StatusReporter::update() {
    // This method should be called from main loop
    publishHealthStatus();       // Every 30 seconds
    publishOperationalStatus();  // Every 10 seconds
    publishPerformanceTelemetry(); // Every 60 seconds
}

// ============================================================================
// HELPER METHODS
// ============================================================================

float StatusReporter::getCpuUsage() {
    static unsigned long lastCheck = 0;
    static unsigned long lastIdleTime = 0;
    
    unsigned long now = millis();
    unsigned long elapsed = now - lastCheck;
    
    if (elapsed > 1000) {
        float usage = 100.0 - ((float)lastIdleTime / elapsed * 100.0);
        lastCheck = now;
        lastIdleTime = 0;
        return usage;
    }
    
    return 25.5; // Default value
}

void StatusReporter::updateConfig(unsigned long timestamp) {
    lastConfigUpdate = timestamp;
    configReloadCount++;
}

void StatusReporter::updateBacklight(int level) {
    backlight = level;
}

// ============================================================================
// LEGACY METHODS (kept for compatibility but updated to v2.2.0)
// ============================================================================

void StatusReporter::publishTelemetry() {
    // Redirect to new v2.2.0 compliant methods
    publishPerformanceTelemetry();
}

void StatusReporter::sendHeartbeat() {
    // Heartbeat is now part of health status
    publishHealthStatus();
}

void StatusReporter::sendStatus(const String& currentScreen, int backlight, int wifiRssi) {
    this->currentScreen = currentScreen;
    this->backlight = backlight;
    publishOperationalStatus();
}

void StatusReporter::reportError(int code, const String& message, JsonObject* context) {
    publishErrorTelemetry(code, message, "error");
}

void StatusReporter::sendError(const String& error, const String& context) {
    publishErrorTelemetry(1, error, "error");
}

void StatusReporter::sendButtonPress(const String& button) {
    reportButtonPress(button, "press");
}

void StatusReporter::sendButtonPress(const String& buttonId, const String& buttonType) {
    reportButtonPress(buttonId, buttonType);
}

void StatusReporter::sendNavigation(const String& from, const String& to) {
    reportScreenChange(from, to);
}

void StatusReporter::sendDisplayEvent(const String& eventType, const JsonObject& eventData) {
    // Convert to v2.2.0 format
    if (eventType == "touch") {
        reportTouchEvent(eventData["x"], eventData["y"], eventData["target"]);
    } else if (eventType == "button_press") {
        reportButtonPress(eventData["button_id"], eventData["action"]);
    }
}

void StatusReporter::sendSystemMetrics() {
    publishPerformanceTelemetry();
}

void StatusReporter::sendEvent(const String& event, const String& data) {
    // Generic event - publish to telemetry
    String topic = "autocore/devices/" + deviceId + "/telemetry/event";
    
    StaticJsonDocument<256> doc;
    doc["event"] = event;
    doc["data"] = data;
    doc["timestamp"] = MQTTProtocol::getTimestamp();
    doc["device_id"] = deviceId;
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient->publish(topic, payload, false, 0);
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