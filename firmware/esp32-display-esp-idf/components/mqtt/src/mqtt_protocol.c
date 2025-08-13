#include "mqtt_protocol.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "esp_system.h"
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <stdio.h>

static const char* TAG = "MQTT_PROTOCOL";

char* mqtt_get_iso_timestamp(void) {
    struct timeval tv;
    struct tm* tm_info;
    char* timestamp = malloc(32);
    
    if (!timestamp) {
        return NULL;
    }
    
    gettimeofday(&tv, NULL);
    tm_info = gmtime(&tv.tv_sec);
    
    strftime(timestamp, 32, "%Y-%m-%dT%H:%M:%SZ", tm_info);
    
    return timestamp;
}

bool mqtt_validate_protocol_version(cJSON* json) {
    if (!json) {
        return false;
    }
    
    cJSON* version = cJSON_GetObjectItem(json, "protocol_version");
    if (!version || !cJSON_IsString(version)) {
        ESP_LOGW(TAG, "Missing or invalid protocol_version field");
        return false;
    }
    
    const char* version_str = cJSON_GetStringValue(version);
    if (!version_str || strcmp(version_str, MQTT_PROTOCOL_VERSION) != 0) {
        ESP_LOGW(TAG, "Protocol version mismatch. Expected: %s, Got: %s", 
                MQTT_PROTOCOL_VERSION, version_str ? version_str : "null");
        return false;
    }
    
    return true;
}

