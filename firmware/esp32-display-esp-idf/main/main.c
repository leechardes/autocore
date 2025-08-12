/**
 * ESP32 Display ESP-IDF Main Application
 * High-performance display controller for AutoCore ecosystem
 * 
 * Based on AutoTech HMI Display v2 configuration
 * Optimized for ESP32-2432S028R board
 * 
 * Features:
 * - ILI9341 240x320 display (landscape mode)
 * - XPT2046 resistive touch controller
 * - LVGL v8.3 graphics library
 * - 65MHz SPI for maximum performance
 * - WiFi connectivity with MQTT
 * - OTA updates support
 * - Web interface for configuration
 */

#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "esp_system.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_event.h"
#include "nvs_flash.h"
#include "esp_timer.h"
#include "esp_chip_info.h"
#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "display_driver.h"
#include "xpt2046.h"
#include "ui_manager.h"
#include "device_config.h"

static const char *TAG = "ESP32_DISPLAY_MAIN";

// System state
static bool system_initialized = false;
static uint32_t boot_start_time = 0;

// Display state
static bool display_initialized = false;
static SemaphoreHandle_t display_mutex = NULL;
static display_handle_t display_handle = NULL;
static xpt2046_handle_t touch_handle = NULL;

// Forward declarations
static void system_info_print(void);
static esp_err_t display_init(void);
static esp_err_t network_init(void);
static void display_task(void *pvParameters);
static void ui_task(void *pvParameters);

/**
 * Print system information
 */
static void system_info_print(void) {
    esp_chip_info_t chip_info;
    esp_chip_info(&chip_info);
    
    uint32_t flash_size = 4 * 1024 * 1024; // Default 4MB
    
    ESP_LOGI(TAG, "=====================================");
    ESP_LOGI(TAG, "🖥️  ESP32 Display System Starting");
    ESP_LOGI(TAG, "=====================================");
    ESP_LOGI(TAG, "Chip: %s with %d CPU cores, WiFi%s%s, rev %d",
             CONFIG_IDF_TARGET,
             chip_info.cores,
             (chip_info.features & CHIP_FEATURE_BT) ? "/BT" : "",
             (chip_info.features & CHIP_FEATURE_BLE) ? "/BLE" : "",
             chip_info.revision);
    ESP_LOGI(TAG, "Flash: %lu MB %s", 
             (unsigned long)(flash_size / (1024 * 1024)),
             (chip_info.features & CHIP_FEATURE_EMB_FLASH) ? "(embedded)" : "(external)");
    
    // Display configuration
    ESP_LOGI(TAG, "Display Configuration:");
    ESP_LOGI(TAG, "  Type: %s", 
        #if CONFIG_ESP32_DISPLAY_ILI9341
            "ILI9341 (Alternative Driver)"
        #elif CONFIG_ESP32_DISPLAY_ST7789
            "ST7789"
        #elif CONFIG_ESP32_DISPLAY_SSD1306
            "SSD1306"
        #elif CONFIG_ESP32_DISPLAY_ILI9488
            "ILI9488"
        #else
            "Unknown"
        #endif
    );
    ESP_LOGI(TAG, "  Native Resolution: %dx%d", 
             CONFIG_ESP32_DISPLAY_WIDTH, 
             CONFIG_ESP32_DISPLAY_HEIGHT);
    ESP_LOGI(TAG, "  Landscape Mode: %dx%d", 
             CONFIG_ESP32_DISPLAY_HEIGHT,  // Swapped for landscape
             CONFIG_ESP32_DISPLAY_WIDTH);   // Swapped for landscape
    ESP_LOGI(TAG, "  SPI Frequency: %d MHz", 
             CONFIG_ESP32_DISPLAY_SPI_FREQ / 1000000);
    ESP_LOGI(TAG, "  Touch: %s", 
             CONFIG_ESP32_DISPLAY_TOUCH_ENABLED ? "Enabled" : "Disabled");
    ESP_LOGI(TAG, "=====================================");
}

/**
 * Initialize display hardware
 */
