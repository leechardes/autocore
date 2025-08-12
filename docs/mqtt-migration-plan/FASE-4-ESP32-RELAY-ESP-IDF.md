# 🔧 FASE 4: Correção do ESP32-Relay-ESP-IDF - MQTT v2.2.0

## 📊 Resumo
- **Componente**: ESP32 Relay (ESP-IDF Framework)
- **Criticidade**: MÉDIA (implementação nativa)
- **Violações identificadas**: 7
- **Esforço estimado**: 8-10 horas
- **Prioridade**: P1 (Paralelo com ESP32-Relay PlatformIO)

## 🔍 Análise de Violações

### 1. Tópicos Incorretos
**Arquivo**: `firmware/esp32-relay-esp-idf/components/network/src/mqtt_handler.c`
**Linhas**: 337, 369, 455

#### Atual (INCORRETO):
```c
// mqtt_handler.c
static void mqtt_subscribe_topics(void) {
    char topic[128];
    
    // Tópicos incorretos
    snprintf(topic, sizeof(topic), "autocore/devices/%s/relay/command", 
             config->device_id);
    esp_mqtt_client_subscribe(client, topic, 1);
    
    snprintf(topic, sizeof(topic), "autocore/devices/%s/relay/status", 
             config->device_id);
    esp_mqtt_client_subscribe(client, topic, 1);
    
    snprintf(topic, sizeof(topic), "autocore/devices/%s/config", 
             config->device_id);
    esp_mqtt_client_subscribe(client, topic, 2);  // Config via MQTT!
}

void mqtt_publish_relay_state(void) {
    char topic[128];
    snprintf(topic, sizeof(topic), "%s/devices/%s/relay/state", 
             config->mqtt_topic_prefix, config->device_id);
    
    // Payload sem UUID
    char payload[256];
    snprintf(payload, sizeof(payload), 
             "{\"channels\":{\"1\":%s,\"2\":%s}}", 
             relay_states[0] ? "true" : "false",
             relay_states[1] ? "true" : "false");
    
    esp_mqtt_client_publish(client, topic, payload, strlen(payload), 1, true);
}
```

#### Correção (v2.2.0):
```c
// mqtt_handler.c
static void mqtt_subscribe_topics(void) {
    char topic[128];
    
    // Tópicos corrigidos conforme v2.2.0
    snprintf(topic, sizeof(topic), "autocore/devices/%s/relays/set", 
             config->device_id);
    esp_mqtt_client_subscribe(client, topic, 1);
    
    snprintf(topic, sizeof(topic), "autocore/devices/%s/relays/heartbeat", 
             config->device_id);
    esp_mqtt_client_subscribe(client, topic, 1);
    
    // Comandos globais
    esp_mqtt_client_subscribe(client, "autocore/commands/all/+", 1);
    
    // Sistema broadcast
    esp_mqtt_client_subscribe(client, "autocore/system/broadcast", 0);
    
    // NÃO subscrever config - deve vir da API REST
    
    ESP_LOGI(TAG, "Subscribed to v2.2.0 compliant topics");
}

void mqtt_publish_relay_state(void) {
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/relays/state", 
             config->device_id);
    
    // Criar payload JSON com cJSON
    cJSON *root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "protocol_version", "2.2.0");
    cJSON_AddStringToObject(root, "uuid", config->device_id);
    cJSON_AddNumberToObject(root, "board_id", config->board_id);
    cJSON_AddStringToObject(root, "timestamp", get_iso_timestamp());
    
    cJSON *channels = cJSON_CreateObject();
    char channel_str[4];
    for (int i = 0; i < config->num_channels; i++) {
        snprintf(channel_str, sizeof(channel_str), "%d", i + 1);
        cJSON_AddBoolToObject(channels, channel_str, relay_states[i]);
    }
    cJSON_AddItemToObject(root, "channels", channels);
    
    char *payload = cJSON_PrintUnformatted(root);
    esp_mqtt_client_publish(client, topic, payload, strlen(payload), 1, true);
    
    cJSON_Delete(root);
    free(payload);
}
```

