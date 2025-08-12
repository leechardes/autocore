/**
 * @file TouchHandler.cpp
 * @brief Touch screen handler implementation
 */

#include "input/TouchHandler.h"
#include "config/DeviceConfig.h"
#include "core/Logger.h"

extern Logger* logger;

// Static instance for callback
TouchHandler* TouchHandler::instance = nullptr;

TouchHandler::TouchHandler() {
    instance = this;
    touchSPI = new SPIClass(VSPI);
    touchscreen = nullptr;
    indev = nullptr;
    debugEnabled = true;  // Habilitar debug
}

TouchHandler::~TouchHandler() {
    if (touchscreen) {
        delete touchscreen;
    }
    if (touchSPI) {
        delete touchSPI;
    }
    instance = nullptr;
}

bool TouchHandler::begin() {
    logger->info("Initializing touch screen");
    
    // Configure SPI for touch screen
    touchSPI->begin(XPT2046_CLK, XPT2046_MISO, XPT2046_MOSI, XPT2046_CS);
    
    // Create touchscreen instance
    touchscreen = new XPT2046_Touchscreen(XPT2046_CS, XPT2046_IRQ);
    
    // Initialize with SPI instance
    if (!touchscreen->begin(*touchSPI)) {
        logger->error("Failed to initialize touch screen!");
        return false;
    }
    
    // Set rotation (same as display)
    touchscreen->setRotation(1);
    
    // Use calibration values from DeviceConfig.h
    touchMinX = TOUCH_MIN_X;
    touchMaxX = TOUCH_MAX_X;
    touchMinY = TOUCH_MIN_Y;
    touchMaxY = TOUCH_MAX_Y;
    
    // Register with LVGL
    static lv_indev_drv_t indev_drv;
    lv_indev_drv_init(&indev_drv);
    indev_drv.type = LV_INDEV_TYPE_POINTER;
    indev_drv.read_cb = TouchHandler::read;
    indev_drv.user_data = this;
    indev = lv_indev_drv_register(&indev_drv);
    
    logger->info("Touch screen initialized successfully");
    logger->debug("Calibration: X[" + String(touchMinX) + "-" + String(touchMaxX) + 
                  "] Y[" + String(touchMinY) + "-" + String(touchMaxY) + "]");
    
    return true;
}

void TouchHandler::read(lv_indev_drv_t* indev_driver, lv_indev_data_t* data) {
    if (!instance || !instance->touchscreen) {
        data->state = LV_INDEV_STATE_REL;
        return;
    }
    
    TouchHandler* handler = (TouchHandler*)indev_driver->user_data;
    
    if (handler->touchscreen->touched()) {
        TS_Point p = handler->touchscreen->getPoint();
        
        // Filter by pressure
        if (p.z < MIN_PRESSURE) {
            data->state = LV_INDEV_STATE_REL;
            return;
        }
        
        // Debounce
        uint32_t now = millis();
        if (now - handler->lastTouchTime < DEBOUNCE_TIME) {
            return;
        }
        handler->lastTouchTime = now;
        
        // Debug raw values
        if (handler->debugEnabled && (now - handler->lastDebugTime > DEBUG_INTERVAL)) {
            logger->info("[TOUCH] RAW: X=" + String(p.x) + ", Y=" + String(p.y) + ", Z=" + String(p.z));
            handler->lastDebugTime = now;
        }
        
        // Auto-calibration (optional)
        if (p.x < handler->touchMinX) handler->touchMinX = p.x;
        if (p.x > handler->touchMaxX) handler->touchMaxX = p.x;
        if (p.y < handler->touchMinY) handler->touchMinY = p.y;
        if (p.y > handler->touchMaxY) handler->touchMaxY = p.y;
        
        // Map to screen coordinates
        data->point.x = map(p.x, handler->touchMinX, handler->touchMaxX, 0, SCREEN_WIDTH - 1);
        data->point.y = map(p.y, handler->touchMinY, handler->touchMaxY, 0, SCREEN_HEIGHT - 1);
        
        // Constrain to screen bounds
        data->point.x = constrain(data->point.x, 0, SCREEN_WIDTH - 1);
        data->point.y = constrain(data->point.y, 0, SCREEN_HEIGHT - 1);
        
        // Debug mapped values
        if (handler->debugEnabled && (handler->lastDebugTime == now)) {
            logger->info("[TOUCH] MAPPED: X=" + String(data->point.x) + ", Y=" + String(data->point.y));
        }
        
        data->state = LV_INDEV_STATE_PR;
    } else {
        data->state = LV_INDEV_STATE_REL;
    }
}

void TouchHandler::setCalibration(uint16_t minX, uint16_t maxX, uint16_t minY, uint16_t maxY) {
    touchMinX = minX;
    touchMaxX = maxX;
    touchMinY = minY;
    touchMaxY = maxY;
    
    logger->info("Touch calibration updated: X[" + String(minX) + "-" + String(maxX) + 
                 "] Y[" + String(minY) + "-" + String(maxY) + "]");
}

void TouchHandler::getCalibration(uint16_t& minX, uint16_t& maxX, uint16_t& minY, uint16_t& maxY) {
    minX = touchMinX;
    maxX = touchMaxX;
    minY = touchMinY;
    maxY = touchMaxY;
}