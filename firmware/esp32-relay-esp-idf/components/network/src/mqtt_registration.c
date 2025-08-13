/**
 * ESP32 Relay MQTT Smart Registration System
 * Intelligent device registration with backend API
 * 
 * Features:
 * - Check if device exists before registering
 * - Fetch MQTT configuration from backend
 * - Smart registration with retry logic
 * - Persistent credential storage
 */

#include <string.h>
#include <stdio.h>
#include "esp_log.h"
#include "esp_http_client.h"
#include "cJSON.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "config_manager.h"
#include "wifi_manager.h"
#include "mqtt_registration.h"

static const char *TAG = "MQTT_REGISTRATION";

// HTTP response buffer
#define HTTP_RESPONSE_BUFFER_SIZE 1024
static char http_response_buffer[HTTP_RESPONSE_BUFFER_SIZE];

// Forward declarations
static esp_err_t http_event_handler(esp_http_client_event_t *evt);
static esp_err_t check_device_exists(const char* device_id, bool* exists);
static esp_err_t fetch_mqtt_config(mqtt_config_t* mqtt_config);
static esp_err_t register_device_with_backend(void);

/**
 * HTTP client event handler
 */
static esp_err_t http_event_handler(esp_http_client_event_t *evt) {
    static int output_len = 0;
    
    switch(evt->event_id) {
        case HTTP_EVENT_ERROR:
            ESP_LOGD(TAG, "HTTP_EVENT_ERROR");
            break;
        case HTTP_EVENT_ON_CONNECTED:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_CONNECTED");
            output_len = 0;
            break;
        case HTTP_EVENT_HEADER_SENT:
            ESP_LOGD(TAG, "HTTP_EVENT_HEADER_SENT");
            break;
        case HTTP_EVENT_ON_HEADER:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_HEADER, key=%s, value=%s", evt->header_key, evt->header_value);
            break;
        case HTTP_EVENT_ON_DATA:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_DATA, len=%d", evt->data_len);
            if (!esp_http_client_is_chunked_response(evt->client)) {
                // Copy response data to buffer
                int copy_len = evt->data_len;
                if (output_len + copy_len >= HTTP_RESPONSE_BUFFER_SIZE) {
                    copy_len = HTTP_RESPONSE_BUFFER_SIZE - output_len - 1;
                }
                if (copy_len > 0) {
                    memcpy(http_response_buffer + output_len, evt->data, copy_len);
                    output_len += copy_len;
                    http_response_buffer[output_len] = '\0';
                }
            }
            break;
        case HTTP_EVENT_ON_FINISH:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_FINISH");
            break;
        case HTTP_EVENT_DISCONNECTED:
            ESP_LOGD(TAG, "HTTP_EVENT_DISCONNECTED");
            output_len = 0;
            break;
        case HTTP_EVENT_REDIRECT:
            ESP_LOGD(TAG, "HTTP_EVENT_REDIRECT");
            break;
    }
    return ESP_OK;
}

/**
 * Check if device already exists in backend
 */
