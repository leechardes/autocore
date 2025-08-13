/**
 * @file Theme.h
 * @brief Definições de cores e estilos do tema AutoCore
 */

#ifndef THEME_H
#define THEME_H

#include <lvgl.h>

// ============================================================================
// CORES DO TEMA
// ============================================================================

// Cores principais
#define COLOR_BACKGROUND    lv_color_hex(0x101010)  // Quase preto (fundo)
#define COLOR_BUTTON_OFF    lv_color_hex(0x2a2a2a)  // Cinza escuro (botão desligado)
#define COLOR_BUTTON_ON     lv_color_hex(0x00aa44)  // Verde (botão ligado)
#define COLOR_BUTTON_SEL    lv_color_hex(0x00aaff)  // Azul ciano (selecionado)
#define COLOR_TEXT_OFF      lv_color_hex(0xcccccc)  // Texto claro
#define COLOR_TEXT_ON       lv_color_hex(0xffffff)  // Texto branco
#define COLOR_NAV_BG        lv_color_hex(0x00aaff)  // Azul para navegação

// Cores adicionais
#define COLOR_BORDER        lv_color_hex(0x404040)  // Bordas sutis
#define COLOR_SHADOW        lv_color_hex(0x000000)  // Sombras
#define COLOR_HIGHLIGHT     lv_color_hex(0x00ccff)  // Realce
#define COLOR_WARNING       lv_color_hex(0xffaa00)  // Aviso
#define COLOR_ERROR         lv_color_hex(0xff0044)  // Erro

// ============================================================================
// ESTILOS PADRÃO
// ============================================================================

// Tamanhos
#define BUTTON_WIDTH        140
#define BUTTON_HEIGHT       50
#define BUTTON_RADIUS       8
#define BUTTON_BORDER       2
#define BUTTON_MARGIN       5

// Fontes
#define FONT_TITLE          &lv_font_montserrat_20
#define FONT_BUTTON         &lv_font_montserrat_16
#define FONT_LABEL          &lv_font_montserrat_14
#define FONT_SMALL          &lv_font_montserrat_12

// ============================================================================
// FUNÇÕES DE ESTILO
// ============================================================================

/**
 * @brief Aplica o tema AutoCore na tela
 * @param screen Objeto da tela
 */
static inline void theme_apply_screen(lv_obj_t* screen) {
    lv_obj_remove_style_all(screen);
    lv_obj_set_style_bg_color(screen, COLOR_BACKGROUND, 0);
    lv_obj_set_style_bg_opa(screen, LV_OPA_COVER, 0);
    lv_obj_set_style_border_width(screen, 0, 0);
    lv_obj_set_style_pad_all(screen, 0, 0);
}

/**
 * @brief Aplica estilo de botão OFF
 * @param btn Objeto do botão
 */
static inline void theme_apply_button_off(lv_obj_t* btn) {
    lv_obj_set_style_bg_color(btn, COLOR_BUTTON_OFF, 0);
    lv_obj_set_style_bg_opa(btn, LV_OPA_COVER, 0);
    lv_obj_set_style_border_color(btn, COLOR_BUTTON_OFF, 0);
    lv_obj_set_style_border_width(btn, BUTTON_BORDER, 0);
    lv_obj_set_style_border_opa(btn, LV_OPA_50, 0);
    lv_obj_set_style_text_color(btn, COLOR_TEXT_OFF, 0);
    lv_obj_set_style_radius(btn, BUTTON_RADIUS, 0);
}

/**
 * @brief Aplica estilo de botão ON
 * @param btn Objeto do botão
 */
static inline void theme_apply_button_on(lv_obj_t* btn) {
    lv_obj_set_style_bg_color(btn, COLOR_BUTTON_ON, 0);
    lv_obj_set_style_bg_opa(btn, LV_OPA_COVER, 0);
    lv_obj_set_style_border_color(btn, COLOR_BUTTON_ON, 0);
    lv_obj_set_style_border_width(btn, BUTTON_BORDER, 0);
    lv_obj_set_style_border_opa(btn, LV_OPA_COVER, 0);
    lv_obj_set_style_text_color(btn, COLOR_TEXT_ON, 0);
    lv_obj_set_style_radius(btn, BUTTON_RADIUS, 0);
}

/**
 * @brief Aplica estilo de botão selecionado
 * @param btn Objeto do botão
 */
static inline void theme_apply_button_selected(lv_obj_t* btn) {
    lv_obj_set_style_bg_color(btn, COLOR_BUTTON_OFF, 0);
    lv_obj_set_style_bg_opa(btn, LV_OPA_COVER, 0);
    lv_obj_set_style_border_color(btn, COLOR_BUTTON_SEL, 0);
    lv_obj_set_style_border_width(btn, BUTTON_BORDER + 1, 0);
    lv_obj_set_style_border_opa(btn, LV_OPA_COVER, 0);
    lv_obj_set_style_text_color(btn, COLOR_TEXT_ON, 0);
    lv_obj_set_style_radius(btn, BUTTON_RADIUS, 0);
}

/**
 * @brief Aplica estilo de botão de navegação
 * @param btn Objeto do botão
 */
static inline void theme_apply_nav_button(lv_obj_t* btn) {
    lv_obj_set_style_bg_color(btn, COLOR_NAV_BG, 0);
    lv_obj_set_style_bg_opa(btn, LV_OPA_COVER, 0);
    lv_obj_set_style_border_width(btn, 0, 0);
    lv_obj_set_style_text_color(btn, COLOR_TEXT_ON, 0);
    lv_obj_set_style_radius(btn, BUTTON_RADIUS, 0);
}

/**
 * @brief Aplica estilo de título
 * @param label Objeto do label
 */
static inline void theme_apply_title(lv_obj_t* label) {
    lv_obj_set_style_text_color(label, COLOR_TEXT_ON, 0);
    lv_obj_set_style_text_font(label, FONT_TITLE, 0);
}

/**
 * @brief Aplica estilo de label padrão
 * @param label Objeto do label
 */
static inline void theme_apply_label(lv_obj_t* label) {
    lv_obj_set_style_text_color(label, COLOR_TEXT_OFF, 0);
    lv_obj_set_style_text_font(label, FONT_LABEL, 0);
}

#endif // THEME_H