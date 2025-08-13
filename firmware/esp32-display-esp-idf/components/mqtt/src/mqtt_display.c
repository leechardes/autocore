#include "mqtt_display.h"
#include "mqtt_client.h"
#include "mqtt_protocol.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "esp_system.h"
#include <string.h>

static const char* TAG = "MQTT_DISPLAY";

// Array de heartbeats para controle de relés momentâneos
static display_heartbeat_t heartbeats[MAX_RELAY_CHANNELS] = {0};

// Forward declarations
static esp_err_t send_command_with_validation(const char* topic, cJSON* payload);
static bool validate_target_uuid(const char* target_uuid);

esp_err_t mqtt_display_send_touch_event(int x, int y, const char* action) {
    if (!action) {
        ESP_LOGE(TAG, "Invalid action parameter");
        return ESP_ERR_INVALID_ARG;
    }
    
    // Usar a função do mqtt_client que já implementa o protocolo v2.2.0
    esp_err_t ret = mqtt_publish_touch_event(x, y, action);
    
    if (ret == ESP_OK) {
        ESP_LOGD(TAG, "Touch event sent: %s at (%d, %d)", action, x, y);
    } else {
        ESP_LOGE(TAG, "Failed to send touch event");
    }
    
    return ret;
}

esp_err_t mqtt_display_send_relay_command(const char* target_uuid, uint8_t channel, 
                                         bool state, const char* function_type) {
    if (!target_uuid || !function_type) {
        ESP_LOGE(TAG, "Invalid parameters for relay command");
        return ESP_ERR_INVALID_ARG;
    }
    
    if (channel < 1 || channel > MAX_RELAY_CHANNELS) {
        ESP_LOGE(TAG, "Invalid channel number: %d", channel);
        return ESP_ERR_INVALID_ARG;
    }
    
    if (!validate_target_uuid(target_uuid)) {
        ESP_LOGE(TAG, "Invalid target UUID format");
        return ESP_ERR_INVALID_ARG;
    }
    
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/relays/set", target_uuid);
    
    cJSON* cmd = cJSON_CreateObject();
    if (!cmd) {
        ESP_LOGE(TAG, "Failed to create command JSON");
        return ESP_ERR_NO_MEM;
    }
    
    // Adicionar campos obrigatórios do protocolo v2.2.0
    mqtt_add_protocol_fields(cmd, mqtt_client_get_device_uuid());
    
    // Adicionar campos específicos do comando
    cJSON_AddNumberToObject(cmd, "channel", channel);
    cJSON_AddBoolToObject(cmd, "state", state);
    cJSON_AddStringToObject(cmd, "function_type", function_type);
    cJSON_AddStringToObject(cmd, "user", "display_touch");
    cJSON_AddStringToObject(cmd, "source_uuid", mqtt_client_get_device_uuid());
    cJSON_AddStringToObject(cmd, "target_uuid", target_uuid);
    
    esp_err_t ret = send_command_with_validation(topic, cmd);
    cJSON_Delete(cmd);
    
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "Sent %s command to %s ch:%d state:%d", 
                function_type, target_uuid, channel, state);
        
        // Se for comando momentâneo e estado ligado, iniciar heartbeat
        if (strcmp(function_type, "momentary") == 0 && state) {
            ret = mqtt_display_start_heartbeat(target_uuid, channel);
            if (ret != ESP_OK) {
                ESP_LOGW(TAG, "Failed to start heartbeat for channel %d", channel);
            }
        } else if (!state) {
            // Se estado é false, parar heartbeat
            mqtt_display_stop_heartbeat(channel);
        }
    }
    
    return ret;
}

esp_err_t mqtt_display_send_macro_command(const char* macro_name, const char* action) {
    if (!macro_name || !action) {
        ESP_LOGE(TAG, "Invalid parameters for macro command");
        return ESP_ERR_INVALID_ARG;
    }
    
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/macros/%s/execute", macro_name);
    
    cJSON* cmd = cJSON_CreateObject();
    if (!cmd) {
        return ESP_ERR_NO_MEM;
    }
    
    mqtt_add_protocol_fields(cmd, mqtt_client_get_device_uuid());
    cJSON_AddStringToObject(cmd, "action", action);
    cJSON_AddStringToObject(cmd, "trigger_source", "display_touch");
    cJSON_AddStringToObject(cmd, "source_uuid", mqtt_client_get_device_uuid());
    
    esp_err_t ret = send_command_with_validation(topic, cmd);
    cJSON_Delete(cmd);
    
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "Sent macro command: %s - %s", macro_name, action);
    }
    
    return ret;
}

