#pragma once

#include <time.h>
#include <stdbool.h>
#include <stdint.h>
#include "cJSON.h"

#ifdef __cplusplus
extern "C" {
#endif

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
} mqtt_command_t;

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
esp_err_t mqtt_parse_command(const char* topic, const char* payload, mqtt_command_t* cmd);
esp_err_t mqtt_parse_relay_command(cJSON* json, mqtt_command_t* cmd);
esp_err_t mqtt_parse_general_command(cJSON* json, mqtt_command_t* cmd);

// Funções de processamento
esp_err_t mqtt_process_command(mqtt_command_t* cmd);
esp_err_t mqtt_process_relay_command(mqtt_command_t* cmd);
esp_err_t mqtt_process_general_command(mqtt_command_t* cmd);

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