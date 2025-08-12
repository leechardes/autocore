/**
 * @file TouchHandler.h
 * @brief Touch screen handler for XPT2046
 */

#ifndef TOUCH_HANDLER_H
#define TOUCH_HANDLER_H

#include <Arduino.h>
#include <XPT2046_Touchscreen.h>
#include <SPI.h>
#include <lvgl.h>

class TouchHandler {
public:
    TouchHandler();
    ~TouchHandler();
    
    // Initialize touch screen
    bool begin();
    
    // LVGL callback
    static void read(lv_indev_drv_t* indev_driver, lv_indev_data_t* data);
    
    // Get LVGL input device
    lv_indev_t* getInputDevice() { return indev; }
    
    // Update calibration values
    void setCalibration(uint16_t minX, uint16_t maxX, uint16_t minY, uint16_t maxY);
    
    // Get current calibration
    void getCalibration(uint16_t& minX, uint16_t& maxX, uint16_t& minY, uint16_t& maxY);
    
    // Enable/disable debug output
    void setDebug(bool enable) { debugEnabled = enable; }
    
private:
    static TouchHandler* instance;
    XPT2046_Touchscreen* touchscreen;
    SPIClass* touchSPI;
    lv_indev_t* indev;
    
    // Calibration values for ESP32-2432S028R
    uint16_t touchMinX = 200;
    uint16_t touchMaxX = 3700;
    uint16_t touchMinY = 240;
    uint16_t touchMaxY = 3800;
    
    // Touch state
    uint32_t lastTouchTime = 0;
    uint32_t lastDebugTime = 0;
    bool debugEnabled = false;
    
    // Minimum pressure threshold
    static const uint16_t MIN_PRESSURE = 200;
    
    // Debounce time in ms
    static const uint32_t DEBOUNCE_TIME = 50;
    
    // Debug interval in ms
    static const uint32_t DEBUG_INTERVAL = 500;
};

#endif // TOUCH_HANDLER_H