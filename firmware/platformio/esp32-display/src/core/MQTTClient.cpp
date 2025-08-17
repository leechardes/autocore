/**
 * @file MQTTClient.cpp
 * @brief Implementation of MQTT client for v2.2.0 compliance
 */

#include "core/MQTTClient.h"
#include "core/MQTTProtocol.h"
#include "core/Logger.h"
#include "config/DeviceConfig.h"
#include "communication/ButtonStateManager.h"
#include <ArduinoJson.h>

extern Logger* logger;

MQTTClient* MQTTClient::instance = nullptr;

MQTTClient::MQTTClient(const String& deviceId, const String& broker, uint16_t port) 
    : deviceId(deviceId), broker(broker), port(port), useDynamicCredentials(false), connected(false), lastReconnectAttempt(0), lastStatusPublish(0) {
    
    instance = this;
    client = new PubSubClient(wifiClient);
    
    // Initialize MQTTProtocol with correct device type
    MQTTProtocol::initialize(deviceId, DEVICE_TYPE);
    
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
    client->setBufferSize(2048); // Increased buffer for v2.2.0 payloads
    logger->info("MQTT buffer size set to: 2048 bytes for v2.2.0 compliance");
}

MQTTClient::~MQTTClient() {
    disconnect();
    delete client;
    instance = nullptr;
}

bool MQTTClient::connect() {
    if (isConnected()) return true;
    
    // Determinar quais credenciais usar
    String effectiveBroker = broker;
    uint16_t effectivePort = port;
    String username = "";
    String password = "";
    
    if (useDynamicCredentials) {
        effectiveBroker = dynamicCredentials.broker_host;
        effectivePort = dynamicCredentials.broker_port;
        username = dynamicCredentials.username;
        password = dynamicCredentials.password;
        
        logger->info("Using dynamic MQTT credentials from API");
    } else {
        // Usar credenciais estáticas do DeviceConfig.h
        username = MQTT_USER;
        password = MQTT_PASSWORD;
        
        logger->info("Using static MQTT credentials from config");
    }
    
    logger->info("Connecting to MQTT broker: " + effectiveBroker + ":" + String(effectivePort));
    
    // Configurar servidor MQTT com credenciais efetivas
    IPAddress ip;
    if (ip.fromString(effectiveBroker)) {
        client->setServer(ip, effectivePort);
        logger->debug("MQTT server configured with IP: " + ip.toString() + ":" + String(effectivePort));
    } else {
        client->setServer(effectiveBroker.c_str(), effectivePort);
        logger->debug("MQTT server configured with hostname: " + effectiveBroker + ":" + String(effectivePort));
    }
    
    // Generate client ID v2.2.0 compliant
    String clientId = "AutoCore-" + MQTTProtocol::getDeviceUUID() + "-" + String(random(0xffff), HEX);
    
    // Last Will Testament v2.2.0 compliant
    String willTopic = "autocore/devices/" + MQTTProtocol::getDeviceUUID() + "/status";
    
    StaticJsonDocument<512> willDoc;
    willDoc["protocol_version"] = PROTOCOL_VERSION;
    willDoc["uuid"] = MQTTProtocol::getDeviceUUID();
    willDoc["status"] = "offline";
    willDoc["timestamp"] = MQTTProtocol::getISOTimestamp();
    willDoc["reason"] = "unexpected_disconnect";
    willDoc["last_seen"] = MQTTProtocol::getISOTimestamp();
    willDoc["device_type"] = "display";
    willDoc["firmware_version"] = DEVICE_VERSION;
    
    String willMessage;
    serializeJson(willDoc, willMessage);
    
    // Attempt connection with QoS 1, Retain true for LWT
    bool connectionResult = false;
    if (!username.isEmpty() && !password.isEmpty()) {
        // Conectar com autenticação
        logger->debug("MQTT connecting with authentication: " + username);
        connectionResult = client->connect(clientId.c_str(), username.c_str(), password.c_str(), willTopic.c_str(), 1, true, willMessage.c_str());
    } else {
        // Conectar sem autenticação
        logger->debug("MQTT connecting without authentication");
        connectionResult = client->connect(clientId.c_str(), willTopic.c_str(), 1, true, willMessage.c_str());
    }
    
    if (connectionResult) {
        connected = true;
        logger->info("MQTT connected as: " + clientId);
        
        // Subscribe to topics first
        subscribeToTopics();
        
        // Publish online status after subscription
        publishStatus();
        
        return true;
    } else {
        logger->error("MQTT connection failed, rc=" + String(client->state()));
        return false;
    }
}

