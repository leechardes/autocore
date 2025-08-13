#ifndef MQTT_CLIENT_H
#define MQTT_CLIENT_H

#include "esp_mqtt_client.h"
#include "mqtt_protocol.h"
#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Estados do cliente MQTT
typedef enum {
    MQTT_STATE_DISCONNECTED = 0,
    MQTT_STATE_CONNECTING,
    MQTT_STATE_CONNECTED,
    MQTT_STATE_ERROR
} mqtt_state_t;

// Estrutura principal do cliente
typedef struct {
    esp_mqtt_client_handle_t client;
    mqtt_state_t state;
    char device_uuid[64];
    uint32_t message_count;
    uint32_t error_count;
    bool initialized;
} mqtt_client_t;

// Callbacks
typedef void (*mqtt_message_callback_t)(const char* topic, const char* payload);

// Funções públicas de inicialização
esp_err_t mqtt_client_init(const char* broker_url, const char* device_uuid);
esp_err_t mqtt_client_start(void);
esp_err_t mqtt_client_stop(void);
esp_err_t mqtt_client_deinit(void);

// Funções de publicação e subscrição
esp_err_t mqtt_client_publish(const char* topic, const char* payload, int qos, bool retain);
esp_err_t mqtt_client_subscribe(const char* topic, int qos);
esp_err_t mqtt_client_unsubscribe(const char* topic);

// Funções de estado
mqtt_state_t mqtt_client_get_state(void);
const char* mqtt_client_get_device_uuid(void);
uint32_t mqtt_client_get_message_count(void);
uint32_t mqtt_client_get_error_count(void);

// Callback registration
void mqtt_client_register_callback(mqtt_message_callback_t callback);

// Funções específicas do display
esp_err_t mqtt_publish_display_status(const char* status);
esp_err_t mqtt_publish_touch_event(int x, int y, const char* action);

#ifdef __cplusplus
}
#endif

#endif // MQTT_CLIENT_H