### 2. Falta Protocol Version em Todos os Payloads
**Arquivo**: `firmware/esp32-relay-esp-idf/components/network/include/mqtt_protocol.h`
**Novo arquivo necessário**

```c
// mqtt_protocol.h - Novo header para protocolo v2.2.0
#ifndef MQTT_PROTOCOL_H
#define MQTT_PROTOCOL_H

#include "cJSON.h"
#include <time.h>

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

// Estrutura base para mensagens MQTT
typedef struct {
    const char *protocol_version;
    const char *uuid;
    char timestamp[32];
} mqtt_base_message_t;

// Funções auxiliares
void mqtt_init_base_message(mqtt_base_message_t *msg, const char *uuid);
cJSON* mqtt_create_base_json(const mqtt_base_message_t *msg);
bool mqtt_validate_protocol_version(cJSON *root);
char* get_iso_timestamp(void);
char* get_iso_timestamp_from_time(time_t timestamp);

// Códigos de erro padronizados
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

const char* mqtt_error_code_to_string(mqtt_error_code_t code);
const char* mqtt_error_type_to_string(mqtt_error_code_t code);

#endif // MQTT_PROTOCOL_H
```

```c
// mqtt_protocol.c - Implementação
#include "mqtt_protocol.h"
#include "esp_log.h"

static const char *TAG = "MQTT_PROTOCOL";

void mqtt_init_base_message(mqtt_base_message_t *msg, const char *uuid) {
    msg->protocol_version = MQTT_PROTOCOL_VERSION;
    msg->uuid = uuid;
    strcpy(msg->timestamp, get_iso_timestamp());
}

cJSON* mqtt_create_base_json(const mqtt_base_message_t *msg) {
    cJSON *root = cJSON_CreateObject();
    if (!root) return NULL;
    
    cJSON_AddStringToObject(root, "protocol_version", msg->protocol_version);
    cJSON_AddStringToObject(root, "uuid", msg->uuid);
    cJSON_AddStringToObject(root, "timestamp", msg->timestamp);
    
    return root;
}

bool mqtt_validate_protocol_version(cJSON *root) {
    cJSON *version = cJSON_GetObjectItem(root, "protocol_version");
    if (!version || !cJSON_IsString(version)) {
        ESP_LOGE(TAG, "Missing protocol_version");
        return false;
    }
    
    // Verificar se é versão 2.x.x
    if (strncmp(version->valuestring, "2.", 2) != 0) {
        ESP_LOGE(TAG, "Incompatible protocol version: %s", version->valuestring);
        return false;
    }
    
    return true;
}

char* get_iso_timestamp(void) {
    static char timestamp[32];
    time_t now;
    time(&now);
    struct tm *tm_info = gmtime(&now);
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%dT%H:%M:%SZ", tm_info);
    return timestamp;
}

const char* mqtt_error_code_to_string(mqtt_error_code_t code) {
    switch (code) {
        case MQTT_ERR_COMMAND_FAILED: return "ERR_001";
        case MQTT_ERR_INVALID_PAYLOAD: return "ERR_002";
        case MQTT_ERR_TIMEOUT: return "ERR_003";
        case MQTT_ERR_UNAUTHORIZED: return "ERR_004";
        case MQTT_ERR_DEVICE_BUSY: return "ERR_005";
        case MQTT_ERR_HARDWARE_FAULT: return "ERR_006";
        case MQTT_ERR_NETWORK_ERROR: return "ERR_007";
        case MQTT_ERR_PROTOCOL_MISMATCH: return "ERR_008";
        default: return "ERR_UNKNOWN";
    }
}
```

### 3. Heartbeat Momentâneo Não Implementado
**Arquivo**: `firmware/esp32-relay-esp-idf/components/network/src/mqtt_momentary.c`
**Novo arquivo**

