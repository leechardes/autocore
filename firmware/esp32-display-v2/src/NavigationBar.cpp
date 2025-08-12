#include "NavigationBar.h"
#include "ui/Theme.h"
#include "Layout.h"

NavigationBar::NavigationBar(lv_obj_t* parent) {
    container = lv_obj_create(parent);
    createLayout();
}

NavigationBar::~NavigationBar() {
    if (container) {
        lv_obj_del(container);
    }
}

void NavigationBar::createLayout() {
    // Container principal já foi criado no construtor
    lv_obj_set_size(container, Layout::DISPLAY_WIDTH, Layout::NAVBAR_HEIGHT);
    lv_obj_align(container, LV_ALIGN_BOTTOM_MID, 0, 0);
    
    // Aplicar tema
    lv_obj_set_style_bg_color(container, COLOR_BACKGROUND, 0);
    lv_obj_set_style_border_width(container, 0, 0);
    lv_obj_set_style_pad_all(container, 5, 0);
    lv_obj_clear_flag(container, LV_OBJ_FLAG_SCROLLABLE);
    
    // Layout flexível
    lv_obj_set_flex_flow(container, LV_FLEX_FLOW_ROW);
    lv_obj_set_flex_align(container, LV_FLEX_ALIGN_SPACE_EVENLY, 
                          LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    
    // Criar botões
    createButton(prevBtn, LV_SYMBOL_LEFT, NAV_PREV);
    createButton(homeBtn, LV_SYMBOL_HOME, NAV_HOME);
    createButton(nextBtn, LV_SYMBOL_RIGHT, NAV_NEXT);
}

void NavigationBar::createButton(lv_obj_t*& btn, const char* label, NavigationDirection dir) {
    btn = lv_btn_create(container);
    lv_obj_set_size(btn, 90, 30);
    
    lv_obj_t* btnLabel = lv_label_create(btn);
    lv_label_set_text(btnLabel, label);
    lv_obj_center(btnLabel);
    
    // Handler de clique
    lv_obj_add_event_cb(btn, [](lv_event_t* e) {
        NavigationBar* navbar = (NavigationBar*)lv_event_get_user_data(e);
        NavigationDirection dir = (NavigationDirection)(intptr_t)lv_obj_get_user_data(lv_event_get_target(e));
        
        if (navbar->navigationCallback) {
            navbar->navigationCallback(dir);
        }
    }, LV_EVENT_CLICKED, this);
    
    lv_obj_set_user_data(btn, (void*)(intptr_t)dir);
    
    applyButtonTheme(btn, true);
}

void NavigationBar::applyButtonTheme(lv_obj_t* btn, bool enabled) {
    if (enabled) {
        // Usar mesma cor do botão quando pressionado (azul ciano)
        lv_obj_set_style_bg_color(btn, COLOR_BUTTON_SEL, 0);
        lv_obj_set_style_bg_color(btn, COLOR_BUTTON_ON, LV_STATE_PRESSED);
        lv_obj_set_style_text_color(btn, COLOR_TEXT_ON, 0);
        lv_obj_add_flag(btn, LV_OBJ_FLAG_CLICKABLE);
    } else {
        lv_obj_set_style_bg_color(btn, lv_color_hex(0x1a1a1a), 0);
        lv_obj_set_style_text_color(btn, lv_color_hex(0x666666), 0);
        lv_obj_clear_flag(btn, LV_OBJ_FLAG_CLICKABLE);
    }
    
    lv_obj_set_style_radius(btn, BUTTON_RADIUS, 0);
    lv_obj_set_style_border_width(btn, 0, 0); // Sem borda
}

void NavigationBar::setPrevEnabled(bool enabled) {
    applyButtonTheme(prevBtn, enabled);
}

void NavigationBar::setHomeEnabled(bool enabled) {
    applyButtonTheme(homeBtn, enabled);
}

void NavigationBar::setNextEnabled(bool enabled) {
    applyButtonTheme(nextBtn, enabled);
}