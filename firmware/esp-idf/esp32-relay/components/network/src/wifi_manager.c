/**
 * ESP32 Relay WiFi Manager Implementation
 * High-performance WiFi management for AutoCore ecosystem
 */

#include <string.h>
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_log.h"
#include "esp_wifi.h"
#include "esp_netif.h"
#include "esp_event.h"
#include "lwip/err.h"
#include "lwip/sys.h"
#include "esp_mac.h"

#include "wifi_manager.h"
#include "config_manager.h"

static const char *TAG = "WIFI_MANAGER";

// WiFi event bits
#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT      BIT1

// WiFi manager state
static wifi_state_t current_wifi_state = WIFI_STATE_DISCONNECTED;
static esp_netif_t *sta_netif = NULL;
static esp_netif_t *ap_netif = NULL;
static EventGroupHandle_t wifi_event_group;
static int retry_count = 0;

// Callbacks
static wifi_connected_cb_t connected_callback = NULL;
static wifi_disconnected_cb_t disconnected_callback = NULL;
static wifi_ap_started_cb_t ap_started_callback = NULL;

// Forward declarations
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                              int32_t event_id, void* event_data);

/**
 * WiFi event handler
 */
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                              int32_t event_id, void* event_data) {
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
        ESP_LOGI(TAG, "WiFi station started, connecting...");
        
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        current_wifi_state = WIFI_STATE_DISCONNECTED;
        
        if (retry_count < WIFI_MAXIMUM_RETRY) {
            esp_wifi_connect();
            retry_count++;
            ESP_LOGI(TAG, "Retry connecting to WiFi (%d/%d)", retry_count, WIFI_MAXIMUM_RETRY);
            current_wifi_state = WIFI_STATE_CONNECTING;
        } else {
            xEventGroupSetBits(wifi_event_group, WIFI_FAIL_BIT);
            ESP_LOGE(TAG, "WiFi connection failed after %d attempts", WIFI_MAXIMUM_RETRY);
            current_wifi_state = WIFI_STATE_ERROR;
            
            // Call disconnected callback
            if (disconnected_callback) {
                disconnected_callback();
            }
        }
        
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "WiFi connected, IP: " IPSTR, IP2STR(&event->ip_info.ip));
        
        retry_count = 0;
        current_wifi_state = WIFI_STATE_CONNECTED;
        xEventGroupSetBits(wifi_event_group, WIFI_CONNECTED_BIT);
        
        // Call connected callback
        if (connected_callback) {
            connected_callback();
        }
        
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_AP_STACONNECTED) {
        wifi_event_ap_staconnected_t* event = (wifi_event_ap_staconnected_t*) event_data;
        ESP_LOGI(TAG, "Station " MACSTR " connected to AP", MAC2STR(event->mac));
        
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_AP_STADISCONNECTED) {
        wifi_event_ap_stadisconnected_t* event = (wifi_event_ap_stadisconnected_t*) event_data;
        ESP_LOGI(TAG, "Station " MACSTR " disconnected from AP", MAC2STR(event->mac));
        
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_AP_START) {
        ESP_LOGI(TAG, "WiFi Access Point started");
        current_wifi_state = WIFI_STATE_AP_MODE;
        
        // Call AP started callback
        if (ap_started_callback) {
            ap_started_callback();
        }
    }
}

/**
 * Initialize WiFi manager
 */
esp_err_t wifi_manager_init(void) {
    esp_err_t ret = ESP_OK;
    
    // Create event group
    wifi_event_group = xEventGroupCreate();
    if (wifi_event_group == NULL) {
        ESP_LOGE(TAG, "Failed to create WiFi event group");
        return ESP_ERR_NO_MEM;
    }
    
    // Initialize network interfaces
    sta_netif = esp_netif_create_default_wifi_sta();
    ap_netif = esp_netif_create_default_wifi_ap();
    
    // Initialize WiFi with default config
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ret = esp_wifi_init(&cfg);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to initialize WiFi: %s", esp_err_to_name(ret));
        return ret;
    }
    
    // Register event handlers
    esp_event_handler_instance_t instance_any_id;
    esp_event_handler_instance_t instance_got_ip;
    
    ret |= esp_event_handler_instance_register(WIFI_EVENT,
                                              ESP_EVENT_ANY_ID,
                                              &wifi_event_handler,
                                              NULL,
                                              &instance_any_id);
    
    ret |= esp_event_handler_instance_register(IP_EVENT,
                                              IP_EVENT_STA_GOT_IP,
                                              &wifi_event_handler,
                                              NULL,
                                              &instance_got_ip);
    
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to register event handlers: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ESP_LOGI(TAG, "WiFi manager initialized successfully");
    return ESP_OK;
}

