#ifndef MQTT_PROTOCOL_H
#define MQTT_PROTOCOL_H

#include <stdbool.h>
#include <stdint.h>
#include "cJSON.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MQTT_PROTOCOL_VERSION "2.2.0"

// QoS Levels conforme especificação v2.2.0
#define QOS_TELEMETRY    0
#define QOS_COMMANDS     1
#define QOS_HEARTBEAT    1
#define QOS_STATUS       1

// Timeouts e intervalos
#define HEARTBEAT_TIMEOUT_MS     1000
#define HEARTBEAT_INTERVAL_MS    500
#define STATUS_PUBLISH_INTERVAL_MS 30000

// Códigos de erro MQTT v2.2.0
typedef enum {
    MQTT_ERR_COMMAND_FAILED = 1,
    MQTT_ERR_INVALID_PAYLOAD,
    MQTT_ERR_TIMEOUT,
    MQTT_ERR_UNAUTHORIZED,
    MQTT_ERR_DEVICE_BUSY,
    MQTT_ERR_HARDWARE_FAULT,
    MQTT_ERR_NETWORK_ERROR,
    MQTT_ERR_PROTOCOL_MISMATCH
} mqtt_error_code_t;

// Estrutura de tópicos conforme v2.2.0
typedef struct {
    char device_status[128];
    char device_commands[128];
    char device_errors[128];
    char display_screen[128];
    char display_config[128];
    char display_touch[128];
    char telemetry_relays[128];
    char telemetry_can[128];
    char telemetry_sensors[128];
    char system_broadcast[128];
    char system_alert[128];
} mqtt_topics_t;

// Funções do protocolo v2.2.0
char* mqtt_get_iso_timestamp(void);
bool mqtt_validate_protocol_version(cJSON* json);
void mqtt_add_protocol_fields(cJSON* json, const char* uuid);
esp_err_t mqtt_publish_error(mqtt_error_code_t code, const char* message, cJSON* context);

// Funções de configuração de tópicos
void mqtt_init_topics(mqtt_topics_t* topics, const char* device_uuid);
const char* mqtt_get_error_string(mqtt_error_code_t code);

// Validação de payloads
bool mqtt_validate_command_payload(cJSON* json);
bool mqtt_validate_status_payload(cJSON* json);
bool mqtt_validate_heartbeat_payload(cJSON* json);

#ifdef __cplusplus
}
#endif

#endif // MQTT_PROTOCOL_H