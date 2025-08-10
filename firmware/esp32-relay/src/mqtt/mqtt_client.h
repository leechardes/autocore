#ifndef MQTT_CLIENT_H
#define MQTT_CLIENT_H

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include "../config/device_config.h"

class AutoCoreMQTTClient {
private:
    WiFiClient wifiClient;
    PubSubClient mqttClient;
    
    String deviceUUID;
    String mqttBroker;
    int mqttPort;
    String mqttUser;
    String mqttPassword;
    
    // Estado da conexão
    bool initialized = false;
    bool connected = false;
    unsigned long lastReconnectAttempt = 0;
    unsigned long lastStatusPublish = 0;
    unsigned long lastTelemetryPublish = 0;
    
    // Callbacks
    std::function<void(String topic, String payload)> messageCallback;
    std::function<void(bool connected)> connectionCallback;
    
    // Tópicos
    String baseTopic;
    String statusTopic;
    String commandTopic;
    String heartbeatTopic;
    String telemetryTopic;
    String configTopic;
    String relayStateTopic;
    String relayCommandTopic;
    
    // Buffer para mensagens offline
    struct QueuedMessage {
        String topic;
        String payload;
        bool retain;
        unsigned long timestamp;
    };
    static const int MESSAGE_QUEUE_SIZE = 10;
    QueuedMessage messageQueue[MESSAGE_QUEUE_SIZE];
    int queueHead = 0;
    int queueTail = 0;
    int queueCount = 0;
    
    // Métodos privados
    void buildTopics();
    void subscribeToTopics();
    void handleIncomingMessage(char* topic, byte* payload, unsigned int length);
    bool reconnect();
    void publishQueuedMessages();
    bool enqueueMessage(const String& topic, const String& payload, bool retain = false);
    void publishLastWill();

public:
    AutoCoreMQTTClient();
    ~AutoCoreMQTTClient();
    
    // Inicialização e configuração
    bool begin(const String& uuid, const String& broker, int port, 
               const String& user = "", const String& password = "");
    void end();
    bool isInitialized() { return initialized; }
    
    // Gerenciamento de conexão
    bool connect();
    void disconnect();
    bool isConnected() { return connected && mqttClient.connected(); }
    void loop(); // Deve ser chamado regularmente no loop principal
    
    // Callbacks
    void onMessage(std::function<void(String topic, String payload)> callback);
    void onConnection(std::function<void(bool connected)> callback);
    
    // Publicação de mensagens
    bool publishStatus(const String& status);
    bool publishTelemetry(const String& telemetryJson);
    bool publishRelayState(int channel, bool state);
    bool publishHeartbeatAck(int channel, int sequence);
    bool publishSafetyEvent(const String& eventJson);
    bool publishDeviceAnnounce();
    
    // Publicação genérica
    bool publish(const String& topic, const String& payload, bool retain = false);
    bool publishToDevice(const String& subtopic, const String& payload, bool retain = false);
    
    // Subscrição
    bool subscribe(const String& topic, int qos = 1);
    bool subscribeToDevice(const String& subtopic, int qos = 1);
    void unsubscribe(const String& topic);
    
    // Utilitários
    String getClientId();
    String getBaseTopic() { return baseTopic; }
    void setKeepAlive(int seconds);
    void setBufferSize(int size);
    
    // Status e debugging
    String getConnectionStatus();
    void printTopics();
    void printQueueStatus();
    int getQueuedMessageCount() { return queueCount; }
    
    // Configurações automáticas
    void enableAutoReconnect(bool enable = true);
    void setReconnectInterval(unsigned long intervalMs);
    void setStatusPublishInterval(unsigned long intervalMs);
    void setTelemetryPublishInterval(unsigned long intervalMs);
    
private:
    // Configurações
    bool autoReconnect = true;
    unsigned long reconnectInterval = MQTT_RECONNECT_INTERVAL;
    unsigned long statusPublishInterval = STATUS_PUBLISH_INTERVAL;
    unsigned long telemetryPublishInterval = TELEMETRY_PUBLISH_INTERVAL;
};

extern AutoCoreMQTTClient mqttClient;

#endif // MQTT_CLIENT_H