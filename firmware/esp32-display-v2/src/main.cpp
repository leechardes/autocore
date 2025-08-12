/**
 * @file main.cpp
 * @brief AutoTech HMI Display v2 - Main entry point
 * 
 * Display HMI totalmente configurável via MQTT
 * Sem arquivo de configuração local - tudo vem do gateway
 */

#include <Arduino.h>
#include <WiFi.h>
#include <lvgl.h>
#include <TFT_eSPI.h>

// Core components
#include "core/Logger.h"
#include "core/MQTTClient.h"
#include "core/ConfigManager.h"

// UI components
#include "ui/ScreenManager.h"
#include "ui/ScreenFactory.h"

// Navigation
#include "navigation/Navigator.h"
#include "navigation/ButtonHandler.h"

// Input
#include "input/TouchHandler.h"

// Communication
#include "communication/ConfigReceiver.h"
#include "communication/StatusReporter.h"
#include "communication/ButtonStateManager.h"

// Network (API support)
#include "network/ScreenApiClient.h"

// Commands
#include "commands/CommandSender.h"

// Models
#include "models/DeviceModels.h"

// Include device configuration
#include "config/DeviceConfig.h"

// Display
static TFT_eSPI tft = TFT_eSPI();
static const uint16_t screenWidth = 320;   // 320 pixels após rotação
static const uint16_t screenHeight = 240; // 240 pixels após rotação

// LVGL
static lv_disp_draw_buf_t draw_buf;
static lv_color_t buf[screenWidth * 10];
static lv_disp_drv_t disp_drv;
static lv_indev_drv_t indev_drv;

// Global logger (used by all modules)
Logger* logger = nullptr;

// Components (global for lambda access)
MQTTClient* mqttClient = nullptr;
ConfigManager* configManager = nullptr;
TouchHandler* touchHandler = nullptr;
ScreenManager* screenManager = nullptr;
Navigator* navigator = nullptr;
ButtonHandler* buttonHandler = nullptr;
ConfigReceiver* configReceiver = nullptr;
StatusReporter* statusReporter = nullptr;
CommandSender* commandSender = nullptr;
ButtonStateManager* buttonStateManager = nullptr;
ScreenApiClient* screenApiClient = nullptr;

// State
static bool configReceived = false;
static unsigned long lastStatusReport = 0;
static unsigned long lastConfigRequest = 0;

/**
 * LVGL display flushing
 */
void my_disp_flush(lv_disp_drv_t *disp, const lv_area_t *area, lv_color_t *color_p) {
    uint32_t w = (area->x2 - area->x1 + 1);
    uint32_t h = (area->y2 - area->y1 + 1);

    tft.startWrite();
    tft.setAddrWindow(area->x1, area->y1, w, h);
    tft.pushColors((uint16_t *)&color_p->full, w * h, true);
    tft.endWrite();

    lv_disp_flush_ready(disp);
}

/**
 * Button input read for LVGL
 */
void button_read(lv_indev_drv_t * indev_drv, lv_indev_data_t * data) {
    static uint32_t last_key = 0;
    
    uint32_t act_key = buttonHandler->getPressedButton();
    
    if(act_key != 0) {
        data->state = LV_INDEV_STATE_PRESSED;
        last_key = act_key;
    } else {
        data->state = LV_INDEV_STATE_RELEASED;
    }
    
    data->key = last_key;
}

/**
 * Setup WiFi connection
 */
void setupWiFi() {
    logger->info("Connecting to WiFi: " + String(WIFI_SSID));
    
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    
    // Show connecting screen
    lv_obj_t* scr = lv_scr_act();
    lv_obj_t* label = lv_label_create(scr);
    lv_label_set_text(label, "Conectando WiFi...");
    lv_obj_center(label);
    
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        logger->debug(".");
        lv_task_handler();
    }
    
    logger->info("WiFi connected! IP: " + WiFi.localIP().toString());
    lv_label_set_text(label, ("WiFi OK\nIP: " + WiFi.localIP().toString()).c_str());
    lv_task_handler();
    delay(1000);
}

/**
 * Setup API client
 */
void setupApiClient() {
    logger->info("Setting up API client");
    logger->debug("API Server: " + String(API_PROTOCOL) + "://" + String(API_SERVER) + ":" + String(API_PORT) + String(API_BASE_PATH));
    
    // Initialize API client
    screenApiClient = new ScreenApiClient();
    
    if (screenApiClient->begin()) {
        logger->info("API client initialized successfully");
        
        // Initialize device registry singleton
        DeviceRegistry::getInstance();
        logger->info("Device registry initialized");
        
        return;
    } else {
        logger->warning("API client initialization failed, will use MQTT fallback");
        logger->debug("API Error: " + screenApiClient->getLastError());
        
        // Don't delete the client - keep it for potential retry
        // Just log the failure and continue
    }
}

/**
 * Setup MQTT connection
 */
