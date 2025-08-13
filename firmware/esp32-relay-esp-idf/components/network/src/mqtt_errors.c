/**
 * MQTT Error Handling for ESP32 Relay v2.2.0
 * Tratamento padronizado de erros conforme protocolo MQTT v2.2.0
 */

#include "mqtt_errors.h"
#include "mqtt_handler.h"
#include "mqtt_protocol.h"
#include "config_manager.h"
#include "cJSON.h"
#include "esp_log.h"
#include <string.h>

static const char *TAG = "MQTT_ERRORS";

// Declaração da função externa
extern esp_err_t mqtt_publish(const char* topic, const char* payload, int qos, bool retain);

/**
 * Publica erro simples
 */
void mqtt_publish_error(mqtt_error_code_t code, const char *message) {
    mqtt_publish_error_with_context(code, message, NULL);
}

/**
 * Publica erro com contexto adicional
 */
void mqtt_publish_error_with_context(mqtt_error_code_t code, 
                                    const char *message, 
                                    cJSON *context) {
    device_config_t *config = config_get();
    if (!config) {
        ESP_LOGE(TAG, "Config unavailable for error publishing");
        return;
    }
    
    char topic[128];
    const char *error_type = mqtt_error_type_to_string(code);
    
    // Tópico: autocore/errors/{uuid}/{error_type}
    snprintf(topic, sizeof(topic), "autocore/errors/%s/%s", 
             config->device_id, error_type);
    
    // Criar payload de erro
    mqtt_base_message_t msg;
    mqtt_init_base_message(&msg, config->device_id);
    
    cJSON *root = mqtt_create_base_json(&msg);
    if (!root) {
        ESP_LOGE(TAG, "Failed to create error JSON");
        return;
    }
    
    cJSON_AddStringToObject(root, "error_code", mqtt_error_code_to_string(code));
    cJSON_AddStringToObject(root, "error_type", error_type);
    cJSON_AddStringToObject(root, "error_message", message ? message : "Unknown error");
    
    // Adicionar board_id
    cJSON_AddNumberToObject(root, "board_id", 1);
    
    // Adicionar contexto se fornecido
    if (context) {
        cJSON_AddItemToObject(root, "context", cJSON_Duplicate(context, true));
    }
    
    char *payload = cJSON_PrintUnformatted(root);
    if (payload) {
        // Publicar com QoS 1
        esp_err_t ret = mqtt_publish(topic, payload, QOS_COMMANDS, false);
        if (ret == ESP_OK) {
            ESP_LOGI(TAG, "Error published: %s", mqtt_error_code_to_string(code));
        } else {
            ESP_LOGE(TAG, "Failed to publish error: %s", esp_err_to_name(ret));
        }
        
        free(payload);
    }
    
    // Log local do erro
    ESP_LOGE(TAG, "%s: %s", mqtt_error_code_to_string(code), 
             message ? message : "Unknown error");
    
    cJSON_Delete(root);
}

/**
 * Publica evento de safety shutoff
 */
void mqtt_publish_safety_shutoff_event(uint8_t channel, const char *source_uuid, 
                                      uint32_t last_heartbeat) {
    device_config_t *config = config_get();
    if (!config) {
        ESP_LOGE(TAG, "Config unavailable for safety shutoff");
        return;
    }
    
    // Tópico de telemetria conforme v2.2.0
    const char *topic = "autocore/telemetry/relays/data";
    
    // Criar payload
    mqtt_base_message_t msg;
    mqtt_init_base_message(&msg, config->device_id);
    
    cJSON *root = mqtt_create_base_json(&msg);
    if (!root) {
        ESP_LOGE(TAG, "Failed to create safety shutoff JSON");
        return;
    }
    
    cJSON_AddNumberToObject(root, "board_id", 1);
    cJSON_AddStringToObject(root, "event", "safety_shutoff");
    cJSON_AddNumberToObject(root, "channel", channel);
    cJSON_AddStringToObject(root, "reason", "heartbeat_timeout");
    cJSON_AddNumberToObject(root, "timeout_ms", HEARTBEAT_TIMEOUT_MS);
    cJSON_AddStringToObject(root, "source_uuid", source_uuid ? source_uuid : "unknown");
    
    // Converter last_heartbeat para timestamp ISO
    if (last_heartbeat > 0) {
        time_t last_time = last_heartbeat / 1000;
        cJSON_AddStringToObject(root, "last_heartbeat", 
                               get_iso_timestamp_from_time(last_time));
    } else {
        cJSON_AddStringToObject(root, "last_heartbeat", "unknown");
    }
    
    char *payload = cJSON_PrintUnformatted(root);
    if (payload) {
        esp_err_t ret = mqtt_publish(topic, payload, QOS_COMMANDS, false);
        if (ret == ESP_OK) {
            ESP_LOGW(TAG, "Safety shutoff published for channel %d", channel);
        } else {
            ESP_LOGE(TAG, "Failed to publish safety shutoff: %s", esp_err_to_name(ret));
        }
        
        free(payload);
    }
    
    ESP_LOGW(TAG, "Safety shutoff on channel %d - heartbeat timeout", channel);
    
    cJSON_Delete(root);
}

