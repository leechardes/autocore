#include "GridContainer.h"
#include "core/Logger.h"

extern Logger* logger;

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
    
    // Se o container não tem tamanho definido, forçar tamanho padrão
    if (containerWidth <= 10 || containerHeight <= 10) {
        // Usar tamanho padrão do conteúdo
        containerWidth = Layout::DISPLAY_WIDTH - (2 * Layout::MARGIN);
        containerHeight = Layout::CONTENT_HEIGHT - Layout::MARGIN;
        
        // Definir tamanho explicitamente
        lv_obj_set_size(obj, containerWidth, containerHeight);
        
        // Forçar atualização do layout LVGL
        lv_obj_update_layout(obj);
        
        logger->info("[GridContainer] Forced container size to: " + String(containerWidth) + "x" + String(containerHeight));
    }
    
    // Usar tamanho do conteúdo (área disponível para children)
    int contentWidth = lv_obj_get_content_width(obj);
    int contentHeight = lv_obj_get_content_height(obj);
    
    // Se content area for muito pequena, usar valores mínimos
    if (contentWidth < 100) contentWidth = Layout::DISPLAY_WIDTH - 40;
    if (contentHeight < 80) contentHeight = Layout::CONTENT_HEIGHT - 40;
    
    logger->info("[GridContainer] Content area: " + String(contentWidth) + "x" + String(contentHeight));
    
    Size containerSize = {
        contentWidth,
        contentHeight
    };
    
    // Calcular tamanho das células do grid 3x2
    Size cellSize = Layout::calculateGridCellSize(containerSize);
    logger->info("[GridContainer] Grid cell size: " + String(cellSize.width) + "x" + String(cellSize.height));
    
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
        
        // Por padrão, todos os componentes ocupam 1 slot
        ComponentSize size = SIZE_NORMAL;
        int slotsNeeded = Layout::getSlotsForSize(size);
        
        // Verificar se cabe na linha atual
        if (currentCol + slotsNeeded > Layout::GRID_COLS) {
            // Ir para próxima linha
            currentRow++;
            currentCol = 0;
            
            // Se passou do número de linhas, pare (componente será na próxima página)
            if (currentRow >= Layout::GRID_ROWS) {
                logger->warning("[GridContainer] Component " + String(i) + " exceeds grid capacity, should be in next page");
                break;
            }
        }
        
        // Calcular posição e tamanho do componente
        Point position = Layout::calculateGridPosition(currentCol, currentRow, cellSize);
        Size componentSize = Layout::calculateComponentSize(size, cellSize);
        
        // APLICAR POSIÇÃO E TAMANHO
        lv_obj_set_size(children[i], componentSize.width, componentSize.height);
        lv_obj_set_pos(children[i], position.x, position.y);
        
        // Forçar visibilidade e desabilitar scroll
        lv_obj_clear_flag(children[i], LV_OBJ_FLAG_HIDDEN);
        lv_obj_clear_flag(children[i], LV_OBJ_FLAG_SCROLLABLE);
        
        // Log detalhado para debug
        logger->info("[GridContainer] Component " + String(i) + " at grid (" + 
                    String(currentCol) + "," + String(currentRow) + ") position: " +
                    String(position.x) + "," + String(position.y) + " size: " +
                    String(componentSize.width) + "x" + String(componentSize.height));
        
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
    
    // Se container é muito pequeno, usar valores padrão
    if (containerWidth < 100) containerWidth = Layout::DISPLAY_WIDTH - 40;
    if (containerHeight < 80) containerHeight = Layout::CONTENT_HEIGHT - 40;
    
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
        
        // Garantir visibilidade
        lv_obj_clear_flag(children[i], LV_OBJ_FLAG_HIDDEN);
        lv_obj_clear_flag(children[i], LV_OBJ_FLAG_SCROLLABLE);
        
        logger->info("[GridContainer] Fixed grid - Component " + String(i) + " at (" + 
                    String(currentCol) + "," + String(currentRow) + ") pos: " +
                    String(position.x) + "," + String(position.y) + " size: " + 
                    String(componentSize.width) + "x" + String(componentSize.height));
        
        currentCol += slotsNeeded;
    }
    
    // Forçar refresh
    lv_obj_invalidate(obj);
}