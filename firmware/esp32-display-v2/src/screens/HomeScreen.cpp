#include "screens/HomeScreen.h"
#include "NavButton.h"
#include "Layout.h"
#include "core/Logger.h"
#include "ui/ScreenManager.h"
#include "core/ConfigManager.h"

extern Logger* logger;
extern ScreenManager* screenManager;
extern ConfigManager* configManager;

HomeScreen::HomeScreen() : ScreenBase() {
    setScreenId("home");
    setIsHome(true);
}

void HomeScreen::setMenuItems(JsonArray items) {
    menuDoc.clear();
    JsonArray menuItems = menuDoc.to<JsonArray>();
    for (JsonVariant item : items) {
        menuItems.add(item);
    }
}

void HomeScreen::build() {
    logger->info("Building Home screen");
    
    // Set header title
    header->setTitle("Menu Principal");
    
    // Clear existing content
    content->clearChildren();
    
    // Get screens from configuration to use as navigation items
    if (configManager && configManager->hasConfig()) {
        JsonArray screens = configManager->getScreens();
        menuDoc.clear();
        JsonArray menuItems = menuDoc.to<JsonArray>();
        
        logger->debug("Building navigation from " + String(screens.size()) + " screens");
        
        // Convert screens to navigation items
        for (JsonObject screen : screens) {
            // Don't skip any screen - all screens should be navigation items
            
            JsonObject navItem = menuItems.createNestedObject();
            navItem["type"] = "navigation";
            navItem["id"] = String("nav_") + String(screen["id"].as<int>());
            navItem["label"] = screen["title"];
            navItem["icon"] = screen["icon"];
            navItem["target"] = String(screen["id"].as<int>());
            
            logger->debug("Added nav item: " + navItem["label"].as<String>() + 
                         " -> " + navItem["target"].as<String>());
        }
        
        logger->info("Created " + String(menuItems.size()) + " navigation items");
    }
    
    rebuildForPage();
}

void HomeScreen::rebuildForPage() {
    // Clear content
    content->clearChildren();
    
    JsonArray menuItems = menuDoc.as<JsonArray>();
    
    int pageSize = Layout::getMaxItemsPerPage();
    int totalItems = menuItems.size(); // Removido +1 for config button
    navState.totalItems = totalItems;
    navState.totalPages = Layout::calculateTotalPages(totalItems);
    
    int startIdx = navState.currentPage * pageSize;
    int endIdx = std::min(startIdx + pageSize, totalItems);
    
    logger->debug("HomeScreen::rebuildForPage - Page " + String(navState.currentPage + 1) + "/" + String(navState.totalPages) +
                  " - Items " + String(startIdx) + " to " + String(endIdx - 1) +
                  " - Total menu items: " + String(menuItems.size()));
    
    // Add menu items for current page
    int idx = 0;
    for (JsonObject item : menuItems) {
        if (idx >= startIdx && idx < endIdx) {
            String type = item["type"] | "navigation";
            String label = item["label"] | "";
            String icon = item["icon"] | "folder";
            String id = item["id"] | "";
            String target = item["target"] | "";
            
            logger->debug("Creating button: " + label + " (icon: " + icon + ", target: " + target + ")");
            
            auto btn = new NavButton(content->getObject(), label, icon, id);
            
            if (type == "navigation" && !target.isEmpty()) {
                btn->setTarget(target);
                btn->setClickCallback([](NavButton* b) {
                    String btnTarget = b->getTarget();
                    logger->info("Navigation button clicked: " + b->getId() + " -> " + btnTarget);
                    if (screenManager && !btnTarget.isEmpty()) {
                        screenManager->navigateTo(btnTarget);
                    }
                });
            }
            
            content->addChild(btn->getObject());
        }
        idx++;
    }
    
    // Removido código que adicionava botão de configuração
    // int configIndex = menuItems.size();
    // if (configIndex >= startIdx && configIndex < endIdx) {
    //     addLocalConfigButton();
    // }
    
    // Update navigation buttons
    updateNavigationButtons();
}

// Método removido - botão de configuração não é mais adicionado localmente
// void HomeScreen::addLocalConfigButton() {
//     Removido - configurações devem vir da API
// }

void HomeScreen::onNavigate(NavigationDirection dir) {
    switch(dir) {
        case NAV_PREV:
            if (navState.currentPage > 0) {
                navState.currentPage--;
                rebuildForPage();
            }
            break;
            
        case NAV_HOME:
            // Already at home, do nothing
            break;
            
        case NAV_NEXT:
            if (navState.currentPage < navState.totalPages - 1) {
                navState.currentPage++;
                rebuildForPage();
            }
            break;
    }
}