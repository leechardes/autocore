/**
 * ESP32 Relay Configuration Manager Implementation
 * NVS-based configuration storage for AutoCore ecosystem
 */

#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "esp_log.h"
#include "esp_system.h"
#include "nvs_flash.h"
#include "nvs.h"
#include "esp_wifi.h"
#include "config_manager.h"

static const char *TAG = "CONFIG_MANAGER";

// Global configuration instance
static device_config_t device_config;
static nvs_handle_t config_nvs_handle;
static bool config_initialized = false;

// Default configuration values
static const device_config_t default_config = {
    .device_id = "",
    .device_name = "",
    .relay_channels = CONFIG_ESP32_RELAY_MAX_CHANNELS,
    .configured = false,
    .wifi_ssid = "",
    .wifi_password = "",
    .backend_ip = CONFIG_ESP32_RELAY_DEFAULT_BACKEND_IP,
    .backend_port = CONFIG_ESP32_RELAY_DEFAULT_BACKEND_PORT,
    .mqtt_broker = CONFIG_ESP32_RELAY_DEFAULT_BACKEND_IP,
    .mqtt_port = CONFIG_ESP32_RELAY_DEFAULT_MQTT_PORT,
    .mqtt_user = "",
    .mqtt_password = "",
    .mqtt_registered = false,
    .relay_states = {0} // All relays off by default
};

/**
 * Initialize configuration manager
 */
esp_err_t config_manager_init(void) {
    esp_err_t err;
    
    // Open NVS namespace
    err = nvs_open(CONFIG_NAMESPACE, NVS_READWRITE, &config_nvs_handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to open NVS namespace: %s", esp_err_to_name(err));
        return err;
    }
    
    // Initialize with default configuration
    memcpy(&device_config, &default_config, sizeof(device_config_t));
    
    // Generate device ID if empty
    if (strlen(device_config.device_id) == 0) {
        config_generate_device_id(device_config.device_id, sizeof(device_config.device_id));
    }
    
    // Generate device name if empty
    if (strlen(device_config.device_name) == 0) {
        uint8_t mac[6];
        esp_wifi_get_mac(WIFI_IF_STA, mac);
        snprintf(device_config.device_name, sizeof(device_config.device_name),
                "ESP32 Relay %02x%02x%02x", mac[3], mac[4], mac[5]);
    }
    
    // Load configuration from NVS
    config_load();
    
    config_initialized = true;
    ESP_LOGI(TAG, "Configuration manager initialized");
    ESP_LOGI(TAG, "Device ID: %s", device_config.device_id);
    ESP_LOGI(TAG, "Device Name: %s", device_config.device_name);
    
    return ESP_OK;
}

/**
 * Get current device configuration
 */
device_config_t* config_get(void) {
    if (!config_initialized) {
        ESP_LOGE(TAG, "Configuration manager not initialized");
        return NULL;
    }
    return &device_config;
}

/**
 * Save configuration to NVS
 */
