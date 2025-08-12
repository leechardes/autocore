#ifndef NAVIGATION_BAR_H
#define NAVIGATION_BAR_H

#include <lvgl.h>
#include <functional>

enum NavigationDirection {
    NAV_PREV,
    NAV_HOME,
    NAV_NEXT
};

class NavigationBar {
private:
    lv_obj_t* container;
    lv_obj_t* prevBtn;
    lv_obj_t* homeBtn;
    lv_obj_t* nextBtn;
    
    std::function<void(NavigationDirection)> navigationCallback;
    
    void createLayout();
    void createButton(lv_obj_t*& btn, const char* label, NavigationDirection dir);
    void applyButtonTheme(lv_obj_t* btn, bool enabled);
    
public:
    NavigationBar(lv_obj_t* parent);
    ~NavigationBar();
    
    void setPrevEnabled(bool enabled);
    void setHomeEnabled(bool enabled);
    void setNextEnabled(bool enabled);
    
    void setNavigationCallback(std::function<void(NavigationDirection)> callback) {
        navigationCallback = callback;
    }
    
    lv_obj_t* getObject() { return container; }
};

#endif