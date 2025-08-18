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

// Cores específicas para widgets
#define COLOR_CARD_BG       lv_color_hex(0x1a1a1a)  // Fundo de cards
#define COLOR_TEXT_MUTED    lv_color_hex(0x888888)  // Texto secundário
#define COLOR_GAUGE_NORMAL  lv_color_hex(0x00aa44)  // Verde para zona normal
#define COLOR_GAUGE_WARNING lv_color_hex(0xff9600)  // Laranja para zona warning
#define COLOR_GAUGE_CRITICAL lv_color_hex(0xff0044) // Vermelho para zona crítica

// ============================================================================
// ESTILOS PADRÃO
// ============================================================================

// Tamanhos
#define BUTTON_WIDTH        140
#define BUTTON_HEIGHT       50
#define BUTTON_RADIUS       8
#define BUTTON_BORDER       2
#define BUTTON_MARGIN       5

// Tamanhos para novos widgets
#define CARD_RADIUS         8
#define CARD_PADDING        12
#define GAUGE_SIZE_SMALL    80
#define GAUGE_SIZE_NORMAL   100
#define GAUGE_SIZE_LARGE    120

// ============================================================================
// CONFIGURAÇÕES DE DISPLAY E GRID
// ============================================================================

// Display Small (320x240) - atual padrão
#define DISPLAY_S_WIDTH     320
#define DISPLAY_S_HEIGHT    240
#define DISPLAY_S_COLS      3
#define DISPLAY_S_ROWS      2
#define DISPLAY_S_MAX_SLOTS 6

// Display Medium (480x320) - futuro
#define DISPLAY_M_WIDTH     480
#define DISPLAY_M_HEIGHT    320
#define DISPLAY_M_COLS      4
#define DISPLAY_M_ROWS      2
#define DISPLAY_M_MAX_SLOTS 8

// Display Large (800x480) - futuro
#define DISPLAY_L_WIDTH     800
#define DISPLAY_L_HEIGHT    480
#define DISPLAY_L_COLS      5
#define DISPLAY_L_ROWS      3
#define DISPLAY_L_MAX_SLOTS 15

// Configuração atual em uso (pode ser alterada dinamicamente)
#define CURRENT_DISPLAY_WIDTH  DISPLAY_S_WIDTH
#define CURRENT_DISPLAY_HEIGHT DISPLAY_S_HEIGHT
#define CURRENT_DISPLAY_COLS   DISPLAY_S_COLS
#define CURRENT_DISPLAY_ROWS   DISPLAY_S_ROWS
#define CURRENT_MAX_SLOTS      DISPLAY_S_MAX_SLOTS

// Tamanhos de slot para componentes (baseado no display atual)
#define SLOT_SMALL          1   // Ocupa 1 slot
#define SLOT_NORMAL         1   // Ocupa 1 slot
#define SLOT_LARGE          2   // Ocupa 2 slots horizontais
#define SLOT_FULL           CURRENT_DISPLAY_COLS   // Ocupa linha inteira

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

/**
 * @brief Aplica estilo de label pequeno/secundário
 * @param label Objeto do label
 */
static inline void theme_apply_label_small(lv_obj_t* label) {
    lv_obj_set_style_text_color(label, COLOR_TEXT_MUTED, 0);
    lv_obj_set_style_text_font(label, FONT_SMALL, 0);
}

/**
 * @brief Aplica estilo de ícone
 * @param label Objeto do label de ícone
 */
static inline void theme_apply_icon(lv_obj_t* label) {
    lv_obj_set_style_text_color(label, COLOR_TEXT_OFF, 0);
    lv_obj_set_style_text_font(label, FONT_LABEL, 0);
}

/**
 * @brief Aplica estilo de card container
 * @param card Objeto do card
 */
static inline void theme_apply_card(lv_obj_t* card) {
    lv_obj_set_style_bg_color(card, COLOR_CARD_BG, 0);
    lv_obj_set_style_bg_opa(card, LV_OPA_COVER, 0);
    lv_obj_set_style_border_color(card, COLOR_BORDER, 0);
    lv_obj_set_style_border_width(card, 1, 0);
    lv_obj_set_style_radius(card, CARD_RADIUS, 0);
    lv_obj_set_style_pad_all(card, CARD_PADDING, 0);
}

#endif // THEME_H