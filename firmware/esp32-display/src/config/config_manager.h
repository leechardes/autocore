/**
 * AutoCore ESP32 Display - Configuration Manager
 * 
 * Gerencia persistência e carregamento de configurações do dispositivo
 * Baseado no padrão do firmware de relé
 */

#pragma once

#include <Arduino.h>
#include <Preferences.h>
#include <ArduinoJson.h>
#include "device_config.h"

/**
 * Gerenciador de configurações do sistema
 * Responsável por carregar, salvar e validar configurações
 */
class ConfigManager {
private:
    Preferences prefs;              // Interface de persistência (NVS)
    DeviceConfig config;            // Configuração atual
    bool initialized;               // Flag de inicialização
    
    // Chaves de armazenamento NVS
    static constexpr const char* NVS_NAMESPACE = "autocore_disp";
    static constexpr const char* KEY_CONFIG_VERSION = "cfg_version";
    static constexpr const char* KEY_DEVICE_UUID = "device_uuid";
    static constexpr const char* KEY_DEVICE_NAME = "device_name";
    static constexpr const char* KEY_WIFI_SSID = "wifi_ssid";
    static constexpr const char* KEY_WIFI_PASSWORD = "wifi_pass";
    static constexpr const char* KEY_BACKEND_HOST = "backend_host";
    static constexpr const char* KEY_BACKEND_PORT = "backend_port";
    static constexpr const char* KEY_MQTT_BROKER = "mqtt_broker";
    static constexpr const char* KEY_MQTT_PORT = "mqtt_port";
    static constexpr const char* KEY_MQTT_USER = "mqtt_user";
    static constexpr const char* KEY_MQTT_PASSWORD = "mqtt_pass";
    static constexpr const char* KEY_CONFIGURED = "configured";
    static constexpr const char* KEY_THEME_JSON = "theme_json";
    static constexpr const char* KEY_SCREENS_JSON = "screens_json";
    
    // Versão da configuração (para migrations futuras)
    static constexpr int CONFIG_VERSION = 1;
    
    // Métodos internos
    bool loadFromNVS();
    bool saveToNVS();
    void applyDefaults();
    String generateDeviceUUID();
    bool validateConfiguration();
    
public:
    ConfigManager();
    ~ConfigManager();
    
    // Inicialização
    bool begin();
    bool isInitialized() const { return initialized; }
    
    // Configuração básica
    DeviceConfig& getConfig() { return config; }
    const DeviceConfig& getConfig() const { return config; }
    bool isConfigured() const { return config.configured; }
    
    // Getters específicos
    String getDeviceUUID() const { return config.device_uuid; }
    String getDeviceName() const { return config.device_name; }
    String getWiFiSSID() const { return config.wifi_ssid; }
    String getWiFiPassword() const { return config.wifi_password; }
    String getBackendHost() const { return config.backend_host; }
    int getBackendPort() const { return config.backend_port; }
    String getMQTTBroker() const { return config.mqtt_broker; }
    int getMQTTPort() const { return config.mqtt_port; }
    String getMQTTUser() const { return config.mqtt_user; }
    String getMQTTPassword() const { return config.mqtt_password; }
    
    // Setters básicos
    void setDeviceName(const String& name);
    void setWiFiCredentials(const String& ssid, const String& password);
    void setBackendConfig(const String& host, int port);
    void setMQTTConfig(const String& broker, int port, const String& user, const String& password);
    
    // Configuração completa via JSON
    bool updateFromJSON(const String& jsonString);
    String exportToJSON() const;
    
    // Configuração de tema
    bool updateTheme(const DisplayTheme& theme);
    bool updateThemeFromJSON(const String& themeJSON);
    String getThemeAsJSON() const;
    
    // Configuração de telas
    bool updateScreens(const std::vector<ScreenConfig>& screens);
    bool updateScreensFromJSON(const String& screensJSON);
    String getScreensAsJSON() const;
    
    // Persistência
    bool save();
    bool load();
    bool factoryReset();
    
    // Validação
    bool validate() const;
    String getValidationErrors() const;
    
    // Status
    void markAsConfigured();
    void markAsUnconfigured();
    unsigned long getLastUpdateTime() const { return config.last_config_update; }
    
    // Debug
    void printConfiguration() const;
    void printStorageInfo() const;
    
    // Compatibilidade com firmware de relé
    bool debugEnabled = true;
};

// Instância global (singleton pattern)
extern ConfigManager configManager;