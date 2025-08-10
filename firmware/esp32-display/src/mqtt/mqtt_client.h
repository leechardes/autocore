/**
 * AutoCore ESP32 Display - MQTT Client
 * 
 * Cliente MQTT para comunicação com o ecossistema AutoCore
 * Baseado no padrão do firmware de relé
 */

#pragma once

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include "../config/device_config.h"

/**
 * Estados do cliente MQTT
 */
enum MQTTState {
    MQTT_DISCONNECTED = 0,
    MQTT_CONNECTING = 1,
    MQTT_CONNECTED = 2,
    MQTT_ERROR = 3,
    MQTT_RECONNECTING = 4
};

/**
 * Callback para mensagens MQTT
 */
typedef std::function<void(String topic, String payload)> MQTTMessageCallback;
typedef std::function<void(bool connected)> MQTTConnectionCallback;

/**
 * Cliente MQTT para displays AutoCore
 * Gerencia conexão, subscrições e publicações
 */
class MQTTClient {
private:
    PubSubClient client;
    WiFiClient wifiClient;
    MQTTState currentState;
    
    // Configurações
    String broker;
    int port;
    String username;
    String password;
    String clientId;
    String deviceUUID;
    
    // Controle de conexão
    unsigned long lastConnectionAttempt;
    unsigned long lastKeepAlive;
    int reconnectAttempts;
    bool autoReconnect;
    bool initialized;
    
    // Timeouts e intervalos
    static constexpr unsigned long CONNECTION_TIMEOUT = 10000;    // 10 segundos
    static constexpr unsigned long RECONNECT_INTERVAL = 15000;    // 15 segundos
    static constexpr unsigned long KEEPALIVE_INTERVAL = 60000;    // 60 segundos
    static constexpr int MAX_RECONNECT_ATTEMPTS = 5;
    
    // Tópicos do dispositivo
    String topicPrefix;
    String topicConfig;
    String topicEvents;
    String topicHeartbeat;
    String topicTelemetry;
    String topicCommands;
    String topicStatus;
    
    // Callbacks
    MQTTMessageCallback messageCallback;
    MQTTConnectionCallback connectionCallback;
    
    // Métodos internos
    void changeState(MQTTState newState);
    void buildTopics();
    void subscribeToTopics();
    void handleMQTTMessage(char* topic, byte* payload, unsigned int length);
    static void staticMessageCallback(char* topic, byte* payload, unsigned int length);
    
    // Lista de subscrições
    std::vector<String> subscriptions;
    
public:
    MQTTClient();
    ~MQTTClient();
    
    // Inicialização
    bool begin(const String& uuid, const String& brokerHost, int brokerPort,
               const String& user = "", const String& pass = "");
    bool isInitialized() const { return initialized; }
    
    // Configuração
    void setCredentials(const String& user, const String& pass);
    void setClientId(const String& id);
    void enableAutoReconnect(bool enable);
    void setKeepAlive(int seconds);
    
    // Estado da conexão
    MQTTState getState() const { return currentState; }
    String getStateString() const;
    bool isConnected() const { return currentState == MQTT_CONNECTED; }
    bool isConnecting() const { return currentState == MQTT_CONNECTING; }
    
    // Conexão
    bool connect();
    bool disconnect();
    bool reconnect();
    
    // Loop principal
    void loop();
    void update() { loop(); }  // Compatibilidade
    
    // Publicações específicas do display
    bool publishEvent(const String& event, const String& data = "");
    bool publishHeartbeat();
    bool publishTelemetry(const String& telemetryData);
    bool publishStatus(const String& status);
    bool publishDeviceAnnounce();
    
    // Publicações genéricas
    bool publish(const String& topic, const String& payload, bool retained = false);
    bool publishJSON(const String& topic, const JsonDocument& doc, bool retained = false);
    
    // Subscrições
    bool subscribe(const String& topic, int qos = 0);
    bool unsubscribe(const String& topic);
    void subscribeToDeviceTopics();
    
    // Callbacks
    void onMessage(MQTTMessageCallback callback) { messageCallback = callback; }
    void onConnection(MQTTConnectionCallback callback) { connectionCallback = callback; }
    
    // Informações
    String getBrokerInfo() const;
    String getTopicsInfo() const;
    unsigned long getLastMessageTime() const;
    int getReconnectAttempts() const { return reconnectAttempts; }
    
    // Eventos específicos do display
    bool sendButtonPress(const String& buttonId, const String& screenId = "");
    bool sendButtonRelease(const String& buttonId, const String& screenId = "");
    bool sendScreenChange(const String& fromScreen, const String& toScreen);
    bool sendUserInteraction(const String& action, const String& data = "");
    bool sendSystemAlert(const String& level, const String& message);
    
    // Monitoramento e diagnóstico
    void printStatus() const;
    void printTopics() const;
    String getStatusJSON() const;
    
    // Utilitários
    static String generateClientId(const String& deviceUUID);
    String formatTopic(const String& pattern, const String& deviceUUID) const;
    
    // Debug
    bool debugEnabled = true;
    
    // Instância estática para callback
    static MQTTClient* instance;
};

// Instância global
extern MQTTClient mqttClient;