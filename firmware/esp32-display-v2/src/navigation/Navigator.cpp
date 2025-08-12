/**
 * @file Navigator.cpp
 * @brief Implementation of navigation system
 */

#include "navigation/Navigator.h"
#include "core/Logger.h"

extern Logger* logger;

Navigator::Navigator(ScreenManager* manager) 
    : screenManager(manager), currentScreenId("home") {
    
    logger->info("Navigator initialized");
}

void Navigator::navigateToScreen(const String& screenId) {
    if (screenId == currentScreenId) {
        logger->debug("Already on screen: " + screenId);
        return;
    }
    
    String previousScreen = currentScreenId;
    
    // Try to show the screen
    if (screenManager->showScreen(screenId)) {
        currentScreenId = screenId;
        addToHistory(screenId);
        
        logger->info("Navigated from " + previousScreen + " to " + screenId);
        
        // Call navigation callback
        if (onNavigateCallback) {
            onNavigateCallback(previousScreen, screenId);
        }
    } else {
        logger->error("Failed to navigate to screen: " + screenId);
    }
}

void Navigator::navigatePrevious() {
    std::vector<String> screens = getScreenOrder();
    int currentIndex = getCurrentScreenIndex();
    
    if (currentIndex > 0) {
        navigateToScreen(screens[currentIndex - 1]);
    } else if (screens.size() > 0) {
        // Wrap around to last screen
        navigateToScreen(screens[screens.size() - 1]);
    }
}

void Navigator::navigateNext() {
    std::vector<String> screens = getScreenOrder();
    int currentIndex = getCurrentScreenIndex();
    
    if (currentIndex >= 0 && currentIndex < screens.size() - 1) {
        navigateToScreen(screens[currentIndex + 1]);
    } else if (screens.size() > 0) {
        // Wrap around to first screen
        navigateToScreen(screens[0]);
    }
}

void Navigator::navigateBack() {
    if (history.size() > 1) {
        // Remove current screen from history
        history.pop_back();
        
        // Get previous screen
        String previousScreen = history.back();
        history.pop_back(); // Remove it as navigateToScreen will add it again
        
        navigateToScreen(previousScreen);
    } else {
        logger->debug("No history to go back");
    }
}

void Navigator::navigateHome() {
    navigateToScreen("home");
}

void Navigator::select() {
    logger->debug("Select action on screen: " + currentScreenId);
    
    // Delegate to screen manager to handle selection
    screenManager->handleSelect(currentScreenId);
}

void Navigator::addToHistory(const String& screenId) {
    // Add to history
    history.push_back(screenId);
    
    // Limit history size
    if (history.size() > MAX_HISTORY) {
        history.erase(history.begin());
    }
}

std::vector<String> Navigator::getScreenOrder() {
    // Get screens from screen manager
    return screenManager->getScreenIds();
}

int Navigator::getCurrentScreenIndex() {
    std::vector<String> screens = getScreenOrder();
    
    for (int i = 0; i < screens.size(); i++) {
        if (screens[i] == currentScreenId) {
            return i;
        }
    }
    
    return -1;
}