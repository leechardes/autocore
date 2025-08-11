/**
 * ESP32 Relay MQTT Client Implementation
 * High-performance MQTT integration for AutoCore ecosystem
 */

#include <string.h>
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/timers.h"
#include "esp_log.h"
#include "esp_system.h"
#include "esp_timer.h"
#include "esp_http_client.h"
#include "cJSON.h"
#include <mqtt_client.h>
#include "mqtt_handler.h"
#include "config_manager.h"
#include "wifi_manager.h"
#include "relay_control.h"

static const char *TAG = "MQTT_CLIENT";

// Macro para MIN se não estiver definido
#ifndef MIN
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif

// Task function for MQTT reboot command
static void mqtt_reboot_task(void *param) {
    vTaskDelay(pdMS_TO_TICKS(2000));
    esp_restart();
    vTaskDelete(NULL);
}

// MQTT client handle and state
static esp_mqtt_client_handle_t mqtt_client_handle = NULL;
static mqtt_state_t current_mqtt_state = MQTT_STATE_DISCONNECTED;
static int mqtt_retry_count = 0;
static TimerHandle_t telemetry_timer = NULL;

// Callbacks
static mqtt_connected_cb_t mqtt_connected_callback = NULL;
static mqtt_disconnected_cb_t mqtt_disconnected_callback = NULL;
static mqtt_command_cb_t mqtt_command_callback = NULL;

// Forward declarations
static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data);
static void telemetry_timer_callback(TimerHandle_t xTimer);
static esp_err_t parse_mqtt_command(const char* data, size_t data_len, mqtt_cmd_data_t* cmd_data);
static void execute_mqtt_command(mqtt_cmd_data_t* cmd_data);

/**
 * MQTT event handler
 */
static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data) {
    esp_mqtt_event_handle_t event = event_data;
    esp_mqtt_client_handle_t client = event->client;
    
    switch (event->event_id) {
        case MQTT_EVENT_CONNECTED:
            ESP_LOGI(TAG, "✅ MQTT Connected");
            current_mqtt_state = MQTT_STATE_CONNECTED;
            mqtt_retry_count = 0;
            
            // Subscribe to command topic
            mqtt_subscribe_commands();
            
            // Publish initial status
            mqtt_publish_status();
            
            // Call connected callback
            if (mqtt_connected_callback) {
                mqtt_connected_callback();
            }
            break;
            
        case MQTT_EVENT_DISCONNECTED:
            ESP_LOGW(TAG, "⚠️ MQTT Disconnected");
            current_mqtt_state = MQTT_STATE_DISCONNECTED;
            
            // Call disconnected callback
            if (mqtt_disconnected_callback) {
                mqtt_disconnected_callback();
            }
            break;
            
        case MQTT_EVENT_SUBSCRIBED:
            ESP_LOGI(TAG, "MQTT subscribed, msg_id=%d", event->msg_id);
            break;
            
        case MQTT_EVENT_UNSUBSCRIBED:
            ESP_LOGI(TAG, "MQTT unsubscribed, msg_id=%d", event->msg_id);
            break;
            
        case MQTT_EVENT_PUBLISHED:
            ESP_LOGD(TAG, "MQTT published, msg_id=%d", event->msg_id);
            break;
            
        case MQTT_EVENT_DATA:
            ESP_LOGI(TAG, "📨 MQTT data received, topic: %.*s", event->topic_len, event->topic);
            ESP_LOGI(TAG, "Data: %.*s", event->data_len, event->data);
            
            // Process received command
            mqtt_process_command(event->topic, event->data, event->data_len);
            break;
            
        case MQTT_EVENT_ERROR:
            ESP_LOGE(TAG, "❌ MQTT error");
            current_mqtt_state = MQTT_STATE_ERROR;
            
            if (event->error_handle->error_type == MQTT_ERROR_TYPE_TCP_TRANSPORT) {
                ESP_LOGE(TAG, "TCP transport error: 0x%x", event->error_handle->esp_transport_sock_errno);
            } else if (event->error_handle->error_type == MQTT_ERROR_TYPE_CONNECTION_REFUSED) {
                ESP_LOGE(TAG, "Connection refused error: 0x%x", event->error_handle->connect_return_code);
            }
            break;
            
        default:
            ESP_LOGD(TAG, "MQTT event: %d", event->event_id);
            break;
    }
}

