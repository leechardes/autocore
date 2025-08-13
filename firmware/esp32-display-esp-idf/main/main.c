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
 * - WiFi connectivity with MQTT v2.2.0
 * - MQTT Protocol v2.2.0 compliant
 * - Real-time heartbeat for momentary relays
 * - OTA updates support
 * - Configuration via API REST
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
#include "esp_wifi.h"
#include "nvs_flash.h"
#include "esp_timer.h"
#include "esp_chip_info.h"
#include "esp_http_client.h"
#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "display_driver.h"
#include "xpt2046.h"
#include "ui_manager.h"
#include "device_config.h"
#include "mqtt_client.h"
#include "mqtt_display.h"
#include "mqtt_protocol.h"

static const char *TAG = "ESP32_DISPLAY_MAIN";

// Configuration defaults
#ifndef CONFIG_MQTT_BROKER_URL
#define CONFIG_MQTT_BROKER_URL "mqtt://192.168.1.100:1883"
#endif

#ifndef CONFIG_API_ENDPOINT
#define CONFIG_API_ENDPOINT "http://192.168.1.100:8000/api"
#endif

#ifndef CONFIG_WIFI_SSID
#define CONFIG_WIFI_SSID "AutoCore-WiFi"
#endif

#ifndef CONFIG_WIFI_PASSWORD
#define CONFIG_WIFI_PASSWORD "autocore123"
#endif

// System state
static bool system_initialized = false;
static bool mqtt_initialized = false;
static bool wifi_connected = false;
static uint32_t boot_start_time = 0;
static char device_uuid[64] = "esp32-display-001";

// Display state
static bool display_initialized = false;
static SemaphoreHandle_t display_mutex = NULL;
static display_handle_t display_handle = NULL;
static xpt2046_handle_t touch_handle = NULL;

// MQTT state
static bool last_touch_processed = false;
static uint32_t last_status_publish = 0;

// Forward declarations
static void system_info_print(void);
static esp_err_t display_init(void);
static esp_err_t wifi_init(void);
static esp_err_t mqtt_init(void);
static esp_err_t config_fetch_from_api(void);
static void generate_device_uuid(void);
static void display_task(void *pvParameters);
static void ui_task(void *pvParameters);
static void heartbeat_task(void *pvParameters);
static void mqtt_message_handler(const char* topic, const char* payload);
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                              int32_t event_id, void* event_data);
static void touch_event_handler(int x, int y, bool pressed);

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
    ESP_LOGI(TAG, "MQTT Configuration:");
    ESP_LOGI(TAG, "  Protocol Version: %s", MQTT_PROTOCOL_VERSION);
    ESP_LOGI(TAG, "  Device UUID: %s", device_uuid);
    ESP_LOGI(TAG, "  Broker URL: %s", CONFIG_MQTT_BROKER_URL);
    ESP_LOGI(TAG, "=====================================");
}

/**
 * Generate device UUID based on MAC address
 */
static void generate_device_uuid(void) {
    uint8_t mac[6];
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
    snprintf(device_uuid, sizeof(device_uuid), "esp32-display-%02x%02x%02x",
             mac[3], mac[4], mac[5]);
    ESP_LOGI(TAG, "Generated device UUID: %s", device_uuid);
}

/**
 * WiFi event handler
 */
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                              int32_t event_id, void* event_data) {
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        ESP_LOGW(TAG, "WiFi disconnected, retrying...");
        wifi_connected = false;
        esp_wifi_connect();
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "Got IP: " IPSTR, IP2STR(&event->ip_info.ip));
        wifi_connected = true;
        
        // Inicializar MQTT após conectar WiFi
        if (!mqtt_initialized) {
            mqtt_init();
        }
    }
}

/**
 * Initialize WiFi
 */
static esp_err_t wifi_init(void) {
    ESP_LOGI(TAG, "Initializing WiFi...");
    
    esp_netif_create_default_wifi_sta();
    
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));
    
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, 
                                              &wifi_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, 
                                              &wifi_event_handler, NULL));
    
    wifi_config_t wifi_config = {
        .sta = {
            .ssid = CONFIG_WIFI_SSID,
            .password = CONFIG_WIFI_PASSWORD,
        },
    };
    
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_config));
    ESP_ERROR_CHECK(esp_wifi_start());
    
    ESP_LOGI(TAG, "WiFi initialization completed");
    return ESP_OK;
}

/**
 * Initialize MQTT v2.2.0
 */
