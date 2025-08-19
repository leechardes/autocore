#include "Container.h"
#include "ui/Theme.h"
#include "core/Logger.h"
#include <algorithm>
#include <Arduino.h>

extern Logger* logger;

// Cores de debug para containers base
lv_color_t BASE_CONTAINER_DEBUG_COLORS[] = {
    lv_color_make(255, 255, 0),    // AMARELO BRILHANTE - Container Base
    lv_color_make(255, 0, 255),    // MAGENTA - Child Container
    lv_color_make(0, 255, 255),    // CIANO - Sub Container
};

const char* BASE_CONTAINER_COLOR_NAMES[] = {
    "AMARELO_BRILHANTE", "MAGENTA", "CIANO"
};

enum BaseContainerColorIndex {
    BASE_COLOR_IDX_MAIN = 0,         // AMARELO BRILHANTE
    BASE_COLOR_IDX_CHILD = 1,        // MAGENTA
    BASE_COLOR_IDX_SUB = 2           // CIANO
};

/**
 * Aplica borda colorida para debug em containers base
 */
void applyBaseContainerDebugBorder(lv_obj_t* obj, BaseContainerColorIndex colorIndex, const String& containerType) {
    if (!obj) return;
    
    // Aplicar borda colorida para debug
    lv_obj_set_style_border_width(obj, 3, 0);
    lv_obj_set_style_border_color(obj, BASE_CONTAINER_DEBUG_COLORS[colorIndex], 0);
    lv_obj_set_style_border_opa(obj, LV_OPA_100, 0);
    
    // Log informativo com tamanho do container
    if (logger) {
        // CORREÇÃO: Forçar atualização de layout antes de obter tamanhos
        lv_obj_update_layout(obj);
        lv_coord_t width = lv_obj_get_width(obj);
        lv_coord_t height = lv_obj_get_height(obj);
        logger->info("[BASE CONTAINER DEBUG] " + containerType + ": Borda " + String(BASE_CONTAINER_COLOR_NAMES[colorIndex]) + 
                    " (" + String(width) + "x" + String(height) + ")");
    }
}

Container::Container(lv_obj_t* parent) : margin(5), gap(10) {
    obj = lv_obj_create(parent);
    applyTheme();
    
    // DEBUG REMOVIDO: Bordas coloridas desabilitadas
    // applyBaseContainerDebugBorder(obj, BASE_COLOR_IDX_MAIN, "Container Base");
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
            // Serial.printf("[Container] INFO: Correcting child parent. Expected %p, got %p\n", obj, childParent);
            // CORREÇÃO: Sempre corrigir o parent para evitar problemas de layout
            lv_obj_set_parent(child, obj);
        }
        
        children.push_back(child);
        // Serial.printf("[Container] Added child %p to container %p, total children: %d\n", 
        //               child, obj, (int)children.size());
        
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
        
        // Serial.printf("[Container] Child added successfully. Final children count: %d\n", (int)children.size());
    } else {
        // Serial.println("[Container] ERROR: Tried to add null child!");
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
    lv_obj_set_style_pad_top(obj, 2, 0);     // Margem superior mínima: 2px
    lv_obj_set_style_pad_bottom(obj, 2, 0);  // Margem inferior mínima: 2px
    lv_obj_set_style_pad_left(obj, 5, 0);    // Margem esquerda reduzida: 5px
    lv_obj_set_style_pad_right(obj, 5, 0);   // Margem direita reduzida: 5px
    
    // GARANTIR QUE NÃO HÁ SCROLL EM NENHUMA SITUAÇÃO
    lv_obj_clear_flag(obj, LV_OBJ_FLAG_SCROLLABLE);
    lv_obj_set_scroll_dir(obj, LV_DIR_NONE);  // Desabilitar scroll em todas as direções
    lv_obj_set_scrollbar_mode(obj, LV_SCROLLBAR_MODE_OFF); // Desabilitar scrollbars
}