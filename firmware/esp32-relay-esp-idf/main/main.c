/**
 * ESP32 Relay ESP-IDF Main Application
 * High-performance C implementation for AutoCore ecosystem
 * 
 * Migrated from MicroPython to ESP-IDF for maximum performance:
 * - Boot time < 1 second
 * - HTTP response < 10ms  
 * - MQTT latency < 50ms
 * - RAM usage < 50KB
 * 
 * Based on FUNCTIONAL_SPECIFICATION.md
 */

#include <stdio.h>
#include <string.h>
#include <sys/param.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/timers.h"
#include "esp_system.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_event.h"
#include "nvs_flash.h"
#include "esp_timer.h"
#include "esp_chip_info.h"

// Application modules
#include "config_manager.h"
#include "wifi_manager.h"
#include "http_server.h"
#include "mqtt_handler.h"
#include "relay_control.h"

// Logging tag
static const char *TAG = "ESP32_RELAY_MAIN";

// System state
static bool system_initialized = false;
static uint32_t boot_start_time = 0;

// Task handles
static TaskHandle_t mqtt_task_handle = NULL;

// Forward declarations
static void system_info_print(void);
static void wifi_connected_handler(void);
static void wifi_disconnected_handler(void);
static void wifi_ap_started_handler(void);
static void mqtt_task(void *pvParameters);
static esp_err_t backend_register_device(void);

/**
 * Print system information
 */
static void system_info_print(void) {
    esp_chip_info_t chip_info;
    esp_chip_info(&chip_info);
    
    // Get flash size from chip info (simplified for ESP-IDF 5.0)
    uint32_t flash_size = 4 * 1024 * 1024; // Default 4MB
    
    ESP_LOGI(TAG, "✅ ESP32 Relay System Starting");
    ESP_LOGI(TAG, "Chip: %s with %d CPU cores, WiFi%s%s, rev %d",
             CONFIG_IDF_TARGET,
             chip_info.cores,
             (chip_info.features & CHIP_FEATURE_BT) ? "/BT" : "",
             (chip_info.features & CHIP_FEATURE_BLE) ? "/BLE" : "",
             chip_info.revision);
    ESP_LOGI(TAG, "Flash: %lu MB %s", 
             (unsigned long)(flash_size / (1024 * 1024)),
             (chip_info.features & CHIP_FEATURE_EMB_FLASH) ? "(embedded)" : "(external)");
    
    // Device configuration info
    device_config_t* config = config_get();
    ESP_LOGI(TAG, "Device ID: %s", config->device_id);
    ESP_LOGI(TAG, "Device Name: %s", config->device_name);
    ESP_LOGI(TAG, "Relay Channels: %d", config->relay_channels);
    ESP_LOGI(TAG, "Configured: %s", config->configured ? "YES" : "NO");
}

/**
 * WiFi connected event handler
 */
static void wifi_connected_handler(void) {
    device_config_t* config = config_get();
    
    ESP_LOGI(TAG, "✅ WiFi Connected!");
    
    // Get IP address
    char ip_str[16];
    if (wifi_manager_get_ip(ip_str, sizeof(ip_str)) == ESP_OK) {
        ESP_LOGI(TAG, "IP Address: %s", ip_str);
    }
    
    // Stop AP mode since we're connected to WiFi
    ESP_LOGI(TAG, "Stopping AP mode as WiFi is connected");
    wifi_manager_stop_ap();
    
    // Start HTTP server (keep it running for configuration access)
    http_server_init();
    
    // Register with backend if configured
    if (strlen(config->backend_ip) > 0 && config->backend_port > 0) {
        ESP_LOGI(TAG, "🔄 Registering with backend...");
        if (backend_register_device() == ESP_OK) {
            ESP_LOGI(TAG, "✅ Backend registration successful");
            
            // Start MQTT client
            if (mqtt_client_init() == ESP_OK) {
                // Create MQTT task on core 1 for optimal performance
                xTaskCreatePinnedToCore(
                    mqtt_task,
                    "mqtt_task",
                    4096,
                    NULL,
                    5,
                    &mqtt_task_handle,
                    1  // Run on core 1
                );
                ESP_LOGI(TAG, "✅ MQTT task started on core 1");
            }
        } else {
            ESP_LOGW(TAG, "⚠️ Backend registration failed, continuing without MQTT");
        }
    } else {
        ESP_LOGI(TAG, "Backend not configured, running HTTP-only mode");
    }
}

/**
 * WiFi disconnected event handler
 */
static void wifi_disconnected_handler(void) {
    ESP_LOGW(TAG, "⚠️ WiFi disconnected");
    
    // Stop MQTT if running
    if (mqtt_task_handle != NULL) {
        mqtt_client_stop();
        vTaskDelete(mqtt_task_handle);
        mqtt_task_handle = NULL;
        ESP_LOGI(TAG, "MQTT task stopped");
    }
    
    // Don't restart AP mode here - let the WiFi manager handle reconnection
}

/**
 * WiFi AP started event handler
 */
static void wifi_ap_started_handler(void) {
    ESP_LOGI(TAG, "🌐 WiFi Access Point started");
    
    // Get AP SSID
    char ap_ssid[32];
    config_get_ap_ssid(ap_ssid, sizeof(ap_ssid));
    
    ESP_LOGI(TAG, "🌐 AP SSID: %s", ap_ssid);
    ESP_LOGI(TAG, "🌐 AP Password: %s", CONFIG_ESP32_RELAY_DEFAULT_AP_PASSWORD);
    ESP_LOGI(TAG, "🌐 Configuration page: http://192.168.4.1");
    
    // Start HTTP server if not already running
    http_server_init();
}

