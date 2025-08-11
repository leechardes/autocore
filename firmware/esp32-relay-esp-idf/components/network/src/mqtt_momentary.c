#include <string.h>
#include "mqtt_protocol.h"
#include "mqtt_telemetry.h"
#include "relay_control.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"

static const char *TAG = "MQTT_MOMENTARY";

// Estrutura para controlar relés momentâneos
typedef struct {
    bool active;                    // Se está ativo
    int channel;                     // Canal do relé (1-16)
    int64_t last_heartbeat;         // Timestamp do último heartbeat
    esp_timer_handle_t timer;        // Timer para verificação
} momentary_relay_t;

// Array para todos os canais
static momentary_relay_t momentary_relays[16];
static SemaphoreHandle_t momentary_mutex = NULL;

// Forward declaration
static void momentary_check_timer_cb(void* arg);

// Inicializa sistema de relés momentâneos
void mqtt_momentary_init(void)
{
    // Cria mutex para acesso thread-safe
    if (momentary_mutex == NULL) {
        momentary_mutex = xSemaphoreCreateMutex();
    }
    
    // Inicializa estruturas
    memset(momentary_relays, 0, sizeof(momentary_relays));
    
    ESP_LOGI(TAG, "Sistema de relés momentâneos inicializado");
}

// Ativa monitoramento de relé momentâneo
esp_err_t mqtt_momentary_start(int channel)
{
    if (channel < 1 || channel > 16) {
        ESP_LOGE(TAG, "Canal inválido: %d", channel);
        return ESP_ERR_INVALID_ARG;
    }
    
    int idx = channel - 1;
    
    if (xSemaphoreTake(momentary_mutex, pdMS_TO_TICKS(100)) != pdTRUE) {
        return ESP_ERR_TIMEOUT;
    }
    
    // Se já tem timer ativo, para ele primeiro
    if (momentary_relays[idx].timer != NULL) {
        esp_timer_stop(momentary_relays[idx].timer);
        esp_timer_delete(momentary_relays[idx].timer);
        momentary_relays[idx].timer = NULL;
    }
    
    // Configura novo monitoramento
    momentary_relays[idx].active = true;
    momentary_relays[idx].channel = channel;
    momentary_relays[idx].last_heartbeat = esp_timer_get_time() / 1000; // em ms
    
    // Cria timer para verificação periódica
    esp_timer_create_args_t timer_args = {
        .callback = &momentary_check_timer_cb,
        .arg = (void*)(intptr_t)channel,
        .name = "momentary_check"
    };
    
    esp_err_t ret = esp_timer_create(&timer_args, &momentary_relays[idx].timer);
    if (ret == ESP_OK) {
        ret = esp_timer_start_periodic(momentary_relays[idx].timer, 
                                       MOMENTARY_CHECK_INTERVAL_MS * 1000); // em us
        if (ret == ESP_OK) {
            ESP_LOGI(TAG, "✅ Monitoramento momentâneo iniciado para canal %d", channel);
        }
    }
    
    xSemaphoreGive(momentary_mutex);
    return ret;
}

// Para monitoramento de relé momentâneo
esp_err_t mqtt_momentary_stop(int channel)
{
    if (channel < 1 || channel > 16) {
        return ESP_ERR_INVALID_ARG;
    }
    
    int idx = channel - 1;
    
    if (xSemaphoreTake(momentary_mutex, pdMS_TO_TICKS(100)) != pdTRUE) {
        return ESP_ERR_TIMEOUT;
    }
    
    if (momentary_relays[idx].timer != NULL) {
        esp_timer_stop(momentary_relays[idx].timer);
        esp_timer_delete(momentary_relays[idx].timer);
        momentary_relays[idx].timer = NULL;
    }
    
    momentary_relays[idx].active = false;
    ESP_LOGI(TAG, "Monitoramento momentâneo parado para canal %d", channel);
    
    xSemaphoreGive(momentary_mutex);
    return ESP_OK;
}

// Atualiza heartbeat de relé momentâneo
esp_err_t mqtt_momentary_heartbeat(int channel)
{
    if (channel < 1 || channel > 16) {
        return ESP_ERR_INVALID_ARG;
    }
    
    int idx = channel - 1;
    
    if (xSemaphoreTake(momentary_mutex, pdMS_TO_TICKS(100)) != pdTRUE) {
        return ESP_ERR_TIMEOUT;
    }
    
    if (momentary_relays[idx].active) {
        momentary_relays[idx].last_heartbeat = esp_timer_get_time() / 1000; // em ms
        ESP_LOGD(TAG, "💓 Heartbeat recebido para canal %d", channel);
        
        // Se relé estava desligado, liga ele
        if (!relay_get_state(idx)) {
            relay_turn_on(idx);
            ESP_LOGI(TAG, "Relé %d religado por heartbeat", channel);
        }
    }
    
    xSemaphoreGive(momentary_mutex);
    return ESP_OK;
}

// Callback do timer de verificação
static void momentary_check_timer_cb(void* arg)
{
    int channel = (int)(intptr_t)arg;
    int idx = channel - 1;
    
    if (xSemaphoreTake(momentary_mutex, 0) != pdTRUE) {
        return; // Skip se não conseguir o mutex imediatamente
    }
    
    if (momentary_relays[idx].active) {
        int64_t now = esp_timer_get_time() / 1000; // em ms
        int64_t elapsed = now - momentary_relays[idx].last_heartbeat;
        
        if (elapsed > MOMENTARY_TIMEOUT_MS) {
            ESP_LOGW(TAG, "⚠️ Timeout de heartbeat no canal %d (%.1fs sem heartbeat)", 
                     channel, elapsed / 1000.0f);
            
            // Desliga o relé
            relay_turn_off(idx);
            
            // Publica safety shutoff
            mqtt_publish_safety_shutoff(channel, "heartbeat_timeout", MOMENTARY_TIMEOUT_MS / 1000.0f);
            
            // Para o monitoramento
            if (momentary_relays[idx].timer != NULL) {
                esp_timer_stop(momentary_relays[idx].timer);
                esp_timer_delete(momentary_relays[idx].timer);
                momentary_relays[idx].timer = NULL;
            }
            momentary_relays[idx].active = false;
            
            ESP_LOGE(TAG, "🛑 Relé %d desligado por segurança (timeout)", channel);
        }
    }
    
    xSemaphoreGive(momentary_mutex);
}