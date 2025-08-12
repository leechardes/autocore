#ifndef SCREEN_BASE_H
#define SCREEN_BASE_H

#include <lvgl.h>
#include <Arduino.h>
#include "Header.h"
#include "GridContainer.h"
#include "NavigationBar.h"

struct NavigationState {
    String currentScreenId;
    int currentPage = 0;
    int selectedIndex = 0;
    int totalItems = 0;
    int totalPages = 0;
    bool isHome = true;
};

class ScreenBase {
protected:
    lv_obj_t* screen;
    Header* header;
    GridContainer* content;
    NavigationBar* navBar;

public:
    NavigationState navState;
    
public:
    ScreenBase();
    virtual ~ScreenBase();
    
    virtual void build();
    virtual void onNavigate(NavigationDirection dir);
    virtual void onSelect();
    virtual void updateNavigationButtons();
    virtual void rebuildContent();
    
    void setScreenId(const String& id) { navState.currentScreenId = id; }
    void setIsHome(bool home) { navState.isHome = home; }
    
    lv_obj_t* getScreen() { return screen; }
    Header* getHeader() { return header; }
    GridContainer* getContent() { return content; }
    NavigationBar* getNavBar() { return navBar; }
    
protected:
    virtual void createLayout();
};

#endif