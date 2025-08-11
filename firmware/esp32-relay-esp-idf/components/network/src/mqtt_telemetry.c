#include "mqtt_protocol.h"
#include "mqtt_handler.h"
#include "config_manager.h"
#include "esp_log.h"
#include <string.h>
#include <time.h>

static const char *TAG = "MQTT_TELEMETRY";

// Publicar evento de telemetria genérico
esp_err_t mqtt_publish_telemetry_event(telemetry_event_t* event)
{
    if (!event) {
        ESP_LOGE(TAG, "Evento de telemetria nulo");
        return ESP_ERR_INVALID_ARG;
    }

    device_config_t* config = config_get();
    if (!config) {
        ESP_LOGE(TAG, "Configuração não disponível");
        return ESP_ERR_INVALID_STATE;
    }

    // Gerar tópico de telemetria
    char topic[256];
    if (strlen(config->mqtt_topic_prefix) > 0) {
        snprintf(topic, sizeof(topic), "%s/devices/%s/telemetry", 
                config->mqtt_topic_prefix, config->device_id);
    } else {
        snprintf(topic, sizeof(topic), "autocore/devices/%s/telemetry", config->device_id);
    }

    // Criar JSON da telemetria
    cJSON *json = cJSON_CreateObject();
    if (!json) {
        ESP_LOGE(TAG, "Erro criando JSON de telemetria");
        return ESP_ERR_NO_MEM;
    }

    // Campos obrigatórios
    cJSON_AddStringToObject(json, "uuid", config->device_id);
    cJSON_AddNumberToObject(json, "board_id", 1);
    
    // Timestamp
    if (event->timestamp > 0) {
        struct tm timeinfo;
        localtime_r(&event->timestamp, &timeinfo);
        char timestamp_str[32];
        strftime(timestamp_str, sizeof(timestamp_str), "%Y-%m-%dT%H:%M:%S", &timeinfo);
        cJSON_AddStringToObject(json, "timestamp", timestamp_str);
    } else {
        cJSON_AddStringToObject(json, "timestamp", "1970-01-01T00:00:00");
    }

    // Campos do evento
    cJSON_AddStringToObject(json, "event", event->event_type);
    
    if (event->channel > 0) {
        cJSON_AddNumberToObject(json, "channel", event->channel);
    }
    
    if (strlen(event->event_type) > 0 && strcmp(event->event_type, "relay_change") == 0) {
        cJSON_AddBoolToObject(json, "state", event->state);
    }
    
    if (strlen(event->trigger) > 0) {
        cJSON_AddStringToObject(json, "trigger", event->trigger);
    }
    
    if (strlen(event->source) > 0) {
        cJSON_AddStringToObject(json, "source", event->source);
    }

    // Converter para string
    char *json_string = cJSON_Print(json);
    if (!json_string) {
        ESP_LOGE(TAG, "Erro convertendo JSON para string");
        cJSON_Delete(json);
        return ESP_ERR_NO_MEM;
    }

    // Publicar
    esp_err_t ret = mqtt_publish(topic, json_string, 0, false);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Erro publicando telemetria: %s", esp_err_to_name(ret));
    } else {
        ESP_LOGI(TAG, "Telemetria publicada: %s -> %s", event->event_type, topic);
        ESP_LOGD(TAG, "Payload: %s", json_string);
    }

    // Limpeza
    free(json_string);
    cJSON_Delete(json);
    
    return ret;
}

// Publicar telemetria de mudança de relé
esp_err_t mqtt_publish_relay_telemetry(int channel, bool state, const char* trigger, const char* source)
{
    if (channel < 1 || channel > 16) {
        ESP_LOGE(TAG, "Canal inválido para telemetria: %d", channel);
        return ESP_ERR_INVALID_ARG;
    }

    telemetry_event_t event = {
        .channel = channel,
        .state = state,
        .timestamp = time(NULL)
    };
    
    // Preencher strings com segurança
    strncpy(event.event_type, "relay_change", sizeof(event.event_type) - 1);
    event.event_type[sizeof(event.event_type) - 1] = '\0';
    
    if (trigger) {
        strncpy(event.trigger, trigger, sizeof(event.trigger) - 1);
        event.trigger[sizeof(event.trigger) - 1] = '\0';
    } else {
        strcpy(event.trigger, "unknown");
    }
    
    if (source) {
        strncpy(event.source, source, sizeof(event.source) - 1);
        event.source[sizeof(event.source) - 1] = '\0';
    } else {
        strcpy(event.source, "system");
    }

    ESP_LOGI(TAG, "Publicando telemetria de relé: canal=%d, state=%s, trigger=%s, source=%s",
             channel, state ? "ON" : "OFF", event.trigger, event.source);

    return mqtt_publish_telemetry_event(&event);
}

// Publicar desligamento de segurança
esp_err_t mqtt_publish_safety_shutoff(int channel, const char* reason, float timeout)
{
    if (channel < 1 || channel > 16) {
        ESP_LOGE(TAG, "Canal inválido para safety shutoff: %d", channel);
        return ESP_ERR_INVALID_ARG;
    }

    device_config_t* config = config_get();
    if (!config) {
        ESP_LOGE(TAG, "Configuração não disponível");
        return ESP_ERR_INVALID_STATE;
    }

    // Gerar tópico de telemetria
    char topic[256];
    if (strlen(config->mqtt_topic_prefix) > 0) {
        snprintf(topic, sizeof(topic), "%s/devices/%s/telemetry", 
                config->mqtt_topic_prefix, config->device_id);
    } else {
        snprintf(topic, sizeof(topic), "autocore/devices/%s/telemetry", config->device_id);
    }

    // Criar JSON específico para safety shutoff
    cJSON *json = cJSON_CreateObject();
    if (!json) {
        ESP_LOGE(TAG, "Erro criando JSON de safety shutoff");
        return ESP_ERR_NO_MEM;
    }

    // Campos obrigatórios
    cJSON_AddStringToObject(json, "uuid", config->device_id);
    cJSON_AddNumberToObject(json, "board_id", 1);
    
    // Timestamp atual
    time_t now = time(NULL);
    struct tm timeinfo;
    localtime_r(&now, &timeinfo);
    char timestamp_str[32];
    strftime(timestamp_str, sizeof(timestamp_str), "%Y-%m-%dT%H:%M:%S", &timeinfo);
    cJSON_AddStringToObject(json, "timestamp", timestamp_str);

    // Campos específicos do safety shutoff
    cJSON_AddStringToObject(json, "event", "safety_shutoff");
    cJSON_AddNumberToObject(json, "channel", channel);
    
    if (reason) {
        cJSON_AddStringToObject(json, "reason", reason);
    } else {
        cJSON_AddStringToObject(json, "reason", "unknown");
    }
    
    cJSON_AddNumberToObject(json, "timeout", timeout);

    // Converter para string
    char *json_string = cJSON_Print(json);
    if (!json_string) {
        ESP_LOGE(TAG, "Erro convertendo safety shutoff JSON para string");
        cJSON_Delete(json);
        return ESP_ERR_NO_MEM;
    }

    // Publicar
    esp_err_t ret = mqtt_publish(topic, json_string, 0, false);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Erro publicando safety shutoff: %s", esp_err_to_name(ret));
    } else {
        ESP_LOGW(TAG, "Safety shutoff publicado: canal=%d, reason=%s, timeout=%.1fs", 
                 channel, reason ? reason : "unknown", timeout);
        ESP_LOGD(TAG, "Payload: %s", json_string);
    }

    // Limpeza
    free(json_string);
    cJSON_Delete(json);
    
    return ret;
}