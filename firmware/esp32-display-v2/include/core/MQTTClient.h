/**
 * @file MQTTClient.h
 * @brief Cliente MQTT v2.2.0 compliant para ESP32
 */

#ifndef MQTT_CLIENT_H
#define MQTT_CLIENT_H

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <functional>
#include <map>
#include "MQTTProtocol.h"

typedef std::function<void(const String& topic, const String& payload)> MessageCallback;

class MQTTClient {
private:
    WiFiClient wifiClient;
    PubSubClient* client;
    String deviceId;
    String broker;
    uint16_t port;
    
    std::map<String, MessageCallback> callbacks;
    bool connected;
    unsigned long lastReconnectAttempt;
    unsigned long lastStatusPublish;
    static const unsigned long STATUS_PUBLISH_INTERVAL = 5000; // 5 segundos
    
    static MQTTClient* instance;
    static void messageReceived(char* topic, byte* payload, unsigned int length);
    void publishStatus();
    void subscribeToTopics();
    bool validateMessage(const JsonDocument& doc);
    void publishError(int code, const String& type, const String& message);
    
public:
    MQTTClient(const String& deviceId, const String& broker, uint16_t port = 1883);
    ~MQTTClient();
    
    bool connect();
    void disconnect();
    bool isConnected();
    
    void loop();
    
    // v2.2.0 compliant publish methods
    bool publish(const String& topic, const String& payload, bool retained = false, uint8_t qos = 0);
    bool publish(const String& topic, const JsonDocument& doc, uint8_t qos = 0, bool retained = false);
    
    // v2.2.0 compliant subscribe methods
    bool subscribe(const String& topic, uint8_t qos = 0, MessageCallback callback = nullptr);
    void unsubscribe(const String& topic);
    
    void setCallback(const String& topic, MessageCallback callback);
    void removeCallback(const String& topic);
    
    String getDeviceId() const { return deviceId; }
};

#endif // MQTT_CLIENT_H