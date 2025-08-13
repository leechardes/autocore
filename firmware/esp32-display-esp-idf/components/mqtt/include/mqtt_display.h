#ifndef MQTT_DISPLAY_H
#define MQTT_DISPLAY_H

#include <stdint.h>
#include <stdbool.h>
#include "cJSON.h"
#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

// Estrutura para controle de heartbeat de relés momentâneos
typedef struct {
    bool active;
    uint32_t last_heartbeat;
    uint32_t sequence;
    char source_uuid[64];
    char target_uuid[64];
    uint8_t channel;
} display_heartbeat_t;

// Máximo de 16 canais de relé conforme especificação
#define MAX_RELAY_CHANNELS 16

// Funções de envio de comandos via MQTT
esp_err_t mqtt_display_send_touch_event(int x, int y, const char* action);
esp_err_t mqtt_display_send_relay_command(const char* target_uuid, uint8_t channel, 
                                         bool state, const char* function_type);
esp_err_t mqtt_display_send_macro_command(const char* macro_name, const char* action);

// Funções de heartbeat para relés momentâneos
esp_err_t mqtt_display_send_heartbeat(const char* target_uuid, uint8_t channel);
void mqtt_display_process_heartbeats(void);
esp_err_t mqtt_display_start_heartbeat(const char* target_uuid, uint8_t channel);
void mqtt_display_stop_heartbeat(uint8_t channel);
void mqtt_display_stop_all_heartbeats(void);

// Funções de processamento de mensagens recebidas
esp_err_t mqtt_display_handle_screen_update(const char* payload);
esp_err_t mqtt_display_handle_config_update(const char* payload);
esp_err_t mqtt_display_handle_relay_state(const char* payload);
esp_err_t mqtt_display_handle_telemetry(const char* topic, const char* payload);
esp_err_t mqtt_display_handle_system_alert(const char* payload);

// Funções de status e diagnóstico
esp_err_t mqtt_display_send_diagnostic_info(void);
esp_err_t mqtt_display_send_error_report(const char* error_code, const char* description);

// Funções de configuração
esp_err_t mqtt_display_request_config(void);
esp_err_t mqtt_display_send_config_ack(bool success, const char* message);

// Utilitários
bool mqtt_display_is_heartbeat_active(uint8_t channel);
uint32_t mqtt_display_get_heartbeat_sequence(uint8_t channel);

#ifdef __cplusplus
}
#endif

#endif // MQTT_DISPLAY_H