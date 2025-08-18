#ifndef GRID_CONTAINER_H
#define GRID_CONTAINER_H

#include "Container.h"
#include "Layout.h"

class GridContainer : public Container {
private:
    int maxColumns = 3;
    int maxRows = 2;
    bool adaptive = true;
    
public:
    GridContainer(lv_obj_t* parent);
    
    void updateLayout() override;
    void setAdaptive(bool enable) { adaptive = enable; }
    void setGridSize(int cols, int rows);
    
private:
    void layoutSingleRow(int itemCount);
    void layoutGrid(int itemCount);
    void layoutGridNew();  // Novo método usando sistema de grid 3x2
};

#endif