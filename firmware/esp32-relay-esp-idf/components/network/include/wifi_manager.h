/**
 * ESP32 Relay WiFi Manager
 * Handles WiFi connection in both Station and Access Point modes
 * 
 * Compatible with AutoCore ecosystem  
 * Based on FUNCTIONAL_SPECIFICATION.md
 */

#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H

#include <stdbool.h>
#include <stdint.h>
#include "esp_wifi.h"
#include "esp_event.h"

#ifdef __cplusplus
extern "C" {
#endif

// WiFi configuration constants
#define WIFI_MAXIMUM_RETRY 15
#define WIFI_CONNECT_TIMEOUT_MS (15 * 1000)
#define WIFI_AP_MAX_CONNECTIONS 4
#define WIFI_AP_CHANNEL 1

// WiFi connection states
typedef enum {
    WIFI_STATE_DISCONNECTED = 0,
    WIFI_STATE_CONNECTING,
    WIFI_STATE_CONNECTED,
    WIFI_STATE_AP_MODE,
    WIFI_STATE_ERROR,
    WIFI_STATE_IDLE
} wifi_state_t;

// WiFi manager callbacks
typedef void (*wifi_connected_cb_t)(void);
typedef void (*wifi_disconnected_cb_t)(void);
typedef void (*wifi_ap_started_cb_t)(void);

/**
 * Initialize WiFi manager
 * Sets up WiFi stack and event handlers
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_init(void);

/**
 * Start WiFi in station mode
 * Attempts to connect to configured network
 * @param ssid Network SSID
 * @param password Network password
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_start_sta(const char* ssid, const char* password);

/**
 * Start WiFi in Access Point mode
 * Creates hotspot for configuration
 * @param ssid AP SSID
 * @param password AP password
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_start_ap(const char* ssid, const char* password);

/**
 * Stop WiFi and cleanup
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_stop(void);

/**
 * Connect to WiFi network
 * Stops AP mode if running and connects to specified network
 * @param ssid Network SSID
 * @param password Network password
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_connect(const char* ssid, const char* password);

/**
 * Stop AP mode
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_stop_ap(void);

/**
 * Get current WiFi state
 * @return Current WiFi state
 */
wifi_state_t wifi_manager_get_state(void);

/**
 * Check if WiFi is connected
 * @return true if connected
 */
bool wifi_manager_is_connected(void);

/**
 * Get current IP address
 * @param ip_str Buffer to store IP address string
 * @param max_len Maximum buffer length
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_get_ip(char* ip_str, size_t max_len);

/**
 * Get current RSSI value
 * @return RSSI value in dBm
 */
int8_t wifi_manager_get_rssi(void);

/**
 * Get MAC address as string
 * @param mac_str Buffer to store MAC address
 * @param max_len Maximum buffer length
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_get_mac_str(char* mac_str, size_t max_len);

/**
 * Set connection callback
 * @param cb Callback function
 */
void wifi_manager_set_connected_cb(wifi_connected_cb_t cb);

/**
 * Set disconnection callback  
 * @param cb Callback function
 */
void wifi_manager_set_disconnected_cb(wifi_disconnected_cb_t cb);

/**
 * Set AP started callback
 * @param cb Callback function  
 */
void wifi_manager_set_ap_started_cb(wifi_ap_started_cb_t cb);

/**
 * Reconnect to WiFi network
 * Uses stored credentials
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_reconnect(void);

/**
 * Smart WiFi configuration
 * Tries STA mode first, falls back to AP mode if failed
 * @return ESP_OK on success
 */
esp_err_t wifi_manager_smart_config(void);

/**
 * Connect to WiFi in Station mode only (no AP fallback)
 * Used for smart boot sequence where we don't want to activate AP mode
 * @param ssid Network SSID
 * @param password Network password
 * @param timeout_ms Connection timeout in milliseconds (0 for default)
 * @return ESP_OK on success, ESP_FAIL on connection failure, ESP_ERR_TIMEOUT on timeout
 */
esp_err_t wifi_manager_connect_sta_only(const char* ssid, const char* password, uint32_t timeout_ms);

#ifdef __cplusplus
}
#endif

#endif // WIFI_MANAGER_H