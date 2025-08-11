/**
 * ESP32 Relay MQTT Client
 * Handles MQTT communication with AutoCore backend
 * 
 * Compatible with AutoCore ecosystem
 * Based on FUNCTIONAL_SPECIFICATION.md
 */

#ifndef MQTT_HANDLER_H
#define MQTT_HANDLER_H

#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

// MQTT configuration constants
#define MQTT_MAX_TOPIC_LEN 128
#define MQTT_MAX_PAYLOAD_LEN 512
#define MQTT_KEEPALIVE_SEC 60
#define MQTT_CONNECT_TIMEOUT_MS 10000
#define MQTT_MAX_RETRY_COUNT 5
#define MQTT_RETRY_DELAY_MS 10000
#define MQTT_TELEMETRY_INTERVAL_SEC CONFIG_ESP32_RELAY_TELEMETRY_INTERVAL

// MQTT topic patterns
#define MQTT_TOPIC_COMMAND_PATTERN "autocore/devices/%s/command"
#define MQTT_TOPIC_STATUS_PATTERN "autocore/devices/%s/status"

// MQTT connection states
typedef enum {
    MQTT_STATE_DISCONNECTED = 0,
    MQTT_STATE_CONNECTING,
    MQTT_STATE_CONNECTED,
    MQTT_STATE_ERROR
} mqtt_state_t;

// MQTT command types
typedef enum {
    MQTT_CMD_UNKNOWN = 0,
    MQTT_CMD_RELAY_ON,
    MQTT_CMD_RELAY_OFF,
    MQTT_CMD_GET_STATUS,
    MQTT_CMD_REBOOT
} mqtt_command_t;

// MQTT command structure
typedef struct {
    mqtt_command_t command;
    uint8_t channel;
    char raw_data[MQTT_MAX_PAYLOAD_LEN];
} mqtt_cmd_data_t;

// MQTT callbacks
typedef void (*mqtt_connected_cb_t)(void);
typedef void (*mqtt_disconnected_cb_t)(void);
typedef void (*mqtt_command_cb_t)(mqtt_cmd_data_t* cmd_data);

/**
 * Initialize MQTT client
 * Sets up MQTT client with configuration
 * @return ESP_OK on success
 */
esp_err_t mqtt_client_init(void);

/**
 * Start MQTT client
 * Connects to broker and starts communication
 * @return ESP_OK on success
 */
esp_err_t mqtt_client_start(void);

/**
 * Stop MQTT client
 * Disconnects and cleans up resources
 * @return ESP_OK on success
 */
esp_err_t mqtt_client_stop(void);

/**
 * Check if MQTT client is connected
 * @return true if connected
 */
bool mqtt_client_is_connected(void);

/**
 * Get current MQTT state
 * @return Current MQTT state
 */
mqtt_state_t mqtt_client_get_state(void);

/**
 * Publish device status
 * Sends current device status and telemetry
 * @return ESP_OK on success
 */
esp_err_t mqtt_publish_status(void);

/**
 * Publish custom message
 * @param topic MQTT topic
 * @param payload Message payload
 * @param payload_len Payload length
 * @return ESP_OK on success
 */
esp_err_t mqtt_publish_message(const char* topic, const char* payload, size_t payload_len);

/**
 * Subscribe to command topic
 * Sets up subscription for device commands
 * @return ESP_OK on success
 */
esp_err_t mqtt_subscribe_commands(void);

/**
 * Process received MQTT command
 * Parses and executes received command
 * @param topic Message topic
 * @param data Message data
 * @param data_len Data length
 * @return ESP_OK on success
 */
esp_err_t mqtt_process_command(const char* topic, const char* data, size_t data_len);

/**
 * Generate status JSON payload
 * Creates telemetry JSON for publishing
 * @param buffer Output buffer
 * @param max_len Maximum buffer length
 * @return ESP_OK on success
 */
esp_err_t mqtt_generate_status_json(char* buffer, size_t max_len);

/**
 * Register device with backend
 * Performs auto-registration via HTTP POST
 * @return ESP_OK on success
 */
esp_err_t mqtt_register_device(void);

/**
 * Set connected callback
 * @param cb Callback function
 */
void mqtt_client_set_connected_cb(mqtt_connected_cb_t cb);

/**
 * Set disconnected callback
 * @param cb Callback function
 */
void mqtt_client_set_disconnected_cb(mqtt_disconnected_cb_t cb);

/**
 * Set command callback
 * @param cb Callback function
 */
void mqtt_client_set_command_cb(mqtt_command_cb_t cb);

/**
 * Start telemetry task
 * Begins periodic status publishing
 * @return ESP_OK on success
 */
esp_err_t mqtt_start_telemetry_task(void);

/**
 * Stop telemetry task
 * Stops periodic status publishing
 * @return ESP_OK on success
 */
esp_err_t mqtt_stop_telemetry_task(void);

/**
 * Reconnect to MQTT broker
 * Attempts reconnection with retry logic
 * @return ESP_OK on success
 */
esp_err_t mqtt_client_reconnect(void);

#ifdef __cplusplus
}
#endif

#endif // MQTT_HANDLER_H