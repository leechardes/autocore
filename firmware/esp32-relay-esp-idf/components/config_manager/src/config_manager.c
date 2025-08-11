/**
 * ESP32 Relay Configuration Manager Implementation
 * NVS-based configuration storage for AutoCore ecosystem
 */

#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "esp_log.h"
#include "esp_system.h"
#include "esp_flash.h"
#include "nvs_flash.h"
#include "nvs.h"
#include "esp_wifi.h"
#include "esp_mac.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
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
    // New MQTT fields defaults
    .device_registered = false,
    .mqtt_broker_host = "",
    .mqtt_broker_port = 0,
    .mqtt_username = "",
    .mqtt_password_new = "",
    .mqtt_topic_prefix = "",
    .last_registration = 0,
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
    
    // ALWAYS generate device ID based on MAC to ensure consistency
    config_generate_device_id(device_config.device_id, sizeof(device_config.device_id));
    
    // ALWAYS generate device name based on MAC to ensure consistency
    // Use last 3 bytes for shorter name
    uint8_t mac[6];
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
    snprintf(device_config.device_name, sizeof(device_config.device_name),
            "ESP32-%02x%02x%02x", mac[3], mac[4], mac[5]);
    
    // Mark as initialized BEFORE loading so config_load() can work
    config_initialized = true;
    
    // Load configuration from NVS (but device_id and device_name will be overridden)
    config_load();
    
    // FORCE correct device_id and device_name after loading
    config_generate_device_id(device_config.device_id, sizeof(device_config.device_id));
    snprintf(device_config.device_name, sizeof(device_config.device_name),
            "ESP32-Relay-%02x%02x%02x", mac[3], mac[4], mac[5]);
    
    // Already marked as initialized above
    ESP_LOGI(TAG, "✅ Configuration manager initialized");
    ESP_LOGI(TAG, "📝 Final configuration after init:");
    ESP_LOGI(TAG, "  Device ID: %s", device_config.device_id);
    ESP_LOGI(TAG, "  Device Name: %s", device_config.device_name);
    ESP_LOGI(TAG, "  WiFi SSID: '%s' (len: %d)", device_config.wifi_ssid, (int)strlen(device_config.wifi_ssid));
    ESP_LOGI(TAG, "  WiFi Password: %s", strlen(device_config.wifi_password) > 0 ? "***SET***" : "EMPTY");
    ESP_LOGI(TAG, "  Configured flag: %s", device_config.configured ? "YES" : "NO");
    ESP_LOGI(TAG, "  Backend: %s:%d", device_config.backend_ip, device_config.backend_port);
    ESP_LOGI(TAG, "  Device registered: %s", device_config.device_registered ? "YES" : "NO");
    
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
    
    ESP_LOGI(TAG, "💾 Saving configuration to NVS...");
    ESP_LOGI(TAG, "  configured flag: %s", device_config.configured ? "true" : "false");
    ESP_LOGI(TAG, "  wifi_ssid: '%s'", device_config.wifi_ssid);
    ESP_LOGI(TAG, "  wifi_password: %s", strlen(device_config.wifi_password) > 0 ? "***SET***" : "EMPTY");
    
    esp_err_t err = ESP_OK;
    esp_err_t temp_err;
    
    // Don't save device_id and device_name - they are always regenerated from MAC
    // err |= nvs_set_str(config_nvs_handle, "device_id", device_config.device_id);
    // err |= nvs_set_str(config_nvs_handle, "device_name", device_config.device_name);
    temp_err = nvs_set_u8(config_nvs_handle, "relay_channels", device_config.relay_channels);
    if (temp_err != ESP_OK) ESP_LOGE(TAG, "  Failed to save relay_channels: %s", esp_err_to_name(temp_err));
    err |= temp_err;
    
    temp_err = nvs_set_u8(config_nvs_handle, "configured", device_config.configured ? 1 : 0);
    if (temp_err != ESP_OK) ESP_LOGE(TAG, "  Failed to save configured flag: %s", esp_err_to_name(temp_err));
    else ESP_LOGI(TAG, "  Saved configured flag: %d", device_config.configured ? 1 : 0);
    err |= temp_err;
    
    // Save WiFi configuration
    temp_err = nvs_set_str(config_nvs_handle, "wifi_ssid", device_config.wifi_ssid);
    if (temp_err != ESP_OK) ESP_LOGE(TAG, "  Failed to save wifi_ssid: %s", esp_err_to_name(temp_err));
    else ESP_LOGI(TAG, "  Saved wifi_ssid: '%s'", device_config.wifi_ssid);
    err |= temp_err;
    
    temp_err = nvs_set_str(config_nvs_handle, "wifi_password", device_config.wifi_password);
    if (temp_err != ESP_OK) ESP_LOGE(TAG, "  Failed to save wifi_password: %s", esp_err_to_name(temp_err));
    else ESP_LOGI(TAG, "  Saved wifi_password");
    err |= temp_err;
    
    // Save backend configuration
    err |= nvs_set_str(config_nvs_handle, "backend_ip", device_config.backend_ip);
    err |= nvs_set_u16(config_nvs_handle, "backend_port", device_config.backend_port);
    
    // Save MQTT configuration (legacy fields)
    err |= nvs_set_str(config_nvs_handle, "mqtt_broker", device_config.mqtt_broker);
    err |= nvs_set_u16(config_nvs_handle, "mqtt_port", device_config.mqtt_port);
    err |= nvs_set_str(config_nvs_handle, "mqtt_user", device_config.mqtt_user);
    err |= nvs_set_str(config_nvs_handle, "mqtt_password", device_config.mqtt_password);
    err |= nvs_set_u8(config_nvs_handle, "mqtt_registered", device_config.mqtt_registered ? 1 : 0);
    
    // Save new MQTT configuration fields
    err |= nvs_set_u8(config_nvs_handle, "dev_registered", device_config.device_registered ? 1 : 0);
    err |= nvs_set_str(config_nvs_handle, "mqtt_host", device_config.mqtt_broker_host);
    err |= nvs_set_u16(config_nvs_handle, "mqtt_port2", device_config.mqtt_broker_port);
    err |= nvs_set_str(config_nvs_handle, "mqtt_user2", device_config.mqtt_username);
    err |= nvs_set_str(config_nvs_handle, "mqtt_pass2", device_config.mqtt_password_new);
    err |= nvs_set_str(config_nvs_handle, "mqtt_prefix", device_config.mqtt_topic_prefix);
    err |= nvs_set_u32(config_nvs_handle, "last_reg", device_config.last_registration);
    
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
    
    ESP_LOGI(TAG, "📂 Loading configuration from NVS...");
    
    // Skip loading device_id and device_name from NVS - they will be regenerated in init
    // This ensures consistency with MAC address
    
    err = nvs_get_u8(config_nvs_handle, "relay_channels", &device_config.relay_channels);
    ESP_LOGI(TAG, "  relay_channels: %d (err: %s)", device_config.relay_channels, esp_err_to_name(err));
    
    if (nvs_get_u8(config_nvs_handle, "configured", &temp_bool) == ESP_OK) {
        device_config.configured = temp_bool != 0;
        ESP_LOGI(TAG, "  configured: %s (value: %d)", device_config.configured ? "YES" : "NO", temp_bool);
    } else {
        ESP_LOGW(TAG, "  configured: NOT FOUND in NVS, using default: %s", device_config.configured ? "YES" : "NO");
    }
    
    // Load WiFi configuration
    required_size = sizeof(device_config.wifi_ssid);
    err = nvs_get_str(config_nvs_handle, "wifi_ssid", device_config.wifi_ssid, &required_size);
    ESP_LOGI(TAG, "  wifi_ssid: '%s' (len: %d, err: %s)", 
             device_config.wifi_ssid, (int)strlen(device_config.wifi_ssid), esp_err_to_name(err));
    
    required_size = sizeof(device_config.wifi_password);
    err = nvs_get_str(config_nvs_handle, "wifi_password", device_config.wifi_password, &required_size);
    ESP_LOGI(TAG, "  wifi_password: %s (len: %d, err: %s)", 
             strlen(device_config.wifi_password) > 0 ? "***SET***" : "EMPTY", 
             (int)strlen(device_config.wifi_password), esp_err_to_name(err));
    
    // Load backend configuration
    required_size = sizeof(device_config.backend_ip);
    err = nvs_get_str(config_nvs_handle, "backend_ip", device_config.backend_ip, &required_size);
    ESP_LOGI(TAG, "  backend_ip: '%s' (err: %s)", device_config.backend_ip, esp_err_to_name(err));
    
    err = nvs_get_u16(config_nvs_handle, "backend_port", &device_config.backend_port);
    ESP_LOGI(TAG, "  backend_port: %d (err: %s)", device_config.backend_port, esp_err_to_name(err));
    
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
    
    // Load new MQTT configuration fields
    if (nvs_get_u8(config_nvs_handle, "dev_registered", &temp_bool) == ESP_OK) {
        device_config.device_registered = temp_bool != 0;
    }
    
    required_size = sizeof(device_config.mqtt_broker_host);
    nvs_get_str(config_nvs_handle, "mqtt_host", device_config.mqtt_broker_host, &required_size);
    
    nvs_get_u16(config_nvs_handle, "mqtt_port2", &device_config.mqtt_broker_port);
    
    required_size = sizeof(device_config.mqtt_username);
    nvs_get_str(config_nvs_handle, "mqtt_user2", device_config.mqtt_username, &required_size);
    
    required_size = sizeof(device_config.mqtt_password_new);
    nvs_get_str(config_nvs_handle, "mqtt_pass2", device_config.mqtt_password_new, &required_size);
    
    required_size = sizeof(device_config.mqtt_topic_prefix);
    nvs_get_str(config_nvs_handle, "mqtt_prefix", device_config.mqtt_topic_prefix, &required_size);
    
    nvs_get_u32(config_nvs_handle, "last_reg", &device_config.last_registration);
    
    // Load relay states
    required_size = sizeof(device_config.relay_states);
    err = nvs_get_blob(config_nvs_handle, "relay_states", device_config.relay_states, &required_size);
    ESP_LOGI(TAG, "  relay_states: loaded %d bytes (err: %s)", (int)required_size, esp_err_to_name(err));
    
    ESP_LOGI(TAG, "📊 Configuration load summary:");
    ESP_LOGI(TAG, "  Device configured: %s", device_config.configured ? "YES" : "NO");
    ESP_LOGI(TAG, "  WiFi SSID present: %s", strlen(device_config.wifi_ssid) > 0 ? "YES" : "NO");
    ESP_LOGI(TAG, "  WiFi password present: %s", strlen(device_config.wifi_password) > 0 ? "YES" : "NO");
    ESP_LOGI(TAG, "  Backend configured: %s", strlen(device_config.backend_ip) > 0 ? "YES" : "NO");
    ESP_LOGI(TAG, "  Device registered: %s", device_config.device_registered ? "YES" : "NO");
    
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
    
    // Regenerate device ID and name with consistent format
    config_generate_device_id(device_config.device_id, sizeof(device_config.device_id));
    uint8_t mac[6];
    esp_wifi_get_mac(WIFI_IF_STA, mac);
    snprintf(device_config.device_name, sizeof(device_config.device_name),
            "ESP32-Relay-%02x%02x%02x", mac[3], mac[4], mac[5]);
    
    ESP_LOGI(TAG, "Configuration reset to defaults");
    return ESP_OK;
}