/**
 * Publica erro de comando inválido
 */
void mqtt_publish_invalid_command_error(const char *command, const char *reason) {
    cJSON *context = cJSON_CreateObject();
    if (context) {
        cJSON_AddStringToObject(context, "command", command ? command : "unknown");
        cJSON_AddStringToObject(context, "reason", reason ? reason : "invalid format");
        
        mqtt_publish_error_with_context(MQTT_ERR_INVALID_PAYLOAD, 
                                       "Invalid command received", context);
        
        cJSON_Delete(context);
    } else {
        mqtt_publish_error(MQTT_ERR_INVALID_PAYLOAD, "Invalid command received");
    }
}

/**
 * Publica erro de canal inválido
 */
void mqtt_publish_invalid_channel_error(int channel) {
    cJSON *context = cJSON_CreateObject();
    if (context) {
        cJSON_AddNumberToObject(context, "channel", channel);
        cJSON_AddStringToObject(context, "valid_range", "1-16");
        
        mqtt_publish_error_with_context(MQTT_ERR_COMMAND_FAILED, 
                                       "Invalid relay channel", context);
        
        cJSON_Delete(context);
    } else {
        mqtt_publish_error(MQTT_ERR_COMMAND_FAILED, "Invalid relay channel");
    }
}

/**
 * Publica erro de timeout de heartbeat
 */
void mqtt_publish_heartbeat_timeout_error(int channel, uint32_t elapsed_ms) {
    cJSON *context = cJSON_CreateObject();
    if (context) {
        cJSON_AddNumberToObject(context, "channel", channel);
        cJSON_AddNumberToObject(context, "elapsed_ms", elapsed_ms);
        cJSON_AddNumberToObject(context, "timeout_ms", HEARTBEAT_TIMEOUT_MS);
        
        mqtt_publish_error_with_context(MQTT_ERR_TIMEOUT, 
                                       "Heartbeat timeout", context);
        
        cJSON_Delete(context);
    } else {
        mqtt_publish_error(MQTT_ERR_TIMEOUT, "Heartbeat timeout");
    }
}

/**
 * Publica erro de versão de protocolo incompatível
 */
void mqtt_publish_protocol_mismatch_error(const char *received_version) {
    cJSON *context = cJSON_CreateObject();
    if (context) {
        cJSON_AddStringToObject(context, "received_version", 
                               received_version ? received_version : "missing");
        cJSON_AddStringToObject(context, "expected_version", "2.x.x");
        cJSON_AddStringToObject(context, "current_version", MQTT_PROTOCOL_VERSION);
        
        mqtt_publish_error_with_context(MQTT_ERR_PROTOCOL_MISMATCH, 
                                       "Incompatible protocol version", context);
        
        cJSON_Delete(context);
    } else {
        mqtt_publish_error(MQTT_ERR_PROTOCOL_MISMATCH, "Incompatible protocol version");
    }
}

/**
 * Publica erro de hardware (falha de relé)
 */
void mqtt_publish_hardware_error(int channel, const char *error_detail) {
    cJSON *context = cJSON_CreateObject();
    if (context) {
        cJSON_AddNumberToObject(context, "channel", channel);
        cJSON_AddStringToObject(context, "detail", 
                               error_detail ? error_detail : "hardware fault");
        
        mqtt_publish_error_with_context(MQTT_ERR_HARDWARE_FAULT, 
                                       "Relay hardware fault", context);
        
        cJSON_Delete(context);
    } else {
        mqtt_publish_error(MQTT_ERR_HARDWARE_FAULT, "Relay hardware fault");
    }
}