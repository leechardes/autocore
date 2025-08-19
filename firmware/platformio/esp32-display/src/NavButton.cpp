#include "NavButton.h"
#include "ui/Theme.h"
#include "ui/Icons.h"
#include "utils/StringUtils.h"
#include "core/Logger.h"
#include <Arduino.h>

extern Logger* logger;

// Cores de debug para NavButtons
lv_color_t NAVBUTTON_DEBUG_COLORS[] = {
    lv_color_make(255, 128, 0),    // LARANJA - NavButton
    lv_color_make(128, 0, 255),    // ROXO - Ícone
    lv_color_make(0, 255, 128),    // VERDE NEON - Label
};

const char* NAVBUTTON_COLOR_NAMES[] = {
    "LARANJA", "ROXO", "VERDE_NEON"
};

enum NavButtonColorIndex {
    NAVBUTTON_COLOR_IDX_BUTTON = 0,   // LARANJA
    NAVBUTTON_COLOR_IDX_ICON = 1,     // ROXO
    NAVBUTTON_COLOR_IDX_LABEL = 2     // VERDE NEON
};

/**
 * Aplica borda colorida para debug em NavButtons
 */
void applyNavButtonDebugBorder(lv_obj_t* obj, NavButtonColorIndex colorIndex, const String& elementType) {
    if (!obj) return;
    
    // Aplicar borda colorida para debug
    lv_obj_set_style_border_width(obj, 2, 0);
    lv_obj_set_style_border_color(obj, NAVBUTTON_DEBUG_COLORS[colorIndex], 0);
    lv_obj_set_style_border_opa(obj, LV_OPA_100, 0);
    
    // Log informativo com tamanho do elemento
    if (logger) {
        lv_coord_t width = lv_obj_get_width(obj);
        lv_coord_t height = lv_obj_get_height(obj);
        logger->info("[NAVBUTTON DEBUG] " + elementType + ": Borda " + String(NAVBUTTON_COLOR_NAMES[colorIndex]) + 
                    " (" + String(width) + "x" + String(height) + ")");
    }
}

NavButton::NavButton(lv_obj_t* parent, const String& text, const String& iconId, const String& buttonId) 
    : id(buttonId) {
    button = lv_btn_create(parent);
    
    // Serial.printf("[NavButton] Creating button '%s' with id '%s'\n", text.c_str(), buttonId.c_str());
    
    // CORREÇÃO: Não definir tamanho fixo aqui - será definido pelo GridContainer
    // baseado no size_display_small do componente
    // lv_obj_set_size(button, 80, 60);  // REMOVIDO
    
    createLayout(text, iconId);
    applyTheme();
    
    // ADIÇÃO DEBUG: Aplicar borda LARANJA no NavButton
    applyNavButtonDebugBorder(button, NAVBUTTON_COLOR_IDX_BUTTON, "NavButton (" + text + ")");
    
    // Verificar posição e tamanho final - removido
    
    // Verificação de visibilidade removida
    
    // Handler de eventos com suporte a press/release para botões momentâneos
    lv_obj_add_event_cb(button, [](lv_event_t* e) {
        NavButton* navBtn = (NavButton*)lv_event_get_user_data(e);
        lv_event_code_t event = lv_event_get_code(e);
        
        if (navBtn->functionType == "momentary") {
            // Para botões momentâneos: press/release
            if (event == LV_EVENT_PRESSED) {
                navBtn->setPressed(true);
                if (navBtn->clickCallback) {
                    navBtn->clickCallback(navBtn);
                }
            } else if (event == LV_EVENT_RELEASED) {
                navBtn->setPressed(false);
                if (navBtn->clickCallback) {
                    navBtn->clickCallback(navBtn);
                }
            }
        } else {
            // Para botões toggle: apenas clicked com debounce
            if (event == LV_EVENT_CLICKED) {
                static unsigned long lastClickTime = 0;
                unsigned long now = millis();
                
                // Debounce - 500ms para evitar múltiplos comandos
                if (now - lastClickTime < 500) {
                    return;
                }
                lastClickTime = now;
                
                if (navBtn->clickCallback) {
                    navBtn->clickCallback(navBtn);
                }
            }
        }
    }, LV_EVENT_ALL, this);
}

NavButton::~NavButton() {
    if (button) {
        lv_obj_del(button);
    }
}

void NavButton::createLayout(const String& text, const String& iconId) {
    // Layout vertical
    lv_obj_set_flex_flow(button, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_flex_align(button, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    
    // Ícone
    icon = lv_label_create(button);
    const char* iconSymbol = Icons::getIcon(iconId.c_str());
    lv_label_set_text(icon, iconSymbol);
    lv_obj_set_style_text_font(icon, &lv_font_montserrat_20, 0);  // Voltando para 20 (maior)
    
    // ADIÇÃO DEBUG: Aplicar borda ROXA no ícone
    applyNavButtonDebugBorder(icon, NAVBUTTON_COLOR_IDX_ICON, "NavButton Icon");
    
    // Label - remover acentos
    label = lv_label_create(button);
    String cleanText = StringUtils::removeAccents(text);
    lv_label_set_text(label, cleanText.c_str());
    lv_obj_set_style_text_font(label, &lv_font_montserrat_10, 0);  // Fonte menor
    lv_label_set_long_mode(label, LV_LABEL_LONG_WRAP);
    lv_obj_set_width(label, lv_pct(90));
    lv_obj_set_style_text_align(label, LV_TEXT_ALIGN_CENTER, 0);
    
    // ADIÇÃO DEBUG: Aplicar borda VERDE NEON no label
    applyNavButtonDebugBorder(label, NAVBUTTON_COLOR_IDX_LABEL, "NavButton Label");
}

void NavButton::applyTheme() {
    // Estilo do botão
    lv_obj_set_style_bg_color(button, COLOR_BUTTON_OFF, 0);
    lv_obj_set_style_bg_color(button, COLOR_BUTTON_SEL, LV_STATE_PRESSED);
    lv_obj_set_style_radius(button, BUTTON_RADIUS, 0);
    lv_obj_set_style_border_width(button, 0, 0); // Sem borda
    lv_obj_set_style_pad_all(button, 8, 0); // Padding normal
    
    // Estilo do texto
    lv_obj_set_style_text_color(icon, COLOR_TEXT_OFF, 0);
    lv_obj_set_style_text_color(label, COLOR_TEXT_OFF, 0);
}

void NavButton::setState(bool on) {
    isOn = on;
    updateStyle();
}

void NavButton::updateStyle() {
    if (isOn) {
        lv_obj_set_style_bg_color(button, COLOR_BUTTON_ON, 0);
        lv_obj_set_style_text_color(icon, COLOR_TEXT_ON, 0);
        lv_obj_set_style_text_color(label, COLOR_TEXT_ON, 0);
    } else {
        lv_obj_set_style_bg_color(button, COLOR_BUTTON_OFF, 0);
        lv_obj_set_style_text_color(icon, COLOR_TEXT_OFF, 0);
        lv_obj_set_style_text_color(label, COLOR_TEXT_OFF, 0);
    }
}