#include "Layout.h"
#include "LayoutConfig.h"
#include <algorithm>
#include <Arduino.h>

Size Layout::calculateButtonSize(int itemCount, Size containerSize) {
    Size buttonSize;
    
    // Usar o tamanho completo já que o container tem padding
    int usableWidth = containerSize.width;
    int usableHeight = containerSize.height; // Sem redução de margem inferior
    
    // Serial.printf("[Layout] Container: %dx%d, Usable: %dx%d, Items: %d\n", 
    //               containerSize.width, containerSize.height, 
    //               usableWidth, usableHeight, itemCount);
    
    if (itemCount <= 0) {
        return {0, 0};
    }
    
    // Comportamento adaptativo baseado no número de itens
    if (itemCount == 1) {
        // Botão único ocupa toda largura
        buttonSize.width = usableWidth;
        buttonSize.height = 65;
    } else if (itemCount == 2) {
        // 2 botões lado a lado
        buttonSize.width = (usableWidth - GAP) / 2;
        buttonSize.height = 65;
    } else if (itemCount == 3) {
        // 3 botões em linha única
        buttonSize.width = (usableWidth - 2 * GAP) / 3;
        buttonSize.height = 65;
    } else if (itemCount == 4) {
        // Grid 2x2
        buttonSize.width = (usableWidth - GAP) / 2;
        buttonSize.height = 65;
    } else {
        // Grid 2x3 padrão (5-6 itens)
        buttonSize.width = (usableWidth - 2 * GAP) / 3;
        buttonSize.height = (usableHeight - GAP) / 2;
        
    }
    
    // Serial.printf("[Layout] Button size calculated: %dx%d\n", buttonSize.width, buttonSize.height);
    return buttonSize;
}

Point Layout::calculateButtonPosition(int index, int itemCount, Size containerSize) {
    Point position;
    Size buttonSize = calculateButtonSize(itemCount, containerSize);
    
    // Posição base: sem margens (container já tem padding)
    position.x = 0;
    position.y = 0;
    
    if (itemCount == 1) {
        // Centralizado
        position.x = 0;
        position.y = 0;
    } else if (itemCount <= 3) {
        // Linha única
        position.x = index * (buttonSize.width + GAP);
        position.y = 0;
    } else if (itemCount == 4) {
        // Grid 2x2
        int col = index % 2;
        int row = index / 2;
        position.x = col * (buttonSize.width + GAP);
        position.y = row * (buttonSize.height + GAP);
    } else if (itemCount == 5) {
        // Caso especial: 3 em cima, 2 embaixo
        if (index < 3) {
            position.x = index * (buttonSize.width + GAP);
            position.y = 0;
        } else {
            // Centralizar os 2 últimos
            int col = index - 3;
            int centerOffset = (buttonSize.width + GAP) / 2;
            position.x = centerOffset + col * (buttonSize.width + GAP);
            position.y = buttonSize.height + GAP;
        }
    } else {
        // Grid 2x3 padrão
        int col = index % 3;
        int row = index / 3;
        position.x = col * (buttonSize.width + GAP);
        position.y = row * (buttonSize.height + GAP);
    }
    
    return position;
}

int Layout::calculateTotalPages(int totalItems) {
    if (totalItems <= 0) return 0;
    return (totalItems + 5) / 6; // Arredonda para cima
}

int Layout::getItemsInPage(int page, int totalItems) {
    int totalPages = calculateTotalPages(totalItems);
    
    if (page < 0 || page >= totalPages) {
        return 0;
    }
    
    if (page < totalPages - 1) {
        return 6; // Páginas completas têm 6 itens
    } else {
        // Última página pode ter menos
        return totalItems - (page * 6);
    }
}

// ============================================================================
// NOVOS MÉTODOS PARA GRID 3x2 CONFIGURÁVEL
// ============================================================================

Size Layout::calculateGridCellSize(Size containerSize) {
    Size cellSize;
    
    // Calcular tamanho de cada célula do grid
    // Considerando gaps entre células
    cellSize.width = (containerSize.width - (GRID_COLS - 1) * GAP) / GRID_COLS;
    cellSize.height = (containerSize.height - (GRID_ROWS - 1) * GAP) / GRID_ROWS;
    
    // Garantir tamanhos mínimos
    if (cellSize.width < 50) cellSize.width = 50;
    if (cellSize.height < 40) cellSize.height = 40;
    
    return cellSize;
}

Point Layout::calculateGridPosition(int col, int row, Size cellSize) {
    Point position;
    
    // Usar offsets centralizados do LayoutConfig.h
    const int LEFT_OFFSET = COMPONENT_LEFT_OFFSET;
    const int TOP_OFFSET = COMPONENT_TOP_OFFSET;
    
    // Importante: GAP deve ser aplicado apenas ENTRE células, não antes da primeira
    if (col == 0) {
        position.x = LEFT_OFFSET;  // Aplicar offset esquerdo
    } else {
        position.x = col * cellSize.width + (col * GAP) + LEFT_OFFSET;
    }
    
    if (row == 0) {
        position.y = TOP_OFFSET;  // Aplicar offset superior
    } else {
        position.y = row * cellSize.height + (row * GAP) + TOP_OFFSET;
    }
    
    return position;
}

ComponentSize Layout::parseComponentSize(const String& sizeStr) {
    if (sizeStr == "small") return SIZE_SMALL;
    if (sizeStr == "large") return SIZE_LARGE;
    if (sizeStr == "full") return SIZE_FULL;
    return SIZE_NORMAL; // default
}

int Layout::getSlotsForSize(ComponentSize size) {
    switch (size) {
        case SIZE_SMALL:  return SLOT_SMALL;
        case SIZE_NORMAL: return SLOT_NORMAL;
        case SIZE_LARGE:  return SLOT_LARGE;
        case SIZE_FULL:   return SLOT_FULL;
        default:          return SLOT_NORMAL;
    }
}

Size Layout::calculateComponentSize(ComponentSize size, Size cellSize) {
    Size componentSize;
    
    switch (size) {
        case SIZE_SMALL:
        case SIZE_NORMAL:
            componentSize.width = cellSize.width;
            componentSize.height = cellSize.height;
            break;
            
        case SIZE_LARGE:
            // Ocupa 2 células horizontalmente
            componentSize.width = (cellSize.width * 2) + GAP;
            componentSize.height = cellSize.height;
            break;
            
        case SIZE_FULL:
            // Ocupa toda a linha
            componentSize.width = (cellSize.width * GRID_COLS) + (GAP * (GRID_COLS - 1));
            componentSize.height = cellSize.height;
            break;
            
        default:
            componentSize = cellSize;
            break;
    }
    
    return componentSize;
}

int Layout::calculateTotalPagesSlots(int totalSlots) {
    if (totalSlots <= 0) return 0;
    return (totalSlots + CURRENT_MAX_SLOTS - 1) / CURRENT_MAX_SLOTS; // Arredonda para cima
}

bool Layout::canFitInPage(int currentSlots, int newComponentSlots) {
    return (currentSlots + newComponentSlots) <= CURRENT_MAX_SLOTS;
}