#ifndef MQTT_HANDLER_H
#define MQTT_HANDLER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include "../config/device_config.h"

// Forward declarations
class RelayController;

class MQTTHandler {
private:
    RelayController* relayController;
    
    // Estatísticas
    unsigned long messagesReceived = 0;
    unsigned long commandsExecuted = 0;
    unsigned long heartbeatsReceived = 0;
    unsigned long errorsCount = 0;
    
    // Métodos privados de processamento
    void handleRelayCommand(const String& payload);
    void handleHeartbeat(const String& payload);
    void handleConfiguration(const String& payload);
    void handleGeneralCommand(const String& payload);
    void handleBroadcast(const String& payload);
    
    // Validação e parsing
    bool validateRelayCommand(const JsonObject& cmd);
    bool validateHeartbeat(const JsonObject& hb);
    bool parseJsonPayload(const String& payload, DynamicJsonDocument& doc);
    
    // Respostas e acknowledgments
    void sendCommandResponse(const String& command, bool success, const String& error = "");
    void sendHeartbeatAck(int channel, int sequence);
    
public:
    MQTTHandler();
    ~MQTTHandler();
    
    // Inicialização
    bool begin(RelayController* controller);
    
    // Handler principal para mensagens MQTT
    void handleMessage(const String& topic, const String& payload);
    
    // Handlers específicos por tópico
    void onRelayCommand(const String& payload);
    void onHeartbeat(const String& payload);
    void onConfiguration(const String& payload);
    void onGeneralCommand(const String& payload);
    void onBroadcast(const String& payload);
    
    // Utilitários de parsing
    String getTopicSuffix(const String& topic, const String& baseTopic);
    bool isTopicMatch(const String& topic, const String& pattern);
    
    // Estatísticas
    unsigned long getMessagesReceived() { return messagesReceived; }
    unsigned long getCommandsExecuted() { return commandsExecuted; }
    unsigned long getHeartbeatsReceived() { return heartbeatsReceived; }
    unsigned long getErrorsCount() { return errorsCount; }
    String getStatisticsJSON();
    void resetStatistics();
    
    // Debug
    void setDebugMode(bool enabled);
    bool debugEnabled = false;
};

extern MQTTHandler mqttHandler;

#endif // MQTT_HANDLER_H