/**
 * Initialize MQTT client
 */
esp_err_t mqtt_client_init(void) {
    if (mqtt_client_handle != NULL) {
        ESP_LOGW(TAG, "MQTT client already initialized");
        return ESP_OK;
    }
    
    device_config_t* config = config_get();
    
    // Build MQTT URI
    char mqtt_uri[128];
    snprintf(mqtt_uri, sizeof(mqtt_uri), "mqtt://%s:%d", 
            strlen(config->mqtt_broker) > 0 ? config->mqtt_broker : config->backend_ip,
            config->mqtt_port > 0 ? config->mqtt_port : 1883);
    
    // Configure MQTT client
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker = {
            .address = {
                .uri = mqtt_uri,
            },
        },
        .credentials = {
            .client_id = config->device_id,
            .username = config->mqtt_user,
            .authentication = {
                .password = config->mqtt_password,
            },
        },
        .session = {
            .keepalive = MQTT_KEEPALIVE_SEC,
            .disable_clean_session = false,
        },
        .network = {
            .timeout_ms = MQTT_CONNECT_TIMEOUT_MS,
            .reconnect_timeout_ms = MQTT_RETRY_DELAY_MS,
        }
    };
    
    // Create MQTT client
    mqtt_client_handle = esp_mqtt_client_init(&mqtt_cfg);
    if (mqtt_client_handle == NULL) {
        ESP_LOGE(TAG, "Failed to initialize MQTT client");
        return ESP_FAIL;
    }
    
    // Register event handler
    esp_err_t ret = esp_mqtt_client_register_event(mqtt_client_handle, ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to register MQTT event handler: %s", esp_err_to_name(ret));
        esp_mqtt_client_destroy(mqtt_client_handle);
        mqtt_client_handle = NULL;
        return ret;
    }
    
    ESP_LOGI(TAG, "MQTT client initialized");
    ESP_LOGI(TAG, "Broker URI: %s", mqtt_uri);
    ESP_LOGI(TAG, "Client ID: %s", config->device_id);
    ESP_LOGI(TAG, "Username: %s", config->mqtt_user);
    
    return ESP_OK;
}

/**
 * Start MQTT client
 */
esp_err_t mqtt_client_start(void) {
    if (mqtt_client_handle == NULL) {
        ESP_LOGE(TAG, "MQTT client not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    current_mqtt_state = MQTT_STATE_CONNECTING;
    esp_err_t ret = esp_mqtt_client_start(mqtt_client_handle);
    
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "MQTT client started");
    } else {
        ESP_LOGE(TAG, "Failed to start MQTT client: %s", esp_err_to_name(ret));
        current_mqtt_state = MQTT_STATE_ERROR;
    }
    
    return ret;
}

/**
 * Stop MQTT client
 */
esp_err_t mqtt_client_stop(void) {
    if (mqtt_client_handle == NULL) {
        ESP_LOGW(TAG, "MQTT client not running");
        return ESP_OK;
    }
    
    // Stop telemetry timer
    mqtt_stop_telemetry_task();
    
    esp_err_t ret = esp_mqtt_client_stop(mqtt_client_handle);
    if (ret == ESP_OK) {
        esp_mqtt_client_destroy(mqtt_client_handle);
        mqtt_client_handle = NULL;
        current_mqtt_state = MQTT_STATE_DISCONNECTED;
        ESP_LOGI(TAG, "MQTT client stopped");
    } else {
        ESP_LOGE(TAG, "Failed to stop MQTT client: %s", esp_err_to_name(ret));
    }
    
    return ret;
}

/**
 * Check if MQTT client is connected
 */
bool mqtt_client_is_connected(void) {
    return (current_mqtt_state == MQTT_STATE_CONNECTED);
}

/**
 * Get current MQTT state
 */
mqtt_state_t mqtt_client_get_state(void) {
    return current_mqtt_state;
}

/**
 * Subscribe to command topic
 */
