/**
 * @file MQTTClient.cpp
 * @brief Implementation of MQTT client
 */

#include "core/MQTTClient.h"
#include "core/Logger.h"
#include "config/DeviceConfig.h"
#include "communication/ButtonStateManager.h"
#include <ArduinoJson.h>

extern Logger* logger;

MQTTClient* MQTTClient::instance = nullptr;

MQTTClient::MQTTClient(const String& deviceId, const String& broker, uint16_t port) 
    : deviceId(deviceId), broker(broker), port(port), connected(false), lastReconnectAttempt(0), lastStatusPublish(0) {
    
    instance = this;
    client = new PubSubClient(wifiClient);
    
    // Try to parse as IP address first
    IPAddress ip;
    if (ip.fromString(broker)) {
        client->setServer(ip, port);
        logger->info("MQTT configured with IP address: " + ip.toString() + ":" + String(port));
    } else {
        client->setServer(broker.c_str(), port);
        logger->info("MQTT configured with hostname: " + broker + ":" + String(port));
    }
    
    client->setCallback(messageReceived);
    client->setBufferSize(MQTT_BUFFER_SIZE); // Buffer size from config
    logger->info("MQTT buffer size set to: " + String(MQTT_BUFFER_SIZE) + " bytes");
}

MQTTClient::~MQTTClient() {
    disconnect();
    delete client;
    instance = nullptr;
}

bool MQTTClient::connect() {
    if (isConnected()) return true;
    
    logger->info("Connecting to MQTT broker: " + broker + ":" + String(port));
    
    // Generate client ID
    String clientId = "AutoTech-" + deviceId + "-" + String(random(0xffff), HEX);
    
    // Last will message
    String willTopic = "autotech/" + deviceId + "/status";
    String willMessage = "{\"status\":\"offline\",\"reason\":\"disconnected\"}";
    
    // Attempt connection
    if (client->connect(clientId.c_str(), willTopic.c_str(), 1, true, willMessage.c_str())) {
        connected = true;
        logger->info("MQTT connected as: " + clientId);
        
        // Publish online status
        String onlineMessage = "{\"status\":\"online\",\"timestamp\":\"" + String(millis()) + "\"}";
        publish(willTopic, onlineMessage, true);
        
        return true;
    } else {
        logger->error("MQTT connection failed, rc=" + String(client->state()));
        return false;
    }
}

void MQTTClient::disconnect() {
    if (client->connected()) {
        // Publish offline status before disconnecting
        String willTopic = "autotech/" + deviceId + "/status";
        String willMessage = "{\"status\":\"offline\",\"reason\":\"shutdown\"}";
        publish(willTopic, willMessage, true);
        
        client->disconnect();
    }
    connected = false;
}

bool MQTTClient::isConnected() {
    return client->connected();
}

void MQTTClient::loop() {
    if (!client->connected()) {
        connected = false;
        
        // Attempt reconnection
        unsigned long now = millis();
        if (now - lastReconnectAttempt > 5000) {
            lastReconnectAttempt = now;
            if (connect()) {
                // Resubscribe to all topics
                for (auto& pair : callbacks) {
                    client->subscribe(pair.first.c_str());
                    logger->debug("Resubscribed to: " + pair.first);
                }
            }
        }
    } else {
        client->loop();
        
        // Publicar status periodicamente
        unsigned long now = millis();
        if (now - lastStatusPublish > STATUS_PUBLISH_INTERVAL) {
            lastStatusPublish = now;
            publishStatus();
        }
    }
}

bool MQTTClient::publish(const String& topic, const String& payload, bool retained) {
    if (!isConnected()) {
        logger->warning("Cannot publish, MQTT not connected");
        return false;
    }
    
    logger->info("Publishing MQTT message:");
    logger->info("  Topic: " + topic);
    logger->info("  Retained: " + String(retained ? "true" : "false"));
    logger->info("  Size: " + String(payload.length()) + " bytes");
    logger->debug("  Payload: " + payload.substring(0, 200) + (payload.length() > 200 ? "..." : ""));
    
    bool result = client->publish(topic.c_str(), payload.c_str(), retained);
    
    if (result) {
        logger->info("  Result: SUCCESS");
    } else {
        logger->error("  Result: FAILED (rc=" + String(client->state()) + ")");
    }
    
    return result;
}

bool MQTTClient::subscribe(const String& topic, MessageCallback callback) {
    if (!isConnected()) {
        logger->warning("Cannot subscribe, MQTT not connected");
        return false;
    }
    
    // Store callback
    callbacks[topic] = callback;
    
    // Subscribe
    bool result = client->subscribe(topic.c_str());
    
    if (result) {
        logger->info("Subscribed to: " + topic);
    } else {
        logger->error("Failed to subscribe to: " + topic);
        callbacks.erase(topic);
    }
    
    return result;
}

void MQTTClient::unsubscribe(const String& topic) {
    client->unsubscribe(topic.c_str());
    callbacks.erase(topic);
    logger->info("Unsubscribed from: " + topic);
}

void MQTTClient::setCallback(const String& topic, MessageCallback callback) {
    callbacks[topic] = callback;
}

void MQTTClient::removeCallback(const String& topic) {
    callbacks.erase(topic);
}

void MQTTClient::messageReceived(char* topic, byte* payload, unsigned int length) {
    if (!instance) return;
    
    // Convert to String
    String topicStr = String(topic);
    String payloadStr;
    payloadStr.reserve(length);
    for (unsigned int i = 0; i < length; i++) {
        payloadStr += (char)payload[i];
    }
    
    logger->info("MQTT message received:");
    logger->info("  Topic: " + topicStr);
    logger->info("  Length: " + String(length) + " bytes");
    logger->debug("  Payload: " + payloadStr.substring(0, 200) + (payloadStr.length() > 200 ? "..." : ""));
    
    // Find and call appropriate callback
    for (auto& pair : instance->callbacks) {
        // Check if topic matches (including wildcards)
        if (topicStr == pair.first || 
            (pair.first.endsWith("#") && topicStr.startsWith(pair.first.substring(0, pair.first.length() - 1))) ||
            (pair.first.indexOf('+') >= 0)) {
            
            // Call callback
            pair.second(topicStr, payloadStr);
        }
    }
    
    // Processar mensagens de status para ButtonStateManager
    extern ButtonStateManager* buttonStateManager;
    if (buttonStateManager && (topicStr.indexOf("/status") > 0 || topicStr.indexOf("/channel/") > 0)) {
        try {
            JsonDocument doc;
            DeserializationError error = deserializeJson(doc, payloadStr);
            
            if (!error) {
                buttonStateManager->handleMQTTMessage(topicStr, doc);
            }
        } catch (...) {
            logger->error("Erro ao processar status para ButtonStateManager");
        }
    }
}

void MQTTClient::publishStatus() {
    // Criar mensagem de status
    JsonDocument doc;
    doc["device_id"] = deviceId;
    doc["status"] = "online";
    doc["timestamp"] = millis();
    doc["uptime"] = millis() / 1000; // tempo em segundos
    doc["type"] = "hmi_display";
    doc["version"] = "2.0.0";
    
    // Adicionar informações de sistema
    doc["system"]["free_heap"] = ESP.getFreeHeap();
    doc["system"]["heap_size"] = ESP.getHeapSize();
    doc["system"]["wifi_rssi"] = WiFi.RSSI();
    
    // Serializar para JSON
    String statusJson;
    serializeJson(doc, statusJson);
    
    // Publicar status
    String topic = "autotech/" + deviceId + "/status";
    publish(topic, statusJson, true);
    
    logger->debug("Status periódico publicado");
}