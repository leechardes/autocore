#ifndef CONTAINER_H
#define CONTAINER_H

#include <lvgl.h>
#include <vector>
#include <functional>

class Container {
protected:
    lv_obj_t* obj;
    std::vector<lv_obj_t*> children;
    int margin;
    int gap;
    
public:
    Container(lv_obj_t* parent);
    virtual ~Container();
    
    virtual void addChild(lv_obj_t* child);
    virtual void removeChild(lv_obj_t* child);
    virtual void clearChildren();
    
    virtual void updateLayout() = 0;
    
    void setMargins(int margin);
    void setGap(int gap);
    void setSize(int width, int height);
    void setPosition(int x, int y);
    
    lv_obj_t* getObject() { return obj; }
    int getChildCount() const { return children.size(); }
    
protected:
    virtual void applyTheme();
};

#endif