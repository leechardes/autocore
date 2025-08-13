/**
 * @file ConfigReceiver.h
 * @brief Recebe configuração via API REST (preferencialmente) ou MQTT (fallback)
 * 
 * Versão 2.0 - Migração para API REST:
 * - Carregamento primário via API HTTP
 * - Fallback automático para MQTT se API falhar
 * - Hot-reload via MQTT mantido
 * - Cache inteligente para otimização
 */

#ifndef CONFIG_RECEIVER_H
#define CONFIG_RECEIVER_H

#include <Arduino.h>
#include <functional>
#include "core/MQTTClient.h"
#include "core/ConfigManager.h"
#include "network/ScreenApiClient.h"

class ConfigReceiver {
private:
    MQTTClient* mqttClient;
    ConfigManager* configManager;
    ScreenApiClient* apiClient;
    
    // MQTT topics (reduzidos - apenas para hot-reload)
    String updateTopic;
    
    // API configuration
    bool useApi;
    bool configReceived;
    
    // Hot reload callback
    std::function<void()> onConfigUpdateCallback;
    
    // Static callbacks
    static ConfigReceiver* instance;
    static void onConfigReceived(const String& topic, const String& payload);
    static void onConfigUpdate(const String& topic, const String& payload);
    
public:
    ConfigReceiver(MQTTClient* mqtt, ConfigManager* config, ScreenApiClient* api = nullptr);
    ~ConfigReceiver();
    
    // Initialize and subscribe to topics
    void begin();
    
    // API Configuration Methods (NEW)
    void setApiClient(ScreenApiClient* client);
    bool loadFromApi();
    bool testApiConnection();
    
    // MQTT Configuration Methods (FALLBACK)
    bool loadFromMqtt();
    void requestConfigMqtt();
    
    // Combined Methods
    bool loadConfiguration(); // Try API first, fallback to MQTT
    
    // Enable hot reload
    void enableHotReload(std::function<void()> callback);
    
    // Status methods
    bool hasConfig() const { return configReceived; }
    bool isUsingApi() const { return useApi; }
    
private:
    void handleConfigUpdate(const String& payload);
    void handleMqttConfigMessage(const String& payload);
    void sendConfigAck(const String& source, const String& status);
};

#endif // CONFIG_RECEIVER_H