```c
// mqtt_momentary.h
#ifndef MQTT_MOMENTARY_H
#define MQTT_MOMENTARY_H

#include <stdbool.h>
#include <stdint.h>

// Estrutura para monitorar heartbeat
typedef struct {
    bool active;
    uint32_t last_received;
    char source_uuid[64];
    uint32_t sequence;
} heartbeat_monitor_t;

// Funções de heartbeat
void mqtt_momentary_init(void);
void mqtt_momentary_handle_heartbeat(const char *payload);
void mqtt_momentary_check_timeouts(void);
void mqtt_momentary_reset_channel(uint8_t channel);

#endif

// mqtt_momentary.c
#include "mqtt_momentary.h"
#include "mqtt_handler.h"
#include "relay_control.h"
#include "cJSON.h"
#include "esp_log.h"
#include "esp_timer.h"

static const char *TAG = "MQTT_MOMENTARY";

static heartbeat_monitor_t monitors[MAX_RELAY_CHANNELS];
static esp_timer_handle_t timeout_timer = NULL;

static void timeout_check_callback(void *arg) {
    mqtt_momentary_check_timeouts();
}

void mqtt_momentary_init(void) {
    memset(monitors, 0, sizeof(monitors));
    
    // Criar timer para verificar timeouts
    esp_timer_create_args_t timer_args = {
        .callback = timeout_check_callback,
        .name = "heartbeat_timeout"
    };
    
    ESP_ERROR_CHECK(esp_timer_create(&timer_args, &timeout_timer));
    ESP_ERROR_CHECK(esp_timer_start_periodic(timeout_timer, 100000)); // 100ms
}

void mqtt_momentary_handle_heartbeat(const char *payload) {
    cJSON *root = cJSON_Parse(payload);
    if (!root) {
        ESP_LOGE(TAG, "Failed to parse heartbeat JSON");
        mqtt_publish_error(MQTT_ERR_INVALID_PAYLOAD, "Invalid heartbeat format");
        return;
    }
    
    // Validar protocol version
    if (!mqtt_validate_protocol_version(root)) {
        mqtt_publish_error(MQTT_ERR_PROTOCOL_MISMATCH, "Invalid protocol version");
        cJSON_Delete(root);
        return;
    }
    
    // Extrair campos
    cJSON *channel_json = cJSON_GetObjectItem(root, "channel");
    cJSON *source_json = cJSON_GetObjectItem(root, "source_uuid");
    cJSON *sequence_json = cJSON_GetObjectItem(root, "sequence");
    
    if (!channel_json || !cJSON_IsNumber(channel_json) ||
        !source_json || !cJSON_IsString(source_json) ||
        !sequence_json || !cJSON_IsNumber(sequence_json)) {
        ESP_LOGE(TAG, "Missing required heartbeat fields");
        mqtt_publish_error(MQTT_ERR_INVALID_PAYLOAD, "Missing heartbeat fields");
        cJSON_Delete(root);
        return;
    }
    
    int channel = channel_json->valueint;
    const char *source_uuid = source_json->valuestring;
    int sequence = sequence_json->valueint;
    
    // Validar canal
    if (channel < 1 || channel > MAX_RELAY_CHANNELS) {
        ESP_LOGE(TAG, "Invalid channel: %d", channel);
        mqtt_publish_error(MQTT_ERR_COMMAND_FAILED, "Invalid channel number");
        cJSON_Delete(root);
        return;
    }
    
    // Atualizar monitor
    heartbeat_monitor_t *monitor = &monitors[channel - 1];
    
    if (!monitor->active || strcmp(monitor->source_uuid, source_uuid) != 0) {
        // Novo heartbeat ou nova fonte
        monitor->active = true;
        strncpy(monitor->source_uuid, source_uuid, sizeof(monitor->source_uuid) - 1);
        ESP_LOGI(TAG, "Started heartbeat monitoring for channel %d from %s", 
                 channel, source_uuid);
    }
    
    // Verificar sequência
    if (monitor->sequence > 0 && sequence != monitor->sequence + 1) {
        ESP_LOGW(TAG, "Heartbeat sequence gap. Expected %d, got %d", 
                 monitor->sequence + 1, sequence);
    }
    
    monitor->sequence = sequence;
    monitor->last_received = esp_timer_get_time() / 1000; // Converter para ms
    
    // Manter relé ligado se for momentâneo
    if (relay_get_function_type(channel) == RELAY_MOMENTARY) {
        relay_set_state(channel, true);
    }
    
    cJSON_Delete(root);
}

void mqtt_momentary_check_timeouts(void) {
    uint32_t now = esp_timer_get_time() / 1000; // ms
    
    for (int i = 0; i < MAX_RELAY_CHANNELS; i++) {
        heartbeat_monitor_t *monitor = &monitors[i];
        
        if (monitor->active) {
            uint32_t elapsed = now - monitor->last_received;
            
            if (elapsed > HEARTBEAT_TIMEOUT_MS) {
                int channel = i + 1;
                
                ESP_LOGW(TAG, "Heartbeat timeout on channel %d (elapsed: %dms)", 
                         channel, elapsed);
                
                // SAFETY SHUTOFF!
                if (relay_get_function_type(channel) == RELAY_MOMENTARY) {
                    relay_set_state(channel, false);
                    
                    // Publicar evento de safety shutoff
                    mqtt_publish_safety_shutoff(channel, monitor->source_uuid, 
                                               monitor->last_received);
                }
                
                // Resetar monitor
                monitor->active = false;
                monitor->source_uuid[0] = '\0';
                monitor->sequence = 0;
            }
        }
    }
}

void mqtt_momentary_reset_channel(uint8_t channel) {
    if (channel > 0 && channel <= MAX_RELAY_CHANNELS) {
        heartbeat_monitor_t *monitor = &monitors[channel - 1];
        monitor->active = false;
        monitor->source_uuid[0] = '\0';
        monitor->sequence = 0;
        
        ESP_LOGI(TAG, "Reset heartbeat monitor for channel %d", channel);
    }
}
```

