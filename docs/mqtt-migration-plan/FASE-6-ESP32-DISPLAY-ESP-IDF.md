# 📱 FASE 6: Implementação ESP32-Display-ESP-IDF - MQTT v2.2.0

## 📊 Resumo
- **Componente**: ESP32 Display (ESP-IDF nativo)
- **Criticidade**: BAIXA (ainda em desenvolvimento inicial)
- **Violações identificadas**: 4 (principalmente ausência de implementação)
- **Esforço estimado**: 12-16 horas
- **Prioridade**: P3 (Implementar do zero seguindo v2.2.0)

## 🎯 Estratégia
Como este projeto ainda está em fase inicial, é uma oportunidade para implementar MQTT v2.2.0 desde o início, sem necessidade de refatoração.

## 🔍 Análise Atual

### Estado Atual
- UI com LVGL implementada ✅
- Touch funcionando ✅
- MQTT não implementado ❌
- Estrutura básica pronta ✅

### Oportunidade
Implementar MQTT corretamente desde o início, servindo como referência para outros projetos.

## 📝 Implementação Completa MQTT v2.2.0

### 1. Criar Componente MQTT
**Novo arquivo**: `components/mqtt/CMakeLists.txt`

```cmake
idf_component_register(
    SRCS "src/mqtt_client.c"
         "src/mqtt_protocol.c"
         "src/mqtt_display.c"
         "src/mqtt_commands.c"
    INCLUDE_DIRS "include"
    REQUIRES mqtt esp_http_client json nvs_flash
)
```

### 2. Header Principal MQTT
**Novo arquivo**: `components/mqtt/include/mqtt_client.h`

```c
#ifndef MQTT_CLIENT_H
#define MQTT_CLIENT_H

#include "esp_mqtt_client.h"
#include "mqtt_protocol.h"

// Estados do cliente MQTT
typedef enum {
    MQTT_STATE_DISCONNECTED = 0,
    MQTT_STATE_CONNECTING,
    MQTT_STATE_CONNECTED,
    MQTT_STATE_ERROR
} mqtt_state_t;

// Estrutura principal do cliente
typedef struct {
    esp_mqtt_client_handle_t client;
    mqtt_state_t state;
    char device_uuid[64];
    uint32_t message_count;
    uint32_t error_count;
    bool initialized;
} mqtt_client_t;

// Funções públicas
esp_err_t mqtt_client_init(const char* broker_url, const char* device_uuid);
esp_err_t mqtt_client_start(void);
esp_err_t mqtt_client_stop(void);
esp_err_t mqtt_client_publish(const char* topic, const char* payload, 
                             int qos, bool retain);
esp_err_t mqtt_client_subscribe(const char* topic, int qos);
mqtt_state_t mqtt_client_get_state(void);

// Callbacks
typedef void (*mqtt_message_callback_t)(const char* topic, const char* payload);
void mqtt_client_register_callback(mqtt_message_callback_t callback);

#endif // MQTT_CLIENT_H
```

### 3. Implementação do Cliente MQTT
**Novo arquivo**: `components/mqtt/src/mqtt_client.c`

