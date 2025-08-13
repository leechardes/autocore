/**
 * @file ConfigManager.h
 * @brief Gerenciador de configurações recebidas via MQTT
 */

#ifndef CONFIG_MANAGER_H
#define CONFIG_MANAGER_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include <functional>
#include <vector>
#include "config/DeviceConfig.h"

typedef std::function<void()> ConfigChangeCallback;

class ConfigManager {
private:
    JsonDocument config;
    bool hasValidConfig;
    String configVersion;
    unsigned long lastUpdate;
    
    ConfigChangeCallback onChangeCallback;
    
public:
    ConfigManager();
    
    // Config management
    bool loadConfig(const String& jsonStr);
    bool hasConfig() const { return hasValidConfig; }
    JsonDocument& getConfig() { return config; }
    
    // Getters for common config sections
    JsonArray getScreens();
    JsonObject getScreen(const String& screenId);
    JsonObject getTheme();
    JsonObject getSettings();
    
    // Get screen IDs when screens are in object format
    std::vector<String> getScreenIds();
    String getFirstScreenId();
    
    // Config validation
    bool validateConfig(const JsonDocument& doc);
    
    // Version control
    String getVersion() const { return configVersion; }
    bool isNewerVersion(const String& version);
    
    // Change notification
    void onChange(ConfigChangeCallback callback) { onChangeCallback = callback; }
    
    // Debug
    void printConfig();
};

#endif // CONFIG_MANAGER_H