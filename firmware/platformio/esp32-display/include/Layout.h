#ifndef LAYOUT_H
#define LAYOUT_H

#include <lvgl.h>

struct Size {
    int width;
    int height;
};

struct Point {
    int x;
    int y;
};

class Layout {
public:
    static const int MARGIN = 10;
    static const int GAP = 10;
    static const int HEADER_HEIGHT = 30;
    static const int NAVBAR_HEIGHT = 40;
    static const int DISPLAY_WIDTH = 320;
    static const int DISPLAY_HEIGHT = 240;
    static const int CONTENT_HEIGHT = DISPLAY_HEIGHT - HEADER_HEIGHT - NAVBAR_HEIGHT;
    
    static Size calculateButtonSize(int itemCount, Size containerSize);
    static Point calculateButtonPosition(int index, int itemCount, Size containerSize);
    static int getMaxItemsPerPage() { return 6; }
    static int calculateTotalPages(int totalItems);
    static int getItemsInPage(int page, int totalItems);
};

#endif