```c
#include "mqtt_client.h"
#include "mqtt_protocol.h"
#include "esp_log.h"
#include "cJSON.h"
#include <string.h>

static const char* TAG = "MQTT_CLIENT";
static mqtt_client_t mqtt_ctx = {0};
static mqtt_message_callback_t message_callback = NULL;

// Forward declarations
static void mqtt_event_handler(void* handler_args, esp_event_base_t base, 
                              int32_t event_id, void* event_data);
static void publish_online_status(void);
static void subscribe_to_topics(void);

esp_err_t mqtt_client_init(const char* broker_url, const char* device_uuid) {
    if (mqtt_ctx.initialized) {
        ESP_LOGW(TAG, "MQTT client already initialized");
        return ESP_OK;
    }
    
    // Copiar UUID do dispositivo
    strncpy(mqtt_ctx.device_uuid, device_uuid, sizeof(mqtt_ctx.device_uuid) - 1);
    
    // Preparar Last Will Testament
    char lwt_topic[128];
    snprintf(lwt_topic, sizeof(lwt_topic), "autocore/devices/%s/status", 
             device_uuid);
    
    // Criar payload LWT
    cJSON* lwt_json = cJSON_CreateObject();
    cJSON_AddStringToObject(lwt_json, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(lwt_json, "uuid", device_uuid);
    cJSON_AddStringToObject(lwt_json, "status", "offline");
    cJSON_AddStringToObject(lwt_json, "timestamp", mqtt_get_iso_timestamp());
    cJSON_AddStringToObject(lwt_json, "reason", "unexpected_disconnect");
    cJSON_AddStringToObject(lwt_json, "last_seen", mqtt_get_iso_timestamp());
    
    char* lwt_payload = cJSON_PrintUnformatted(lwt_json);
    cJSON_Delete(lwt_json);
    
    // Configurar cliente MQTT
    esp_mqtt_client_config_t mqtt_cfg = {
        .uri = broker_url,
        .client_id = device_uuid,
        .lwt_topic = lwt_topic,
        .lwt_msg = lwt_payload,
        .lwt_qos = 1,
        .lwt_retain = true,
        .lwt_msg_len = strlen(lwt_payload),
        .keepalive = 60,
        .task_stack = 8192,
        .buffer_size = 2048
    };
    
    mqtt_ctx.client = esp_mqtt_client_init(&mqtt_cfg);
    free(lwt_payload);
    
    if (mqtt_ctx.client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize MQTT client");
        return ESP_FAIL;
    }
    
    // Registrar event handler
    esp_mqtt_client_register_event(mqtt_ctx.client, ESP_EVENT_ANY_ID, 
                                   mqtt_event_handler, NULL);
    
    mqtt_ctx.initialized = true;
    mqtt_ctx.state = MQTT_STATE_DISCONNECTED;
    
    ESP_LOGI(TAG, "MQTT client initialized with v2.2.0 compliance");
    return ESP_OK;
}

static void mqtt_event_handler(void* handler_args, esp_event_base_t base, 
                              int32_t event_id, void* event_data) {
    esp_mqtt_event_handle_t event = event_data;
    
    switch (event->event_id) {
        case MQTT_EVENT_CONNECTED:
            ESP_LOGI(TAG, "Connected to MQTT broker");
            mqtt_ctx.state = MQTT_STATE_CONNECTED;
            
            // Publicar status online
            publish_online_status();
            
            // Subscrever aos tópicos
            subscribe_to_topics();
            break;
            
        case MQTT_EVENT_DISCONNECTED:
            ESP_LOGW(TAG, "Disconnected from MQTT broker");
            mqtt_ctx.state = MQTT_STATE_DISCONNECTED;
            break;
            
        case MQTT_EVENT_DATA:
            ESP_LOGD(TAG, "Received message on topic: %.*s", 
                    event->topic_len, event->topic);
            
            if (message_callback) {
                // Criar strings null-terminated
                char topic[256] = {0};
                char payload[2048] = {0};
                
                memcpy(topic, event->topic, MIN(event->topic_len, sizeof(topic) - 1));
                memcpy(payload, event->data, MIN(event->data_len, sizeof(payload) - 1));
                
                // Validar protocol_version
                cJSON* json = cJSON_Parse(payload);
                if (json) {
                    if (mqtt_validate_protocol_version(json)) {
                        message_callback(topic, payload);
                    } else {
                        ESP_LOGW(TAG, "Message without valid protocol_version");
                        mqtt_publish_error(MQTT_ERR_PROTOCOL_MISMATCH, 
                                         "Invalid protocol version", NULL);
                    }
                    cJSON_Delete(json);
                } else {
                    // Mensagem não é JSON, processar mesmo assim
                    message_callback(topic, payload);
                }
            }
            
            mqtt_ctx.message_count++;
            break;
            
        case MQTT_EVENT_ERROR:
            ESP_LOGE(TAG, "MQTT error: %d", event->error_handle->error_type);
            mqtt_ctx.state = MQTT_STATE_ERROR;
            mqtt_ctx.error_count++;
            break;
            
        default:
            break;
    }
}

static void publish_online_status(void) {
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/status", 
             mqtt_ctx.device_uuid);
    
    // Criar payload de status
    cJSON* status = cJSON_CreateObject();
    cJSON_AddStringToObject(status, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(status, "uuid", mqtt_ctx.device_uuid);
    cJSON_AddStringToObject(status, "status", "online");
    cJSON_AddStringToObject(status, "timestamp", mqtt_get_iso_timestamp());
    cJSON_AddStringToObject(status, "firmware_version", APP_VERSION);
    cJSON_AddStringToObject(status, "device_type", "esp32_display");
    cJSON_AddNumberToObject(status, "free_heap", esp_get_free_heap_size());
    cJSON_AddNumberToObject(status, "uptime", esp_timer_get_time() / 1000000);
    
    // Adicionar capacidades do display
    cJSON* capabilities = cJSON_CreateObject();
    cJSON_AddBoolToObject(capabilities, "touch", true);
    cJSON_AddBoolToObject(capabilities, "color", true);
    cJSON_AddStringToObject(capabilities, "resolution", "320x240");
    cJSON_AddStringToObject(capabilities, "display_type", "ILI9341");
    cJSON_AddItemToObject(status, "capabilities", capabilities);
    
    char* payload = cJSON_PrintUnformatted(status);
    cJSON_Delete(status);
    
    esp_mqtt_client_publish(mqtt_ctx.client, topic, payload, 
                           strlen(payload), 1, true);
    free(payload);
    
    ESP_LOGI(TAG, "Published online status");
}

static void subscribe_to_topics(void) {
    char topic[128];
    
    // Comandos específicos do display
    snprintf(topic, sizeof(topic), "autocore/devices/%s/display/screen", 
             mqtt_ctx.device_uuid);
    esp_mqtt_client_subscribe(mqtt_ctx.client, topic, 1);
    
    snprintf(topic, sizeof(topic), "autocore/devices/%s/display/config", 
             mqtt_ctx.device_uuid);
    esp_mqtt_client_subscribe(mqtt_ctx.client, topic, 1);
    
    // Estados de relés para exibir
    esp_mqtt_client_subscribe(mqtt_ctx.client, 
                            "autocore/devices/+/relays/state", 0);
    
    // Telemetria (sem UUID no tópico!)
    esp_mqtt_client_subscribe(mqtt_ctx.client, 
                            "autocore/telemetry/relays/data", 0);
    esp_mqtt_client_subscribe(mqtt_ctx.client, 
                            "autocore/telemetry/can/+", 0);
    esp_mqtt_client_subscribe(mqtt_ctx.client, 
                            "autocore/telemetry/sensors/+", 0);
    
    // Sistema
    esp_mqtt_client_subscribe(mqtt_ctx.client, 
                            "autocore/system/broadcast", 0);
    esp_mqtt_client_subscribe(mqtt_ctx.client, 
                            "autocore/system/alert", 1);
    
    // Erros para exibir
    esp_mqtt_client_subscribe(mqtt_ctx.client, 
                            "autocore/errors/+/+", 1);
    
    ESP_LOGI(TAG, "Subscribed to v2.2.0 compliant topics");
}

esp_err_t mqtt_client_publish(const char* topic, const char* payload, 
                             int qos, bool retain) {
    if (!mqtt_ctx.initialized || mqtt_ctx.state != MQTT_STATE_CONNECTED) {
        ESP_LOGW(TAG, "Cannot publish - not connected");
        return ESP_FAIL;
    }
    
    int msg_id = esp_mqtt_client_publish(mqtt_ctx.client, topic, payload, 
                                        strlen(payload), qos, retain);
    
    if (msg_id < 0) {
        ESP_LOGE(TAG, "Failed to publish to %s", topic);
        return ESP_FAIL;
    }
    
    ESP_LOGD(TAG, "Published to %s (msg_id: %d)", topic, msg_id);
    return ESP_OK;
}
```