void MQTTClient::disconnect() {
    if (client->connected()) {
        // Publish offline status before disconnecting v2.2.0 compliant
        String willTopic = "autocore/devices/" + MQTTProtocol::getDeviceUUID() + "/status";
        
        StaticJsonDocument<512> offlineDoc;
        offlineDoc["protocol_version"] = PROTOCOL_VERSION;
        offlineDoc["uuid"] = MQTTProtocol::getDeviceUUID();
        offlineDoc["status"] = "offline";
        offlineDoc["timestamp"] = MQTTProtocol::getISOTimestamp();
        offlineDoc["reason"] = "graceful_shutdown";
        offlineDoc["last_seen"] = MQTTProtocol::getISOTimestamp();
        
        String willMessage;
        serializeJson(offlineDoc, willMessage);
        
        publish(willTopic, willMessage, true, QOS_STATUS);
        
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

bool MQTTClient::publish(const String& topic, const String& payload, bool retained, uint8_t qos) {
    if (!isConnected()) {
        logger->warning("Cannot publish, MQTT not connected");
        return false;
    }
    
    logger->info("Publishing MQTT message:");
    logger->info("  Topic: " + topic);
    logger->info("  QoS: " + String(qos));
    logger->info("  Retained: " + String(retained ? "true" : "false"));
    logger->info("  Size: " + String(payload.length()) + " bytes");
    logger->debug("  Payload: " + payload.substring(0, 200) + (payload.length() > 200 ? "..." : ""));
    
    bool result = client->publish(topic.c_str(), (const uint8_t*)payload.c_str(), payload.length(), retained);
    
    if (result) {
        logger->info("  Result: SUCCESS");
    } else {
        logger->error("  Result: FAILED (rc=" + String(client->state()) + ")");
    }
    
    return result;
}

bool MQTTClient::publish(const String& topic, const JsonDocument& doc, uint8_t qos, bool retained) {
    String payload;
    serializeJson(doc, payload);
    return publish(topic, payload, retained, qos);
}

bool MQTTClient::subscribe(const String& topic, uint8_t qos, MessageCallback callback) {
    if (!isConnected()) {
        logger->warning("Cannot subscribe, MQTT not connected");
        return false;
    }
    
    // Store callback
    if (callback) {
        callbacks[topic] = callback;
    }
    
    // Subscribe with QoS
    bool result = client->subscribe(topic.c_str(), qos);
    
    if (result) {
        logger->info("Subscribed to: " + topic + " (QoS " + String(qos) + ")");
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

void MQTTClient::subscribeToTopics() {
    // Tópicos MQTT v2.2.0 - ESP32-display
    // Usa UUID completo para identificação de dispositivos
    
    // IMPORTANTE: ESP32-display busca configurações via REST API
    // NÃO usa MQTT para receber configurações
    
    // Status de dispositivos (usando wildcard para múltiplos UUIDs)
    // Formato: autocore/devices/{uuid}/status
    subscribe("autocore/devices/+/status", QOS_TELEMETRY);
    subscribe("autocore/devices/+/response", QOS_TELEMETRY);
    subscribe("autocore/devices/+/telemetry/data", QOS_TELEMETRY);
    
    // Sistema e broadcast
    subscribe("autocore/system/ping", QOS_TELEMETRY);
    subscribe("autocore/system/emergency_stop", QOS_COMMANDS);
    subscribe("autocore/broadcast", QOS_TELEMETRY);
    
    // Presets status
    subscribe("autocore/preset/status", QOS_TELEMETRY);
    
    // Security events
    subscribe("autocore/security/event", QOS_COMMANDS);
    
    logger->info("MQTT: Subscribed to protocol v2.2.0 topics");
    logger->info("  UUID: " + MQTTProtocol::getDeviceUUID());
    logger->info("  Config: via REST API /api/config/full/{uuid}");
    logger->info("  Topics: using full UUID format (autocore/devices/{uuid}/...)");
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
    
    // Parse JSON and validate protocol version
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, payloadStr);
    
    if (!error) {
        // Validate protocol version for all messages
        if (!instance->validateMessage(doc)) {
            return; // Invalid message, already logged
        }
    }
    
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
    if (buttonStateManager && (topicStr.indexOf("/status") > 0 || topicStr.indexOf("/relays/state") > 0)) {
        try {
            if (!error) {
                buttonStateManager->handleMQTTMessage(topicStr, doc);
            }
        } catch (...) {
            logger->error("Erro ao processar status para ButtonStateManager");
        }
    }
}

bool MQTTClient::validateMessage(const JsonDocument& doc) {
    if (!MQTTProtocol::validateProtocolVersion(doc)) {
        logger->warning("MQTT: Message without valid protocol_version");
        publishError(8, "PROTOCOL_MISMATCH", "Missing or invalid protocol_version");
        return false;
    }
    return true;
}

void MQTTClient::publishError(int code, const String& type, const String& message) {
    String topic = "autocore/errors/" + MQTTProtocol::getDeviceUUID() + "/" + type;
    
    StaticJsonDocument<512> doc;
    MQTTProtocol::addProtocolFields(doc);
    
    doc["error_code"] = code;
    doc["error_type"] = type;
    doc["error_message"] = message;
    doc["device_type"] = "display";
    
    String payload;
    serializeJson(doc, payload);
    publish(topic, payload);
    
    logger->error("MQTT: " + String(code) + ": " + message);
}

void MQTTClient::publishStatus() {
    // Status v2.2.0 compliant
    String topic = "autocore/devices/" + MQTTProtocol::getDeviceUUID() + "/status";
    
    StaticJsonDocument<1024> doc;
    MQTTProtocol::addProtocolFields(doc); // Adiciona version, uuid, timestamp
    
    doc["status"] = "online";
    doc["device_type"] = "display";
    doc["firmware_version"] = DEVICE_VERSION;
    doc["ip_address"] = WiFi.localIP().toString();
    doc["wifi_signal"] = WiFi.RSSI();
    doc["uptime"] = millis() / 1000;
    doc["last_seen"] = MQTTProtocol::getISOTimestamp();
    
    // Informações do sistema
    JsonObject system = doc["system"].to<JsonObject>();
    system["free_heap"] = ESP.getFreeHeap();
    system["heap_size"] = ESP.getHeapSize();
    system["cpu_freq"] = ESP.getCpuFreqMHz();
    system["flash_size"] = ESP.getFlashChipSize();
    
    // Informações do display
    JsonObject display = doc["display"].to<JsonObject>();
    display["type"] = "touch_2.4";
    display["resolution"] = "320x240";
    display["color_depth"] = "16bit";
    display["backlight"] = true;
    
    // Capacidades
    JsonObject capabilities = doc["capabilities"].to<JsonObject>();
    capabilities["touch"] = true;
    capabilities["color"] = true;
    capabilities["lvgl"] = true;
    capabilities["ota"] = true;
    
    // Publicar com QoS 1 e Retained
    String payload;
    serializeJson(doc, payload);
    publish(topic, payload, true);
    
    logger->debug("Status v2.2.0 publicado");
}

void MQTTClient::setDynamicCredentials(const MQTTCredentials& creds) {
    dynamicCredentials = creds;
    useDynamicCredentials = true;
    
    logger->info("Dynamic MQTT credentials set");
    logger->debug("  Broker: " + creds.broker_host + ":" + String(creds.broker_port));
    logger->debug("  Username: " + creds.username);
    logger->debug("  Topic prefix: " + creds.topic_prefix);
}

bool MQTTClient::loadDynamicCredentials() {
    MQTTCredentials creds;
    if (DeviceRegistration::loadMQTTCredentials(creds)) {
        setDynamicCredentials(creds);
        return true;
    }
    
    logger->warning("Failed to load dynamic MQTT credentials, using static config");
    useDynamicCredentials = false;
    return false;
}