/**
 * Update WiFi credentials
 */
esp_err_t config_set_wifi(const char* ssid, const char* password) {
    ESP_LOGI(TAG, "📝 config_set_wifi called with SSID: '%s'", ssid ? ssid : "NULL");
    
    if (!ssid || strlen(ssid) == 0) {
        ESP_LOGE(TAG, "Invalid SSID");
        return ESP_ERR_INVALID_ARG;
    }
    
    ESP_LOGI(TAG, "  Before update: configured=%s, wifi_ssid='%s'", 
             device_config.configured ? "true" : "false", device_config.wifi_ssid);
    
    strncpy(device_config.wifi_ssid, ssid, sizeof(device_config.wifi_ssid) - 1);
    device_config.wifi_ssid[sizeof(device_config.wifi_ssid) - 1] = '\0';
    
    if (password) {
        strncpy(device_config.wifi_password, password, sizeof(device_config.wifi_password) - 1);
        device_config.wifi_password[sizeof(device_config.wifi_password) - 1] = '\0';
        ESP_LOGI(TAG, "  Password set (len: %d)", (int)strlen(password));
    } else {
        device_config.wifi_password[0] = '\0';
        ESP_LOGI(TAG, "  No password provided");
    }
    
    device_config.configured = true;
    
    ESP_LOGI(TAG, "  After update: configured=%s, wifi_ssid='%s'", 
             device_config.configured ? "true" : "false", device_config.wifi_ssid);
    ESP_LOGI(TAG, "✅ WiFi credentials updated successfully");
    
    // Automatically save after setting WiFi
    esp_err_t save_err = config_save();
    if (save_err != ESP_OK) {
        ESP_LOGE(TAG, "❌ Failed to save WiFi config to NVS: %s", esp_err_to_name(save_err));
    } else {
        ESP_LOGI(TAG, "✅ WiFi config saved to NVS");
    }
    
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
 * Generate device ID based on Flash chip unique ID (permanent hardware ID)
 */
esp_err_t config_generate_device_id(char* device_id, size_t max_len) {
    if (!device_id || max_len < 32) {
        return ESP_ERR_INVALID_ARG;
    }
    
    uint64_t flash_id = 0;
    
    // Try to read Flash chip unique ID
    esp_err_t ret = esp_flash_read_unique_chip_id(NULL, &flash_id);
    
    if (ret == ESP_OK && flash_id != 0) {
        // Use full Flash ID (16 hex characters)
        snprintf(device_id, max_len, "esp32-%016llx", 
                (unsigned long long)flash_id);
        ESP_LOGI(TAG, "Generated device ID from Flash ID: %s", device_id);
    } else {
        // Fallback: Use MAC address if Flash ID not available
        ESP_LOGW(TAG, "Flash ID not available, using MAC as fallback");
        uint8_t mac[6];
        esp_read_mac(mac, ESP_MAC_WIFI_STA);
        
        // Use full MAC address for fallback
        snprintf(device_id, max_len, "esp32-%02x%02x%02x%02x%02x%02x", 
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
        ESP_LOGI(TAG, "Generated device ID from MAC: %s", device_id);
    }
    
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

/**
 * Save MQTT credentials from backend registration
 */
esp_err_t config_save_mqtt_credentials(const char* broker_host, uint16_t broker_port,
                                     const char* username, const char* password,
                                     const char* topic_prefix) {
    if (!broker_host || !username || !password) {
        ESP_LOGE(TAG, "Invalid MQTT credentials");
        return ESP_ERR_INVALID_ARG;
    }
    
    if (!config_initialized) {
        ESP_LOGE(TAG, "Configuration manager not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Update MQTT credentials in memory
    strncpy(device_config.mqtt_broker_host, broker_host, sizeof(device_config.mqtt_broker_host) - 1);
    device_config.mqtt_broker_host[sizeof(device_config.mqtt_broker_host) - 1] = '\0';
    
    device_config.mqtt_broker_port = broker_port;
    
    strncpy(device_config.mqtt_username, username, sizeof(device_config.mqtt_username) - 1);
    device_config.mqtt_username[sizeof(device_config.mqtt_username) - 1] = '\0';
    
    strncpy(device_config.mqtt_password_new, password, sizeof(device_config.mqtt_password_new) - 1);
    device_config.mqtt_password_new[sizeof(device_config.mqtt_password_new) - 1] = '\0';
    
    if (topic_prefix) {
        strncpy(device_config.mqtt_topic_prefix, topic_prefix, sizeof(device_config.mqtt_topic_prefix) - 1);
        device_config.mqtt_topic_prefix[sizeof(device_config.mqtt_topic_prefix) - 1] = '\0';
    } else {
        // Default topic prefix based on device ID (truncate if needed)
        snprintf(device_config.mqtt_topic_prefix, sizeof(device_config.mqtt_topic_prefix),
                "devices/%.22s", device_config.device_id); // Leave space for "devices/" prefix
    }
    
    // Mark device as registered and update timestamp
    device_config.device_registered = true;
    device_config.last_registration = xTaskGetTickCount() / configTICK_RATE_HZ; // Convert ticks to seconds
    
    ESP_LOGI(TAG, "MQTT credentials saved: %s@%s:%d, prefix: %s", 
             username, broker_host, broker_port, device_config.mqtt_topic_prefix);
    
    // Save to NVS
    return config_save();
}

/**
 * Set device registration status
 */
esp_err_t config_set_registration_status(bool registered) {
    if (!config_initialized) {
        ESP_LOGE(TAG, "Configuration manager not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    device_config.device_registered = registered;
    if (registered) {
        device_config.last_registration = xTaskGetTickCount() / configTICK_RATE_HZ; // Convert ticks to seconds
    }
    
    ESP_LOGI(TAG, "Device registration status updated: %s", registered ? "registered" : "not registered");
    
    // Save to NVS
    return config_save();
}

/**
 * Check if device is registered with backend
 */
bool config_is_device_registered(void) {
    if (!config_initialized) {
        return false;
    }
    return device_config.device_registered;
}

/**
 * Factory reset - completely erase all NVS data and restart
 */
esp_err_t config_factory_reset(void) {
    ESP_LOGI(TAG, "🔄 Factory reset initiated...");
    
    if (!config_initialized) {
        ESP_LOGE(TAG, "Configuration manager not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Stop any running services first (this should be called from main task)
    ESP_LOGI(TAG, "Stopping all services before factory reset...");
    
    // Close current NVS handle
    nvs_close(config_nvs_handle);
    
    // Erase entire NVS partition
    esp_err_t err = nvs_flash_erase();
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to erase NVS flash: %s", esp_err_to_name(err));
        return err;
    }
    
    // Reinitialize NVS
    err = nvs_flash_init();
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to reinitialize NVS: %s", esp_err_to_name(err));
        return err;
    }
    
    ESP_LOGI(TAG, "✅ Factory reset completed. Restarting device...");
    
    // Wait a moment for logs to be transmitted
    vTaskDelay(pdMS_TO_TICKS(1000));
    
    // Restart the device
    esp_restart();
    
    // This line should never be reached
    return ESP_OK;
}