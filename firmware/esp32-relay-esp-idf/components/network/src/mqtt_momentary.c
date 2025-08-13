#include <string.h>
#include <inttypes.h>
#include "mqtt_protocol.h"
#include "mqtt_telemetry.h"
#include "mqtt_errors.h"
#include "relay_control.h"
#include "config_manager.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "cJSON.h"

static const char *TAG = "MQTT_MOMENTARY";

// Estrutura para monitorar heartbeat conforme v2.2.0
typedef struct {
    bool active;                    // Se está ativo
    int channel;                    // Canal do relé (1-16)
    uint32_t last_received;         // Timestamp do último heartbeat (ms)
    char source_uuid[64];           // UUID da fonte do heartbeat
    uint32_t sequence;              // Número de sequência do heartbeat
    esp_timer_handle_t timer;       // Timer para verificação
} heartbeat_monitor_t;

// Array para todos os canais (máximo 16)
static heartbeat_monitor_t monitors[16];
static SemaphoreHandle_t momentary_mutex = NULL;
static esp_timer_handle_t timeout_timer = NULL;

// Forward declarations
static void timeout_check_callback(void *arg);
static void momentary_check_timer_cb(void* arg);

// Inicializa sistema de heartbeat momentâneo v2.2.0
void mqtt_momentary_init(void)
{
    // Cria mutex para acesso thread-safe
    if (momentary_mutex == NULL) {
        momentary_mutex = xSemaphoreCreateMutex();
        if (!momentary_mutex) {
            ESP_LOGE(TAG, "Failed to create momentary mutex");
            return;
        }
    }
    
    // Inicializa estruturas
    memset(monitors, 0, sizeof(monitors));
    
    // Criar timer global para verificar timeouts
    if (timeout_timer == NULL) {
        esp_timer_create_args_t timer_args = {
            .callback = timeout_check_callback,
            .name = "heartbeat_timeout"
        };
        
        esp_err_t ret = esp_timer_create(&timer_args, &timeout_timer);
        if (ret == ESP_OK) {
            ret = esp_timer_start_periodic(timeout_timer, 100000); // 100ms
            if (ret == ESP_OK) {
                ESP_LOGI(TAG, "Heartbeat monitoring initialized (v2.2.0)");
            } else {
                ESP_LOGE(TAG, "Failed to start timeout timer: %s", esp_err_to_name(ret));
            }
        } else {
            ESP_LOGE(TAG, "Failed to create timeout timer: %s", esp_err_to_name(ret));
        }
    }
}

// Processa heartbeat recebido conforme v2.2.0
void mqtt_momentary_handle_heartbeat(const char *payload)
{
    if (!payload) {
        ESP_LOGE(TAG, "Heartbeat payload is NULL");
        mqtt_publish_error(MQTT_ERR_INVALID_PAYLOAD, "Null heartbeat payload");
        return;
    }
    
    cJSON *root = cJSON_Parse(payload);
    if (!root) {
        ESP_LOGE(TAG, "Failed to parse heartbeat JSON");
        mqtt_publish_error(MQTT_ERR_INVALID_PAYLOAD, "Invalid heartbeat JSON format");
        return;
    }
    
    // Validar protocol version
    if (!mqtt_validate_protocol_version(root)) {
        mqtt_publish_protocol_mismatch_error(cJSON_GetObjectItem(root, "protocol_version") ? 
                                           cJSON_GetObjectItem(root, "protocol_version")->valuestring : "missing");
        cJSON_Delete(root);
        return;
    }
    
    // Extrair campos obrigatórios
    cJSON *channel_json = cJSON_GetObjectItem(root, "channel");
    cJSON *source_json = cJSON_GetObjectItem(root, "source_uuid");
    cJSON *sequence_json = cJSON_GetObjectItem(root, "sequence");
    
    if (!channel_json || !cJSON_IsNumber(channel_json) ||
        !source_json || !cJSON_IsString(source_json) ||
        !sequence_json || !cJSON_IsNumber(sequence_json)) {
        ESP_LOGE(TAG, "Missing required heartbeat fields");
        mqtt_publish_invalid_command_error("heartbeat", "missing required fields");
        cJSON_Delete(root);
        return;
    }
    
    int channel = channel_json->valueint;
    const char *source_uuid = source_json->valuestring;
    int sequence = sequence_json->valueint;
    
    // Validar canal
    if (channel < 1 || channel > 16) {
        ESP_LOGE(TAG, "Invalid channel: %d", channel);
        mqtt_publish_invalid_channel_error(channel);
        cJSON_Delete(root);
        return;
    }
    
    // Processar heartbeat
    if (xSemaphoreTake(momentary_mutex, pdMS_TO_TICKS(100)) == pdTRUE) {
        heartbeat_monitor_t *monitor = &monitors[channel - 1];
        
        if (!monitor->active || strcmp(monitor->source_uuid, source_uuid) != 0) {
            // Novo heartbeat ou nova fonte
            monitor->active = true;
            monitor->channel = channel;
            strncpy(monitor->source_uuid, source_uuid, sizeof(monitor->source_uuid) - 1);
            monitor->source_uuid[sizeof(monitor->source_uuid) - 1] = '\0';
            ESP_LOGI(TAG, "Started heartbeat monitoring for channel %d from %s", 
                     channel, source_uuid);
        }
        
        // Verificar sequência
        if (monitor->sequence > 0 && sequence != monitor->sequence + 1) {
            ESP_LOGW(TAG, "Heartbeat sequence gap. Expected %" PRIu32 ", got %d", 
                     monitor->sequence + 1, sequence);
        }
        
        monitor->sequence = sequence;
        monitor->last_received = esp_timer_get_time() / 1000; // Converter para ms
        
        // Manter relé ligado se for momentâneo
        // TODO: Verificar se é relé momentâneo via relay_control
        relay_turn_on(channel - 1); // relay_control usa índice 0-based
        
        xSemaphoreGive(momentary_mutex);
    } else {
        ESP_LOGE(TAG, "Failed to acquire mutex for heartbeat processing");
    }
    
    cJSON_Delete(root);
}