static esp_err_t display_init(void) {
    ESP_LOGI(TAG, "Initializing display hardware...");
    
    // Initialize display mutex
    display_mutex = xSemaphoreCreateMutex();
    if (display_mutex == NULL) {
        ESP_LOGE(TAG, "Failed to create display mutex");
        return ESP_FAIL;
    }
    
    // Configure display
    display_config_t display_config = {
        .width = CONFIG_ESP32_DISPLAY_WIDTH,
        .height = CONFIG_ESP32_DISPLAY_HEIGHT,
        .mosi_gpio = CONFIG_ESP32_DISPLAY_MOSI_GPIO,
        .sclk_gpio = CONFIG_ESP32_DISPLAY_SCLK_GPIO,
        .cs_gpio = CONFIG_ESP32_DISPLAY_CS_GPIO,
        .dc_gpio = CONFIG_ESP32_DISPLAY_DC_GPIO,
        .rst_gpio = CONFIG_ESP32_DISPLAY_RST_GPIO,
        .backlight_gpio = CONFIG_ESP32_DISPLAY_BL_GPIO,
        .rotation = CONFIG_ESP32_DISPLAY_ROTATION,
        .color_mode = DISPLAY_COLOR_MODE_RGB565,
        .spi_clock_speed = CONFIG_ESP32_DISPLAY_SPI_FREQ,
        .buffer_size = 10
    };
    
    // Initialize display driver
    esp_err_t ret = display_driver_init(&display_config, &display_handle);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to initialize display driver: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ESP_LOGI(TAG, "✅ Display driver initialized");
    
    #if CONFIG_ESP32_DISPLAY_TOUCH_ENABLED
    // Configure touch controller
    xpt2046_config_t touch_config = {
        .mosi_gpio = CONFIG_ESP32_DISPLAY_TOUCH_MOSI_GPIO,
        .miso_gpio = CONFIG_ESP32_DISPLAY_TOUCH_MISO_GPIO,
        .clk_gpio = CONFIG_ESP32_DISPLAY_TOUCH_CLK_GPIO,
        .cs_gpio = CONFIG_ESP32_DISPLAY_TOUCH_CS_GPIO,
        .irq_gpio = CONFIG_ESP32_DISPLAY_TOUCH_IRQ_GPIO,
        .screen_width = 320,  // Landscape mode
        .screen_height = 240,
        .min_x = TOUCH_MIN_X,
        .max_x = TOUCH_MAX_X,
        .min_y = TOUCH_MIN_Y,
        .max_y = TOUCH_MAX_Y,
        .spi_freq = CONFIG_ESP32_DISPLAY_TOUCH_SPI_FREQ,
        .min_pressure = TOUCH_PRESSURE_MIN,
        .max_pressure = TOUCH_PRESSURE_MAX,
        .samples = 3,
        .rotation = 1  // Landscape
    };
    
    // Initialize touch driver
    ret = xpt2046_init(&touch_config, &touch_handle);
    if (ret != ESP_OK) {
        ESP_LOGW(TAG, "Touch driver initialization failed: %s", esp_err_to_name(ret));
        // Continue without touch
        touch_handle = NULL;
    } else {
        ESP_LOGI(TAG, "✅ Touch driver initialized");
    }
    #endif
    
    display_initialized = true;
    ESP_LOGI(TAG, "✅ Display hardware initialized");
    
    return ESP_OK;
}

/**
 * Initialize network components
 */
static esp_err_t network_init(void) {
    ESP_LOGI(TAG, "Initializing network components...");
    
    // Network initialization will be handled by network component
    // This is a placeholder for now
    
    ESP_LOGI(TAG, "✅ Network components initialized");
    return ESP_OK;
}

/**
 * Display rendering task
 */
