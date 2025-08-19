#include "GridContainer.h"
#include "LayoutConfig.h"
#include "core/Logger.h"

extern Logger* logger;

// Array de cores para bordas de debug - facilita identificação visual
lv_color_t DEBUG_BORDER_COLORS[] = {
    lv_color_make(255, 0, 0),    // Vermelho
    lv_color_make(0, 255, 0),    // Verde
    lv_color_make(0, 0, 255),    // Azul
    lv_color_make(255, 255, 0),  // Amarelo
    lv_color_make(255, 0, 255),  // Magenta
    lv_color_make(0, 255, 255),  // Ciano
    lv_color_make(255, 165, 0),  // Laranja
    lv_color_make(128, 0, 128),  // Roxo
    lv_color_make(255, 192, 203), // Rosa
    lv_color_make(0, 128, 0)     // Verde Escuro
};

const char* DEBUG_COLOR_NAMES[] = {
    "VERMELHO", "VERDE", "AZUL", "AMARELO", "MAGENTA", 
    "CIANO", "LARANJA", "ROXO", "ROSA", "VERDE_ESCURO"
};

const int DEBUG_COLORS_COUNT = sizeof(DEBUG_BORDER_COLORS) / sizeof(DEBUG_BORDER_COLORS[0]);

/**
 * Aplica borda colorida para debug/identificação visual
 * @param obj Objeto LVGL para aplicar a borda
 * @param colorIndex Índice da cor no array de cores
 * @param label Label/nome do componente para logs
 * @param componentInfo Informações adicionais do componente (name, label, icon)
 */
void applyDebugBorder(lv_obj_t* obj, int colorIndex, const String& label, const String& componentInfo = "") {
    if (!obj) return;
    
    // Usar modulo para não estourar o array
    int safeColorIndex = colorIndex % DEBUG_COLORS_COUNT;
    
    // Aplicar borda colorida para debug
    lv_obj_set_style_border_width(obj, 3, 0);  // 3px de largura
    lv_obj_set_style_border_color(obj, DEBUG_BORDER_COLORS[safeColorIndex], 0);
    lv_obj_set_style_border_opa(obj, LV_OPA_100, 0);  // Opacidade total
    
    // Log informativo com tamanho do container
    if (logger) {
        // CORREÇÃO: Forçar atualização de layout antes de obter tamanhos
        lv_obj_update_layout(obj);
        lv_coord_t width = lv_obj_get_width(obj);
        lv_coord_t height = lv_obj_get_height(obj);
        String logMsg = "[DEBUG BORDER] " + label;
        if (!componentInfo.isEmpty()) {
            logMsg += " (" + componentInfo + ")";
        }
        logMsg += ": Borda " + String(DEBUG_COLOR_NAMES[safeColorIndex]) + 
                  " (" + String(width) + "x" + String(height) + ")";
        logger->info(logMsg);
    }
}

GridContainer::GridContainer(lv_obj_t* parent) : Container(parent) {
    // Container base já cria o objeto e aplica tema
}

void GridContainer::setGridSize(int cols, int rows) {
    maxColumns = cols;
    maxRows = rows;
    updateLayout();
}