esp_err_t mqtt_display_start_heartbeat(const char* target_uuid, uint8_t channel) {
    if (!target_uuid || channel < 1 || channel > MAX_RELAY_CHANNELS) {
        return ESP_ERR_INVALID_ARG;
    }
    
    display_heartbeat_t* hb = &heartbeats[channel - 1];
    
    // Configurar heartbeat
    hb->active = true;
    hb->sequence = 0;
    hb->channel = channel;
    hb->last_heartbeat = 0;
    strncpy(hb->source_uuid, mqtt_client_get_device_uuid(), sizeof(hb->source_uuid) - 1);
    strncpy(hb->target_uuid, target_uuid, sizeof(hb->target_uuid) - 1);
    hb->source_uuid[sizeof(hb->source_uuid) - 1] = '\0';
    hb->target_uuid[sizeof(hb->target_uuid) - 1] = '\0';
    
    ESP_LOGI(TAG, "Started heartbeat for channel %d to %s", channel, target_uuid);
    return ESP_OK;
}

esp_err_t mqtt_display_send_heartbeat(const char* target_uuid, uint8_t channel) {
    if (!target_uuid || channel < 1 || channel > MAX_RELAY_CHANNELS) {
        return ESP_ERR_INVALID_ARG;
    }
    
    display_heartbeat_t* hb = &heartbeats[channel - 1];
    if (!hb->active) {
        return ESP_FAIL;
    }
    
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/relays/heartbeat", target_uuid);
    
    cJSON* heartbeat = cJSON_CreateObject();
    if (!heartbeat) {
        return ESP_ERR_NO_MEM;
    }
    
    mqtt_add_protocol_fields(heartbeat, mqtt_client_get_device_uuid());
    cJSON_AddNumberToObject(heartbeat, "channel", channel);
    cJSON_AddStringToObject(heartbeat, "source_uuid", hb->source_uuid);
    cJSON_AddStringToObject(heartbeat, "target_uuid", target_uuid);
    cJSON_AddNumberToObject(heartbeat, "sequence", ++hb->sequence);
    
    esp_err_t ret = send_command_with_validation(topic, heartbeat);
    cJSON_Delete(heartbeat);
    
    if (ret == ESP_OK) {
        hb->last_heartbeat = esp_timer_get_time() / 1000;  // Converter para ms
        ESP_LOGD(TAG, "Sent heartbeat #%lu for channel %d", 
                (unsigned long)hb->sequence, channel);
    } else {
        ESP_LOGW(TAG, "Failed to send heartbeat for channel %d", channel);
    }
    
    return ret;
}

void mqtt_display_process_heartbeats(void) {
    uint32_t now = esp_timer_get_time() / 1000;  // Converter para ms
    
    for (int i = 0; i < MAX_RELAY_CHANNELS; i++) {
        display_heartbeat_t* hb = &heartbeats[i];
        
        if (hb->active) {
            // Verificar se é hora de enviar próximo heartbeat
            if ((now - hb->last_heartbeat) >= HEARTBEAT_INTERVAL_MS) {
                esp_err_t ret = mqtt_display_send_heartbeat(hb->target_uuid, hb->channel);
                if (ret != ESP_OK) {
                    ESP_LOGW(TAG, "Heartbeat failed for channel %d, stopping", hb->channel);
                    hb->active = false;
                }
            }
        }
    }
}

void mqtt_display_stop_heartbeat(uint8_t channel) {
    if (channel > 0 && channel <= MAX_RELAY_CHANNELS) {
        heartbeats[channel - 1].active = false;
        ESP_LOGI(TAG, "Stopped heartbeat for channel %d", channel);
    }
}