### 4. Last Will Testament Não Configurado
**Arquivo**: `firmware/esp32-relay-esp-idf/components/network/src/mqtt_handler.c`

#### Atual:
```c
esp_mqtt_client_config_t mqtt_cfg = {
    .uri = CONFIG_BROKER_URL,
    .client_id = config->device_id,
};
```

#### Correção:
```c
static char lwt_payload[512];

static void prepare_lwt_message(void) {
    cJSON *root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(root, "uuid", config->device_id);
    cJSON_AddStringToObject(root, "status", "offline");
    cJSON_AddStringToObject(root, "timestamp", get_iso_timestamp());
    cJSON_AddStringToObject(root, "reason", "unexpected_disconnect");
    cJSON_AddStringToObject(root, "last_seen", get_iso_timestamp());
    
    char *json_str = cJSON_PrintUnformatted(root);
    strncpy(lwt_payload, json_str, sizeof(lwt_payload) - 1);
    
    cJSON_Delete(root);
    free(json_str);
}

esp_err_t mqtt_client_init(void) {
    char lwt_topic[128];
    snprintf(lwt_topic, sizeof(lwt_topic), "autocore/devices/%s/status", 
             config->device_id);
    
    prepare_lwt_message();
    
    esp_mqtt_client_config_t mqtt_cfg = {
        .uri = CONFIG_BROKER_URL,
        .client_id = config->device_id,
        // Configurar Last Will Testament
        .lwt_topic = lwt_topic,
        .lwt_msg = lwt_payload,
        .lwt_qos = 1,
        .lwt_retain = true,
        .lwt_msg_len = strlen(lwt_payload),
        // Outros parâmetros
        .keepalive = 60,
        .disable_clean_session = false,
        .task_stack = 4096,
        .buffer_size = 1024
    };
    
    client = esp_mqtt_client_init(&mqtt_cfg);
    
    if (client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize MQTT client");
        return ESP_FAIL;
    }
    
    esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID, 
                                   mqtt_event_handler, NULL);
    
    ESP_LOGI(TAG, "MQTT client initialized with LWT");
    return ESP_OK;
}

// Publicar status online após conectar
static void mqtt_publish_online_status(void) {
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/status", 
             config->device_id);
    
    cJSON *root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(root, "uuid", config->device_id);
    cJSON_AddStringToObject(root, "status", "online");
    cJSON_AddStringToObject(root, "timestamp", get_iso_timestamp());
    cJSON_AddStringToObject(root, "firmware_version", APP_VERSION);
    cJSON_AddStringToObject(root, "ip_address", get_ip_address());
    cJSON_AddNumberToObject(root, "wifi_signal", get_wifi_rssi());
    cJSON_AddNumberToObject(root, "free_memory", esp_get_free_heap_size());
    cJSON_AddNumberToObject(root, "uptime", esp_timer_get_time() / 1000000);
    
    char *payload = cJSON_PrintUnformatted(root);
    esp_mqtt_client_publish(client, topic, payload, strlen(payload), 1, true);
    
    cJSON_Delete(root);
    free(payload);
}
```