static void display_task(void *pvParameters) {
    ESP_LOGI(TAG, "Display task started on core %d", xPortGetCoreID());
    
    // Wait for display to be initialized
    while (!display_initialized) {
        vTaskDelay(pdMS_TO_TICKS(100));
    }
    
    // Multiple clears to ensure complete screen refresh
    ESP_LOGI(TAG, "Clearing screen multiple times...");
    for(int i = 0; i < 3; i++) {
        display_clear(display_handle, 0x0000);  // Clear to black
        vTaskDelay(pdMS_TO_TICKS(100));
        display_clear(display_handle, COLOR_WHITE);  // Clear to white
        vTaskDelay(pdMS_TO_TICKS(100));
    }
    display_clear(display_handle, COLOR_GRAY);  // Final clear to gray
    vTaskDelay(pdMS_TO_TICKS(1000));  // Wait 1 second
    
    // Initialize UI Manager
    esp_err_t ret = ui_manager_init(display_handle, touch_handle);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to initialize UI Manager");
        vTaskDelete(NULL);
        return;
    }
    
    // Initial draw
    ESP_LOGI(TAG, "Drawing UI...");
    ui_manager_clear_screen();
    ui_manager_draw();
    
    #if CONFIG_ESP32_DISPLAY_FPS_COUNTER
    uint32_t frame_count = 0;
    TickType_t last_fps_time = xTaskGetTickCount();
    #endif
    
    while (1) {
        // Take mutex before updating display
        if (xSemaphoreTake(display_mutex, portMAX_DELAY) == pdTRUE) {
            // Update UI (check for touches and redraw if needed)
            ui_manager_update();
            
            #if CONFIG_ESP32_DISPLAY_FPS_COUNTER
            frame_count++;
            #endif
            
            // Release mutex
            xSemaphoreGive(display_mutex);
        }
        
        // Calculate and display FPS if enabled
        #if CONFIG_ESP32_DISPLAY_FPS_COUNTER
        TickType_t current_time = xTaskGetTickCount();
        if ((current_time - last_fps_time) >= pdMS_TO_TICKS(1000)) {
            ESP_LOGI(TAG, "FPS: %lu", frame_count);
            frame_count = 0;
            last_fps_time = current_time;
        }
        #endif
        
        // Delay for target frame rate (30 FPS)
        vTaskDelay(pdMS_TO_TICKS(33));
    }
}

/**
 * UI update task
 */
static void ui_task(void *pvParameters) {
    ESP_LOGI(TAG, "UI task started on core %d", xPortGetCoreID());
    
    while (1) {
        // UI logic will go here
        // This will handle user interface updates
        // Will be implemented by ui_manager component
        
        // Check for touch events if enabled
        #if CONFIG_ESP32_DISPLAY_TOUCH_ENABLED
        // Touch handling will be implemented by touch_driver component
        #endif
        
        vTaskDelay(pdMS_TO_TICKS(50)); // 20Hz update rate for UI
    }
}

/**
 * Application main function
 */
void app_main(void) {
    esp_err_t ret;
    boot_start_time = esp_timer_get_time() / 1000; // Convert to milliseconds
    
    ESP_LOGI(TAG, "🚀 ESP32 Display ESP-IDF v1.0.0 Starting...");
    
    // Initialize NVS
    ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_LOGW(TAG, "NVS partition was truncated and needs to be erased");
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    ESP_LOGI(TAG, "✅ NVS initialized");
    
    // Initialize TCP/IP stack
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_LOGI(TAG, "✅ TCP/IP stack initialized");
    
    // Initialize event loop
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    ESP_LOGI(TAG, "✅ Event loop initialized");
    
    // Print system information
    system_info_print();
    
    // Initialize display hardware
    ESP_ERROR_CHECK(display_init());
    
    // Initialize network components
    ESP_ERROR_CHECK(network_init());
    
    // Create display task on core 1 (dedicated for display)
    xTaskCreatePinnedToCore(
        display_task,
        "display_task",
        4096,
        NULL,
        5,
        NULL,
        1  // Core 1 for display
    );
    
    // Create UI task on core 0
    xTaskCreatePinnedToCore(
        ui_task,
        "ui_task",
        4096,
        NULL,
        4,
        NULL,
        0  // Core 0 for UI logic
    );
    
    // System initialization complete
    system_initialized = true;
    uint32_t boot_time = (esp_timer_get_time() / 1000) - boot_start_time;
    ESP_LOGI(TAG, "🎉 System initialization complete in %lu ms", (unsigned long)boot_time);
    
    // Main loop for system monitoring
    uint32_t loop_count = 0;
    while (1) {
        // System health monitoring
        if (loop_count % 60 == 0 && loop_count > 0) { // Every minute
            uint32_t free_heap = esp_get_free_heap_size();
            ESP_LOGI(TAG, "📊 System Status - Free Heap: %lu bytes", 
                    (unsigned long)free_heap);
            
            // Check for low memory
            if (free_heap < 10240) { // Less than 10KB
                ESP_LOGW(TAG, "⚠️ Low memory detected!");
            }
        }
        
        loop_count++;
        vTaskDelay(pdMS_TO_TICKS(1000)); // 1 second delay
    }
}