/**
 * Start WiFi in station mode
 */
esp_err_t wifi_manager_start_sta(const char* ssid, const char* password) {
    if (!ssid || strlen(ssid) == 0) {
        ESP_LOGE(TAG, "Invalid SSID");
        return ESP_ERR_INVALID_ARG;
    }
    
    esp_err_t ret;
    
    // Configure WiFi
    wifi_config_t wifi_config = {0};
    strncpy((char*)wifi_config.sta.ssid, ssid, sizeof(wifi_config.sta.ssid) - 1);
    
    if (password && strlen(password) > 0) {
        strncpy((char*)wifi_config.sta.password, password, sizeof(wifi_config.sta.password) - 1);
    }
    
    wifi_config.sta.threshold.authmode = WIFI_AUTH_WPA2_PSK;
    wifi_config.sta.pmf_cfg.capable = true;
    wifi_config.sta.pmf_cfg.required = false;
    
    // Set WiFi mode to station
    ret = esp_wifi_set_mode(WIFI_MODE_STA);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to set WiFi mode: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ret = esp_wifi_set_config(WIFI_IF_STA, &wifi_config);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to set WiFi config: %s", esp_err_to_name(ret));
        return ret;
    }
    
    // Start WiFi
    ret = esp_wifi_start();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to start WiFi: %s", esp_err_to_name(ret));
        return ret;
    }
    
    retry_count = 0;
    current_wifi_state = WIFI_STATE_CONNECTING;
    
    ESP_LOGI(TAG, "WiFi station mode started, connecting to: %s", ssid);
    
    // Wait for connection with timeout
    EventBits_t bits = xEventGroupWaitBits(wifi_event_group,
                                          WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
                                          pdFALSE,
                                          pdFALSE,
                                          pdMS_TO_TICKS(WIFI_CONNECT_TIMEOUT_MS));
    
    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "WiFi connected successfully");
        return ESP_OK;
    } else if (bits & WIFI_FAIL_BIT) {
        ESP_LOGE(TAG, "WiFi connection failed");
        return ESP_FAIL;
    } else {
        ESP_LOGE(TAG, "WiFi connection timeout");
        return ESP_ERR_TIMEOUT;
    }
}

/**
 * Start WiFi in Access Point mode
 */
esp_err_t wifi_manager_start_ap(const char* ssid, const char* password) {
    if (!ssid || strlen(ssid) == 0) {
        ESP_LOGE(TAG, "Invalid AP SSID");
        return ESP_ERR_INVALID_ARG;
    }
    
    esp_err_t ret;
    
    // Configure AP
    wifi_config_t wifi_config = {
        .ap = {
            .channel = WIFI_AP_CHANNEL,
            .max_connection = WIFI_AP_MAX_CONNECTIONS,
            .authmode = WIFI_AUTH_WPA_WPA2_PSK
        },
    };
    
    strncpy((char*)wifi_config.ap.ssid, ssid, sizeof(wifi_config.ap.ssid) - 1);
    wifi_config.ap.ssid_len = strlen(ssid);
    
    if (password && strlen(password) >= 8) {
        strncpy((char*)wifi_config.ap.password, password, sizeof(wifi_config.ap.password) - 1);
    } else {
        wifi_config.ap.authmode = WIFI_AUTH_OPEN;
        ESP_LOGW(TAG, "AP password too short or empty, using open mode");
    }
    
    // Set WiFi mode to AP
    ret = esp_wifi_set_mode(WIFI_MODE_AP);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to set WiFi AP mode: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ret = esp_wifi_set_config(WIFI_IF_AP, &wifi_config);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to set WiFi AP config: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ret = esp_wifi_start();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to start WiFi AP: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ESP_LOGI(TAG, "WiFi AP started: %s", ssid);
    if (wifi_config.ap.authmode != WIFI_AUTH_OPEN) {
        ESP_LOGI(TAG, "AP Password: %s", password);
    }
    ESP_LOGI(TAG, "AP IP: 192.168.4.1");
    
    return ESP_OK;
}

/**
 * Stop WiFi and cleanup
 */
esp_err_t wifi_manager_stop(void) {
    esp_err_t ret = esp_wifi_stop();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to stop WiFi: %s", esp_err_to_name(ret));
        return ret;
    }
    
    current_wifi_state = WIFI_STATE_DISCONNECTED;
    ESP_LOGI(TAG, "WiFi stopped");
    return ESP_OK;
}

/**
 * Get current WiFi state
 */
wifi_state_t wifi_manager_get_state(void) {
    return current_wifi_state;
}

/**
 * Check if WiFi is connected
 */
bool wifi_manager_is_connected(void) {
    return current_wifi_state == WIFI_STATE_CONNECTED;
}