### 5. Telemetria com UUID no Tópico
**Arquivo**: `firmware/esp32-relay-esp-idf/components/network/src/mqtt_telemetry.c`

#### Atual:
```c
void mqtt_publish_telemetry(void) {
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/telemetry", 
             config->device_id);
    // ...
}
```

#### Correção:
```c
// mqtt_telemetry.c
void mqtt_publish_telemetry(void) {
    // UUID agora só no payload, não no tópico
    const char *topic = "autocore/telemetry/relays/data";
    
    cJSON *root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(root, "uuid", config->device_id);  // UUID aqui!
    cJSON_AddNumberToObject(root, "board_id", config->board_id);
    cJSON_AddStringToObject(root, "timestamp", get_iso_timestamp());
    
    // Métricas do sistema
    cJSON *metrics = cJSON_CreateObject();
    cJSON_AddNumberToObject(metrics, "uptime", esp_timer_get_time() / 1000000);
    cJSON_AddNumberToObject(metrics, "free_heap", esp_get_free_heap_size());
    cJSON_AddNumberToObject(metrics, "wifi_rssi", get_wifi_rssi());
    cJSON_AddNumberToObject(metrics, "temperature", read_internal_temperature());
    cJSON_AddItemToObject(root, "metrics", metrics);
    
    // Estados dos relés
    cJSON *channels = cJSON_CreateObject();
    char channel_str[4];
    for (int i = 0; i < config->num_channels; i++) {
        snprintf(channel_str, sizeof(channel_str), "%d", i + 1);
        
        cJSON *channel_obj = cJSON_CreateObject();
        cJSON_AddBoolToObject(channel_obj, "state", relay_get_state(i + 1));
        cJSON_AddStringToObject(channel_obj, "function_type", 
                              relay_get_function_type_string(i + 1));
        cJSON_AddNumberToObject(channel_obj, "activation_count", 
                              relay_get_activation_count(i + 1));
        
        cJSON_AddItemToObject(channels, channel_str, channel_obj);
    }
    cJSON_AddItemToObject(root, "channels", channels);
    
    char *payload = cJSON_PrintUnformatted(root);
    
    // QoS 0 para telemetria
    esp_mqtt_client_publish(client, topic, payload, strlen(payload), 0, false);
    
    cJSON_Delete(root);
    free(payload);
}

// Publicar evento de mudança de relé
void mqtt_publish_relay_event(uint8_t channel, bool state, const char *trigger) {
    const char *topic = "autocore/telemetry/relays/data";
    
    cJSON *root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(root, "uuid", config->device_id);
    cJSON_AddNumberToObject(root, "board_id", config->board_id);
    cJSON_AddStringToObject(root, "timestamp", get_iso_timestamp());
    cJSON_AddStringToObject(root, "event", "relay_change");
    cJSON_AddNumberToObject(root, "channel", channel);
    cJSON_AddBoolToObject(root, "state", state);
    cJSON_AddStringToObject(root, "trigger", trigger);
    
    char *payload = cJSON_PrintUnformatted(root);
    esp_mqtt_client_publish(client, topic, payload, strlen(payload), 0, false);
    
    cJSON_Delete(root);
    free(payload);
}
```

### 6. Tratamento de Erros
**Arquivo**: `firmware/esp32-relay-esp-idf/components/network/src/mqtt_errors.c`
**Novo arquivo**