### 4. Protocolo MQTT v2.2.0
**Novo arquivo**: `components/mqtt/include/mqtt_protocol.h`

```c
#ifndef MQTT_PROTOCOL_H
#define MQTT_PROTOCOL_H

#include <stdbool.h>
#include "cJSON.h"

#define MQTT_PROTOCOL_VERSION "2.2.0"

// QoS Levels
#define QOS_TELEMETRY    0
#define QOS_COMMANDS     1
#define QOS_HEARTBEAT    1
#define QOS_STATUS       1

// Timeouts
#define HEARTBEAT_TIMEOUT_MS     1000
#define HEARTBEAT_INTERVAL_MS    500

// Error codes
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

// Funções do protocolo
char* mqtt_get_iso_timestamp(void);
bool mqtt_validate_protocol_version(cJSON* json);
void mqtt_add_protocol_fields(cJSON* json, const char* uuid);
void mqtt_publish_error(mqtt_error_code_t code, const char* message, cJSON* context);

#endif // MQTT_PROTOCOL_H
```

### 5. Comandos do Display
**Novo arquivo**: `components/mqtt/src/mqtt_display.c`

```c
#include "mqtt_display.h"
#include "mqtt_client.h"
#include "mqtt_protocol.h"
#include "ui_manager.h"
#include "esp_log.h"

static const char* TAG = "MQTT_DISPLAY";

// Estrutura para comandos de display com heartbeat
typedef struct {
    bool active;
    uint32_t last_heartbeat;
    uint32_t sequence;
    char source_uuid[64];
    uint8_t channel;
} display_heartbeat_t;

static display_heartbeat_t heartbeats[16] = {0};

void mqtt_display_send_touch_event(int x, int y, const char* action) {
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/display/touch", 
             mqtt_get_device_uuid());
    
    cJSON* event = cJSON_CreateObject();
    mqtt_add_protocol_fields(event, mqtt_get_device_uuid());
    
    cJSON_AddStringToObject(event, "action", action);
    cJSON* position = cJSON_CreateObject();
    cJSON_AddNumberToObject(position, "x", x);
    cJSON_AddNumberToObject(position, "y", y);
    cJSON_AddItemToObject(event, "position", position);
    
    char* payload = cJSON_PrintUnformatted(event);
    mqtt_client_publish(topic, payload, QOS_TELEMETRY, false);
    
    cJSON_Delete(event);
    free(payload);
    
    ESP_LOGD(TAG, "Sent touch event: %s at (%d, %d)", action, x, y);
}

void mqtt_display_send_relay_command(const char* target_uuid, uint8_t channel, 
                                    bool state, const char* function_type) {
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/relays/set", target_uuid);
    
    cJSON* cmd = cJSON_CreateObject();
    mqtt_add_protocol_fields(cmd, mqtt_get_device_uuid());
    
    cJSON_AddNumberToObject(cmd, "channel", channel);
    cJSON_AddBoolToObject(cmd, "state", state);
    cJSON_AddStringToObject(cmd, "function_type", function_type);
    cJSON_AddStringToObject(cmd, "user", "display_touch");
    cJSON_AddStringToObject(cmd, "source_uuid", mqtt_get_device_uuid());
    
    char* payload = cJSON_PrintUnformatted(cmd);
    mqtt_client_publish(topic, payload, QOS_COMMANDS, false);
    
    cJSON_Delete(cmd);
    free(payload);
    
    ESP_LOGI(TAG, "Sent %s command to %s ch:%d state:%d", 
            function_type, target_uuid, channel, state);
    
    // Se for momentâneo e ligando, iniciar heartbeat
    if (strcmp(function_type, "momentary") == 0 && state && channel <= 16) {
        display_heartbeat_t* hb = &heartbeats[channel - 1];
        hb->active = true;
        hb->sequence = 0;
        hb->channel = channel;
        strncpy(hb->source_uuid, target_uuid, sizeof(hb->source_uuid) - 1);
        ESP_LOGI(TAG, "Started heartbeat for channel %d", channel);
    }
}

void mqtt_display_send_heartbeat(const char* target_uuid, uint8_t channel) {
    if (channel > 16) return;
    
    display_heartbeat_t* hb = &heartbeats[channel - 1];
    if (!hb->active) return;
    
    char topic[128];
    snprintf(topic, sizeof(topic), "autocore/devices/%s/relays/heartbeat", 
             target_uuid);
    
    cJSON* heartbeat = cJSON_CreateObject();
    mqtt_add_protocol_fields(heartbeat, mqtt_get_device_uuid());
    
    cJSON_AddNumberToObject(heartbeat, "channel", channel);
    cJSON_AddStringToObject(heartbeat, "source_uuid", mqtt_get_device_uuid());
    cJSON_AddStringToObject(heartbeat, "target_uuid", target_uuid);
    cJSON_AddNumberToObject(heartbeat, "sequence", ++hb->sequence);
    
    char* payload = cJSON_PrintUnformatted(heartbeat);
    mqtt_client_publish(topic, payload, QOS_HEARTBEAT, false);
    
    cJSON_Delete(heartbeat);
    free(payload);
    
    hb->last_heartbeat = esp_timer_get_time() / 1000;
}

void mqtt_display_process_heartbeats(void) {
    uint32_t now = esp_timer_get_time() / 1000;
    
    for (int i = 0; i < 16; i++) {
        display_heartbeat_t* hb = &heartbeats[i];
        
        if (hb->active) {
            if (now - hb->last_heartbeat >= HEARTBEAT_INTERVAL_MS) {
                mqtt_display_send_heartbeat(hb->source_uuid, hb->channel);
            }
        }
    }
}

void mqtt_display_stop_heartbeat(uint8_t channel) {
    if (channel > 0 && channel <= 16) {
        heartbeats[channel - 1].active = false;
        ESP_LOGI(TAG, "Stopped heartbeat for channel %d", channel);
    }
}

void mqtt_display_handle_screen_update(const char* payload) {
    cJSON* json = cJSON_Parse(payload);
    if (!json) {
        ESP_LOGE(TAG, "Failed to parse screen update");
        return;
    }
    
    // Validar protocol_version
    if (!mqtt_validate_protocol_version(json)) {
        mqtt_publish_error(MQTT_ERR_PROTOCOL_MISMATCH, 
                         "Invalid protocol version", json);
        cJSON_Delete(json);
        return;
    }
    
    // Processar atualização de tela
    cJSON* screen_data = cJSON_GetObjectItem(json, "screen_data");
    if (screen_data) {
        ui_manager_update_screen(screen_data);
    }
    
    cJSON_Delete(json);
}
```