void setupMQTT() {
    logger->info("Setting up MQTT client");
    logger->debug("MQTT Broker: '" + String(MQTT_BROKER) + "'");
    logger->debug("MQTT Port: " + String(MQTT_PORT));
    
    mqttClient = new MQTTClient(DEVICE_ID, MQTT_BROKER, MQTT_PORT);
    configReceiver = new ConfigReceiver(mqttClient, configManager, screenApiClient);
    statusReporter = new StatusReporter(mqttClient, DEVICE_ID);
    commandSender = new CommandSender(mqttClient, logger, DEVICE_ID);
    buttonStateManager = new ButtonStateManager(mqttClient, screenManager);
    
    // Show connecting screen
    lv_obj_t* scr = lv_scr_act();
    lv_obj_t* label = lv_label_create(scr);
    lv_label_set_text(label, "Conectando MQTT...");
    lv_obj_center(label);
    lv_task_handler();
    
    if (mqttClient->connect()) {
        logger->info("MQTT connected!");
        lv_label_set_text(label, "MQTT Conectado!");
        
        // Setup config receiver
        configReceiver->begin();
        
        // Setup button state manager
        buttonStateManager->begin();
        
        // Enable hot reload with callback
        configReceiver->enableHotReload([]() {
            logger->info("Hot reload triggered! Rebuilding UI...");
            
            // Rebuild UI with new configuration
            if (screenManager && configManager->hasConfig()) {
                screenManager->buildFromConfig(configManager->getConfig());
                
                // Navigate back to home or current screen
                if (navigator) {
                    String currentScreen = navigator->getCurrentScreen();
                    navigator->navigateToScreen(currentScreen);
                }
                
                // Visual feedback - flash green LED
                digitalWrite(LED_G_PIN, LOW);
                delay(100);
                digitalWrite(LED_G_PIN, HIGH);
            }
        });
        
        // Load initial configuration using new combined method (API first, MQTT fallback)
        logger->info("Loading initial configuration...");
        if (configReceiver->loadConfiguration()) {
            logger->info("Initial configuration loaded successfully");
        } else {
            logger->warning("Failed to load initial configuration, will retry periodically");
        }
        lastConfigRequest = millis();
        
    } else {
        logger->error("Failed to connect to MQTT!");
        lv_label_set_text(label, "Erro MQTT!");
    }
    
    lv_task_handler();
    delay(1000);
}

/**
 * Initialize display and LVGL
 */
void setupDisplay() {
    logger->info("Initializing display");
    
    // Initialize TFT
    tft.init();
    tft.setRotation(1); // Landscape - mesma rotação do teste funcional
    tft.fillScreen(TFT_BLACK); // Forçar fundo preto inicial
    
    // Configurar backlight com PWM para controle de brilho
    pinMode(TFT_BACKLIGHT_PIN, OUTPUT);
    
    // Configurar PWM no pino do backlight
    // Canal 0, frequência 5000Hz, resolução 8 bits (0-255)
    ledcSetup(0, 5000, 8);
    ledcAttachPin(TFT_BACKLIGHT_PIN, 0);
    
    // Definir brilho inicial (50%)
    ledcWrite(0, 128); // 50% de brilho
    
    // Initialize LVGL
    lv_init();
    
    // Initialize display buffer
    lv_disp_draw_buf_init(&draw_buf, buf, NULL, screenWidth * 10);
    
    // Initialize display driver
    lv_disp_drv_init(&disp_drv);
    disp_drv.hor_res = screenWidth;
    disp_drv.ver_res = screenHeight;
    disp_drv.flush_cb = my_disp_flush;
    disp_drv.draw_buf = &draw_buf;
    lv_disp_drv_register(&disp_drv);
    
    // Initialize input device driver for buttons
    lv_indev_drv_init(&indev_drv);
    indev_drv.type = LV_INDEV_TYPE_KEYPAD;
    indev_drv.read_cb = button_read;
    lv_indev_drv_register(&indev_drv);
    
    // Initialize touch screen
    touchHandler = new TouchHandler();
    if (!touchHandler->begin()) {
        logger->error("Failed to initialize touch screen!");
    } else {
        // Enable debug for testing
        touchHandler->setDebug(true);
    }
    
    logger->info("Display initialized");
}

/**
 * Setup UI components
 */
void setupUI() {
    logger->info("Setting up UI components");
    
    configManager = new ConfigManager();
    screenManager = new ScreenManager();
    navigator = new Navigator(screenManager);
    buttonHandler = new ButtonHandler(BTN_PREV_PIN, BTN_SELECT_PIN, BTN_NEXT_PIN);
    
    // Configure button callbacks
    buttonHandler->onPrevious([](){ navigator->navigatePrevious(); });
    buttonHandler->onSelect([](){ navigator->select(); });
    buttonHandler->onNext([](){ navigator->navigateNext(); });
    
    logger->info("UI components ready");
}

/**
 * Show waiting for config screen
 */
void showWaitingScreen() {
    lv_obj_t* scr = lv_scr_act();
    lv_obj_clean(scr);
    
    lv_obj_t* label = lv_label_create(scr);
    lv_label_set_text(label, "Aguardando configuracao...");
    lv_obj_center(label);
    
    // Add spinner
    lv_obj_t* spinner = lv_spinner_create(scr, 1000, 60);
    lv_obj_set_size(spinner, 50, 50);
    lv_obj_align(spinner, LV_ALIGN_CENTER, 0, 40);
}

