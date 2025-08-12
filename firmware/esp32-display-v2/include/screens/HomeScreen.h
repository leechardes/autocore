#ifndef HOME_SCREEN_H
#define HOME_SCREEN_H

#include "ScreenBase.h"
#include <ArduinoJson.h>

class HomeScreen : public ScreenBase {
private:
    StaticJsonDocument<2048> menuDoc;
    
public:
    HomeScreen();
    
    void setMenuItems(JsonArray items);
    
    void build() override;
    void onNavigate(NavigationDirection dir) override;
    
private:
    // void addLocalConfigButton(); // Removido - configurações vêm da API
    void rebuildForPage();
};

#endif // HOME_SCREEN_H