```c
// mqtt_errors.c
#include "mqtt_errors.h"
#include "mqtt_handler.h"
#include "mqtt_protocol.h"
#include "cJSON.h"
#include "esp_log.h"

static const char *TAG = "MQTT_ERRORS";

void mqtt_publish_error(mqtt_error_code_t code, const char *message) {
    mqtt_publish_error_with_context(code, message, NULL);
}

void mqtt_publish_error_with_context(mqtt_error_code_t code, 
                                    const char *message, 
                                    cJSON *context) {
    char topic[128];
    const char *error_type = mqtt_error_type_to_string(code);
    
    snprintf(topic, sizeof(topic), "autocore/errors/%s/%s", 
             config->device_id, error_type);
    
    // Criar payload de erro
    cJSON *root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(root, "uuid", config->device_id);
    cJSON_AddStringToObject(root, "error_code", mqtt_error_code_to_string(code));
    cJSON_AddStringToObject(root, "error_type", error_type);
    cJSON_AddStringToObject(root, "error_message", message);
    cJSON_AddStringToObject(root, "timestamp", get_iso_timestamp());
    
    if (context) {
        cJSON_AddItemToObject(root, "context", cJSON_Duplicate(context, true));
    }
    
    char *payload = cJSON_PrintUnformatted(root);
    
    // Publicar com QoS 1
    esp_mqtt_client_publish(client, topic, payload, strlen(payload), 1, false);
    
    ESP_LOGE(TAG, "%s: %s", mqtt_error_code_to_string(code), message);
    
    cJSON_Delete(root);
    free(payload);
}

void mqtt_publish_safety_shutoff(uint8_t channel, const char *source_uuid, 
                                uint32_t last_heartbeat) {
    const char *topic = "autocore/telemetry/relays/data";
    
    cJSON *root = cJSON_CreateObject();
    cJSON_AddStringToObject(root, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(root, "uuid", config->device_id);
    cJSON_AddNumberToObject(root, "board_id", config->board_id);
    cJSON_AddStringToObject(root, "event", "safety_shutoff");
    cJSON_AddNumberToObject(root, "channel", channel);
    cJSON_AddStringToObject(root, "reason", "heartbeat_timeout");
    cJSON_AddNumberToObject(root, "timeout_ms", HEARTBEAT_TIMEOUT_MS);
    cJSON_AddStringToObject(root, "source_uuid", source_uuid);
    
    // Converter last_heartbeat para timestamp ISO
    time_t last_time = last_heartbeat / 1000;
    cJSON_AddStringToObject(root, "last_heartbeat", 
                           get_iso_timestamp_from_time(last_time));
    cJSON_AddStringToObject(root, "timestamp", get_iso_timestamp());
    
    char *payload = cJSON_PrintUnformatted(root);
    esp_mqtt_client_publish(client, topic, payload, strlen(payload), 1, false);
    
    ESP_LOGW(TAG, "Safety shutoff on channel %d - heartbeat timeout", channel);
    
    cJSON_Delete(root);
    free(payload);
}
```

### 7. Configuração via API REST
**Arquivo**: `firmware/esp32-relay-esp-idf/components/config_manager/src/config_manager.c`

```c
// config_manager.c - Adicionar busca de config via API
#include "esp_http_client.h"

esp_err_t config_fetch_from_api(void) {
    char url[256];
    snprintf(url, sizeof(url), "http://%s/api/devices/%s/config", 
             CONFIG_API_HOST, config->device_id);
    
    esp_http_client_config_t http_config = {
        .url = url,
        .timeout_ms = 5000,
        .method = HTTP_METHOD_GET,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    
    esp_err_t err = esp_http_client_perform(client);
    
    if (err == ESP_OK) {
        int status_code = esp_http_client_get_status_code(client);
        
        if (status_code == 200) {
            int content_length = esp_http_client_get_content_length(client);
            char *buffer = malloc(content_length + 1);
            
            esp_http_client_read(client, buffer, content_length);
            buffer[content_length] = '\0';
            
            // Parse e aplicar configuração
            config_apply_json(buffer);
            
            free(buffer);
            ESP_LOGI(TAG, "Configuration fetched from API successfully");
        } else {
            ESP_LOGE(TAG, "Failed to fetch config. Status: %d", status_code);
            err = ESP_FAIL;
        }
    }
    
    esp_http_client_cleanup(client);
    return err;
}
```

