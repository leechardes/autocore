#include "Layout.h"
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