esp_err_t mqtt_subscribe_commands(void) {
    if (!mqtt_client_is_connected()) {
        ESP_LOGE(TAG, "MQTT not connected");
        return ESP_ERR_INVALID_STATE;
    }
    
    device_config_t* config = config_get();
    char topic[MQTT_MAX_TOPIC_LEN];
    
    snprintf(topic, sizeof(topic), MQTT_TOPIC_COMMAND_PATTERN, config->device_id);
    
    int msg_id = esp_mqtt_client_subscribe(mqtt_client_handle, topic, 1); // QoS 1
    if (msg_id >= 0) {
        ESP_LOGI(TAG, "Subscribed to commands: %s", topic);
        return ESP_OK;
    } else {
        ESP_LOGE(TAG, "Failed to subscribe to commands");
        return ESP_FAIL;
    }
}

/**
 * Publish device status
 */
esp_err_t mqtt_publish_status(void) {
    if (!mqtt_client_is_connected()) {
        ESP_LOGD(TAG, "MQTT not connected, skipping status publish");
        return ESP_ERR_INVALID_STATE;
    }
    
    device_config_t* config = config_get();
    char topic[MQTT_MAX_TOPIC_LEN];
    char payload[MQTT_MAX_PAYLOAD_LEN];
    
    // Generate topic
    snprintf(topic, sizeof(topic), MQTT_TOPIC_STATUS_PATTERN, config->device_id);
    
    // Generate status JSON
    esp_err_t ret = mqtt_generate_status_json(payload, sizeof(payload));
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to generate status JSON");
        return ret;
    }
    
    // Publish status
    int msg_id = esp_mqtt_client_publish(mqtt_client_handle, topic, payload, strlen(payload), 1, 0);
    if (msg_id >= 0) {
        ESP_LOGD(TAG, "Published status to: %s", topic);
        return ESP_OK;
    } else {
        ESP_LOGE(TAG, "Failed to publish status");
        return ESP_FAIL;
    }
}

/**
 * Publish custom message
 */
esp_err_t mqtt_publish_message(const char* topic, const char* payload, size_t payload_len) {
    if (!mqtt_client_is_connected()) {
        return ESP_ERR_INVALID_STATE;
    }
    
    if (!topic || !payload) {
        return ESP_ERR_INVALID_ARG;
    }
    
    int msg_id = esp_mqtt_client_publish(mqtt_client_handle, topic, payload, payload_len, 1, 0);
    return (msg_id >= 0) ? ESP_OK : ESP_FAIL;
}

/**
 * Process received MQTT command
 */
esp_err_t mqtt_process_command(const char* topic, const char* data, size_t data_len) {
    if (!topic || !data || data_len == 0) {
        return ESP_ERR_INVALID_ARG;
    }
    
    // Parse command JSON
    mqtt_cmd_data_t cmd_data;
    esp_err_t ret = parse_mqtt_command(data, data_len, &cmd_data);
    
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to parse MQTT command");
        return ret;
    }
    
    // Execute command
    execute_mqtt_command(&cmd_data);
    
    // Call command callback if set
    if (mqtt_command_callback) {
        mqtt_command_callback(&cmd_data);
    }
    
    return ESP_OK;
}

/**
 * Parse MQTT command JSON
 */
static esp_err_t parse_mqtt_command(const char* data, size_t data_len, mqtt_cmd_data_t* cmd_data) {
    if (!data || !cmd_data) {
        return ESP_ERR_INVALID_ARG;
    }
    
    // Initialize command data
    memset(cmd_data, 0, sizeof(mqtt_cmd_data_t));
    strncpy(cmd_data->raw_data, data, MIN(data_len, sizeof(cmd_data->raw_data) - 1));
    
    // Parse JSON
    cJSON *json = cJSON_ParseWithLength(data, data_len);
    if (json == NULL) {
        ESP_LOGE(TAG, "Invalid JSON command");
        return ESP_ERR_INVALID_ARG;
    }
    
    // Extract command
    cJSON *command_item = cJSON_GetObjectItem(json, "command");
    if (!cJSON_IsString(command_item)) {
        ESP_LOGE(TAG, "Missing or invalid command field");
        cJSON_Delete(json);
        return ESP_ERR_INVALID_ARG;
    }
    
    const char* command_str = command_item->valuestring;
    
    // Map command string to enum
    if (strcmp(command_str, "relay_on") == 0) {
        cmd_data->command = MQTT_CMD_RELAY_ON;
    } else if (strcmp(command_str, "relay_off") == 0) {
        cmd_data->command = MQTT_CMD_RELAY_OFF;
    } else if (strcmp(command_str, "get_status") == 0) {
        cmd_data->command = MQTT_CMD_GET_STATUS;
    } else if (strcmp(command_str, "reboot") == 0) {
        cmd_data->command = MQTT_CMD_REBOOT;
    } else {
        ESP_LOGW(TAG, "Unknown command: %s", command_str);
        cmd_data->command = MQTT_CMD_UNKNOWN;
    }
    
    // Extract channel (if present)
    cJSON *channel_item = cJSON_GetObjectItem(json, "channel");
    if (cJSON_IsNumber(channel_item)) {
        cmd_data->channel = (uint8_t)channel_item->valueint;
    }
    
    cJSON_Delete(json);
    return ESP_OK;
}

