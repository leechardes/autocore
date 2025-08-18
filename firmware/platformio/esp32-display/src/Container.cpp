#include "Container.h"
#include "ui/Theme.h"
#include <algorithm>
#include <Arduino.h>

Container::Container(lv_obj_t* parent) : margin(10), gap(10) {
    obj = lv_obj_create(parent);
    applyTheme();
}

Container::~Container() {
    clearChildren();
    if (obj) {
        lv_obj_del(obj);
    }
}

void Container::addChild(lv_obj_t* child) {
    if (child) {
        // Verificar se parent está correto antes de adicionar
        lv_obj_t* childParent = lv_obj_get_parent(child);
        if (childParent != obj) {
            Serial.printf("[Container] WARNING: Child parent mismatch. Expected %p, got %p\n", obj, childParent);
            // Se necessário, corrigir o parent
            lv_obj_set_parent(child, obj);
        }
        
        children.push_back(child);
        Serial.printf("[Container] Added child %p to container %p, total children: %d\n", 
                      child, obj, (int)children.size());
        
        // Forçar visibilidade e garantir que o child não tem scroll
        lv_obj_clear_flag(child, LV_OBJ_FLAG_HIDDEN);
        lv_obj_clear_flag(child, LV_OBJ_FLAG_SCROLLABLE);
        lv_obj_set_scroll_dir(child, LV_DIR_NONE);
        lv_obj_set_scrollbar_mode(child, LV_SCROLLBAR_MODE_OFF);
        
        // Aplicar posição e tamanho inicial temporário
        lv_obj_set_size(child, 50, 50);
        lv_obj_set_pos(child, 0, 0);
        
        // Forçar atualização do layout
        updateLayout();
        
        Serial.printf("[Container] Child added successfully. Final children count: %d\n", (int)children.size());
    } else {
        Serial.println("[Container] ERROR: Tried to add null child!");
    }
}

void Container::removeChild(lv_obj_t* child) {
    auto it = std::find(children.begin(), children.end(), child);
    if (it != children.end()) {
        lv_obj_del(child);
        children.erase(it);
        updateLayout();
    }
}

void Container::clearChildren() {
    for (auto child : children) {
        lv_obj_del(child);
    }
    children.clear();
}

void Container::setMargins(int newMargin) {
    margin = newMargin;
    lv_obj_set_style_pad_all(obj, margin, 0);
    updateLayout();
}

void Container::setGap(int newGap) {
    gap = newGap;
    updateLayout();
}

void Container::setSize(int width, int height) {
    // Serial.printf("[Container] Setting size to %dx%d\n", width, height);
    lv_obj_set_size(obj, width, height);
    updateLayout();
}

void Container::setPosition(int x, int y) {
    // Serial.printf("[Container] Setting position to (%d, %d)\n", x, y);
    lv_obj_set_pos(obj, x, y);
}

void Container::applyTheme() {
    lv_obj_set_style_bg_color(obj, COLOR_BACKGROUND, 0);
    lv_obj_set_style_border_width(obj, 0, 0); // Sem borda
    lv_obj_set_style_pad_top(obj, 0, 0);     // Sem margem superior
    lv_obj_set_style_pad_bottom(obj, 5, 0);  // Margem inferior de 5px
    lv_obj_set_style_pad_left(obj, margin, 0);   // Margem esquerda
    lv_obj_set_style_pad_right(obj, margin, 0);  // Margem direita
    
    // GARANTIR QUE NÃO HÁ SCROLL EM NENHUMA SITUAÇÃO
    lv_obj_clear_flag(obj, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_set_scroll_dir(obj, LV_DIR_NONE);  // Desabilitar scroll em todas as direções
    lv_obj_set_scrollbar_mode(obj, LV_SCROLLBAR_MODE_OFF); // Desabilitar scrollbars
}