esp_err_t config_save(void) {
    if (!config_initialized) {
        ESP_LOGE(TAG, "Configuration manager not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    esp_err_t err = ESP_OK;
    
    // Save device configuration
    err |= nvs_set_str(config_nvs_handle, "device_id", device_config.device_id);
    err |= nvs_set_str(config_nvs_handle, "device_name", device_config.device_name);
    err |= nvs_set_u8(config_nvs_handle, "relay_channels", device_config.relay_channels);
    err |= nvs_set_u8(config_nvs_handle, "configured", device_config.configured ? 1 : 0);
    
    // Save WiFi configuration
    err |= nvs_set_str(config_nvs_handle, "wifi_ssid", device_config.wifi_ssid);
    err |= nvs_set_str(config_nvs_handle, "wifi_password", device_config.wifi_password);
    
    // Save backend configuration
    err |= nvs_set_str(config_nvs_handle, "backend_ip", device_config.backend_ip);
    err |= nvs_set_u16(config_nvs_handle, "backend_port", device_config.backend_port);
    
    // Save MQTT configuration
    err |= nvs_set_str(config_nvs_handle, "mqtt_broker", device_config.mqtt_broker);
    err |= nvs_set_u16(config_nvs_handle, "mqtt_port", device_config.mqtt_port);
    err |= nvs_set_str(config_nvs_handle, "mqtt_user", device_config.mqtt_user);
    err |= nvs_set_str(config_nvs_handle, "mqtt_password", device_config.mqtt_password);
    err |= nvs_set_u8(config_nvs_handle, "mqtt_registered", device_config.mqtt_registered ? 1 : 0);
    
    // Save relay states
    err |= nvs_set_blob(config_nvs_handle, "relay_states", device_config.relay_states, 
                       sizeof(device_config.relay_states));
    
    // Commit changes
    err |= nvs_commit(config_nvs_handle);
    
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to save configuration: %s", esp_err_to_name(err));
        return err;
    }
    
    ESP_LOGI(TAG, "Configuration saved successfully");
    return ESP_OK;
}

/**
 * Load configuration from NVS
 */
esp_err_t config_load(void) {
    if (!config_initialized) {
        ESP_LOGE(TAG, "Configuration manager not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    size_t required_size;
    esp_err_t err;
    uint8_t temp_bool;
    
    // Load device configuration
    required_size = sizeof(device_config.device_id);
    err = nvs_get_str(config_nvs_handle, "device_id", device_config.device_id, &required_size);
    if (err == ESP_ERR_NVS_NOT_FOUND) {
        config_generate_device_id(device_config.device_id, sizeof(device_config.device_id));
    }
    
    required_size = sizeof(device_config.device_name);
    err = nvs_get_str(config_nvs_handle, "device_name", device_config.device_name, &required_size);
    if (err == ESP_ERR_NVS_NOT_FOUND) {
        uint8_t mac[6];
        esp_wifi_get_mac(WIFI_IF_STA, mac);
        snprintf(device_config.device_name, sizeof(device_config.device_name),
                "ESP32 Relay %02x%02x%02x", mac[3], mac[4], mac[5]);
    }
    
    nvs_get_u8(config_nvs_handle, "relay_channels", &device_config.relay_channels);
    if (nvs_get_u8(config_nvs_handle, "configured", &temp_bool) == ESP_OK) {
        device_config.configured = temp_bool != 0;
    }
    
    // Load WiFi configuration
    required_size = sizeof(device_config.wifi_ssid);
    nvs_get_str(config_nvs_handle, "wifi_ssid", device_config.wifi_ssid, &required_size);
    
    required_size = sizeof(device_config.wifi_password);
    nvs_get_str(config_nvs_handle, "wifi_password", device_config.wifi_password, &required_size);
    
    // Load backend configuration
    required_size = sizeof(device_config.backend_ip);
    nvs_get_str(config_nvs_handle, "backend_ip", device_config.backend_ip, &required_size);
    nvs_get_u16(config_nvs_handle, "backend_port", &device_config.backend_port);
    
    // Load MQTT configuration
    required_size = sizeof(device_config.mqtt_broker);
    nvs_get_str(config_nvs_handle, "mqtt_broker", device_config.mqtt_broker, &required_size);
    nvs_get_u16(config_nvs_handle, "mqtt_port", &device_config.mqtt_port);
    
    required_size = sizeof(device_config.mqtt_user);
    nvs_get_str(config_nvs_handle, "mqtt_user", device_config.mqtt_user, &required_size);
    
    required_size = sizeof(device_config.mqtt_password);
    nvs_get_str(config_nvs_handle, "mqtt_password", device_config.mqtt_password, &required_size);
    
    if (nvs_get_u8(config_nvs_handle, "mqtt_registered", &temp_bool) == ESP_OK) {
        device_config.mqtt_registered = temp_bool != 0;
    }
    
    // Load relay states
    required_size = sizeof(device_config.relay_states);
    nvs_get_blob(config_nvs_handle, "relay_states", device_config.relay_states, &required_size);
    
    ESP_LOGI(TAG, "Configuration loaded successfully");
    return ESP_OK;
}

/**
 * Reset configuration to defaults
 */
esp_err_t config_reset(void) {
    if (!config_initialized) {
        ESP_LOGE(TAG, "Configuration manager not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Erase all NVS entries
    esp_err_t err = nvs_erase_all(config_nvs_handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to erase NVS: %s", esp_err_to_name(err));
        return err;
    }
    
    err = nvs_commit(config_nvs_handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to commit NVS erase: %s", esp_err_to_name(err));
        return err;
    }
    
    // Reset to default configuration
    memcpy(&device_config, &default_config, sizeof(device_config_t));
    
    // Regenerate device ID and name
    config_generate_device_id(device_config.device_id, sizeof(device_config.device_id));
    uint8_t mac[6];
    esp_wifi_get_mac(WIFI_IF_STA, mac);
    snprintf(device_config.device_name, sizeof(device_config.device_name),
            "ESP32 Relay %02x%02x%02x", mac[3], mac[4], mac[5]);
    
    ESP_LOGI(TAG, "Configuration reset to defaults");
    return ESP_OK;
}

/**
 * Update WiFi credentials
 */
esp_err_t config_set_wifi(const char* ssid, const char* password) {
    if (!ssid || strlen(ssid) == 0) {
        ESP_LOGE(TAG, "Invalid SSID");
        return ESP_ERR_INVALID_ARG;
    }
    
    strncpy(device_config.wifi_ssid, ssid, sizeof(device_config.wifi_ssid) - 1);
    device_config.wifi_ssid[sizeof(device_config.wifi_ssid) - 1] = '\0';
    
    if (password) {
        strncpy(device_config.wifi_password, password, sizeof(device_config.wifi_password) - 1);
        device_config.wifi_password[sizeof(device_config.wifi_password) - 1] = '\0';
    } else {
        device_config.wifi_password[0] = '\0';
    }
    
    device_config.configured = true;
    
    ESP_LOGI(TAG, "WiFi credentials updated: %s", ssid);
    return ESP_OK;
}

/**
 * Update backend configuration
 */
esp_err_t config_set_backend(const char* ip, uint16_t port) {
    if (!ip || strlen(ip) == 0 || port == 0) {
        ESP_LOGE(TAG, "Invalid backend configuration");
        return ESP_ERR_INVALID_ARG;
    }
    
    strncpy(device_config.backend_ip, ip, sizeof(device_config.backend_ip) - 1);
    device_config.backend_ip[sizeof(device_config.backend_ip) - 1] = '\0';
    device_config.backend_port = port;
    
    // Also update MQTT broker to same IP by default
    strncpy(device_config.mqtt_broker, ip, sizeof(device_config.mqtt_broker) - 1);
    device_config.mqtt_broker[sizeof(device_config.mqtt_broker) - 1] = '\0';
    
    ESP_LOGI(TAG, "Backend configuration updated: %s:%d", ip, port);
    return ESP_OK;
}

/**
 * Update MQTT configuration
 */
esp_err_t config_set_mqtt(const char* broker, uint16_t port, 
                         const char* user, const char* password) {
    if (!broker || strlen(broker) == 0 || port == 0) {
        ESP_LOGE(TAG, "Invalid MQTT configuration");
        return ESP_ERR_INVALID_ARG;
    }
    
    strncpy(device_config.mqtt_broker, broker, sizeof(device_config.mqtt_broker) - 1);
    device_config.mqtt_broker[sizeof(device_config.mqtt_broker) - 1] = '\0';
    device_config.mqtt_port = port;
    
    if (user) {
        strncpy(device_config.mqtt_user, user, sizeof(device_config.mqtt_user) - 1);
        device_config.mqtt_user[sizeof(device_config.mqtt_user) - 1] = '\0';
    }
    
    if (password) {
        strncpy(device_config.mqtt_password, password, sizeof(device_config.mqtt_password) - 1);
        device_config.mqtt_password[sizeof(device_config.mqtt_password) - 1] = '\0';
    }
    
    device_config.mqtt_registered = true;
    
    ESP_LOGI(TAG, "MQTT configuration updated: %s:%d", broker, port);
    return ESP_OK;
}

/**
 * Update relay state
 */
esp_err_t config_set_relay_state(uint8_t channel, uint8_t state) {
    if (channel >= CONFIG_ESP32_RELAY_MAX_CHANNELS) {
        ESP_LOGE(TAG, "Invalid relay channel: %d", channel);
        return ESP_ERR_INVALID_ARG;
    }
    
    if (state > 1) {
        ESP_LOGE(TAG, "Invalid relay state: %d", state);
        return ESP_ERR_INVALID_ARG;
    }
    
    device_config.relay_states[channel] = state;
    
    ESP_LOGD(TAG, "Relay state updated: Channel %d = %d", channel, state);
    return ESP_OK;
}

/**
 * Get relay state
 */
uint8_t config_get_relay_state(uint8_t channel) {
    if (channel >= CONFIG_ESP32_RELAY_MAX_CHANNELS) {
        ESP_LOGE(TAG, "Invalid relay channel: %d", channel);
        return 0;
    }
    
    return device_config.relay_states[channel];
}

/**
 * Generate device ID based on MAC address
 */
esp_err_t config_generate_device_id(char* device_id, size_t max_len) {
    if (!device_id || max_len < 16) {
        return ESP_ERR_INVALID_ARG;
    }
    
    uint8_t mac[6];
    esp_wifi_get_mac(WIFI_IF_STA, mac);
    
    snprintf(device_id, max_len, "esp32_relay_%02x%02x%02x", 
            mac[3], mac[4], mac[5]);
    
    return ESP_OK;
}

/**
 * Get AP SSID for current device
 */
esp_err_t config_get_ap_ssid(char* ap_ssid, size_t max_len) {
    if (!ap_ssid || max_len < 20) {
        return ESP_ERR_INVALID_ARG;
    }
    
    uint8_t mac[6];
    esp_wifi_get_mac(WIFI_IF_STA, mac);
    
    snprintf(ap_ssid, max_len, "%s-%02x%02x%02x", 
            CONFIG_ESP32_RELAY_DEFAULT_AP_SSID_PREFIX,
            mac[3], mac[4], mac[5]);
    
    return ESP_OK;
}

/**
 * Validate configuration parameters
 */
bool config_validate(void) {
    // Check device ID
    if (strlen(device_config.device_id) == 0) {
        ESP_LOGE(TAG, "Device ID is empty");
        return false;
    }
    
    // Check relay channels
    if (device_config.relay_channels == 0 || 
        device_config.relay_channels > CONFIG_ESP32_RELAY_MAX_CHANNELS) {
        ESP_LOGE(TAG, "Invalid relay channels: %d", device_config.relay_channels);
        return false;
    }
    
    // If configured, WiFi SSID must not be empty
    if (device_config.configured && strlen(device_config.wifi_ssid) == 0) {
        ESP_LOGE(TAG, "Configured but WiFi SSID is empty");
        return false;
    }
    
    // Backend configuration validation
    if (strlen(device_config.backend_ip) > 0) {
        if (device_config.backend_port == 0) {
            ESP_LOGE(TAG, "Backend IP set but port is 0");
            return false;
        }
    }
    
    ESP_LOGI(TAG, "Configuration validation passed");
    return true;
}