/**
 * Execute MQTT command
 */
static void execute_mqtt_command(mqtt_cmd_data_t* cmd_data) {
    if (!cmd_data) {
        return;
    }
    
    ESP_LOGI(TAG, "🚀 Executing command: %d, channel: %d", cmd_data->command, cmd_data->channel);
    
    switch (cmd_data->command) {
        case MQTT_CMD_RELAY_ON:
            if (relay_is_valid_channel(cmd_data->channel)) {
                relay_turn_on(cmd_data->channel);
                ESP_LOGI(TAG, "⚡ Relay channel %d turned ON", cmd_data->channel);
            } else {
                ESP_LOGE(TAG, "Invalid relay channel: %d", cmd_data->channel);
            }
            break;
            
        case MQTT_CMD_RELAY_OFF:
            if (relay_is_valid_channel(cmd_data->channel)) {
                relay_turn_off(cmd_data->channel);
                ESP_LOGI(TAG, "⚡ Relay channel %d turned OFF", cmd_data->channel);
            } else {
                ESP_LOGE(TAG, "Invalid relay channel: %d", cmd_data->channel);
            }
            break;
            
        case MQTT_CMD_GET_STATUS:
            ESP_LOGI(TAG, "📊 Status requested, publishing...");
            mqtt_publish_status();
            break;
            
        case MQTT_CMD_REBOOT:
            ESP_LOGI(TAG, "🔄 Reboot requested, restarting in 2 seconds...");
            // Schedule reboot
            xTaskCreate(mqtt_reboot_task, "reboot_task", 1024, NULL, 5, NULL);
            break;
            
        default:
            ESP_LOGW(TAG, "Unknown or invalid command: %d", cmd_data->command);
            break;
    }
}

/**
 * Generate status JSON payload
 */
esp_err_t mqtt_generate_status_json(char* buffer, size_t max_len) {
    if (!buffer) {
        return ESP_ERR_INVALID_ARG;
    }
    
    device_config_t* config = config_get();
    
    // Get system info
    uint32_t uptime = esp_timer_get_time() / 1000000; // Convert to seconds
    int8_t rssi = wifi_manager_get_rssi();
    uint32_t free_memory = esp_get_free_heap_size();
    
    // Get relay states
    uint8_t relay_states[RELAY_MAX_CHANNELS];
    relay_get_all_states(relay_states);
    
    // Create JSON object
    cJSON *json = cJSON_CreateObject();
    cJSON *relay_array = cJSON_CreateArray();
    
    // Add device info
    cJSON_AddStringToObject(json, "uuid", config->device_id);
    cJSON_AddStringToObject(json, "status", "online");
    cJSON_AddNumberToObject(json, "uptime", uptime);
    cJSON_AddNumberToObject(json, "wifi_rssi", rssi);
    cJSON_AddNumberToObject(json, "free_memory", free_memory);
    
    // Add relay states
    for (int i = 0; i < config->relay_channels; i++) {
        cJSON_AddItemToArray(relay_array, cJSON_CreateNumber(relay_states[i]));
    }
    cJSON_AddItemToObject(json, "relay_states", relay_array);
    
    // Convert to compact string (no formatting)
    char *json_string = cJSON_PrintUnformatted(json);
    if (json_string) {
        strncpy(buffer, json_string, max_len - 1);
        buffer[max_len - 1] = '\0';
        free(json_string);
    }
    
    cJSON_Delete(json);
    
    return ESP_OK;
}

