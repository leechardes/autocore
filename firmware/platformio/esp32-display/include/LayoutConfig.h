#ifndef LAYOUT_CONFIG_H
#define LAYOUT_CONFIG_H

#include "ui/Theme.h"  // Para ter acesso a DISPLAY_WIDTH, CONTENT_HEIGHT, etc.

/**
 * @file LayoutConfig.h
 * @brief Configurações centralizadas de layout para o display ESP32
 * 
 * Este arquivo concentra todos os ajustes de posicionamento,
 * margens e tamanhos para facilitar a manutenção e ajustes finos.
 */

// ============================================================================
// CONFIGURAÇÕES DO CONTAINER PRINCIPAL
// ============================================================================

// Margens do container principal (em pixels)
#define MAIN_CONTAINER_MARGIN_LEFT   5    // Margem esquerda do container principal
#define MAIN_CONTAINER_MARGIN_RIGHT  5    // Margem direita do container principal
#define MAIN_CONTAINER_MARGIN_TOP    0    // Margem superior do container principal
#define MAIN_CONTAINER_MARGIN_BOTTOM 0    // Margem inferior do container principal

// Largura e posição do container principal
#define MAIN_CONTAINER_WIDTH  (CURRENT_DISPLAY_WIDTH - MAIN_CONTAINER_MARGIN_LEFT - MAIN_CONTAINER_MARGIN_RIGHT)
#define MAIN_CONTAINER_X_POS  MAIN_CONTAINER_MARGIN_LEFT

// ============================================================================
// CONFIGURAÇÕES DO GRID CONTAINER
// ============================================================================

// Fallback para tamanhos do GridContainer quando não definidos
#define GRID_CONTAINER_FALLBACK_WIDTH  (CURRENT_DISPLAY_WIDTH - 16)   // 304px para display de 320px
#define GRID_CONTAINER_FALLBACK_HEIGHT (Layout::CONTENT_HEIGHT - 5)    // Margem de 5px no total

// Tamanho da área de conteúdo quando muito pequena
#define GRID_CONTENT_MIN_WIDTH  (CURRENT_DISPLAY_WIDTH - 20)  // 300px para display de 320px
#define GRID_CONTENT_MIN_HEIGHT (Layout::CONTENT_HEIGHT - 10)  // Margem de 10px no total

// Padding interno do container
#define GRID_CONTAINER_PADDING  2  // Padding interno mínimo em pixels

// ============================================================================
// CONFIGURAÇÕES DE POSICIONAMENTO DOS COMPONENTES
// ============================================================================

// Offsets para ajustar posição dos componentes dentro do grid
#define COMPONENT_LEFT_OFFSET   4   // Move componentes para direita (pixels) - ajustado após remover bordas
#define COMPONENT_TOP_OFFSET    2  // Move componentes para cima (pixels)

// Gap entre componentes do grid
#define GRID_COMPONENT_GAP      10  // Espaçamento entre componentes

// ============================================================================
// CONFIGURAÇÕES DE TAMANHO DOS COMPONENTES
// ============================================================================

// Tamanhos mínimos para componentes
#define COMPONENT_MIN_WIDTH     50  // Largura mínima de um componente
#define COMPONENT_MIN_HEIGHT    40  // Altura mínima de um componente

// Tamanhos específicos para componentes large
#define COMPONENT_LARGE_MIN_WIDTH  140  // Largura mínima para componentes large

// ============================================================================
// CONFIGURAÇÕES DE DEBUG
// ============================================================================

// Larguras das bordas de debug (em pixels)
#define DEBUG_BORDER_ROOT       4  // Borda do container principal
#define DEBUG_BORDER_DEFAULT    3  // Borda padrão para outros containers
#define DEBUG_BORDER_COMPONENT  2  // Borda para componentes individuais

// ============================================================================
// MACROS DE CONVENIÊNCIA
// ============================================================================

// Calcula largura total do container principal
#define CALCULATE_MAIN_WIDTH()    (CURRENT_DISPLAY_WIDTH - MAIN_CONTAINER_MARGIN_LEFT - MAIN_CONTAINER_MARGIN_RIGHT)

// Calcula posição X do container principal
#define CALCULATE_MAIN_X_POS()    MAIN_CONTAINER_MARGIN_LEFT

// Verifica se um tamanho é muito pequeno e precisa de fallback
#define NEEDS_WIDTH_FALLBACK(w)  ((w) < 100)
#define NEEDS_HEIGHT_FALLBACK(h) ((h) < 80)

#endif // LAYOUT_CONFIG_H