## 📝 Implementação Passo a Passo

### Passo 1: Criar Estrutura de Protocol v2.2.0
```bash
cd firmware/esp32-relay-esp-idf
# Criar novos arquivos
touch components/network/include/mqtt_protocol.h
touch components/network/src/mqtt_protocol.c
touch components/network/include/mqtt_errors.h
touch components/network/src/mqtt_errors.c
```

### Passo 2: Atualizar CMakeLists.txt
```cmake
# components/network/CMakeLists.txt
idf_component_register(
    SRCS "src/mqtt_handler.c"
         "src/mqtt_protocol.c"
         "src/mqtt_momentary.c"
         "src/mqtt_telemetry.c"
         "src/mqtt_errors.c"
         "src/wifi_manager.c"
    INCLUDE_DIRS "include"
    REQUIRES mqtt esp_http_client json
)
```

### Passo 3: Corrigir Tópicos
1. Atualizar mqtt_handler.c
2. Trocar relay/ por relays/
3. Remover subscrição de config

### Passo 4: Implementar Heartbeat
1. Criar mqtt_momentary.c/h
2. Adicionar timer de verificação
3. Implementar safety shutoff

### Passo 5: Configurar LWT
1. Modificar mqtt_client_init()
2. Adicionar payload de LWT
3. Publicar status online

### Passo 6: Testes
```c
// test/test_mqtt_protocol.c
#include "unity.h"
#include "mqtt_protocol.h"

void test_protocol_version(void) {
    mqtt_base_message_t msg;
    mqtt_init_base_message(&msg, "esp32-relay-001");
    
    TEST_ASSERT_EQUAL_STRING("2.2.0", msg.protocol_version);
    TEST_ASSERT_EQUAL_STRING("esp32-relay-001", msg.uuid);
    TEST_ASSERT_NOT_NULL(msg.timestamp);
}

void test_heartbeat_timeout(void) {
    // Simular heartbeat
    const char *heartbeat = "{\"protocol_version\":\"2.2.0\","
                           "\"channel\":1,"
                           "\"source_uuid\":\"test-001\","
                           "\"sequence\":1}";
    
    mqtt_momentary_handle_heartbeat(heartbeat);
    
    // Esperar timeout
    vTaskDelay(pdMS_TO_TICKS(1100));
    
    mqtt_momentary_check_timeouts();
    
    // Verificar se relé foi desligado
    TEST_ASSERT_FALSE(relay_get_state(1));
}

void app_main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_protocol_version);
    RUN_TEST(test_heartbeat_timeout);
    UNITY_END();
}
```

## 🧪 Validação

### Build e Flash
```bash
# Configurar projeto
idf.py menuconfig

# Compilar
idf.py build

# Flash
idf.py -p /dev/ttyUSB0 flash

# Monitor
idf.py -p /dev/ttyUSB0 monitor
```

### Checklist
- [ ] Tópicos seguem padrão v2.2.0
- [ ] Protocol version em todos os payloads
- [ ] Heartbeat com timeout funcionando
- [ ] LWT configurado
- [ ] Telemetria sem UUID no tópico
- [ ] Configuração via API REST
- [ ] Tratamento de erros padronizado

## 📊 Métricas de Sucesso
- ✅ 7/7 violações corrigidas
- ✅ Safety shutoff testado
- ✅ 100% conformidade v2.2.0
- ✅ Performance mantida

## 📝 Notas
- ESP-IDF tem melhor controle de memória
- Usar cJSON para manipulação JSON
- Testar exaustivamente safety shutoff
- Considerar watchdog timer

---
**Criado em**: 12/08/2025  
**Status**: Documentado  
**Estimativa**: 8-10 horas  
**Complexidade**: Média-Alta