/**
 * MQTT task - runs on core 1
 */
static void mqtt_task(void *pvParameters) {
    ESP_LOGI(TAG, "🚀 MQTT task started");
    
    // Start MQTT client
    if (mqtt_client_start() != ESP_OK) {
        ESP_LOGE(TAG, "❌ Failed to start MQTT client");
        vTaskDelete(NULL);
        return;
    }
    
    // Start telemetry publishing
    if (mqtt_start_telemetry_task() != ESP_OK) {
        ESP_LOGE(TAG, "❌ Failed to start telemetry task");
    }
    
    // MQTT task main loop
    while (1) {
        // Check MQTT connection status
        if (!mqtt_client_is_connected()) {
            ESP_LOGW(TAG, "⚠️ MQTT disconnected, attempting reconnection");
            mqtt_client_reconnect();
        }
        
        // Task runs every 5 seconds
        vTaskDelay(pdMS_TO_TICKS(5000));
    }
}

/**
 * Register device with AutoCore backend
 */
static esp_err_t backend_register_device(void) {
    device_config_t* config = config_get();
    
    // Use mqtt_register_device function which handles HTTP registration
    esp_err_t ret = mqtt_register_device();
    
    if (ret == ESP_OK) {
        // Save updated configuration
        config_save();
        ESP_LOGI(TAG, "✅ Device registered with backend");
    } else {
        ESP_LOGE(TAG, "❌ Backend registration failed");
    }
    
    return ret;
}

/**
 * Application main function
 */
void app_main(void) {
    esp_err_t ret;
    boot_start_time = esp_timer_get_time() / 1000; // Convert to milliseconds
    
    ESP_LOGI(TAG, "🚀 ESP32 Relay ESP-IDF v2.0 Starting...");
    
    // Initialize NVS (required for WiFi and config storage)
    ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_LOGW(TAG, "⚠️ NVS partition was truncated and needs to be erased");
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
    
    // Initialize configuration manager
    ESP_ERROR_CHECK(config_manager_init());
    ESP_LOGI(TAG, "✅ Configuration manager initialized");
    
    // Print system information
    system_info_print();
    
    // Initialize relay control
    ESP_ERROR_CHECK(relay_control_init());
    ESP_LOGI(TAG, "✅ Relay control initialized");
    
    // Restore relay states from configuration
    relay_restore_states();
    ESP_LOGI(TAG, "✅ Relay states restored");
    
    // Initialize WiFi manager
    ESP_ERROR_CHECK(wifi_manager_init());
    ESP_LOGI(TAG, "✅ WiFi manager initialized");
    
    // Set WiFi callbacks
    wifi_manager_set_connected_cb(wifi_connected_handler);
    wifi_manager_set_disconnected_cb(wifi_disconnected_handler);
    wifi_manager_set_ap_started_cb(wifi_ap_started_handler);
    
    // Start WiFi in smart configuration mode
    ESP_LOGI(TAG, "🔄 Starting WiFi smart configuration...");
    ret = wifi_manager_smart_config();
    
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "❌ WiFi initialization failed");
        // Continue in AP mode for configuration
        device_config_t* config = config_get();
        char ap_ssid[32];
        config_get_ap_ssid(ap_ssid, sizeof(ap_ssid));
        wifi_manager_start_ap(ap_ssid, CONFIG_ESP32_RELAY_DEFAULT_AP_PASSWORD);
        http_server_init();
    }
    
    // System initialization complete
    system_initialized = true;
    uint32_t boot_time = (esp_timer_get_time() / 1000) - boot_start_time;
    ESP_LOGI(TAG, "🎉 System initialization complete in %lu ms", (unsigned long)boot_time);
    
    // Main application loop (runs on core 0)
    uint32_t loop_count = 0;
    while (1) {
        // Periodic system maintenance
        if (loop_count % 60 == 0) { // Every 60 seconds
            // Log system status
            ESP_LOGI(TAG, "📊 System Status - Uptime: %llu s, Free Heap: %lu bytes", 
                    (unsigned long long)(esp_timer_get_time() / 1000000),
                    (unsigned long)esp_get_free_heap_size());
            
            // Check memory and cleanup if necessary
            if (esp_get_free_heap_size() < 10240) { // Less than 10KB
                ESP_LOGW(TAG, "⚠️ Low memory detected, performing cleanup");
                // Force garbage collection equivalent
                esp_restart(); // In extreme cases, restart to recover
            }
            
            // Save configuration periodically
            config_save();
        }
        
        // Check WiFi connectivity
        if (!wifi_manager_is_connected() && loop_count % 60 == 30) {
            ESP_LOGI(TAG, "🔄 Checking WiFi connectivity...");
            wifi_manager_reconnect();
        }
        
        loop_count++;
        vTaskDelay(pdMS_TO_TICKS(1000)); // 1 second delay
    }
}

/**
 * Task to handle system monitoring and maintenance
 * This could be expanded for additional monitoring features
 */
void system_monitor_task(void *pvParameters) {
    while (1) {
        // Monitor system health
        uint32_t free_heap = esp_get_free_heap_size();
        
        if (free_heap < 5120) { // Less than 5KB
            ESP_LOGE(TAG, "❌ Critical memory low: %lu bytes", (unsigned long)free_heap);
            // Emergency cleanup or restart
            esp_restart();
        }
        
        vTaskDelay(pdMS_TO_TICKS(10000)); // Check every 10 seconds
    }
}