void mqtt_add_protocol_fields(cJSON* json, const char* uuid) {
    if (!json || !uuid) {
        return;
    }
    
    // Campos obrigatórios do protocolo v2.2.0
    cJSON_AddStringToObject(json, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(json, "uuid", uuid);
    
    char* timestamp = mqtt_get_iso_timestamp();
    if (timestamp) {
        cJSON_AddStringToObject(json, "timestamp", timestamp);
        free(timestamp);
    }
}

esp_err_t mqtt_publish_error(mqtt_error_code_t code, const char* message, cJSON* context) {
    // Declaração externa para evitar dependência circular
    extern esp_err_t mqtt_client_publish(const char* topic, const char* payload, int qos, bool retain);
    extern const char* mqtt_client_get_device_uuid(void);
    extern mqtt_state_t mqtt_client_get_state(void);
    
    // Log do erro localmente
    ESP_LOGE(TAG, "MQTT Error %d: %s", code, message ? message : "Unknown error");
    
    // Verificar se MQTT está conectado
    if (mqtt_client_get_state() != 1) { // MQTT_STATE_CONNECTED = 1
        ESP_LOGW(TAG, "Cannot publish error - MQTT not connected");
        return ESP_FAIL;
    }
    
    // Criar payload do erro
    cJSON* error_json = cJSON_CreateObject();
    if (!error_json) {
        return ESP_ERR_NO_MEM;
    }
    
    // Campos obrigatórios do protocolo v2.2.0
    mqtt_add_protocol_fields(error_json, mqtt_client_get_device_uuid());
    cJSON_AddNumberToObject(error_json, "error_code", code);
    cJSON_AddStringToObject(error_json, "error_message", message ? message : "Unknown error");
    cJSON_AddStringToObject(error_json, "error_type", mqtt_get_error_string(code));
    cJSON_AddStringToObject(error_json, "severity", "error");
    cJSON_AddStringToObject(error_json, "source", "esp32_display");
    
    // Adicionar contexto se fornecido
    if (context) {
        cJSON_AddItemToObject(error_json, "context", cJSON_Duplicate(context, true));
    }
    
    // Criar tópico de erro
    char error_topic[128];
    snprintf(error_topic, sizeof(error_topic), "autocore/devices/%s/errors", 
             mqtt_client_get_device_uuid());
    
    char* payload = cJSON_PrintUnformatted(error_json);
    cJSON_Delete(error_json);
    
    if (!payload) {
        return ESP_ERR_NO_MEM;
    }
    
    // Publicar erro com QoS 1 para garantir entrega
    esp_err_t ret = mqtt_client_publish(error_topic, payload, QOS_COMMANDS, false);
    free(payload);
    
    if (ret == ESP_OK) {
        ESP_LOGD(TAG, "Error published to MQTT");
    } else {
        ESP_LOGW(TAG, "Failed to publish error to MQTT");
    }
    
    return ret;
}

void mqtt_init_topics(mqtt_topics_t* topics, const char* device_uuid) {
    if (!topics || !device_uuid) {
        return;
    }
    
    // Tópicos específicos do dispositivo
    snprintf(topics->device_status, sizeof(topics->device_status), 
             "autocore/devices/%s/status", device_uuid);
    snprintf(topics->device_commands, sizeof(topics->device_commands), 
             "autocore/devices/%s/commands", device_uuid);
    snprintf(topics->device_errors, sizeof(topics->device_errors), 
             "autocore/devices/%s/errors", device_uuid);
    
    // Tópicos específicos do display
    snprintf(topics->display_screen, sizeof(topics->display_screen), 
             "autocore/devices/%s/display/screen", device_uuid);
    snprintf(topics->display_config, sizeof(topics->display_config), 
             "autocore/devices/%s/display/config", device_uuid);
    snprintf(topics->display_touch, sizeof(topics->display_touch), 
             "autocore/devices/%s/display/touch", device_uuid);
    
    // Tópicos de telemetria (sem UUID conforme v2.2.0)
    strncpy(topics->telemetry_relays, "autocore/telemetry/relays/data", 
            sizeof(topics->telemetry_relays) - 1);
    strncpy(topics->telemetry_can, "autocore/telemetry/can", 
            sizeof(topics->telemetry_can) - 1);
    strncpy(topics->telemetry_sensors, "autocore/telemetry/sensors", 
            sizeof(topics->telemetry_sensors) - 1);
    
    // Tópicos de sistema
    strncpy(topics->system_broadcast, "autocore/system/broadcast", 
            sizeof(topics->system_broadcast) - 1);
    strncpy(topics->system_alert, "autocore/system/alert", 
            sizeof(topics->system_alert) - 1);
    
    ESP_LOGI(TAG, "MQTT topics initialized for device: %s", device_uuid);
}

const char* mqtt_get_error_string(mqtt_error_code_t code) {
    switch (code) {
        case MQTT_ERR_COMMAND_FAILED:
            return "Command failed";
        case MQTT_ERR_INVALID_PAYLOAD:
            return "Invalid payload";
        case MQTT_ERR_TIMEOUT:
            return "Timeout";
        case MQTT_ERR_UNAUTHORIZED:
            return "Unauthorized";
        case MQTT_ERR_DEVICE_BUSY:
            return "Device busy";
        case MQTT_ERR_HARDWARE_FAULT:
            return "Hardware fault";
        case MQTT_ERR_NETWORK_ERROR:
            return "Network error";
        case MQTT_ERR_PROTOCOL_MISMATCH:
            return "Protocol version mismatch";
        default:
            return "Unknown error";
    }
}

bool mqtt_validate_command_payload(cJSON* json) {
    if (!json) {
        return false;
    }
    
    // Validar campos obrigatórios
    if (!mqtt_validate_protocol_version(json)) {
        return false;
    }
    
    cJSON* uuid = cJSON_GetObjectItem(json, "uuid");
    if (!uuid || !cJSON_IsString(uuid)) {
        ESP_LOGW(TAG, "Missing or invalid uuid field in command");
        return false;
    }
    
    cJSON* timestamp = cJSON_GetObjectItem(json, "timestamp");
    if (!timestamp || !cJSON_IsString(timestamp)) {
        ESP_LOGW(TAG, "Missing or invalid timestamp field in command");
        return false;
    }
    
    return true;
}

bool mqtt_validate_status_payload(cJSON* json) {
    if (!json) {
        return false;
    }
    
    // Validar campos obrigatórios
    if (!mqtt_validate_protocol_version(json)) {
        return false;
    }
    
    cJSON* uuid = cJSON_GetObjectItem(json, "uuid");
    if (!uuid || !cJSON_IsString(uuid)) {
        ESP_LOGW(TAG, "Missing or invalid uuid field in status");
        return false;
    }
    
    cJSON* status = cJSON_GetObjectItem(json, "status");
    if (!status || !cJSON_IsString(status)) {
        ESP_LOGW(TAG, "Missing or invalid status field");
        return false;
    }
    
    const char* status_str = cJSON_GetStringValue(status);
    if (!status_str || (strcmp(status_str, "online") != 0 && strcmp(status_str, "offline") != 0)) {
        ESP_LOGW(TAG, "Invalid status value: %s", status_str ? status_str : "null");
        return false;
    }
    
    return true;
}

bool mqtt_validate_heartbeat_payload(cJSON* json) {
    if (!json) {
        return false;
    }
    
    // Validar campos obrigatórios
    if (!mqtt_validate_protocol_version(json)) {
        return false;
    }
    
    cJSON* source_uuid = cJSON_GetObjectItem(json, "source_uuid");
    if (!source_uuid || !cJSON_IsString(source_uuid)) {
        ESP_LOGW(TAG, "Missing or invalid source_uuid field in heartbeat");
        return false;
    }
    
    cJSON* target_uuid = cJSON_GetObjectItem(json, "target_uuid");
    if (!target_uuid || !cJSON_IsString(target_uuid)) {
        ESP_LOGW(TAG, "Missing or invalid target_uuid field in heartbeat");
        return false;
    }
    
    cJSON* channel = cJSON_GetObjectItem(json, "channel");
    if (!channel || !cJSON_IsNumber(channel)) {
        ESP_LOGW(TAG, "Missing or invalid channel field in heartbeat");
        return false;
    }
    
    int channel_num = cJSON_GetNumberValue(channel);
    if (channel_num < 1 || channel_num > 16) {
        ESP_LOGW(TAG, "Invalid channel number: %d", channel_num);
        return false;
    }
    
    cJSON* sequence = cJSON_GetObjectItem(json, "sequence");
    if (!sequence || !cJSON_IsNumber(sequence)) {
        ESP_LOGW(TAG, "Missing or invalid sequence field in heartbeat");
        return false;
    }
    
    return true;
}