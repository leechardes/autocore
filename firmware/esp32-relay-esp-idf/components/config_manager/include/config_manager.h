/**
 * ESP32 Relay Configuration Manager
 * Manages device configuration using NVS storage
 * 
 * Compatible with AutoCore ecosystem
 * Based on FUNCTIONAL_SPECIFICATION.md
 */

#ifndef CONFIG_MANAGER_H
#define CONFIG_MANAGER_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Configuration constants
#define CONFIG_NAMESPACE "esp32_relay"
#define CONFIG_DEVICE_ID_MAX_LEN 64
#define CONFIG_DEVICE_NAME_MAX_LEN 128
#define CONFIG_WIFI_SSID_MAX_LEN 32
#define CONFIG_WIFI_PASSWORD_MAX_LEN 64
#define CONFIG_IP_STR_MAX_LEN 16
#define CONFIG_MQTT_USER_MAX_LEN 64
#define CONFIG_MQTT_PASSWORD_MAX_LEN 64

// Device configuration structure
typedef struct {
    // Device identification
    char device_id[CONFIG_DEVICE_ID_MAX_LEN];
    char device_name[CONFIG_DEVICE_NAME_MAX_LEN];
    uint8_t relay_channels;
    bool configured;
    
    // WiFi configuration
    char wifi_ssid[CONFIG_WIFI_SSID_MAX_LEN];
    char wifi_password[CONFIG_WIFI_PASSWORD_MAX_LEN];
    
    // Backend configuration
    char backend_ip[CONFIG_IP_STR_MAX_LEN];
    uint16_t backend_port;
    
    // MQTT configuration
    char mqtt_broker[CONFIG_IP_STR_MAX_LEN];
    uint16_t mqtt_port;
    char mqtt_user[CONFIG_MQTT_USER_MAX_LEN];
    char mqtt_password[CONFIG_MQTT_PASSWORD_MAX_LEN];
    bool mqtt_registered;
    
    // Relay states (16 channels max)
    uint8_t relay_states[CONFIG_ESP32_RELAY_MAX_CHANNELS];
} device_config_t;

/**
 * Initialize configuration manager
 * Sets up NVS and loads configuration
 * @return ESP_OK on success
 */
esp_err_t config_manager_init(void);

/**
 * Get current device configuration
 * @return Pointer to device configuration
 */
device_config_t* config_get(void);

/**
 * Save current configuration to NVS
 * @return ESP_OK on success
 */
esp_err_t config_save(void);

/**
 * Load configuration from NVS
 * @return ESP_OK on success
 */
esp_err_t config_load(void);

/**
 * Reset configuration to defaults
 * @return ESP_OK on success
 */
esp_err_t config_reset(void);

/**
 * Update WiFi credentials
 * @param ssid WiFi SSID
 * @param password WiFi password
 * @return ESP_OK on success
 */
esp_err_t config_set_wifi(const char* ssid, const char* password);

/**
 * Update backend configuration
 * @param ip Backend IP address
 * @param port Backend port
 * @return ESP_OK on success
 */
esp_err_t config_set_backend(const char* ip, uint16_t port);

/**
 * Update MQTT configuration
 * @param broker MQTT broker IP
 * @param port MQTT broker port
 * @param user MQTT username
 * @param password MQTT password
 * @return ESP_OK on success
 */
esp_err_t config_set_mqtt(const char* broker, uint16_t port, 
                         const char* user, const char* password);

/**
 * Update relay state
 * @param channel Relay channel (0-15)
 * @param state Relay state (0 or 1)
 * @return ESP_OK on success
 */
esp_err_t config_set_relay_state(uint8_t channel, uint8_t state);

/**
 * Get relay state
 * @param channel Relay channel (0-15)
 * @return Relay state (0 or 1)
 */
uint8_t config_get_relay_state(uint8_t channel);

/**
 * Generate device ID based on MAC address
 * @param device_id Buffer to store device ID
 * @param max_len Maximum buffer length
 * @return ESP_OK on success
 */
esp_err_t config_generate_device_id(char* device_id, size_t max_len);

/**
 * Get AP SSID for current device
 * @param ap_ssid Buffer to store AP SSID
 * @param max_len Maximum buffer length
 * @return ESP_OK on success
 */
esp_err_t config_get_ap_ssid(char* ap_ssid, size_t max_len);

/**
 * Validate configuration parameters
 * @return true if configuration is valid
 */
bool config_validate(void);

#ifdef __cplusplus
}
#endif

#endif // CONFIG_MANAGER_H