static esp_err_t mqtt_init(void) {
    if (mqtt_initialized) {
        ESP_LOGW(TAG, "MQTT already initialized");
        return ESP_OK;
    }
    
    ESP_LOGI(TAG, "Initializing MQTT v2.2.0...");
    
    // Inicializar cliente MQTT
    ESP_ERROR_CHECK(mqtt_client_init(CONFIG_MQTT_BROKER_URL, device_uuid));
    mqtt_client_register_callback(mqtt_message_handler);
    ESP_ERROR_CHECK(mqtt_client_start());
    
    mqtt_initialized = true;
    ESP_LOGI(TAG, "MQTT v2.2.0 initialized successfully");
    
    return ESP_OK;
}

/**
 * MQTT message handler
 */
static void mqtt_message_handler(const char* topic, const char* payload) {
    ESP_LOGI(TAG, "Received MQTT message on topic: %s", topic);
    
    if (strstr(topic, "/display/screen")) {
        mqtt_display_handle_screen_update(payload);
    } else if (strstr(topic, "/display/config")) {
        mqtt_display_handle_config_update(payload);
    } else if (strstr(topic, "/relays/state")) {
        mqtt_display_handle_relay_state(payload);
    } else if (strstr(topic, "/telemetry/")) {
        mqtt_display_handle_telemetry(topic, payload);
    } else if (strstr(topic, "/system/alert")) {
        mqtt_display_handle_system_alert(payload);
    } else if (strstr(topic, "/system/broadcast")) {
        ESP_LOGI(TAG, "System broadcast: %s", payload);
    } else if (strstr(topic, "/errors/")) {
        ESP_LOGW(TAG, "Error received: %s", payload);
    } else {
        ESP_LOGD(TAG, "Unhandled topic: %s", topic);
    }
}

/**
 * Touch event handler
 */
static void touch_event_handler(int x, int y, bool pressed) {
    if (pressed && !last_touch_processed) {
        ESP_LOGI(TAG, "Touch event at (%d, %d)", x, y);
        
        // Enviar evento de touch via MQTT
        if (mqtt_initialized && mqtt_client_get_state() == MQTT_STATE_CONNECTED) {
            mqtt_display_send_touch_event(x, y, "tap");
        }
        
        last_touch_processed = true;
    } else if (!pressed) {
        last_touch_processed = false;
    }
}

/**
 * Heartbeat task for momentary relays
 */
static void heartbeat_task(void *pvParameters) {
    ESP_LOGI(TAG, "Heartbeat task started on core %d", xPortGetCoreID());
    
    while (1) {
        if (mqtt_initialized && mqtt_client_get_state() == MQTT_STATE_CONNECTED) {
            // Processar heartbeats ativos
            mqtt_display_process_heartbeats();
            
            // Publicar status periodicamente
            uint32_t now = esp_timer_get_time() / 1000;
            if ((now - last_status_publish) >= STATUS_PUBLISH_INTERVAL_MS) {
                mqtt_display_send_diagnostic_info();
                last_status_publish = now;
            }
        }
        
        vTaskDelay(pdMS_TO_TICKS(100));  // Verificar a cada 100ms
    }
}

/**
 * Fetch configuration from API REST
 */
