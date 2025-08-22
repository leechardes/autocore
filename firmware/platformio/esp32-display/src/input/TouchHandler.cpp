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
    logger = ::logger;  // Usar logger global
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
    uint32_t now = millis();
    
    // Ler estado raw do touch
    bool rawPressed = false;
    TS_Point p;
    
    if (handler->touchscreen->touched()) {
        p = handler->touchscreen->getPoint();
        
        // Filtrar por pressão - threshold mais alto
        if (p.z >= MIN_PRESSURE) {
            rawPressed = true;
        }
    }
    
    // Filtro de estado para estabilização
    if (rawPressed != handler->lastRawState) {
        // Estado mudou, iniciar timer de confirmação
        handler->lastRawState = rawPressed;
        handler->stateChangeTime = now;
        
        // Debug raw values apenas na mudança
        if (handler->debugEnabled && handler->logger) {
            handler->logger->info("[TOUCH] State change detected: " + 
                        String(rawPressed ? "PRESSED" : "RELEASED") + 
                        " (pressure: " + String(p.z) + ")");
        }
    }
    
    // Confirmar mudança de estado após tempo de estabilização
    if (handler->lastRawState != handler->touchState) {
        if (now - handler->stateChangeTime >= STATE_CONFIRM_TIME) {
            // Estado confirmado, aplicar mudança
            handler->touchState = handler->lastRawState;
            
            if (handler->debugEnabled && handler->logger) {
                handler->logger->info("[TOUCH] State confirmed: " + 
                            String(handler->touchState ? "PRESSED" : "RELEASED"));
            }
        }
    }
    
    // Retornar estado estável
    if (handler->touchState && rawPressed) {
        // Mapear coordenadas apenas se realmente pressionado
        data->point.x = map(p.x, handler->touchMinX, handler->touchMaxX, 0, SCREEN_WIDTH - 1);
        data->point.y = map(p.y, handler->touchMinY, handler->touchMaxY, 0, SCREEN_HEIGHT - 1);
        
        // Constrain to screen bounds
        data->point.x = constrain(data->point.x, 0, SCREEN_WIDTH - 1);
        data->point.y = constrain(data->point.y, 0, SCREEN_HEIGHT - 1);
        
        data->state = LV_INDEV_STATE_PR;
        
        // Log apenas se debugEnabled
        if (handler->debugEnabled && (now - handler->lastDebugTime > 1000)) {
            handler->lastDebugTime = now;
            if (handler->logger) {
                handler->logger->info("[TOUCH] STABLE - X=" + String(data->point.x) + 
                                    ", Y=" + String(data->point.y));
            }
        }
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