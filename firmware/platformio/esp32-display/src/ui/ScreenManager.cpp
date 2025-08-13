/**
 * @file ScreenManager.cpp
 * @brief Implementation of screen manager
 */

#include "ui/ScreenManager.h"
#include "ui/ScreenFactory.h"
#include "ui/Theme.h"
#include "core/Logger.h"
#include "NavButton.h"
#include "screens/HomeScreen.h"

extern Logger* logger;

ScreenManager::ScreenManager() : currentScreen(nullptr) {
    logger->info("ScreenManager initialized");
}

ScreenManager::~ScreenManager() {
    clearAllScreens();
}

bool ScreenManager::showScreen(const String& screenId) {
    if (useNewSystem) {
        // Try new system first
        auto it = screens.find(screenId);
        if (it != screens.end()) {
            currentScreen = it->second.get();
            currentScreenId = screenId;
            if (currentScreen && currentScreen->getScreen()) {
                lv_scr_load(currentScreen->getScreen());
                logger->debug("Showing screen (new system): " + screenId);
                return true;
            }
        }
    }
    
    // Fall back to legacy system
    auto legacyIt = legacyScreens.find(screenId);
    if (legacyIt != legacyScreens.end()) {
        currentScreen = nullptr;  // Clear new system pointer
        currentScreenId = screenId;
        lv_scr_load(legacyIt->second);
        logger->debug("Showing screen (legacy): " + screenId);
        return true;
    }
    
    logger->error("Screen not found: " + screenId);
    return false;
}

void ScreenManager::addLegacyScreen(const String& screenId, lv_obj_t* screen) {
    if (legacyScreens.find(screenId) != legacyScreens.end()) {
        logger->warning("Legacy screen already exists: " + screenId + ", replacing");
        lv_obj_del(legacyScreens[screenId]);
    }
    
    legacyScreens[screenId] = screen;
    logger->debug("Added legacy screen: " + screenId);
}

void ScreenManager::addScreen(const String& screenId, std::unique_ptr<ScreenBase> screen) {
    if (screen) {
        screens[screenId] = std::move(screen);
        logger->debug("Added screen (new system): " + screenId);
    }
}

void ScreenManager::removeScreen(const String& screenId) {
    // Try new system first
    auto it = screens.find(screenId);
    if (it != screens.end()) {
        screens.erase(it);
        logger->debug("Removed screen (new system): " + screenId);
        return;
    }
    
    // Try legacy system
    auto legacyIt = legacyScreens.find(screenId);
    if (legacyIt != legacyScreens.end()) {
        lv_obj_del(legacyIt->second);
        legacyScreens.erase(legacyIt);
        logger->debug("Removed screen (legacy): " + screenId);
    }
}

void ScreenManager::clearAllScreens() {
    // Clear new system screens
    screens.clear();
    
    // Clear legacy screens
    for (auto& pair : legacyScreens) {
        lv_obj_del(pair.second);
    }
    legacyScreens.clear();
    
    currentScreen = nullptr;
    currentScreenId = "";
}

void ScreenManager::buildFromConfig(JsonDocument& config) {
    logger->info("Building screens from configuration...");
    
    clearAllScreens();
    
    if (!config["screens"].is<JsonArray>()) {
        logger->error("No screens array found in configuration");
        return;
    }
    
    // New format: screens is always an array
    logger->info("Processing screens in new hierarchical format");
    JsonArray screensArray = config["screens"].as<JsonArray>();
    
    // First, check if we need to create a Home screen
    bool hasHomeScreen = false;
    for (JsonObject screenConfig : screensArray) {
        if (screenConfig["order_index"].as<int>() == 0) {
            // This is meant to be the home screen
            // Create a special HomeScreen instance instead
            hasHomeScreen = true;
            logger->info("Creating Home screen from screens list");
            
            // Create HomeScreen instance
            auto homeScreen = std::unique_ptr<HomeScreen>(new HomeScreen());
            homeScreen->build();
            addScreen("home", std::move(homeScreen));
            break;
        }
    }
    
    // Now create all screens (including the one with order_index = 0)
    for (JsonObject screenConfig : screensArray) {
        createScreen(screenConfig);
    }
    
    logger->info("Created " + String(screens.size()) + " screens");
    
    // Show home screen by default
    if (hasHomeScreen) {
        showScreen("home");
    } else if (!screens.empty()) {
        // Show first screen if no home screen
        showScreen(screens.begin()->first);
    }
}

std::vector<String> ScreenManager::getScreenIds() {
    std::vector<String> ids;
    
    for (const auto& pair : screens) {
        ids.push_back(pair.first);
    }
    
    return ids;
}

void ScreenManager::handleSelect(const String& screenId) {
    // TODO: Implement selection handling based on focused element
    logger->debug("Handling select on screen: " + screenId);
}

void ScreenManager::createScreen(JsonObject& screenConfig) {
    // Convert id to string if it's a number
    String screenId;
    if (screenConfig["id"].is<int>()) {
        screenId = String(screenConfig["id"].as<int>());
    } else {
        screenId = screenConfig["id"].as<String>();
    }
    
    String title = screenConfig["title"].as<String>();
    
    logger->debug("Creating screen: " + screenId + " - " + title);
    
    // Use new system
    useNewSystem = true;
    
    // Create screen with new layout system
    auto screen = ScreenFactory::createScreen(screenConfig);
    
    if (screen) {
        addScreen(screenId, std::move(screen));
    } else {
        logger->error("Failed to create screen: " + screenId);
    }
}

// New system functions
lv_obj_t* ScreenManager::getCurrentLvglScreen() {
    if (currentScreen) {
        return currentScreen->getScreen();
    }
    
    // Check legacy system
    auto it = legacyScreens.find(currentScreenId);
    if (it != legacyScreens.end()) {
        return it->second;
    }
    
    return nullptr;
}

void ScreenManager::navigateHome() {
    logger->info("ScreenManager::navigateHome called");
    
    // Navigate to the special home screen we created
    if (screens.find("home") != screens.end()) {
        showScreen("home");
    } else {
        logger->warning("Home screen not found!");
    }
}

void ScreenManager::navigateTo(const String& screenId) {
    logger->info("ScreenManager::navigateTo called with: " + screenId);
    showScreen(screenId);
}
