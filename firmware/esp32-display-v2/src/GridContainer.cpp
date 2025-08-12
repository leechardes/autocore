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
        // logger->info("[GridContainer] No children to layout");
        return;
    }
    
    // Log para debug
    logger->info("[GridContainer] Updating layout with " + String(itemCount) + " items");
    
    // Forçar atualização do tamanho do objeto
    lv_obj_update_layout(obj);
    
    int containerWidth = lv_obj_get_width(obj);
    int containerHeight = lv_obj_get_height(obj);
    
    logger->info("[GridContainer] Container size: " + String(containerWidth) + "x" + String(containerHeight));
    
    // Se o container ainda não tem tamanho, usar o tamanho configurado
    if (containerWidth == 0 || containerHeight == 0) {
        containerWidth = Layout::DISPLAY_WIDTH;
        containerHeight = Layout::CONTENT_HEIGHT;
        logger->info("[GridContainer] Using default size: " + String(containerWidth) + "x" + String(containerHeight));
    }
    
    if (adaptive) {
        // Usar o tamanho do conteúdo (já considera padding)
        int contentWidth = lv_obj_get_content_width(obj);
        int contentHeight = lv_obj_get_content_height(obj);
        
        // Se ainda for 0, usar o tamanho padrão menos as margens
        if (contentWidth == 0 || contentHeight == 0) {
            contentWidth = Layout::DISPLAY_WIDTH - (2 * Layout::MARGIN);
            contentHeight = Layout::CONTENT_HEIGHT - Layout::MARGIN;
        }
        
        // Debug detalhado das margens
        logger->info("[GridContainer] Container padding L/R/T/B: " + 
                     String(lv_obj_get_style_pad_left(obj, 0)) + "/" +
                     String(lv_obj_get_style_pad_right(obj, 0)) + "/" +
                     String(lv_obj_get_style_pad_top(obj, 0)) + "/" +
                     String(lv_obj_get_style_pad_bottom(obj, 0)));
        logger->info("[GridContainer] Content area: " + String(contentWidth) + "x" + String(contentHeight));
        
        
        Size containerSize = {
            contentWidth,
            contentHeight
        };
        
        for (int i = 0; i < itemCount; i++) {
            // Verificar se o child é válido
            if (!children[i]) {
                logger->error("[GridContainer] Child " + String(i) + " is NULL!");
                continue;
            }
            
            Size buttonSize = Layout::calculateButtonSize(itemCount, containerSize);
            Point position = Layout::calculateButtonPosition(i, itemCount, containerSize);
            
            // Garantir tamanhos positivos
            if (buttonSize.width <= 0 || buttonSize.height <= 0) {
                logger->error("[GridContainer] Invalid button size: " + String(buttonSize.width) + "x" + String(buttonSize.height));
                buttonSize.width = 80;
                buttonSize.height = 60;
            }
            
            lv_obj_set_size(children[i], buttonSize.width, buttonSize.height);
            lv_obj_set_pos(children[i], position.x, position.y);
            
            // Forçar visibilidade
            lv_obj_clear_flag(children[i], LV_OBJ_FLAG_HIDDEN);
            
            // Verificar resultado
            int actualW = lv_obj_get_width(children[i]);
            int actualH = lv_obj_get_height(children[i]);
            int actualX = lv_obj_get_x(children[i]);
            int actualY = lv_obj_get_y(children[i]);
            
            // Log detalhado para primeiro e último botão de cada linha
            if (i == 0 || i == 2 || i == 3 || i == 5) {
                logger->info("[GridContainer] Button " + String(i) + " position: X=" + String(actualX) + 
                             ", Width=" + String(actualW) + ", Right edge=" + String(actualX + actualW));
            }
            
        }
        
        // Forçar refresh do LVGL
        lv_obj_invalidate(obj);
        
    } else {
        // Layout de grid fixo
        layoutGrid(itemCount);
    }
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