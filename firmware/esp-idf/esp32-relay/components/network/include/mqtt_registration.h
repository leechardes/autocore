/**
 * ESP32 Relay MQTT Smart Registration System Header
 * Intelligent device registration with backend API
 */

#ifndef MQTT_REGISTRATION_H
#define MQTT_REGISTRATION_H

#include "esp_err.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * MQTT configuration structure
 */
typedef struct {
    char broker_host[64];     // MQTT broker hostname/IP
    uint16_t broker_port;     // MQTT broker port
    char username[32];        // MQTT username
    char password[64];        // MQTT password
    char topic_prefix[32];    // Topic prefix for messages
} mqtt_config_t;

/**
 * Perform smart MQTT registration
 * 
 * This function implements the intelligent registration logic:
 * 1. Check if device is already registered locally (skip if recent)
 * 2. Check if device exists in backend via GET /api/devices/uuid/{id}
 * 3. Register device if it doesn't exist via POST /api/devices
 * 4. Fetch MQTT configuration via GET /api/mqtt/config
 * 5. Save MQTT credentials to NVS persistently
 * 
 * @return ESP_OK on success
 */
esp_err_t mqtt_smart_registration(void);

/**
 * Get saved MQTT credentials from NVS
 * 
 * @param mqtt_config Pointer to structure to fill with credentials
 * @return ESP_OK on success, ESP_ERR_NOT_FOUND if no credentials saved
 */
esp_err_t mqtt_get_saved_credentials(mqtt_config_t* mqtt_config);

/**
 * Update device MAC and IP address in backend
 * 
 * This function updates only the MAC address (in uppercase) and IP address
 * for an already registered device.
 * 
 * @return ESP_OK on success
 */
esp_err_t mqtt_update_device_network_info(void);

#ifdef __cplusplus
}
#endif

#endif // MQTT_REGISTRATION_H