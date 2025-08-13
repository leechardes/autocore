/**
 * @file Navigator.h
 * @brief Sistema de navegação entre telas
 */

#ifndef NAVIGATOR_H
#define NAVIGATOR_H

#include <Arduino.h>
#include <vector>
#include <functional>
#include "ui/ScreenManager.h"

typedef std::function<void(const String& from, const String& to)> NavigationCallback;

class Navigator {
private:
    ScreenManager* screenManager;
    
    // Navigation state
    String currentScreenId;
    std::vector<String> history;
    static const size_t MAX_HISTORY = 10;
    
    // Callbacks
    NavigationCallback onNavigateCallback;
    
public:
    Navigator(ScreenManager* manager);
    
    // Navigation methods
    void navigateToScreen(const String& screenId);
    void navigatePrevious();
    void navigateNext();
    void navigateBack();
    void navigateHome();
    
    // Selection
    void select();
    
    // Get current state
    String getCurrentScreen() const { return currentScreenId; }
    bool canGoBack() const { return history.size() > 1; }
    
    // Set callback
    void onNavigate(NavigationCallback callback) { onNavigateCallback = callback; }
    
private:
    void addToHistory(const String& screenId);
    std::vector<String> getScreenOrder();
    int getCurrentScreenIndex();
};

#endif // NAVIGATOR_H