// Forward declaration
void lv_tick_task(void * pvParameters);

/**
 * Arduino setup
 */
void setup() {
    Serial.begin(SERIAL_BAUD_RATE);
    delay(100);
    
    // Initialize logger with configured debug level
    LogLevel logLevel = LOG_INFO;
    #if DEBUG_LEVEL == 0
        logLevel = LOG_ERROR;  // Only errors
    #elif DEBUG_LEVEL == 1
        logLevel = LOG_ERROR;
    #elif DEBUG_LEVEL == 2
        logLevel = LOG_INFO;
    #elif DEBUG_LEVEL >= 3
        logLevel = LOG_DEBUG;
    #endif
    
    logger = new Logger(logLevel);
    logger->info("=== AutoTech HMI Display v2 ===");
    logger->info("Device ID: " + String(DEVICE_ID));
    logger->info("Version: " + String(DEVICE_VERSION));
    logger->info("WiFi SSID: " + String(WIFI_SSID));
    logger->info("MQTT Broker: " + String(MQTT_BROKER) + ":" + String(MQTT_PORT));
    
    // Setup hardware
    pinMode(LED_R_PIN, OUTPUT);
    pinMode(LED_G_PIN, OUTPUT);
    pinMode(LED_B_PIN, OUTPUT);
    
    // Status LED - Red (initializing)
    digitalWrite(LED_R_PIN, HIGH);
    digitalWrite(LED_G_PIN, LOW);
    digitalWrite(LED_B_PIN, LOW);
    
    // Initialize display
    setupDisplay();
    
    // Initialize UI components
    setupUI();
    
    // Connect to WiFi
    setupWiFi();
    
    // Setup API client
    setupApiClient();
    
    // Connect to MQTT
    setupMQTT();
    
    // Show waiting screen
    showWaitingScreen();
    
    // Status LED - Yellow (waiting for config)
    digitalWrite(LED_R_PIN, HIGH);
    digitalWrite(LED_G_PIN, HIGH);
    digitalWrite(LED_B_PIN, LOW);
    
    logger->info("Setup complete, waiting for configuration...");
    
    // Create LVGL tick task
    xTaskCreatePinnedToCore(
        lv_tick_task,   // Task function
        "lv_tick",      // Name
        1024,           // Stack size
        NULL,           // Parameters
        1,              // Priority
        NULL,           // Task handle
        0               // Core
    );
}

/**
 * LVGL tick task
 */
void lv_tick_task(void * pvParameters) {
    (void) pvParameters;
    
    while(1) {
        lv_tick_inc(LVGL_TICK_PERIOD);
        delay(LVGL_TICK_PERIOD);
    }
}

/**
 * Arduino main loop
 */
void loop() {
    // Handle LVGL
    lv_task_handler();
    
    // Handle buttons
    buttonHandler->update();
    
    // Handle MQTT
    if (mqttClient && mqttClient->isConnected()) {
        mqttClient->loop();
        
        // Check if we received configuration
        if (!configReceived && configManager->hasConfig()) {
            logger->info("Configuration received! Building UI...");
            
            // Build UI from configuration
            screenManager->buildFromConfig(configManager->getConfig());
            
            // Navigate to home screen
            navigator->navigateToScreen("home");
            
            configReceived = true;
            
            // Status LED - Green (operational)
            digitalWrite(LED_R_PIN, LOW);
            digitalWrite(LED_G_PIN, HIGH);
            digitalWrite(LED_B_PIN, LOW);
        }
        
        // Send periodic status reports
        if (millis() - lastStatusReport > STATUS_REPORT_INTERVAL) {
            statusReporter->sendStatus(
                navigator->getCurrentScreen(),
                100, // backlight
                WiFi.RSSI()
            );
            lastStatusReport = millis();
        }
        
        // Request config if not received
        if (!configReceived && millis() - lastConfigRequest > CONFIG_REQUEST_INTERVAL) {
            logger->warning("No config received, trying to load again...");
            if (configReceiver->loadConfiguration()) {
                logger->info("Configuration loaded on retry");
            } else {
                logger->warning("Configuration retry failed, will try again later");
            }
            lastConfigRequest = millis();
        }
        
    } else {
        // Try to reconnect
        static unsigned long lastReconnect = 0;
        if (millis() - lastReconnect > MQTT_RECONNECT_DELAY) {
            logger->warning("MQTT disconnected, attempting reconnect...");
            
            if (mqttClient->connect()) {
                logger->info("MQTT reconnected!");
                
                // Re-load configuration if needed
                if (!configReceived) {
                    configReceiver->loadConfiguration();
                    lastConfigRequest = millis();
                }
            }
            
            lastReconnect = millis();
        }
        
        // Status LED - Red (disconnected)
        digitalWrite(LED_R_PIN, HIGH);
        digitalWrite(LED_G_PIN, LOW);
        digitalWrite(LED_B_PIN, LOW);
    }
    
    delay(5);
}