/**
 * Register device with backend
 */
esp_err_t mqtt_register_device(void) {
    device_config_t* config = config_get();
    
    if (strlen(config->backend_ip) == 0 || config->backend_port == 0) {
        ESP_LOGE(TAG, "Backend configuration missing");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Prepare HTTP client configuration
    char url[128];
    snprintf(url, sizeof(url), "http://%s:%d/api/devices", config->backend_ip, config->backend_port);
    
    esp_http_client_config_t http_config = {
        .url = url,
        .method = HTTP_METHOD_POST,
        .timeout_ms = 10000,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    if (client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize HTTP client");
        return ESP_FAIL;
    }
    
    // Prepare registration data
    cJSON *json = cJSON_CreateObject();
    char mac_str[18];
    wifi_manager_get_mac_str(mac_str, sizeof(mac_str));
    
    char ip_str[16];
    wifi_manager_get_ip(ip_str, sizeof(ip_str));
    
    cJSON_AddStringToObject(json, "uuid", config->device_id);
    cJSON_AddStringToObject(json, "name", config->device_name);
    cJSON_AddStringToObject(json, "type", "esp32_relay");
    cJSON_AddStringToObject(json, "mac_address", mac_str);
    cJSON_AddStringToObject(json, "ip_address", ip_str);
    cJSON_AddStringToObject(json, "firmware_version", "2.0.0");
    cJSON_AddStringToObject(json, "hardware_version", "ESP32-WROOM-32");
    
    char *json_string = cJSON_Print(json);
    if (json_string == NULL) {
        ESP_LOGE(TAG, "Failed to create JSON payload");
        cJSON_Delete(json);
        esp_http_client_cleanup(client);
        return ESP_FAIL;
    }
    
    // Set HTTP headers
    esp_http_client_set_header(client, "Content-Type", "application/json");
    esp_http_client_set_post_field(client, json_string, strlen(json_string));
    
    ESP_LOGI(TAG, "Registering device: %s", json_string);
    
    // Perform HTTP request
    esp_err_t ret = esp_http_client_perform(client);
    int status_code = esp_http_client_get_status_code(client);
    
    if (ret == ESP_OK && status_code == 200) {
        ESP_LOGI(TAG, "✅ Device registration successful");
        
        // Parse response to get MQTT credentials
        int content_length = esp_http_client_get_content_length(client);
        if (content_length > 0) {
            char response_buffer[512];
            int read_len = esp_http_client_read_response(client, response_buffer, sizeof(response_buffer) - 1);
            if (read_len > 0) {
                response_buffer[read_len] = '\0';
                ESP_LOGI(TAG, "Registration response: %s", response_buffer);
                
                // Parse response JSON to extract MQTT credentials
                cJSON *response_json = cJSON_Parse(response_buffer);
                if (response_json) {
                    cJSON *mqtt_user = cJSON_GetObjectItem(response_json, "mqtt_user");
                    cJSON *mqtt_password = cJSON_GetObjectItem(response_json, "mqtt_password");
                    cJSON *mqtt_broker = cJSON_GetObjectItem(response_json, "mqtt_broker");
                    cJSON *mqtt_port = cJSON_GetObjectItem(response_json, "mqtt_port");
                    
                    if (mqtt_user && cJSON_IsString(mqtt_user) &&
                        mqtt_password && cJSON_IsString(mqtt_password)) {
                        
                        // Update MQTT configuration
                        const char* broker = mqtt_broker && cJSON_IsString(mqtt_broker) ? 
                                            mqtt_broker->valuestring : config->mqtt_broker;
                        int port = mqtt_port && cJSON_IsNumber(mqtt_port) ? 
                                  mqtt_port->valueint : config->mqtt_port;
                        
                        config_set_mqtt(broker, port, mqtt_user->valuestring, mqtt_password->valuestring);
                        
                        ESP_LOGI(TAG, "MQTT credentials updated: %s@%s:%d", 
                                mqtt_user->valuestring, broker, port);
                    }
                    
                    cJSON_Delete(response_json);
                }
            }
        }
        
        ret = ESP_OK;
    } else {
        ESP_LOGE(TAG, "❌ Device registration failed: %s, HTTP %d", esp_err_to_name(ret), status_code);
        ret = ESP_FAIL;
    }
    
    // Cleanup
    free(json_string);
    cJSON_Delete(json);
    esp_http_client_cleanup(client);
    
    return ret;
}

/**
 * Set connected callback
 */
void mqtt_client_set_connected_cb(mqtt_connected_cb_t cb) {
    mqtt_connected_callback = cb;
}

/**
 * Set disconnected callback
 */
void mqtt_client_set_disconnected_cb(mqtt_disconnected_cb_t cb) {
    mqtt_disconnected_callback = cb;
}

/**
 * Set command callback
 */
void mqtt_client_set_command_cb(mqtt_command_cb_t cb) {
    mqtt_command_callback = cb;
}

/**
 * Telemetry timer callback
 */
static void telemetry_timer_callback(TimerHandle_t xTimer) {
    if (mqtt_client_is_connected()) {
        mqtt_publish_status();
    } else {
        ESP_LOGD(TAG, "MQTT not connected, skipping telemetry");
    }
}

/**
 * Start telemetry task
 */
esp_err_t mqtt_start_telemetry_task(void) {
    if (telemetry_timer != NULL) {
        ESP_LOGW(TAG, "Telemetry timer already running");
        return ESP_OK;
    }
    
    // Create timer for periodic telemetry
    telemetry_timer = xTimerCreate(
        "telemetry_timer",
        pdMS_TO_TICKS(MQTT_TELEMETRY_INTERVAL_SEC * 1000),
        pdTRUE,  // Auto-reload
        NULL,    // Timer ID
        telemetry_timer_callback
    );
    
    if (telemetry_timer == NULL) {
        ESP_LOGE(TAG, "Failed to create telemetry timer");
        return ESP_FAIL;
    }
    
    if (xTimerStart(telemetry_timer, pdMS_TO_TICKS(1000)) != pdPASS) {
        ESP_LOGE(TAG, "Failed to start telemetry timer");
        xTimerDelete(telemetry_timer, 0);
        telemetry_timer = NULL;
        return ESP_FAIL;
    }
    
    ESP_LOGI(TAG, "📊 Telemetry task started (interval: %d seconds)", MQTT_TELEMETRY_INTERVAL_SEC);
    return ESP_OK;
}

/**
 * Stop telemetry task
 */
esp_err_t mqtt_stop_telemetry_task(void) {
    if (telemetry_timer == NULL) {
        ESP_LOGW(TAG, "Telemetry timer not running");
        return ESP_OK;
    }
    
    if (xTimerStop(telemetry_timer, pdMS_TO_TICKS(1000)) == pdPASS) {
        xTimerDelete(telemetry_timer, 0);
        telemetry_timer = NULL;
        ESP_LOGI(TAG, "Telemetry task stopped");
        return ESP_OK;
    } else {
        ESP_LOGE(TAG, "Failed to stop telemetry timer");
        return ESP_FAIL;
    }
}

/**
 * Reconnect to MQTT broker
 */
esp_err_t mqtt_client_reconnect(void) {
    if (mqtt_client_handle == NULL) {
        ESP_LOGE(TAG, "MQTT client not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    if (current_mqtt_state == MQTT_STATE_CONNECTED) {
        ESP_LOGI(TAG, "MQTT already connected");
        return ESP_OK;
    }
    
    if (mqtt_retry_count >= MQTT_MAX_RETRY_COUNT) {
        ESP_LOGE(TAG, "Maximum MQTT retry count reached");
        return ESP_FAIL;
    }
    
    mqtt_retry_count++;
    ESP_LOGI(TAG, "🔄 MQTT reconnection attempt %d/%d", mqtt_retry_count, MQTT_MAX_RETRY_COUNT);
    
    current_mqtt_state = MQTT_STATE_CONNECTING;
    esp_err_t ret = esp_mqtt_client_reconnect(mqtt_client_handle);
    
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to initiate MQTT reconnection: %s", esp_err_to_name(ret));
        current_mqtt_state = MQTT_STATE_ERROR;
    }
    
    return ret;
}