### 6. Integração com UI Manager
**Atualizar**: `main/main.c`

```c
#include "mqtt_client.h"
#include "mqtt_display.h"
#include "config_manager.h"

// Task para processar heartbeats
static void heartbeat_task(void* pvParameters) {
    while (1) {
        mqtt_display_process_heartbeats();
        vTaskDelay(pdMS_TO_TICKS(100));  // Verificar a cada 100ms
    }
}

// Callback para mensagens MQTT
static void mqtt_message_handler(const char* topic, const char* payload) {
    ESP_LOGI(TAG, "Received message on topic: %s", topic);
    
    if (strstr(topic, "/display/screen")) {
        mqtt_display_handle_screen_update(payload);
    } else if (strstr(topic, "/relays/state")) {
        ui_update_relay_status(payload);
    } else if (strstr(topic, "/telemetry/")) {
        ui_update_telemetry(payload);
    } else if (strstr(topic, "/system/alert")) {
        ui_show_alert(payload);
    }
}

void app_main(void) {
    // Inicializar NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    
    // Inicializar WiFi
    wifi_init();
    
    // Obter UUID do dispositivo
    char device_uuid[64];
    config_get_device_uuid(device_uuid, sizeof(device_uuid));
    
    // Inicializar MQTT v2.2.0
    ESP_ERROR_CHECK(mqtt_client_init(CONFIG_MQTT_BROKER_URL, device_uuid));
    mqtt_client_register_callback(mqtt_message_handler);
    ESP_ERROR_CHECK(mqtt_client_start());
    
    // Inicializar UI
    ui_manager_init();
    
    // Inicializar touch
    xpt2046_init();
    
    // Criar task para heartbeats
    xTaskCreate(heartbeat_task, "heartbeat", 2048, NULL, 5, NULL);
    
    // Buscar configuração via API REST
    config_fetch_from_api();
    
    ESP_LOGI(TAG, "ESP32 Display ESP-IDF started with MQTT v2.2.0");
    
    // Loop principal
    while (1) {
        ui_manager_update();
        
        // Processar eventos de touch
        if (touch_is_pressed()) {
            touch_point_t point = touch_get_point();
            
            // Enviar evento via MQTT
            mqtt_display_send_touch_event(point.x, point.y, "tap");
            
            // Processar na UI
            ui_handle_touch(point.x, point.y);
        }
        
        vTaskDelay(pdMS_TO_TICKS(10));
    }
}
```