static esp_err_t config_fetch_from_api(void) {
    if (!wifi_connected) {
        ESP_LOGW(TAG, "WiFi not connected, skipping API config fetch");
        return ESP_FAIL;
    }
    
    ESP_LOGI(TAG, "Fetching configuration from API...");
    
    // Build URL with dynamic device UUID
    char api_url[256];
    snprintf(api_url, sizeof(api_url), "%s/devices/%s/config", CONFIG_API_ENDPOINT, device_uuid);
    
    esp_http_client_config_t config = {
        .url = api_url,
        .method = HTTP_METHOD_GET,
        .timeout_ms = 5000,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&config);
    if (!client) {
        ESP_LOGE(TAG, "Failed to initialize HTTP client");
        return ESP_FAIL;
    }
    
    esp_err_t err = esp_http_client_perform(client);
    
    if (err == ESP_OK) {
        int status_code = esp_http_client_get_status_code(client);
        int content_length = esp_http_client_get_content_length(client);
        
        ESP_LOGI(TAG, "HTTP Status: %d, Content Length: %d", status_code, content_length);
        
        if (status_code == 200 && content_length > 0) {
            char* buffer = malloc(content_length + 1);
            if (buffer) {
                int data_read = esp_http_client_read(client, buffer, content_length);
                if (data_read > 0) {
                    buffer[data_read] = '\0';
                    ESP_LOGI(TAG, "Configuration received: %s", buffer);
                    // Aqui processaria a configuração recebida
                }
                free(buffer);
            }
        }
    } else {
        ESP_LOGW(TAG, "HTTP request failed: %s", esp_err_to_name(err));
    }
    
    esp_http_client_cleanup(client);
    return err;
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
    
    ESP_LOGI(TAG, "🚀 ESP32 Display ESP-IDF v1.0.0 with MQTT v2.2.0 Starting...");
    
    // Initialize NVS
    ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_LOGW(TAG, "NVS partition was truncated and needs to be erased");
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    ESP_LOGI(TAG, "✅ NVS initialized");
    
    // Generate device UUID based on MAC address
    generate_device_uuid();
    
    // Print system information (now includes MQTT info)
    system_info_print();
    
    // Initialize display hardware
    ESP_ERROR_CHECK(display_init());
    
    // Initialize WiFi
    ESP_ERROR_CHECK(wifi_init());
    ESP_LOGI(TAG, "✅ WiFi initialization started");
    
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
    
    // Create heartbeat task for MQTT v2.2.0 on core 0
    xTaskCreatePinnedToCore(
        heartbeat_task,
        "heartbeat_task",
        4096,
        NULL,
        3,
        NULL,
        0  // Core 0 for MQTT heartbeat
    );
    
    // Wait for WiFi connection before fetching config
    ESP_LOGI(TAG, "Waiting for WiFi connection...");
    uint32_t wifi_wait_count = 0;
    while (!wifi_connected && wifi_wait_count < 30) {  // Wait up to 30 seconds
        vTaskDelay(pdMS_TO_TICKS(1000));
        wifi_wait_count++;
    }
    
    if (wifi_connected) {
        ESP_LOGI(TAG, "✅ WiFi connected, fetching configuration...");
        // Fetch initial configuration from API REST
        config_fetch_from_api();
    } else {
        ESP_LOGW(TAG, "⚠️ WiFi connection timeout, continuing without initial config");
    }
    
    // System initialization complete
    system_initialized = true;
    uint32_t boot_time = (esp_timer_get_time() / 1000) - boot_start_time;
    ESP_LOGI(TAG, "🎉 ESP32 Display with MQTT v2.2.0 initialized in %lu ms", (unsigned long)boot_time);
    
    // Main loop for system monitoring
    uint32_t loop_count = 0;
    uint32_t last_status_log = 0;
    
    while (1) {
        uint32_t current_time = esp_timer_get_time() / 1000;
        
        // System health monitoring every minute
        if (loop_count % 60 == 0 && loop_count > 0) {
            uint32_t free_heap = esp_get_free_heap_size();
            ESP_LOGI(TAG, "📊 System Status - Free Heap: %lu bytes", 
                    (unsigned long)free_heap);
            
            // Check for low memory
            if (free_heap < 10240) { // Less than 10KB
                ESP_LOGW(TAG, "⚠️ Low memory detected!");
            }
            
            // MQTT status
            if (mqtt_initialized) {
                const char* mqtt_state_str = "unknown";
                switch (mqtt_client_get_state()) {
                    case MQTT_STATE_DISCONNECTED: mqtt_state_str = "disconnected"; break;
                    case MQTT_STATE_CONNECTING: mqtt_state_str = "connecting"; break;
                    case MQTT_STATE_CONNECTED: mqtt_state_str = "connected"; break;
                    case MQTT_STATE_ERROR: mqtt_state_str = "error"; break;
                }
                ESP_LOGI(TAG, "📡 MQTT Status: %s, Messages: %lu, Errors: %lu",
                        mqtt_state_str, 
                        (unsigned long)mqtt_client_get_message_count(),
                        (unsigned long)mqtt_client_get_error_count());
            }
        }
        
        // Touch handling with MQTT integration
        #if CONFIG_ESP32_DISPLAY_TOUCH_ENABLED
        if (touch_handle && display_initialized) {
            xpt2046_touch_data_t touch_data;
            if (xpt2046_is_touched(touch_handle)) {
                if (xpt2046_read_touch(touch_handle, &touch_data) == ESP_OK) {
                    touch_event_handler(touch_data.x, touch_data.y, true);
                }
            } else {
                touch_event_handler(0, 0, false);  // Released
            }
        }
        #endif
        
        // Try to reconnect MQTT if WiFi is connected but MQTT is not
        if (wifi_connected && !mqtt_initialized) {
            static uint32_t last_mqtt_retry = 0;
            if ((current_time - last_mqtt_retry) >= 10000) {  // Try every 10 seconds
                ESP_LOGI(TAG, "Attempting to initialize MQTT...");
                mqtt_init();
                last_mqtt_retry = current_time;
            }
        }
        
        loop_count++;
        vTaskDelay(pdMS_TO_TICKS(1000)); // 1 second delay
    }
}