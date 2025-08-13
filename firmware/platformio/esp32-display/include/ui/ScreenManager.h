/**
 * @file ScreenManager.h
 * @brief Gerenciador de telas da interface
 */

#ifndef SCREEN_MANAGER_H
#define SCREEN_MANAGER_H

#include <Arduino.h>
#include <lvgl.h>
#include <ArduinoJson.h>
#include <vector>
#include <map>
#include <memory>
#include "ScreenBase.h"

class ScreenManager {
private:
    std::map<String, std::unique_ptr<ScreenBase>> screens;
    std::map<String, lv_obj_t*> legacyScreens; // For backward compatibility
    ScreenBase* currentScreen;
    String currentScreenId;
    bool useNewSystem = true; // Flag to enable new system
    
public:
    ScreenManager();
    ~ScreenManager();
    
    // Screen management - new system
    bool showScreen(const String& screenId);
    void addScreen(const String& screenId, std::unique_ptr<ScreenBase> screen);
    void removeScreen(const String& screenId);
    void clearAllScreens();
    
    // Navigation
    void navigateTo(const String& screenId);
    void navigateHome();
    
    // Legacy support
    void addLegacyScreen(const String& screenId, lv_obj_t* screen);
    void setUseNewSystem(bool use) { useNewSystem = use; }
    
    // Build screens from config
    void buildFromConfig(JsonDocument& config);
    
    // Get screen info
    std::vector<String> getScreenIds();
    ScreenBase* getCurrentScreen() { return currentScreen; }
    lv_obj_t* getCurrentLvglScreen();
    String getCurrentScreenId() { return currentScreenId; }
    
    // Handle selection on current screen
    void handleSelect(const String& screenId);
    
private:
    void createScreen(JsonObject& screenConfig);
};

#endif // SCREEN_MANAGER_H