void GridContainer::updateLayout() {
    int itemCount = children.size();
    if (itemCount == 0) {
        return;
    }
    
    // Log para debug
    logger->info("[GridContainer] Updating layout with " + String(itemCount) + " items using grid 3x2");
    
    // PRIMEIRO: Garantir que o container tem tamanho adequado
    int containerWidth = lv_obj_get_width(obj);
    int containerHeight = lv_obj_get_height(obj);
    
    // CORREÇÃO: Se o container não tem tamanho definido, forçar tamanho otimizado
    if (containerWidth <= 10 || containerHeight <= 10) {
        // Usar configurações centralizadas do LayoutConfig.h
        containerWidth = GRID_CONTAINER_FALLBACK_WIDTH;
        containerHeight = GRID_CONTAINER_FALLBACK_HEIGHT;
        
        // Definir tamanho explicitamente
        lv_obj_set_size(obj, containerWidth, containerHeight);
        
        // Forçar atualização do layout LVGL
        lv_obj_update_layout(obj);
        
        logger->info("[GridContainer] Forced container size to: " + String(containerWidth) + "x" + String(containerHeight));
    }
    
    // Usar tamanho do conteúdo (área disponível para children)
    int contentWidth = lv_obj_get_content_width(obj);
    int contentHeight = lv_obj_get_content_height(obj);
    
    // CORREÇÃO: Se content area for muito pequena, usar valores otimizados
    if (NEEDS_WIDTH_FALLBACK(contentWidth)) contentWidth = GRID_CONTENT_MIN_WIDTH;
    if (NEEDS_HEIGHT_FALLBACK(contentHeight)) contentHeight = GRID_CONTENT_MIN_HEIGHT;
    
    logger->info("[GridContainer] Content area: " + String(contentWidth) + "x" + String(contentHeight));
    
    Size containerSize = {
        contentWidth,
        contentHeight
    };
    
    // Calcular tamanho das células do grid 3x2
    Size cellSize = Layout::calculateGridCellSize(containerSize);
    
    logger->info("[GRID DEBUG] Cell calculation:");
    logger->info("[GRID DEBUG]   Container: " + String(contentWidth) + "x" + String(contentHeight));
    logger->info("[GRID DEBUG]   Grid: " + String(Layout::GRID_COLS) + " cols x " + String(Layout::GRID_ROWS) + " rows");
    logger->info("[GRID DEBUG]   Spacing: 10px");
    logger->info("[GRID DEBUG]   Calculated cell size: " + String(cellSize.width) + "x" + String(cellSize.height));
    
    // VERIFICAÇÃO CRÍTICA: Se células são muito pequenas, usar valores mínimos
    if (cellSize.width < 50) cellSize.width = 80;
    if (cellSize.height < 40) cellSize.height = 60;
    
    // Layout de componentes em grid 3x2
    int currentCol = 0;
    int currentRow = 0;
    
    for (int i = 0; i < itemCount; i++) {
        // Verificar se o child é válido
        if (!children[i]) {
            logger->error("[GridContainer] Child " + String(i) + " is NULL!");
            continue;
        }
        
        // SOLUÇÃO: Ler o ComponentSize diretamente do user_data do objeto
        // O ScreenFactory já armazenou o tamanho correto no user_data
        ComponentSize size = (ComponentSize)(intptr_t)lv_obj_get_user_data(children[i]);
        String sizeType = "normal";
        
        // Validar e aplicar defaults se necessário
        if (size < SIZE_SMALL || size > SIZE_FULL) {
            logger->warning("[GridContainer] Invalid ComponentSize in user_data: " + String((int)size) + ", using NORMAL");
            size = SIZE_NORMAL;
        }
        
        // Converter ComponentSize para string para logs
        switch(size) {
            case SIZE_SMALL:
                sizeType = "small";
                break;
            case SIZE_NORMAL:
                sizeType = "normal";
                break;
            case SIZE_LARGE:
                sizeType = "large";
                break;
            case SIZE_FULL:
                sizeType = "full";
                break;
            default:
                sizeType = "normal";
                break;
        }
        
        // CORREÇÃO: Forçar atualização antes de obter dimensões para logs
        lv_obj_update_layout(children[i]);
        lv_coord_t objWidth = lv_obj_get_width(children[i]);
        lv_coord_t objHeight = lv_obj_get_height(children[i]);
        
        // DEBUG REMOVIDO: Log de tamanho dos componentes
        // logger->debug("[GridContainer] Component " + String(i) + " size from user_data: " + sizeType + 
        //              " (ComponentSize=" + String((int)size) + "), current dimensions: " + 
        //              String(objWidth) + "x" + String(objHeight));
        
        int slotsNeeded = Layout::getSlotsForSize(size);
        
        // Verificar se cabe na linha atual
        if (currentCol + slotsNeeded > Layout::GRID_COLS) {
            // Ir para próxima linha
            currentRow++;
            currentCol = 0;
            
            // Se passou do número de linhas, pare (componente será na próxima página)
            if (currentRow >= Layout::GRID_ROWS) {
                logger->warning("[GridContainer] Component " + String(i) + " exceeds grid capacity, should be in next page");
                // IMPORTANTE: Ocultar componente que não cabe na página
                lv_obj_add_flag(children[i], LV_OBJ_FLAG_HIDDEN);
                continue;  // Continuar para processar próximos componentes (podem estar ocultos também)
            }
        }
        
        // Calcular posição e tamanho do componente
        Point position = Layout::calculateGridPosition(currentCol, currentRow, cellSize);
        Size componentSize = Layout::calculateComponentSize(size, cellSize);
        
        // CORREÇÃO: Garantir tamanhos mínimos e máximos para evitar componentes muito pequenos
        if (componentSize.width < 60) componentSize.width = 60;
        if (componentSize.height < 50) componentSize.height = 50;
        
        // Para componentes large, garantir que tenham tamanho suficiente
        if (size == SIZE_LARGE) {
            if (componentSize.width < 140) componentSize.width = 140;
        }
        
        // APLICAR POSIÇÃO E TAMANHO
        lv_obj_set_size(children[i], componentSize.width, componentSize.height);
        lv_obj_set_pos(children[i], position.x, position.y);
        
        // ADIÇÃO DEBUG: Aplicar borda colorida para identificação visual
        applyDebugBorder(children[i], i, "Container " + String(i + 1), "Component " + String(i));
        
        // Forçar visibilidade e desabilitar scroll
        lv_obj_clear_flag(children[i], LV_OBJ_FLAG_HIDDEN);
        lv_obj_clear_flag(children[i], LV_OBJ_FLAG_SCROLLABLE);
        
        // Log detalhado para debug com informação de slots
        logger->info("[GridContainer] Component " + String(i) + ": size " + sizeType + " (" + String(slotsNeeded) + 
                    " slots), position: " + String(position.x) + "," + String(position.y) + 
                    " dimensions: " + String(componentSize.width) + "x" + String(componentSize.height));
        
        // Avançar posição no grid
        currentCol += slotsNeeded;
    }
    
    // Forçar refresh do LVGL para garantir que mudanças sejam aplicadas
    lv_obj_invalidate(obj);
    lv_refr_now(NULL);
}

