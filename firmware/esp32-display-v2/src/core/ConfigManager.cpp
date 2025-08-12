/**
 * @file ConfigManager.cpp
 * @brief Implementation of configuration manager
 */

#include "core/ConfigManager.h"
#include "core/Logger.h"
#include <vector>

extern Logger* logger;

ConfigManager::ConfigManager() : hasValidConfig(false), lastUpdate(0) {
    // Initialize with empty config
    config.clear();
}

bool ConfigManager::loadConfig(const String& jsonStr) {
    logger->info("Loading new configuration...");
    logger->info("JSON string length: " + String(jsonStr.length()));
    
    // Clear existing config
    config.clear();
    
    // Parse JSON
    DeserializationError error = deserializeJson(config, jsonStr);
    
    if (error) {
        logger->error("Failed to parse config: " + String(error.c_str()));
        logger->error("Error code: " + String(error.code()));
        return false;
    }
    
    logger->info("Config parsed successfully, document size: " + String(config.size()));
    logger->info("Memory usage: " + String(config.memoryUsage()) + " bytes");
    
    // Validate configuration
    if (!validateConfig(config)) {
        logger->error("Invalid configuration structure");
        config.clear();
        return false;
    }
    
    // Extract version
    if (config["version"].is<JsonVariant>()) {
        configVersion = config["version"].as<String>();
    } else {
        configVersion = "1.0.0";
    }
    
    hasValidConfig = true;
    lastUpdate = millis();
    
    logger->info("Configuration loaded successfully. Version: " + configVersion);
    
    // Notify change
    if (onChangeCallback) {
        onChangeCallback();
    }
    
    return true;
}

JsonArray ConfigManager::getScreens() {
    if (!hasValidConfig) {
        return JsonArray();
    }
    
    // New hierarchical format: screens is already an array
    if (config["screens"].is<JsonArray>()) {
        return config["screens"].as<JsonArray>();
    }
    
    // Legacy object format: convert to array
    if (config["screens"].is<JsonObject>()) {
        // This is the old format, we won't support it anymore
        logger->warning("Legacy screens object format detected");
    }
    
    return JsonArray();
}

JsonObject ConfigManager::getScreen(const String& screenId) {
    if (!hasValidConfig || !config["screens"].is<JsonArray>()) {
        return JsonObject();
    }
    
    // New format: screens is an array, match by id
    JsonArray screens = config["screens"].as<JsonArray>();
    
    // If screenId is numeric, try to find by id
    int id = screenId.toInt();
    if (id > 0) {
        for (JsonObject screen : screens) {
            if (screen["id"].as<int>() == id) {
                return screen;
            }
        }
    }
    
    // If screenId is "home", return first screen (order_index = 0)
    if (screenId == "home") {
        for (JsonObject screen : screens) {
            if (screen["order_index"].as<int>() == 0) {
                return screen;
            }
        }
        // If no screen with order_index 0, return first screen
        if (screens.size() > 0) {
            return screens[0].as<JsonObject>();
        }
    }
    
    return JsonObject(); // Return empty object if not found
}

std::vector<String> ConfigManager::getScreenIds() {
    std::vector<String> ids;
    
    if (!hasValidConfig || !config["screens"].is<JsonArray>()) {
        return ids;
    }
    
    // New format: screens is an array, collect ids as strings
    JsonArray screens = config["screens"].as<JsonArray>();
    for (JsonObject screen : screens) {
        if (screen["id"].is<JsonVariant>()) {
            ids.push_back(String(screen["id"].as<int>()));
        }
    }
    
    return ids;
}

String ConfigManager::getFirstScreenId() {
    if (!hasValidConfig || !config["screens"].is<JsonArray>()) {
        return "2"; // Default to first screen id in our structure
    }
    
    JsonArray screens = config["screens"].as<JsonArray>();
    
    // Find screen with order_index = 0
    for (JsonObject screen : screens) {
        if (screen["order_index"].as<int>() == 0) {
            return String(screen["id"].as<int>());
        }
    }
    
    // If no screen with order_index 0, return first screen id
    if (screens.size() > 0) {
        return String(screens[0]["id"].as<int>());
    }
    
    return "2"; // Default
}

JsonObject ConfigManager::getTheme() {
    if (!hasValidConfig || !config["theme"].is<JsonVariant>()) {
        // Return default theme
        JsonObject defaultTheme = config["theme"].to<JsonObject>();
        defaultTheme["background"] = "#000000";
        defaultTheme["text"] = "#FFFFFF";
        defaultTheme["primary"] = "#0066CC";
        defaultTheme["secondary"] = "#FF6600";
        return defaultTheme;
    }
    
    return config["theme"].as<JsonObject>();
}

JsonObject ConfigManager::getSettings() {
    if (!hasValidConfig || !config["settings"].is<JsonVariant>()) {
        // Return default settings
        JsonObject defaultSettings = config["settings"].to<JsonObject>();
        defaultSettings["language"] = "pt-BR";
        defaultSettings["backlight"] = 100;
        defaultSettings["auto_dim"] = true;
        defaultSettings["button_sound"] = true;
        return defaultSettings;
    }
    
    return config["settings"].as<JsonObject>();
}

bool ConfigManager::validateConfig(const JsonDocument& doc) {
    // Simply check if screens exists as a field
    if (!doc.containsKey("screens")) {
        logger->error("Config missing screens field");
        return false;
    }
    
    // For now, accept any screens format
    logger->info("Config validation passed - screens field exists");
    return true;
}

bool ConfigManager::isNewerVersion(const String& version) {
    // Simple version comparison (assumes format X.Y.Z)
    int currentMajor, currentMinor, currentPatch;
    int newMajor, newMinor, newPatch;
    
    sscanf(configVersion.c_str(), "%d.%d.%d", &currentMajor, &currentMinor, &currentPatch);
    sscanf(version.c_str(), "%d.%d.%d", &newMajor, &newMinor, &newPatch);
    
    if (newMajor > currentMajor) return true;
    if (newMajor < currentMajor) return false;
    
    if (newMinor > currentMinor) return true;
    if (newMinor < currentMinor) return false;
    
    return newPatch > currentPatch;
}

void ConfigManager::printConfig() {
    if (!hasValidConfig) {
        logger->info("No valid configuration loaded");
        return;
    }
    
    String output;
    serializeJsonPretty(config, output);
    
    logger->info("Current configuration:");
    
    // Print in chunks to avoid Serial buffer overflow
    int chunkSize = 256;
    for (int i = 0; i < output.length(); i += chunkSize) {
        Serial.print(output.substring(i, min(i + chunkSize, (int)output.length())));
        delay(10); // Give Serial time to flush
    }
}