/**
 * Get current IP address
 */
esp_err_t wifi_manager_get_ip(char* ip_str, size_t max_len) {
    if (!ip_str || max_len < 16) {
        return ESP_ERR_INVALID_ARG;
    }
    
    if (current_wifi_state == WIFI_STATE_CONNECTED && sta_netif) {
        esp_netif_ip_info_t ip_info;
        esp_err_t ret = esp_netif_get_ip_info(sta_netif, &ip_info);
        if (ret == ESP_OK) {
            snprintf(ip_str, max_len, IPSTR, IP2STR(&ip_info.ip));
            return ESP_OK;
        }
    } else if (current_wifi_state == WIFI_STATE_AP_MODE && ap_netif) {
        esp_netif_ip_info_t ip_info;
        esp_err_t ret = esp_netif_get_ip_info(ap_netif, &ip_info);
        if (ret == ESP_OK) {
            snprintf(ip_str, max_len, IPSTR, IP2STR(&ip_info.ip));
            return ESP_OK;
        }
    }
    
    strncpy(ip_str, "0.0.0.0", max_len - 1);
    ip_str[max_len - 1] = '\0';
    return ESP_FAIL;
}

/**
 * Get current RSSI value
 */
int8_t wifi_manager_get_rssi(void) {
    if (current_wifi_state != WIFI_STATE_CONNECTED) {
        return -100; // No signal
    }
    
    wifi_ap_record_t ap_info;
    esp_err_t ret = esp_wifi_sta_get_ap_info(&ap_info);
    if (ret == ESP_OK) {
        return ap_info.rssi;
    }
    
    return -100;
}

/**
 * Get MAC address as string
 */
esp_err_t wifi_manager_get_mac_str(char* mac_str, size_t max_len) {
    if (!mac_str || max_len < 18) {
        return ESP_ERR_INVALID_ARG;
    }
    
    uint8_t mac[6];
    esp_err_t ret = esp_wifi_get_mac(WIFI_IF_STA, mac);
    if (ret == ESP_OK) {
        snprintf(mac_str, max_len, "%02x:%02x:%02x:%02x:%02x:%02x",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
        return ESP_OK;
    }
    
    return ret;
}

/**
 * Set connection callback
 */
void wifi_manager_set_connected_cb(wifi_connected_cb_t cb) {
    connected_callback = cb;
}

/**
 * Set disconnection callback
 */
void wifi_manager_set_disconnected_cb(wifi_disconnected_cb_t cb) {
    disconnected_callback = cb;
}

/**
 * Set AP started callback
 */
void wifi_manager_set_ap_started_cb(wifi_ap_started_cb_t cb) {
    ap_started_callback = cb;
}

/**
 * Reconnect to WiFi network
 */
esp_err_t wifi_manager_reconnect(void) {
    if (current_wifi_state == WIFI_STATE_CONNECTED) {
        ESP_LOGI(TAG, "Already connected to WiFi");
        return ESP_OK;
    }
    
    device_config_t* config = config_get();
    if (strlen(config->wifi_ssid) == 0) {
        ESP_LOGE(TAG, "No WiFi credentials configured");
        return ESP_ERR_INVALID_STATE;
    }
    
    ESP_LOGI(TAG, "Attempting WiFi reconnection...");
    return wifi_manager_start_sta(config->wifi_ssid, config->wifi_password);
}

/**
 * Smart WiFi configuration
 */
esp_err_t wifi_manager_smart_config(void) {
    device_config_t* config = config_get();
    
    // Try station mode if configured
    if (config->configured && strlen(config->wifi_ssid) > 0) {
        ESP_LOGI(TAG, "Attempting station mode connection...");
        esp_err_t ret = wifi_manager_start_sta(config->wifi_ssid, config->wifi_password);
        
        if (ret == ESP_OK) {
            ESP_LOGI(TAG, "Station mode connection successful");
            return ESP_OK;
        } else {
            ESP_LOGW(TAG, "Station mode connection failed, falling back to AP mode");
        }
    } else {
        ESP_LOGI(TAG, "Device not configured, starting in AP mode");
    }
    
    // Fallback to AP mode
    char ap_ssid[32];
    config_get_ap_ssid(ap_ssid, sizeof(ap_ssid));
    
    esp_err_t ret = wifi_manager_start_ap(ap_ssid, CONFIG_ESP32_RELAY_DEFAULT_AP_PASSWORD);
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "AP mode started successfully");
    } else {
        ESP_LOGE(TAG, "Failed to start AP mode");
    }
    
    return ret;
}

/**
 * Connect to WiFi network
 * Stops AP mode if running and connects to specified network
 */