// Verifica timeouts de heartbeat
void mqtt_momentary_check_timeouts(void)
{
    if (xSemaphoreTake(momentary_mutex, pdMS_TO_TICKS(10)) != pdTRUE) {
        return; // Skip se não conseguir o mutex rapidamente
    }
    
    uint32_t now = esp_timer_get_time() / 1000; // ms
    
    for (int i = 0; i < 16; i++) {
        heartbeat_monitor_t *monitor = &monitors[i];
        
        if (monitor->active) {
            uint32_t elapsed = now - monitor->last_received;
            
            if (elapsed > HEARTBEAT_TIMEOUT_MS) {
                int channel = i + 1;
                
                ESP_LOGW(TAG, "Heartbeat timeout on channel %d (elapsed: %" PRIu32 "ms)", 
                         channel, elapsed);
                
                // SAFETY SHUTOFF!
                relay_turn_off(i); // relay_control usa índice 0-based
                
                // Publicar evento de safety shutoff
                mqtt_publish_safety_shutoff_event(channel, monitor->source_uuid, 
                                                 monitor->last_received);
                
                // Publicar erro de timeout
                mqtt_publish_heartbeat_timeout_error(channel, elapsed);
                
                // Resetar monitor
                monitor->active = false;
                monitor->source_uuid[0] = '\0';
                monitor->sequence = 0;
                monitor->last_received = 0;
                
                ESP_LOGE(TAG, "Safety shutoff executed on channel %d", channel);
            }
        }
    }
    
    xSemaphoreGive(momentary_mutex);
}

// Reseta monitor de heartbeat para um canal
void mqtt_momentary_reset_channel(uint8_t channel)
{
    if (channel < 1 || channel > 16) {
        ESP_LOGE(TAG, "Invalid channel for reset: %d", channel);
        return;
    }
    
    if (xSemaphoreTake(momentary_mutex, pdMS_TO_TICKS(100)) == pdTRUE) {
        heartbeat_monitor_t *monitor = &monitors[channel - 1];
        monitor->active = false;
        monitor->source_uuid[0] = '\0';
        monitor->sequence = 0;
        monitor->last_received = 0;
        
        ESP_LOGI(TAG, "Reset heartbeat monitor for channel %d", channel);
        xSemaphoreGive(momentary_mutex);
    } else {
        ESP_LOGE(TAG, "Failed to acquire mutex for channel reset");
    }
}

// Callback do timer global de verificação
static void timeout_check_callback(void *arg)
{
    mqtt_momentary_check_timeouts();
}

// Para monitoramento de relé momentâneo (compatibilidade)
esp_err_t mqtt_momentary_stop(int channel)
{
    if (channel < 1 || channel > 16) {
        return ESP_ERR_INVALID_ARG;
    }
    
    mqtt_momentary_reset_channel(channel);
    return ESP_OK;
}

// Ativa monitoramento (compatibilidade)
esp_err_t mqtt_momentary_start(int channel)
{
    if (channel < 1 || channel > 16) {
        ESP_LOGE(TAG, "Invalid channel: %d", channel);
        return ESP_ERR_INVALID_ARG;
    }
    
    // O monitoramento agora é ativado automaticamente quando heartbeat é recebido
    ESP_LOGI(TAG, "Momentary monitoring ready for channel %d", channel);
    return ESP_OK;
}

// Processa heartbeat para canal específico (compatibilidade)
esp_err_t mqtt_momentary_heartbeat(int channel)
{
    if (channel < 1 || channel > 16) {
        ESP_LOGE(TAG, "Invalid channel for heartbeat: %d", channel);
        return ESP_ERR_INVALID_ARG;
    }
    
    // Criar JSON simulado para usar a função principal
    cJSON *json = cJSON_CreateObject();
    if (!json) {
        ESP_LOGE(TAG, "Failed to create JSON for heartbeat");
        return ESP_ERR_NO_MEM;
    }
    
    cJSON_AddNumberToObject(json, "channel", channel);
    cJSON_AddStringToObject(json, "source_uuid", "legacy_interface");
    cJSON_AddNumberToObject(json, "sequence", 1);
    
    char *json_string = cJSON_Print(json);
    if (json_string) {
        mqtt_momentary_handle_heartbeat(json_string);
        free(json_string);
    }
    
    cJSON_Delete(json);
    
    ESP_LOGD(TAG, "Heartbeat processed for channel %d via compatibility interface", channel);
    return ESP_OK;
}

// Legacy callback (manter compatibilidade)
static void momentary_check_timer_cb(void* arg)
{
    // Não usado na nova implementação v2.2.0
    // Mantido para compatibilidade
}