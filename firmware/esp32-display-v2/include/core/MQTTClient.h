/**
 * @file MQTTClient.h
 * @brief Cliente MQTT otimizado para ESP32
 */

#ifndef MQTT_CLIENT_H
#define MQTT_CLIENT_H

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <functional>
#include <map>

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
    
public:
    MQTTClient(const String& deviceId, const String& broker, uint16_t port = 1883);
    ~MQTTClient();
    
    bool connect();
    void disconnect();
    bool isConnected();
    
    void loop();
    
    bool publish(const String& topic, const String& payload, bool retained = false);
    bool subscribe(const String& topic, MessageCallback callback);
    void unsubscribe(const String& topic);
    
    void setCallback(const String& topic, MessageCallback callback);
    void removeCallback(const String& topic);
    
    String getDeviceId() const { return deviceId; }
};

#endif // MQTT_CLIENT_H