void GridContainer::layoutSingleRow(int itemCount) {
    int containerWidth = lv_obj_get_content_width(obj);
    int buttonWidth = (containerWidth - (itemCount - 1) * gap) / itemCount;
    int buttonHeight = 65;
    
    for (int i = 0; i < itemCount; i++) {
        lv_obj_set_size(children[i], buttonWidth, buttonHeight);
        lv_obj_set_pos(children[i], i * (buttonWidth + gap), 0);
    }
}

void GridContainer::layoutGrid(int itemCount) {
    // Considerar o padding do container
    int containerWidth = lv_obj_get_content_width(obj);
    int containerHeight = lv_obj_get_content_height(obj);
    
    int cols = std::min(itemCount, maxColumns);
    int rows = (itemCount + cols - 1) / cols;
    
    int buttonWidth = (containerWidth - (cols - 1) * gap) / cols;
    int buttonHeight = (containerHeight - (rows - 1) * gap) / rows;
    
    for (int i = 0; i < itemCount; i++) {
        int col = i % cols;
        int row = i / cols;
        
        lv_obj_set_size(children[i], buttonWidth, buttonHeight);
        lv_obj_set_pos(children[i], 
                       col * (buttonWidth + gap),
                       row * (buttonHeight + gap));
    }
}

void GridContainer::layoutGridNew() {
    int itemCount = children.size();
    if (itemCount == 0) return;
    
    logger->info("[GridContainer] Fixed grid layout with " + String(itemCount) + " items");
    
    // Garantir que container tem tamanho adequado
    int containerWidth = lv_obj_get_content_width(obj);
    int containerHeight = lv_obj_get_content_height(obj);
    
    // CORREÇÃO: Se container é muito pequeno, usar valores otimizados
    if (containerWidth < 100) containerWidth = Layout::DISPLAY_WIDTH - 10;  // Reduzido de 40 para 10
    if (containerHeight < 80) containerHeight = Layout::CONTENT_HEIGHT - 10; // Reduzido de 40 para 10
    
    Size containerSize = { containerWidth, containerHeight };
    Size cellSize = Layout::calculateGridCellSize(containerSize);
    
    // Garantir tamanhos mínimos das células
    if (cellSize.width < 50) cellSize.width = 80;
    if (cellSize.height < 40) cellSize.height = 60;
    
    logger->info("[GridContainer] Fixed grid - container: " + String(containerWidth) + "x" + String(containerHeight) + 
                " cell size: " + String(cellSize.width) + "x" + String(cellSize.height));
    
    int currentCol = 0;
    int currentRow = 0;
    
    for (int i = 0; i < itemCount; i++) {
        if (!children[i]) {
            logger->warning("[GridContainer] Child " + String(i) + " is NULL in fixed grid");
            continue;
        }
        
        // No modo fixo, todos os componentes são SIZE_NORMAL
        ComponentSize size = SIZE_NORMAL;
        int slotsNeeded = Layout::getSlotsForSize(size);
        
        // Verificar se cabe na linha atual
        if (currentCol + slotsNeeded > Layout::GRID_COLS) {
            currentRow++;
            currentCol = 0;
            
            if (currentRow >= Layout::GRID_ROWS) {
                logger->warning("[GridContainer] Fixed grid - component " + String(i) + " exceeds capacity");
                break;
            }
        }
        
        Point position = Layout::calculateGridPosition(currentCol, currentRow, cellSize);
        Size componentSize = Layout::calculateComponentSize(size, cellSize);
        
        // Aplicar posição e tamanho
        lv_obj_set_size(children[i], componentSize.width, componentSize.height);
        lv_obj_set_pos(children[i], position.x, position.y);
        
        // ADIÇÃO DEBUG: Aplicar borda colorida para identificação visual no grid fixo
        applyDebugBorder(children[i], i, "Grid Fixo Container " + String(i + 1), "FixedGrid Component " + String(i));
        
        // Garantir visibilidade
        lv_obj_clear_flag(children[i], LV_OBJ_FLAG_HIDDEN);
        lv_obj_clear_flag(children[i], LV_OBJ_FLAG_SCROLLABLE);
        
        logger->info("[GridContainer] Fixed grid - Component " + String(i) + ": size normal (" + String(slotsNeeded) + 
                    " slot), position: " + String(position.x) + "," + String(position.y) + 
                    " dimensions: " + String(componentSize.width) + "x" + String(componentSize.height));
        
        currentCol += slotsNeeded;
    }
    
    // Forçar refresh
    lv_obj_invalidate(obj);
}