void mqtt_display_stop_all_heartbeats(void) {
    for (int i = 0; i < MAX_RELAY_CHANNELS; i++) {
        heartbeats[i].active = false;
    }
    ESP_LOGI(TAG, "Stopped all heartbeats");
}

esp_err_t mqtt_display_handle_screen_update(const char* payload) {
    if (!payload) {
        return ESP_ERR_INVALID_ARG;
    }
    
    cJSON* json = cJSON_Parse(payload);
    if (!json) {
        ESP_LOGE(TAG, "Failed to parse screen update payload");
        return ESP_FAIL;
    }
    
    // Validar protocol_version
    if (!mqtt_validate_protocol_version(json)) {
        mqtt_publish_error(MQTT_ERR_PROTOCOL_MISMATCH, 
                         "Invalid protocol version in screen update", json);
        cJSON_Delete(json);
        return ESP_FAIL;
    }
    
    // Processar dados da tela
    cJSON* screen_data = cJSON_GetObjectItem(json, "screen_data");
    if (screen_data) {
        // Aqui seria a integração com o UI Manager
        // ui_manager_update_screen(screen_data);
        ESP_LOGI(TAG, "Processing screen update");
    }
    
    cJSON_Delete(json);
    return ESP_OK;
}

esp_err_t mqtt_display_handle_config_update(const char* payload) {
    if (!payload) {
        return ESP_ERR_INVALID_ARG;
    }
    
    cJSON* json = cJSON_Parse(payload);
    if (!json) {
        ESP_LOGE(TAG, "Failed to parse config update payload");
        return ESP_FAIL;
    }
    
    if (!mqtt_validate_protocol_version(json)) {
        mqtt_publish_error(MQTT_ERR_PROTOCOL_MISMATCH, 
                         "Invalid protocol version in config update", json);
        cJSON_Delete(json);
        return ESP_FAIL;
    }
    
    // Processar configuração
    ESP_LOGI(TAG, "Processing config update");
    
    // Enviar ACK
    mqtt_display_send_config_ack(true, "Configuration applied successfully");
    
    cJSON_Delete(json);
    return ESP_OK;
}

esp_err_t mqtt_display_handle_relay_state(const char* payload) {
    if (!payload) {
        return ESP_ERR_INVALID_ARG;
    }
    
    cJSON* json = cJSON_Parse(payload);
    if (!json) {
        ESP_LOGE(TAG, "Failed to parse relay state payload");
        return ESP_FAIL;
    }
    
    // Atualizar UI com estado do relé
    // ui_update_relay_status(payload);
    ESP_LOGD(TAG, "Updated relay state in UI");
    
    cJSON_Delete(json);
    return ESP_OK;
}

esp_err_t mqtt_display_handle_telemetry(const char* topic, const char* payload) {
    if (!topic || !payload) {
        return ESP_ERR_INVALID_ARG;
    }
    
    // Processar telemetria conforme o tópico
    if (strstr(topic, "telemetry/relays")) {
        ESP_LOGD(TAG, "Processing relay telemetry");
    } else if (strstr(topic, "telemetry/can")) {
        ESP_LOGD(TAG, "Processing CAN telemetry");
    } else if (strstr(topic, "telemetry/sensors")) {
        ESP_LOGD(TAG, "Processing sensor telemetry");
    }
    
    // Atualizar UI com telemetria
    // ui_update_telemetry(topic, payload);
    
    return ESP_OK;
}

esp_err_t mqtt_display_handle_system_alert(const char* payload) {
    if (!payload) {
        return ESP_ERR_INVALID_ARG;
    }
    
    ESP_LOGW(TAG, "System alert received: %s", payload);
    
    // Mostrar alerta na UI
    // ui_show_alert(payload);
    
    return ESP_OK;
}

