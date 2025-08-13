#pragma once

#include <time.h>
#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"
#include "cJSON.h"

#ifdef __cplusplus
extern "C" {
#endif

// Versão do protocolo MQTT v2.2.0
#define MQTT_PROTOCOL_VERSION "2.2.0"

// QoS Levels conforme v2.2.0
#define QOS_TELEMETRY    0
#define QOS_COMMANDS     1
#define QOS_HEARTBEAT    1
#define QOS_STATUS       1
#define QOS_CRITICAL     2

// Timeouts e intervalos
#define HEARTBEAT_TIMEOUT_MS     1000
#define HEARTBEAT_INTERVAL_MS    500
#define STATUS_INTERVAL_MS       30000

// Configurações de timeout para relé momentâneo
#define MOMENTARY_TIMEOUT_MS 1000  // 1 segundo sem heartbeat = desliga
#define MOMENTARY_CHECK_INTERVAL_MS 100  // Verifica a cada 100ms

// Tipos de comando MQTT
typedef enum {
    MQTT_CMD_RELAY,     // Comandos de relé (on/off/toggle)
    MQTT_CMD_GENERAL    // Comandos gerais (reset/status/reboot)
} mqtt_cmd_type_t;

// Comandos de relé
typedef enum {
    RELAY_CMD_ON,       // Ligar
    RELAY_CMD_OFF,      // Desligar
    RELAY_CMD_TOGGLE,   // Alternar
    RELAY_CMD_ALL       // Todos os relés
} relay_cmd_t;

// Comandos gerais
typedef enum {
    GENERAL_CMD_RESET,  // Reset sistema
    GENERAL_CMD_STATUS, // Solicitar status
    GENERAL_CMD_REBOOT, // Reiniciar sistema
    GENERAL_CMD_OTA     // Atualização OTA
} general_cmd_t;

// Estrutura de comando MQTT
typedef struct {
    mqtt_cmd_type_t type;
    union {
        struct {
            int channel;           // 1-16 ou -1 para "all"
            relay_cmd_t cmd;       // ON, OFF, TOGGLE
            bool is_momentary;     // Relé momentâneo
            char source[32];       // Origem do comando
            char user[32];         // Usuário que executou (opcional)
        } relay;
        struct {
            general_cmd_t cmd;     // RESET, STATUS, REBOOT, OTA
            int delay;             // Delay para reboot (segundos)
            char type[16];         // Tipo de reset ("all", "relays", "config")
            char data[128];        // Dados extras (URL OTA, etc)
        } general;
    } data;
} mqtt_command_struct_t;

// Estrutura de telemetria
typedef struct {
    char event_type[32];    // "relay_change", "safety_shutoff", etc
    int channel;            // Canal do relé
    bool state;             // Estado atual
    char trigger[32];       // "mqtt", "web", "button", "auto"
    char source[32];        // Origem do comando
    time_t timestamp;       // Timestamp do evento
} telemetry_event_t;

// Funções do parser
esp_err_t mqtt_parse_command(const char* topic, const char* payload, mqtt_command_struct_t* cmd);
esp_err_t mqtt_parse_relay_command(cJSON* json, mqtt_command_struct_t* cmd);
esp_err_t mqtt_parse_general_command(cJSON* json, mqtt_command_struct_t* cmd);

// Funções de processamento
esp_err_t mqtt_process_command_struct(mqtt_command_struct_t* cmd);
esp_err_t mqtt_process_relay_command(mqtt_command_struct_t* cmd);
esp_err_t mqtt_process_general_command(mqtt_command_struct_t* cmd);

// Estrutura base para mensagens MQTT v2.2.0
typedef struct {
    const char *protocol_version;
    const char *uuid;
    char timestamp[32];
} mqtt_base_message_t;

// Códigos de erro padronizados v2.2.0
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

// Funções auxiliares do protocolo v2.2.0
void mqtt_init_base_message(mqtt_base_message_t *msg, const char *uuid);
cJSON* mqtt_create_base_json(const mqtt_base_message_t *msg);
bool mqtt_validate_protocol_version(cJSON *root);
char* get_iso_timestamp(void);
char* get_iso_timestamp_from_time(time_t timestamp);

// Funções de validação
bool mqtt_validate_uuid(const char *uuid);
bool mqtt_validate_timestamp(const char *timestamp);

// Funções de criação de payloads padronizados
cJSON* mqtt_create_online_status(const char *uuid, const char *firmware_version, 
                                const char *ip_address, int wifi_signal, 
                                size_t free_memory, uint64_t uptime);
cJSON* mqtt_create_lwt_payload(const char *uuid, const char *reason);

// Códigos de erro
const char* mqtt_error_code_to_string(mqtt_error_code_t code);
const char* mqtt_error_type_to_string(mqtt_error_code_t code);

// Funções de telemetria
esp_err_t mqtt_publish_telemetry_event(telemetry_event_t* event);
esp_err_t mqtt_publish_relay_telemetry(int channel, bool state, const char* trigger, const char* source);
esp_err_t mqtt_publish_safety_shutoff(int channel, const char* reason, float timeout);

// Utilitários
const char* relay_cmd_to_string(relay_cmd_t cmd);
relay_cmd_t string_to_relay_cmd(const char* str);
const char* general_cmd_to_string(general_cmd_t cmd);
general_cmd_t string_to_general_cmd(const char* str);

#ifdef __cplusplus
}
#endif