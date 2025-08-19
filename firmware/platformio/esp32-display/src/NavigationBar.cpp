#include "NavigationBar.h"
#include "ui/Theme.h"
#include "Layout.h"
#include "core/Logger.h"

extern Logger* logger;

// Cores de debug para botões da navigation bar
lv_color_t NAVBAR_DEBUG_COLORS[] = {
    lv_color_make(255, 0, 128),    // PINK - Botão Prev
    lv_color_make(128, 255, 0),    // VERDE LIMA - Botão Home
    lv_color_make(0, 128, 255),    // AZUL ROYAL - Botão Next
};

const char* NAVBAR_COLOR_NAMES[] = {
    "PINK", "VERDE_LIMA", "AZUL_ROYAL"
};

enum NavbarColorIndex {
    NAVBAR_COLOR_IDX_PREV = 0,       // PINK
    NAVBAR_COLOR_IDX_HOME = 1,       // VERDE LIMA
    NAVBAR_COLOR_IDX_NEXT = 2        // AZUL ROYAL
};

/**
 * Aplica borda colorida para debug em botões da navigation bar
 */
void applyNavbarDebugBorder(lv_obj_t* obj, NavbarColorIndex colorIndex, const String& buttonType) {
    if (!obj || !logger) return;
    
    // Aplicar borda colorida para debug
    lv_obj_set_style_border_width(obj, 2, 0);
    lv_obj_set_style_border_color(obj, NAVBAR_DEBUG_COLORS[colorIndex], 0);
    lv_obj_set_style_border_opa(obj, LV_OPA_100, 0);
    
    // Log informativo com tamanho do botão
    // CORREÇÃO: Forçar atualização de layout antes de obter tamanhos
    lv_obj_update_layout(obj);
    lv_coord_t width = lv_obj_get_width(obj);
    lv_coord_t height = lv_obj_get_height(obj);
    logger->info("[NAVBAR DEBUG] " + buttonType + ": Borda " + String(NAVBAR_COLOR_NAMES[colorIndex]) + 
                " (" + String(width) + "x" + String(height) + ")");
}

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
    
    // DEBUG REMOVIDO: Bordas coloridas desabilitadas
    // applyNavbarDebugBorder(prevBtn, NAVBAR_COLOR_IDX_PREV, "Botão Prev");
    // applyNavbarDebugBorder(homeBtn, NAVBAR_COLOR_IDX_HOME, "Botão Home");
    // applyNavbarDebugBorder(nextBtn, NAVBAR_COLOR_IDX_NEXT, "Botão Next");
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
        
        // Log do clique
        extern Logger* logger;
        if (logger) {
            String dirStr = (dir == NAV_PREV) ? "PREV" : (dir == NAV_HOME) ? "HOME" : "NEXT";
            logger->info("[NavigationBar] Button clicked: " + dirStr);
        }
        
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
    if (logger) {
        logger->debug("[NavigationBar] setPrevEnabled: " + String(enabled ? "true" : "false"));
    }
    applyButtonTheme(prevBtn, enabled);
}

void NavigationBar::setHomeEnabled(bool enabled) {
    if (logger) {
        logger->debug("[NavigationBar] setHomeEnabled: " + String(enabled ? "true" : "false"));
    }
    applyButtonTheme(homeBtn, enabled);
}

void NavigationBar::setNextEnabled(bool enabled) {
    if (logger) {
        logger->debug("[NavigationBar] setNextEnabled: " + String(enabled ? "true" : "false"));
    }
    applyButtonTheme(nextBtn, enabled);
}