esp_err_t mqtt_display_send_diagnostic_info(void) {
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/diagnostics", 
             mqtt_client_get_device_uuid());
    
    cJSON* diag = cJSON_CreateObject();
    if (!diag) {
        return ESP_ERR_NO_MEM;
    }
    
    mqtt_add_protocol_fields(diag, mqtt_client_get_device_uuid());
    
    // Informações de sistema
    cJSON_AddNumberToObject(diag, "free_heap", esp_get_free_heap_size());
    cJSON_AddNumberToObject(diag, "uptime", esp_timer_get_time() / 1000000);
    cJSON_AddNumberToObject(diag, "message_count", mqtt_client_get_message_count());
    cJSON_AddNumberToObject(diag, "error_count", mqtt_client_get_error_count());
    
    // Estado do MQTT
    const char* mqtt_state_str = "unknown";
    switch (mqtt_client_get_state()) {
        case MQTT_STATE_DISCONNECTED: mqtt_state_str = "disconnected"; break;
        case MQTT_STATE_CONNECTING: mqtt_state_str = "connecting"; break;
        case MQTT_STATE_CONNECTED: mqtt_state_str = "connected"; break;
        case MQTT_STATE_ERROR: mqtt_state_str = "error"; break;
    }
    cJSON_AddStringToObject(diag, "mqtt_state", mqtt_state_str);
    
    // Heartbeats ativos
    cJSON* active_heartbeats = cJSON_CreateArray();
    if (active_heartbeats) {
        for (int i = 0; i < MAX_RELAY_CHANNELS; i++) {
            if (heartbeats[i].active) {
                cJSON* hb_info = cJSON_CreateObject();
                if (hb_info) {
                    cJSON_AddNumberToObject(hb_info, "channel", heartbeats[i].channel);
                    cJSON_AddStringToObject(hb_info, "target_uuid", heartbeats[i].target_uuid);
                    cJSON_AddNumberToObject(hb_info, "sequence", heartbeats[i].sequence);
                    cJSON_AddItemToArray(active_heartbeats, hb_info);
                }
            }
        }
        cJSON_AddItemToObject(diag, "active_heartbeats", active_heartbeats);
    }
    
    esp_err_t ret = send_command_with_validation(topic, diag);
    cJSON_Delete(diag);
    
    return ret;
}

esp_err_t mqtt_display_send_config_ack(bool success, const char* message) {
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/config/ack", 
             mqtt_client_get_device_uuid());
    
    cJSON* ack = cJSON_CreateObject();
    if (!ack) {
        return ESP_ERR_NO_MEM;
    }
    
    mqtt_add_protocol_fields(ack, mqtt_client_get_device_uuid());
    cJSON_AddBoolToObject(ack, "success", success);
    if (message) {
        cJSON_AddStringToObject(ack, "message", message);
    }
    
    esp_err_t ret = send_command_with_validation(topic, ack);
    cJSON_Delete(ack);
    
    return ret;
}

// Funções auxiliares
bool mqtt_display_is_heartbeat_active(uint8_t channel) {
    if (channel < 1 || channel > MAX_RELAY_CHANNELS) {
        return false;
    }
    return heartbeats[channel - 1].active;
}

uint32_t mqtt_display_get_heartbeat_sequence(uint8_t channel) {
    if (channel < 1 || channel > MAX_RELAY_CHANNELS) {
        return 0;
    }
    return heartbeats[channel - 1].sequence;
}

static esp_err_t send_command_with_validation(const char* topic, cJSON* payload) {
    if (!topic || !payload) {
        return ESP_ERR_INVALID_ARG;
    }
    
    char* payload_str = cJSON_PrintUnformatted(payload);
    if (!payload_str) {
        return ESP_ERR_NO_MEM;
    }
    
    esp_err_t ret = mqtt_client_publish(topic, payload_str, QOS_COMMANDS, false);
    free(payload_str);
    
    return ret;
}

static bool validate_target_uuid(const char* target_uuid) {
    if (!target_uuid) {
        return false;
    }
    
    size_t len = strlen(target_uuid);
    if (len < 8 || len > 63) {  // UUIDs básicos têm pelo menos 8 chars
        return false;
    }
    
    // Validação básica: deve conter apenas caracteres válidos
    for (size_t i = 0; i < len; i++) {
        char c = target_uuid[i];
        if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || 
              (c >= '0' && c <= '9') || c == '-' || c == '_')) {
            return false;
        }
    }
    
    return true;
}