esp_err_t wifi_manager_connect(const char* ssid, const char* password) {
    if (!ssid || strlen(ssid) == 0) {
        ESP_LOGE(TAG, "Invalid SSID");
        return ESP_ERR_INVALID_ARG;
    }
    
    ESP_LOGI(TAG, "Connecting to WiFi: %s", ssid);
    
    // Stop AP mode if running
    if (current_wifi_state == WIFI_STATE_AP_MODE) {
        ESP_LOGI(TAG, "Stopping AP mode before connecting to WiFi");
        wifi_manager_stop_ap();
    }
    
    // Start STA mode
    return wifi_manager_start_sta(ssid, password);
}

/**
 * Stop AP mode
 */
esp_err_t wifi_manager_stop_ap(void) {
    if (current_wifi_state != WIFI_STATE_AP_MODE) {
        return ESP_OK;
    }
    
    ESP_LOGI(TAG, "Stopping AP mode");
    
    esp_err_t ret = esp_wifi_set_mode(WIFI_MODE_NULL);
    if (ret == ESP_OK) {
        current_wifi_state = WIFI_STATE_IDLE;
        ESP_LOGI(TAG, "AP mode stopped");
    } else {
        ESP_LOGE(TAG, "Failed to stop AP mode: %s", esp_err_to_name(ret));
    }
    
    return ret;
}

/**
 * Connect to WiFi in Station mode only (no AP fallback)
 * Used for smart boot sequence where we don't want to activate AP mode
 */
esp_err_t wifi_manager_connect_sta_only(const char* ssid, const char* password, uint32_t timeout_ms) {
    if (!ssid || strlen(ssid) == 0) {
        ESP_LOGE(TAG, "Invalid SSID");
        return ESP_ERR_INVALID_ARG;
    }
    
    if (timeout_ms == 0) {
        timeout_ms = WIFI_CONNECT_TIMEOUT_MS;
    }
    
    ESP_LOGI(TAG, "🔄 Connecting to WiFi (STA only): %s", ssid);
    
    esp_err_t ret;
    
    // Stop any current WiFi operation
    if (current_wifi_state == WIFI_STATE_AP_MODE) {
        ESP_LOGI(TAG, "Stopping AP mode for STA connection");
        wifi_manager_stop();
        vTaskDelay(pdMS_TO_TICKS(500)); // Wait for stop to complete
    }
    
    // Configure WiFi for station mode
    wifi_config_t wifi_config = {0};
    strncpy((char*)wifi_config.sta.ssid, ssid, sizeof(wifi_config.sta.ssid) - 1);
    
    if (password && strlen(password) > 0) {
        strncpy((char*)wifi_config.sta.password, password, sizeof(wifi_config.sta.password) - 1);
    }
    
    wifi_config.sta.threshold.authmode = WIFI_AUTH_WPA2_PSK;
    wifi_config.sta.pmf_cfg.capable = true;
    wifi_config.sta.pmf_cfg.required = false;
    
    // Set WiFi mode to station only
    ret = esp_wifi_set_mode(WIFI_MODE_STA);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to set WiFi STA mode: %s", esp_err_to_name(ret));
        return ret;
    }
    
    ret = esp_wifi_set_config(WIFI_IF_STA, &wifi_config);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to set WiFi config: %s", esp_err_to_name(ret));
        return ret;
    }
    
    // Clear event bits
    xEventGroupClearBits(wifi_event_group, WIFI_CONNECTED_BIT | WIFI_FAIL_BIT);
    
    // Start WiFi
    ret = esp_wifi_start();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to start WiFi: %s", esp_err_to_name(ret));
        return ret;
    }
    
    retry_count = 0;
    current_wifi_state = WIFI_STATE_CONNECTING;
    
    ESP_LOGI(TAG, "Waiting for WiFi connection (timeout: %lu ms)...", (unsigned long)timeout_ms);
    
    // Wait for connection with specified timeout
    EventBits_t bits = xEventGroupWaitBits(wifi_event_group,
                                          WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
                                          pdFALSE,
                                          pdFALSE,
                                          pdMS_TO_TICKS(timeout_ms));
    
    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "✅ WiFi connected successfully (STA only)");
        return ESP_OK;
    } else if (bits & WIFI_FAIL_BIT) {
        ESP_LOGW(TAG, "⚠️ WiFi connection failed (STA only)");
        current_wifi_state = WIFI_STATE_DISCONNECTED;
        return ESP_FAIL;
    } else {
        ESP_LOGW(TAG, "⏰ WiFi connection timeout (STA only)");
        current_wifi_state = WIFI_STATE_DISCONNECTED;
        esp_wifi_stop(); // Stop WiFi on timeout
        return ESP_ERR_TIMEOUT;
    }
}