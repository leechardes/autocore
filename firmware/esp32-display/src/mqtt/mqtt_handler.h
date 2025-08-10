/**
 * AutoCore ESP32 Display - MQTT Handler
 * 
 * Processa mensagens MQTT e coordena ações do display
 * Baseado no padrão do firmware de relé
 */

#pragma once

#include <Arduino.h>
#include <ArduinoJson.h>
#include "../config/device_config.h"

// Forward declarations
class ScreenManager;
class ConfigManager;

/**
 * Tipos de mensagens MQTT
 */
enum MQTTMessageType {
    MSG_CONFIG_UPDATE = 0,
    MSG_RELAY_STATE = 1,
    MSG_CAN_DATA = 2,
    MSG_SYSTEM_BROADCAST = 3,
    MSG_DISPLAY_COMMAND = 4,
    MSG_THEME_UPDATE = 5,
    MSG_SCREEN_UPDATE = 6,
    MSG_UNKNOWN = 99
};

/**
 * Handler para processamento de mensagens MQTT
 * Coordena atualizações de UI baseadas em eventos do sistema
 */
class MQTTHandler {
private:
    bool initialized;
    ScreenManager* screenManager;
    ConfigManager* configManager;
    
    // Contadores de mensagens
    unsigned long messagesProcessed;
    unsigned long lastMessageTime;
    unsigned long configUpdateTime;
    
    // Cache de estados
    std::map<String, bool> relayStates;
    std::map<String, float> canValues;
    String lastThemeUpdate;
    
    // Processadores específicos
    void handleConfigUpdate(const String& payload);
    void handleRelayStateUpdate(const String& topic, const String& payload);
    void handleCANDataUpdate(const String& payload);
    void handleSystemBroadcast(const String& payload);
    void handleDisplayCommand(const String& payload);
    void handleThemeUpdate(const String& payload);
    void handleScreenUpdate(const String& payload);
    
    // Utilitários
    MQTTMessageType getMessageType(const String& topic);
    String extractRelayIdFromTopic(const String& topic);
    bool validateJSON(const String& payload);
    bool updateRelayButtonStates();
    bool updateCANDisplays();
    
    // Processamento de comandos
    void processButtonCommand(const JsonObject& command);
    void processScreenCommand(const JsonObject& command);
    void processSystemCommand(const JsonObject& command);
    
public:
    MQTTHandler();
    ~MQTTHandler();
    
    // Inicialização
    bool begin(ScreenManager* scrMgr = nullptr);
    bool isInitialized() const { return initialized; }
    
    // Processamento principal
    void handleMessage(const String& topic, const String& payload);
    void update();
    
    // Configuração
    void setScreenManager(ScreenManager* manager);
    void setConfigManager(ConfigManager* manager);
    
    // Estados
    bool getRelayState(const String& relayId) const;
    float getCANValue(const String& signal) const;
    std::map<String, bool> getAllRelayStates() const { return relayStates; }
    std::map<String, float> getAllCANValues() const { return canValues; }
    
    // Sincronização
    void requestConfigUpdate();
    void requestRelayStates();
    void requestCANData();
    void syncAllStates();
    
    // Estatísticas
    unsigned long getMessagesProcessed() const { return messagesProcessed; }
    unsigned long getLastMessageTime() const { return lastMessageTime; }
    String getStatsJSON() const;
    
    // Debug e diagnóstico
    void printStats() const;
    void printCachedStates() const;
    void clearCache();
    
    // Debug
    bool debugEnabled = true;
};

// Instância global
extern MQTTHandler mqttHandler;