/**
 * @file ScreenFactory.h
 * @brief Factory para criar telas dinamicamente usando o novo sistema de layout
 */

#ifndef SCREEN_FACTORY_H
#define SCREEN_FACTORY_H

#include <Arduino.h>
#include <lvgl.h>
#include <ArduinoJson.h>
#include "ScreenBase.h"
#include "NavButton.h"
#include <memory>

class ScreenFactory {
public:
    // Create screen from JSON config using new layout system
    static std::unique_ptr<ScreenBase> createScreen(JsonObject& config);
    
    // Create navigation item (button that navigates to another screen)
    static NavButton* createNavigationItem(lv_obj_t* parent, JsonObject& config);
    
    // Create relay control item
    static NavButton* createRelayItem(lv_obj_t* parent, JsonObject& config);
    
    // Create action item
    static NavButton* createActionItem(lv_obj_t* parent, JsonObject& config);
    
    // Create mode selector item
    static NavButton* createModeItem(lv_obj_t* parent, JsonObject& config);
    
    // Create display item (read-only information)
    static NavButton* createDisplayItem(lv_obj_t* parent, JsonObject& config);
    
    // Novos métodos para widgets melhorados
    static NavButton* createSwitchItem(lv_obj_t* parent, JsonObject& config);
    static lv_obj_t* createSwitchDirectly(lv_obj_t* parent, JsonObject& config);
    static NavButton* createGaugeItem(lv_obj_t* parent, JsonObject& config);
    static lv_obj_t* createGaugeDirectly(lv_obj_t* parent, JsonObject& config);
    
    // Métodos auxiliares para gauges
    static lv_obj_t* createCircularGauge(lv_obj_t* parent, JsonObject& config, float minVal, float maxVal);
    static lv_obj_t* createLinearGauge(lv_obj_t* parent, JsonObject& config, float minVal, float maxVal);
    
    // Utilitários para formatting e cores
    static String formatDisplayValue(float value, JsonObject& config);
    static void applyDynamicColors(lv_obj_t* obj, JsonObject& config, float value);
    static lv_coord_t calculateItemSize(const String& size, bool isWidth);
    
    // Parse action_payload JSON string (público para DataBinder)
    static float parseActionPayload(JsonObject& config, const String& key, float defaultValue);
    
    // Legacy methods (to be removed after full migration)
    static lv_obj_t* createScreenLegacy(JsonObject& config);
    static lv_obj_t* createButton(lv_obj_t* parent, JsonObject& config);
    static lv_obj_t* createLabel(lv_obj_t* parent, JsonObject& config);
    static lv_obj_t* createSwitch(lv_obj_t* parent, JsonObject& config);
    static lv_obj_t* createSlider(lv_obj_t* parent, JsonObject& config);
    static lv_obj_t* createGauge(lv_obj_t* parent, JsonObject& config);
    static lv_obj_t* createList(lv_obj_t* parent, JsonObject& config);
    
private:
    // Apply common styles
    static void applyCommonStyles(lv_obj_t* obj, JsonObject& config);
    
    // Position element
    static void positionElement(lv_obj_t* obj, JsonObject& config);
    
    // Parse color from hex string
    static lv_color_t parseColor(const String& colorStr);
};

#endif // SCREEN_FACTORY_H