#ifndef LAYOUT_H
#define LAYOUT_H

#include <lvgl.h>
#include <Arduino.h>
#include "ui/Theme.h"

struct Size {
    int width;
    int height;
};

struct Point {
    int x;
    int y;
};

// Enumeração para tamanhos de componentes
enum ComponentSize {
    SIZE_SMALL,
    SIZE_NORMAL, 
    SIZE_LARGE,
    SIZE_FULL
};

class Layout {
public:
    static const int MARGIN = 10;
    static const int GAP = 10;
    static const int HEADER_HEIGHT = 30;
    static const int NAVBAR_HEIGHT = 40;
    static const int DISPLAY_WIDTH = CURRENT_DISPLAY_WIDTH;
    static const int DISPLAY_HEIGHT = CURRENT_DISPLAY_HEIGHT;
    static const int CONTENT_HEIGHT = DISPLAY_HEIGHT - HEADER_HEIGHT - NAVBAR_HEIGHT;
    static const int GRID_COLS = CURRENT_DISPLAY_COLS;
    static const int GRID_ROWS = CURRENT_DISPLAY_ROWS;
    
    // Métodos para grid 3x2 configurável
    static Size calculateGridCellSize(Size containerSize);
    static Point calculateGridPosition(int col, int row, Size cellSize);
    static ComponentSize parseComponentSize(const String& sizeStr);
    static int getSlotsForSize(ComponentSize size);
    static Size calculateComponentSize(ComponentSize size, Size cellSize);
    
    // Métodos legados (mantidos para compatibilidade)
    static Size calculateButtonSize(int itemCount, Size containerSize);
    static Point calculateButtonPosition(int index, int itemCount, Size containerSize);
    static int getMaxItemsPerPage() { return CURRENT_MAX_SLOTS; }
    static int calculateTotalPages(int totalItems);
    static int getItemsInPage(int page, int totalItems);
    
    // Novos métodos para paginação baseada em slots
    static int calculateTotalPagesSlots(int totalSlots);
    static int getMaxSlotsPerPage() { return CURRENT_MAX_SLOTS; }
    static bool canFitInPage(int currentSlots, int newComponentSlots);
};

#endif