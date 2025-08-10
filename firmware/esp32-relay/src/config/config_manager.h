#ifndef CONFIG_MANAGER_H
#define CONFIG_MANAGER_H

#include <Arduino.h>
#include <Preferences.h>
#include <WiFi.h>
#include <ArduinoJson.h>
#include "device_config.h"

class ConfigManager {
private:
    DeviceConfig config;
    Preferences preferences;
    bool initialized = false;

    // Métodos privados
    String generateUUID();
    bool validateConfig();
    void setDefaults();

public:
    ConfigManager();
    ~ConfigManager();

    // Inicialização
    bool begin();
    bool isInitialized() { return initialized; }

    // Configuração do dispositivo
    DeviceConfig& getConfig() { return config; }
    bool saveConfig();
    bool loadConfig();
    void resetConfig();

    // Configurações específicas
    bool setDeviceInfo(const String& name, const String& uuid = "");
    bool setWiFiCredentials(const String& ssid, const String& password);
    bool setBackendInfo(const String& ip, int port);
    bool setMQTTInfo(const String& broker, int port, const String& user = "", const String& pass = "");
    
    // Configuração de relés
    bool setRelayChannel(int channel, const RelayChannelConfig& channelConfig);
    RelayChannelConfig getRelayChannel(int channel);
    bool enableRelayChannel(int channel, int gpio_pin, const String& name, const String& type = "toggle");
    bool disableRelayChannel(int channel);
    
    // Estado de configuração
    bool isConfigured();
    void setConfigured(bool configured);
    
    // Validação
    bool isWiFiConfigured();
    bool isMQTTConfigured();
    bool isBackendConfigured();
    
    // Utilitários
    String getDeviceUUID();
    String getDeviceName();
    String getStatusJSON();
    String getConfigJSON();
    bool loadConfigFromJSON(const String& json);
    
    // Debug e manutenção
    void printConfig();
    void factoryReset();
    size_t getUsedNVSSpace();
    size_t getFreeNVSSpace();
};

extern ConfigManager configManager;

#endif // CONFIG_MANAGER_H