## 📝 Implementação Passo a Passo

### Passo 1: Criar Estrutura de Componentes
```bash
cd firmware/esp32-display-esp-idf
mkdir -p components/mqtt/include
mkdir -p components/mqtt/src
```

### Passo 2: Implementar Componente MQTT
1. Criar todos os arquivos listados acima
2. Adicionar ao CMakeLists.txt principal
3. Configurar menuconfig

### Passo 3: Integrar com UI Existente
1. Adicionar callbacks MQTT ao UI manager
2. Implementar handlers para comandos
3. Conectar touch events com MQTT

### Passo 4: Configuração via API
```c
// config_fetch.c
void config_fetch_from_api(void) {
    esp_http_client_config_t config = {
        .url = CONFIG_API_ENDPOINT,
        .method = HTTP_METHOD_GET,
    };
    
    esp_http_client_handle_t client = esp_http_client_init(&config);
    esp_err_t err = esp_http_client_perform(client);
    
    if (err == ESP_OK) {
        // Processar configuração
        int content_length = esp_http_client_get_content_length(client);
        char* buffer = malloc(content_length + 1);
        esp_http_client_read(client, buffer, content_length);
        
        config_apply(buffer);
        free(buffer);
    }
    
    esp_http_client_cleanup(client);
}
```

### Passo 5: Menuconfig
```
# sdkconfig
CONFIG_MQTT_BROKER_URL="mqtt://192.168.1.100"
CONFIG_API_ENDPOINT="http://192.168.1.100:8000/api"
CONFIG_DEVICE_TYPE="esp32_display"
```

## 🧪 Validação

### Build e Flash
```bash
idf.py build
idf.py -p /dev/ttyUSB0 flash monitor
```

### Testes
- [ ] MQTT conecta com LWT
- [ ] Protocol version em todos os payloads
- [ ] Touch events publicados
- [ ] Heartbeat funcionando
- [ ] Telemetria recebida e exibida
- [ ] Configuração via API REST

## 📊 Métricas de Sucesso
- ✅ 100% conformidade v2.2.0 desde o início
- ✅ Nenhuma refatoração necessária
- ✅ Código limpo e organizado
- ✅ Referência para outros projetos

## 📝 Notas
- Implementação limpa desde o início
- Serve como referência de boas práticas
- Aproveitar para documentar bem
- Criar testes unitários

---
**Criado em**: 12/08/2025  
**Status**: Documentado  
**Estimativa**: 12-16 horas  
**Complexidade**: Média (implementação nova)