static esp_err_t check_device_exists(const char* device_id, bool* exists) {
    if (!device_id || !exists) {
        return ESP_ERR_INVALID_ARG;
    }
    
    *exists = false;
    device_config_t* config = config_get();
    
    if (strlen(config->backend_ip) == 0 || config->backend_port == 0) {
        ESP_LOGE(TAG, "Backend configuration missing");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Build URL for device check
    char url[256];
    snprintf(url, sizeof(url), "http://%s:%d/api/devices/uuid/%s", 
            config->backend_ip, config->backend_port, device_id);
    
    ESP_LOGI(TAG, "Checking if device exists: %s", url);
    
    // Clear response buffer
    memset(http_response_buffer, 0, sizeof(http_response_buffer));
    
    // Configure HTTP client
    esp_http_client_config_t http_config = {
        .url = url,
        .method = HTTP_METHOD_GET,
        .timeout_ms = 10000,
        .event_handler = http_event_handler,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    if (client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize HTTP client");
        return ESP_FAIL;
    }
    
    // Perform HTTP request
    esp_err_t err = esp_http_client_perform(client);
    int status_code = esp_http_client_get_status_code(client);
    
    if (err == ESP_OK) {
        if (status_code == 200) {
            ESP_LOGI(TAG, "✅ Device exists in backend");
            *exists = true;
        } else if (status_code == 404) {
            ESP_LOGI(TAG, "ℹ️ Device not found in backend (will register)");
            *exists = false;
        } else {
            ESP_LOGW(TAG, "⚠️ Unexpected status code: %d", status_code);
            err = ESP_FAIL;
        }
    } else {
        ESP_LOGE(TAG, "❌ HTTP request failed: %s", esp_err_to_name(err));
    }
    
    esp_http_client_cleanup(client);
    return err;
}

/**
 * Fetch MQTT configuration from backend
 */
static esp_err_t fetch_mqtt_config(mqtt_config_t* mqtt_config) {
    if (!mqtt_config) {
        return ESP_ERR_INVALID_ARG;
    }
    
    device_config_t* config = config_get();
    
    if (strlen(config->backend_ip) == 0 || config->backend_port == 0) {
        ESP_LOGE(TAG, "Backend configuration missing");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Build URL for MQTT config
    char url[256];
    snprintf(url, sizeof(url), "http://%s:%d/api/mqtt/config", 
            config->backend_ip, config->backend_port);
    
    ESP_LOGI(TAG, "Fetching MQTT config from: %s", url);
    
    // Clear response buffer
    memset(http_response_buffer, 0, sizeof(http_response_buffer));
    
    // Configure HTTP client
    esp_http_client_config_t http_config = {
        .url = url,
        .method = HTTP_METHOD_GET,
        .timeout_ms = 10000,
        .event_handler = http_event_handler,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    if (client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize HTTP client");
        return ESP_FAIL;
    }
    
    // Perform HTTP request
    esp_err_t err = esp_http_client_perform(client);
    int status_code = esp_http_client_get_status_code(client);
    
    if (err == ESP_OK && status_code == 200) {
        ESP_LOGI(TAG, "MQTT config response: %s", http_response_buffer);
        
        // Parse JSON response
        cJSON *json = cJSON_Parse(http_response_buffer);
        if (json) {
            cJSON *broker = cJSON_GetObjectItem(json, "broker");
            cJSON *port = cJSON_GetObjectItem(json, "port");
            cJSON *username = cJSON_GetObjectItem(json, "username");
            cJSON *password = cJSON_GetObjectItem(json, "password");
            cJSON *topic_prefix = cJSON_GetObjectItem(json, "topic_prefix");
            
            if (broker && cJSON_IsString(broker)) {
                strncpy(mqtt_config->broker_host, broker->valuestring, sizeof(mqtt_config->broker_host) - 1);
                mqtt_config->broker_host[sizeof(mqtt_config->broker_host) - 1] = '\0';
            }
            
            if (port && cJSON_IsNumber(port)) {
                mqtt_config->broker_port = port->valueint;
            }
            
            if (username && cJSON_IsString(username)) {
                strncpy(mqtt_config->username, username->valuestring, sizeof(mqtt_config->username) - 1);
                mqtt_config->username[sizeof(mqtt_config->username) - 1] = '\0';
            }
            
            if (password && cJSON_IsString(password)) {
                strncpy(mqtt_config->password, password->valuestring, sizeof(mqtt_config->password) - 1);
                mqtt_config->password[sizeof(mqtt_config->password) - 1] = '\0';
            }
            
            if (topic_prefix && cJSON_IsString(topic_prefix)) {
                strncpy(mqtt_config->topic_prefix, topic_prefix->valuestring, sizeof(mqtt_config->topic_prefix) - 1);
                mqtt_config->topic_prefix[sizeof(mqtt_config->topic_prefix) - 1] = '\0';
            } else {
                // Default topic prefix (truncate if needed)
                snprintf(mqtt_config->topic_prefix, sizeof(mqtt_config->topic_prefix),
                        "devices/%.22s", config->device_id); // Leave space for "devices/" prefix
            }
            
            cJSON_Delete(json);
            ESP_LOGI(TAG, "✅ MQTT config fetched successfully");
            ESP_LOGI(TAG, "Broker: %s:%d", mqtt_config->broker_host, mqtt_config->broker_port);
            ESP_LOGI(TAG, "Username: %s", mqtt_config->username);
            ESP_LOGI(TAG, "Topic prefix: %s", mqtt_config->topic_prefix);
            
        } else {
            ESP_LOGE(TAG, "Failed to parse MQTT config JSON");
            err = ESP_FAIL;
        }
    } else {
        ESP_LOGE(TAG, "❌ Failed to fetch MQTT config: %s, HTTP %d", 
                esp_err_to_name(err), status_code);
        err = ESP_FAIL;
    }
    
    esp_http_client_cleanup(client);
    return err;
}

/**
 * Register device with backend
 */
static esp_err_t register_device_with_backend(void) {
    device_config_t* config = config_get();
    
    if (strlen(config->backend_ip) == 0 || config->backend_port == 0) {
        ESP_LOGE(TAG, "Backend configuration missing");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Build URL for device registration
    char url[256];
    snprintf(url, sizeof(url), "http://%s:%d/api/devices", 
            config->backend_ip, config->backend_port);
    
    ESP_LOGI(TAG, "Registering device with backend: %s", url);
    
    // Prepare registration data
    cJSON *json = cJSON_CreateObject();
    
    char mac_str[18];
    wifi_manager_get_mac_str(mac_str, sizeof(mac_str));
    
    // Convert MAC to uppercase
    for (int i = 0; mac_str[i]; i++) {
        if (mac_str[i] >= 'a' && mac_str[i] <= 'f') {
            mac_str[i] = mac_str[i] - 'a' + 'A';
        }
    }
    
    char ip_str[16];
    wifi_manager_get_ip(ip_str, sizeof(ip_str));
    
    cJSON_AddStringToObject(json, "uuid", config->device_id);
    cJSON_AddStringToObject(json, "name", config->device_name);
    cJSON_AddStringToObject(json, "type", "esp32_relay");
    cJSON_AddStringToObject(json, "mac_address", mac_str);
    cJSON_AddStringToObject(json, "ip_address", ip_str);
    cJSON_AddStringToObject(json, "firmware_version", "2.0.0");
    cJSON_AddStringToObject(json, "hardware_version", "ESP32-WROOM-32");
    cJSON_AddNumberToObject(json, "relay_channels", config->relay_channels);
    
    char *json_string = cJSON_Print(json);
    if (json_string == NULL) {
        ESP_LOGE(TAG, "Failed to create registration JSON");
        cJSON_Delete(json);
        return ESP_FAIL;
    }
    
    ESP_LOGI(TAG, "Registration payload: %s", json_string);
    
    // Clear response buffer
    memset(http_response_buffer, 0, sizeof(http_response_buffer));
    
    // Configure HTTP client
    esp_http_client_config_t http_config = {
        .url = url,
        .method = HTTP_METHOD_POST,
        .timeout_ms = 15000,
        .event_handler = http_event_handler,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    if (client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize HTTP client");
        free(json_string);
        cJSON_Delete(json);
        return ESP_FAIL;
    }
    
    // Set headers and payload
    esp_http_client_set_header(client, "Content-Type", "application/json");
    esp_http_client_set_post_field(client, json_string, strlen(json_string));
    
    // Perform HTTP request
    esp_err_t err = esp_http_client_perform(client);
    int status_code = esp_http_client_get_status_code(client);
    
    if (err == ESP_OK && (status_code == 200 || status_code == 201)) {
        ESP_LOGI(TAG, "✅ Device registration successful");
        ESP_LOGI(TAG, "Registration response: %s", http_response_buffer);
        
        // Mark device as registered
        config_set_registration_status(true);
        
    } else if (err == ESP_OK && status_code == 500 && strlen(http_response_buffer) > 0) {
        // Check if error is due to duplicate MAC address
        if (strstr(http_response_buffer, "UNIQUE constraint failed: devices.mac_address") != NULL ||
            strstr(http_response_buffer, "mac_address") != NULL) {
            ESP_LOGW(TAG, "⚠️ Device with this MAC already exists, treating as success");
            config_set_registration_status(true);
            err = ESP_OK; // Treat as success since device exists
        } else {
            ESP_LOGE(TAG, "❌ Device registration failed with server error: HTTP 500");
            ESP_LOGE(TAG, "Error response: %s", http_response_buffer);
            err = ESP_FAIL;
        }
    } else {
        ESP_LOGE(TAG, "❌ Device registration failed: %s, HTTP %d", 
                esp_err_to_name(err), status_code);
        if (strlen(http_response_buffer) > 0) {
            ESP_LOGE(TAG, "Error response: %s", http_response_buffer);
        }
        err = ESP_FAIL;
    }
    
    // Cleanup
    free(json_string);
    cJSON_Delete(json);
    esp_http_client_cleanup(client);
    
    return err;
}

/**
 * Smart MQTT registration - main entry point
 */
esp_err_t mqtt_smart_registration(void) {
    ESP_LOGI(TAG, "🚀 Starting smart MQTT registration...");
    
    device_config_t* config = config_get();
    if (!config) {
        ESP_LOGE(TAG, "Failed to get device configuration");
        return ESP_FAIL;
    }
    
    // Check if WiFi is connected
    if (!wifi_manager_is_connected()) {
        ESP_LOGE(TAG, "WiFi not connected, cannot register");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Step 1: Check if device is already registered locally
    if (config_is_device_registered()) {
        uint32_t current_time = xTaskGetTickCount() / configTICK_RATE_HZ; // Convert to seconds
        uint32_t time_since_registration = current_time - config->last_registration;
        
        // If registered within last 24 hours, skip registration
        if (time_since_registration < 86400) { // 24 hours
            ESP_LOGI(TAG, "✅ Device registered locally %lu seconds ago, skipping registration", 
                    (unsigned long)time_since_registration);
            
            // Just fetch MQTT config to ensure it's up to date
            mqtt_config_t mqtt_config = {0};
            esp_err_t err = fetch_mqtt_config(&mqtt_config);
            if (err == ESP_OK) {
                config_save_mqtt_credentials(mqtt_config.broker_host, mqtt_config.broker_port,
                                           mqtt_config.username, mqtt_config.password,
                                           mqtt_config.topic_prefix);
            }
            return err;
        } else {
            ESP_LOGI(TAG, "ℹ️ Registration expired (%lu seconds ago), will re-register", 
                    (unsigned long)time_since_registration);
        }
    }
    
    // Step 2: Check if device exists in backend
    bool device_exists = false;
    esp_err_t err = check_device_exists(config->device_id, &device_exists);
    if (err != ESP_OK) {
        ESP_LOGW(TAG, "Failed to check device existence, proceeding with registration");
    }
    
    // Step 3: Register device if it doesn't exist
    if (!device_exists) {
        ESP_LOGI(TAG, "🔄 Device not found in backend, registering...");
        err = register_device_with_backend();
        if (err != ESP_OK) {
            // Check if error is due to MAC address already existing
            // In this case, the device exists but with different UUID
            // We should just continue and fetch MQTT config
            ESP_LOGW(TAG, "⚠️ Device registration failed, but may exist with different UUID");
            ESP_LOGW(TAG, "Continuing to fetch MQTT config anyway...");
            // Mark as registered since device exists (even if with different UUID)
            config_set_registration_status(true);
        } else {
            ESP_LOGI(TAG, "✅ Device registered successfully");
        }
    } else {
        ESP_LOGI(TAG, "✅ Device already exists in backend");
        config_set_registration_status(true);
    }
    
    // Step 4: Fetch MQTT configuration
    ESP_LOGI(TAG, "📡 Fetching MQTT configuration...");
    mqtt_config_t mqtt_config = {0};
    err = fetch_mqtt_config(&mqtt_config);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "❌ Failed to fetch MQTT configuration");
        return err;
    }
    
    // Step 5: Save MQTT credentials
    err = config_save_mqtt_credentials(mqtt_config.broker_host, mqtt_config.broker_port,
                                     mqtt_config.username, mqtt_config.password,
                                     mqtt_config.topic_prefix);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "❌ Failed to save MQTT credentials");
        return err;
    }
    
    ESP_LOGI(TAG, "🎉 Smart MQTT registration completed successfully!");
    return ESP_OK;
}

/**
 * Get saved MQTT credentials
 */
esp_err_t mqtt_get_saved_credentials(mqtt_config_t* mqtt_config) {
    if (!mqtt_config) {
        return ESP_ERR_INVALID_ARG;
    }
    
    device_config_t* config = config_get();
    if (!config) {
        return ESP_FAIL;
    }
    
    // Check if we have saved MQTT credentials
    if (strlen(config->mqtt_broker_host) == 0 || strlen(config->mqtt_username) == 0) {
        ESP_LOGW(TAG, "No saved MQTT credentials found");
        return ESP_ERR_NOT_FOUND;
    }
    
    // Copy credentials
    strncpy(mqtt_config->broker_host, config->mqtt_broker_host, sizeof(mqtt_config->broker_host) - 1);
    mqtt_config->broker_host[sizeof(mqtt_config->broker_host) - 1] = '\0';
    
    mqtt_config->broker_port = config->mqtt_broker_port;
    
    strncpy(mqtt_config->username, config->mqtt_username, sizeof(mqtt_config->username) - 1);
    mqtt_config->username[sizeof(mqtt_config->username) - 1] = '\0';
    
    strncpy(mqtt_config->password, config->mqtt_password_new, sizeof(mqtt_config->password) - 1);
    mqtt_config->password[sizeof(mqtt_config->password) - 1] = '\0';
    
    strncpy(mqtt_config->topic_prefix, config->mqtt_topic_prefix, sizeof(mqtt_config->topic_prefix) - 1);
    mqtt_config->topic_prefix[sizeof(mqtt_config->topic_prefix) - 1] = '\0';
    
    ESP_LOGI(TAG, "Retrieved saved MQTT credentials: %s@%s:%d", 
             mqtt_config->username, mqtt_config->broker_host, mqtt_config->broker_port);
    
    return ESP_OK;
}

/**
 * Update device MAC and IP address in backend
 */
esp_err_t mqtt_update_device_network_info(void) {
    device_config_t* config = config_get();
    
    if (strlen(config->backend_ip) == 0 || config->backend_port == 0) {
        ESP_LOGE(TAG, "Backend configuration missing");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Build URL for device update
    char url[256];
    snprintf(url, sizeof(url), "http://%s:%d/api/devices/%s", 
            config->backend_ip, config->backend_port, config->device_id);
    
    ESP_LOGI(TAG, "Updating device network info: %s", url);
    
    // Get MAC address in uppercase
    char mac_str[18];
    wifi_manager_get_mac_str(mac_str, sizeof(mac_str));
    
    // Convert MAC to uppercase
    for (int i = 0; mac_str[i]; i++) {
        if (mac_str[i] >= 'a' && mac_str[i] <= 'f') {
            mac_str[i] = mac_str[i] - 'a' + 'A';
        }
    }
    
    // Get IP address
    char ip_str[16];
    wifi_manager_get_ip(ip_str, sizeof(ip_str));
    
    // Prepare update data - only MAC and IP
    cJSON *json = cJSON_CreateObject();
    cJSON_AddStringToObject(json, "mac_address", mac_str);
    cJSON_AddStringToObject(json, "ip_address", ip_str);
    
    char *json_string = cJSON_Print(json);
    if (json_string == NULL) {
        ESP_LOGE(TAG, "Failed to create update JSON");
        cJSON_Delete(json);
        return ESP_FAIL;
    }
    
    ESP_LOGI(TAG, "Update payload: %s", json_string);
    
    // Clear response buffer
    memset(http_response_buffer, 0, sizeof(http_response_buffer));
    
    // Configure HTTP client
    esp_http_client_config_t http_config = {
        .url = url,
        .event_handler = http_event_handler,
        .method = HTTP_METHOD_PATCH,
        .timeout_ms = 5000,
        .buffer_size = HTTP_RESPONSE_BUFFER_SIZE,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    if (client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize HTTP client");
        free(json_string);
        cJSON_Delete(json);
        return ESP_FAIL;
    }
    
    // Set headers
    esp_http_client_set_header(client, "Content-Type", "application/json");
    esp_http_client_set_post_field(client, json_string, strlen(json_string));
    
    // Execute request
    esp_err_t err = esp_http_client_perform(client);
    int status_code = esp_http_client_get_status_code(client);
    
    // Cleanup JSON
    free(json_string);
    cJSON_Delete(json);
    
    if (err == ESP_OK && (status_code == 200 || status_code == 204)) {
        ESP_LOGI(TAG, "✅ Device network info updated successfully");
        ESP_LOGI(TAG, "MAC: %s, IP: %s", mac_str, ip_str);
    } else {
        ESP_LOGW(TAG, "Failed to update device network info: %s, HTTP %d", 
                esp_err_to_name(err), status_code);
        if (strlen(http_response_buffer) > 0) {
            ESP_LOGD(TAG, "Response: %s", http_response_buffer);
        }
        err = ESP_FAIL;
    }
    
    esp_http_client_cleanup(client);
    return err;
}