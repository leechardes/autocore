#include "mqtt_client.h"
#include "mqtt_protocol.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "esp_system.h"
#include "cJSON.h"
#include <string.h>

#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

static const char* TAG = "MQTT_CLIENT";
static mqtt_client_t mqtt_ctx = {0};
static mqtt_message_callback_t message_callback = NULL;
static mqtt_topics_t topics = {0};

// Forward declarations
static void mqtt_event_handler(void* handler_args, esp_event_base_t base, 
                              int32_t event_id, void* event_data);
static void publish_online_status(void);
static void subscribe_to_topics(void);
static esp_err_t create_lwt_message(char** lwt_payload);

esp_err_t mqtt_client_init(const char* broker_url, const char* device_uuid) {
    if (mqtt_ctx.initialized) {
        ESP_LOGW(TAG, "MQTT client already initialized");
        return ESP_OK;
    }
    
    if (!broker_url || !device_uuid) {
        ESP_LOGE(TAG, "Invalid parameters for MQTT client init");
        return ESP_ERR_INVALID_ARG;
    }
    
    // Copiar UUID do dispositivo
    strncpy(mqtt_ctx.device_uuid, device_uuid, sizeof(mqtt_ctx.device_uuid) - 1);
    mqtt_ctx.device_uuid[sizeof(mqtt_ctx.device_uuid) - 1] = '\0';
    
    // Inicializar tópicos
    mqtt_init_topics(&topics, device_uuid);
    
    // Preparar Last Will Testament
    char* lwt_payload = NULL;
    esp_err_t lwt_ret = create_lwt_message(&lwt_payload);
    if (lwt_ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to create LWT message");
        return lwt_ret;
    }
    
    // Configurar cliente MQTT com LWT obrigatório
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker = {
            .address.uri = broker_url,
        },
        .credentials = {
            .client_id = device_uuid,
        },
        .session = {
            .last_will = {
                .topic = topics.device_status,
                .msg = lwt_payload,
                .msg_len = strlen(lwt_payload),
                .qos = QOS_STATUS,
                .retain = true,
            },
            .keepalive = 60,
        },
        .task = {
            .stack_size = 8192,
        },
        .buffer = {
            .size = 2048,
        }
    };
    
    mqtt_ctx.client = esp_mqtt_client_init(&mqtt_cfg);
    free(lwt_payload);
    
    if (mqtt_ctx.client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize MQTT client");
        return ESP_FAIL;
    }
    
    // Registrar event handler
    esp_err_t ret = esp_mqtt_client_register_event(mqtt_ctx.client, ESP_EVENT_ANY_ID, 
                                                  mqtt_event_handler, NULL);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to register MQTT event handler");
        esp_mqtt_client_destroy(mqtt_ctx.client);
        return ret;
    }
    
    mqtt_ctx.initialized = true;
    mqtt_ctx.state = MQTT_STATE_DISCONNECTED;
    mqtt_ctx.message_count = 0;
    mqtt_ctx.error_count = 0;
    
    ESP_LOGI(TAG, "MQTT client initialized with v2.2.0 compliance");
    ESP_LOGI(TAG, "Device UUID: %s", device_uuid);
    ESP_LOGI(TAG, "LWT Topic: %s", topics.device_status);
    
    return ESP_OK;
}

esp_err_t mqtt_client_start(void) {
    if (!mqtt_ctx.initialized) {
        ESP_LOGE(TAG, "MQTT client not initialized");
        return ESP_FAIL;
    }
    
    if (mqtt_ctx.state == MQTT_STATE_CONNECTED) {
        ESP_LOGW(TAG, "MQTT client already connected");
        return ESP_OK;
    }
    
    mqtt_ctx.state = MQTT_STATE_CONNECTING;
    esp_err_t ret = esp_mqtt_client_start(mqtt_ctx.client);
    
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to start MQTT client: %s", esp_err_to_name(ret));
        mqtt_ctx.state = MQTT_STATE_ERROR;
        mqtt_ctx.error_count++;
        return ret;
    }
    
    ESP_LOGI(TAG, "MQTT client started, connecting...");
    return ESP_OK;
}

static esp_err_t create_lwt_message(char** lwt_payload) {
    cJSON* lwt_json = cJSON_CreateObject();
    if (!lwt_json) {
        return ESP_ERR_NO_MEM;
    }
    
    // Campos obrigatórios do protocolo v2.2.0
    cJSON_AddStringToObject(lwt_json, "protocol_version", MQTT_PROTOCOL_VERSION);
    cJSON_AddStringToObject(lwt_json, "uuid", mqtt_ctx.device_uuid);
    cJSON_AddStringToObject(lwt_json, "status", "offline");
    cJSON_AddStringToObject(lwt_json, "timestamp", mqtt_get_iso_timestamp());
    cJSON_AddStringToObject(lwt_json, "reason", "unexpected_disconnect");
    cJSON_AddStringToObject(lwt_json, "last_seen", mqtt_get_iso_timestamp());
    cJSON_AddStringToObject(lwt_json, "device_type", "esp32_display");
    
    *lwt_payload = cJSON_PrintUnformatted(lwt_json);
    cJSON_Delete(lwt_json);
    
    if (*lwt_payload == NULL) {
        return ESP_ERR_NO_MEM;
    }
    
    return ESP_OK;
}

static void mqtt_event_handler(void* handler_args, esp_event_base_t base, 
                              int32_t event_id, void* event_data) {
    esp_mqtt_event_handle_t event = event_data;
    
    switch (event->event_id) {
        case MQTT_EVENT_CONNECTED:
            ESP_LOGI(TAG, "Connected to MQTT broker");
            mqtt_ctx.state = MQTT_STATE_CONNECTED;
            
            // Publicar status online imediatamente
            publish_online_status();
            
            // Subscrever aos tópicos v2.2.0
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
                
                int topic_len = MIN(event->topic_len, sizeof(topic) - 1);
                int payload_len = MIN(event->data_len, sizeof(payload) - 1);
                
                memcpy(topic, event->topic, topic_len);
                memcpy(payload, event->data, payload_len);
                
                // Validar protocol_version para payloads JSON
                cJSON* json = cJSON_Parse(payload);
                if (json) {
                    if (mqtt_validate_protocol_version(json)) {
                        message_callback(topic, payload);
                    } else {
                        ESP_LOGW(TAG, "Message without valid protocol_version");
                        mqtt_publish_error(MQTT_ERR_PROTOCOL_MISMATCH, 
                                         "Invalid protocol version", json);
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
            ESP_LOGE(TAG, "MQTT error occurred");
            if (event->error_handle) {
                ESP_LOGE(TAG, "Error type: %d", event->error_handle->error_type);
                if (event->error_handle->error_type == MQTT_ERROR_TYPE_TCP_TRANSPORT) {
                    ESP_LOGE(TAG, "Transport error: 0x%x", event->error_handle->esp_transport_sock_errno);
                    ESP_LOGE(TAG, "TLS stack error: 0x%x", event->error_handle->esp_tls_stack_err);
                    ESP_LOGE(TAG, "TLS cert verify error: 0x%x", event->error_handle->esp_tls_cert_verify_flags);
                }
            }
            mqtt_ctx.state = MQTT_STATE_ERROR;
            mqtt_ctx.error_count++;
            break;
            
        case MQTT_EVENT_SUBSCRIBED:
            ESP_LOGD(TAG, "Subscribed to topic (msg_id=%d)", event->msg_id);
            break;
            
        case MQTT_EVENT_UNSUBSCRIBED:
            ESP_LOGD(TAG, "Unsubscribed from topic (msg_id=%d)", event->msg_id);
            break;
            
        case MQTT_EVENT_PUBLISHED:
            ESP_LOGD(TAG, "Message published (msg_id=%d)", event->msg_id);
            break;
            
        default:
            ESP_LOGD(TAG, "Other MQTT event: %ld", event->event_id);
            break;
    }
}

static void publish_online_status(void) {
    // Criar payload de status conforme v2.2.0
    cJSON* status = cJSON_CreateObject();
    if (!status) {
        ESP_LOGE(TAG, "Failed to create status JSON");
        return;
    }
    
    // Campos obrigatórios do protocolo
    mqtt_add_protocol_fields(status, mqtt_ctx.device_uuid);
    cJSON_AddStringToObject(status, "status", "online");
    cJSON_AddStringToObject(status, "device_type", "esp32_display");
    cJSON_AddNumberToObject(status, "free_heap", esp_get_free_heap_size());
    cJSON_AddNumberToObject(status, "uptime", esp_timer_get_time() / 1000000);
    
    // Adicionar capacidades do display
    cJSON* capabilities = cJSON_CreateObject();
    if (capabilities) {
        cJSON_AddBoolToObject(capabilities, "touch", true);
        cJSON_AddBoolToObject(capabilities, "color", true);
        cJSON_AddStringToObject(capabilities, "resolution", "320x240");
        cJSON_AddStringToObject(capabilities, "display_type", "ILI9341");
        cJSON_AddStringToObject(capabilities, "orientation", "landscape");
        cJSON_AddItemToObject(status, "capabilities", capabilities);
    }
    
    char* payload = cJSON_PrintUnformatted(status);
    cJSON_Delete(status);
    
    if (payload) {
        esp_err_t ret = esp_mqtt_client_publish(mqtt_ctx.client, topics.device_status, 
                                               payload, strlen(payload), QOS_STATUS, true);
        if (ret >= 0) {
            ESP_LOGI(TAG, "Published online status (msg_id=%d)", ret);
        } else {
            ESP_LOGE(TAG, "Failed to publish online status");
        }
        free(payload);
    }
}

static void subscribe_to_topics(void) {
    int msg_id;
    
    // Comandos específicos do display
    msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, topics.display_screen, QOS_COMMANDS);
    ESP_LOGI(TAG, "Subscribed to display/screen (msg_id=%d)", msg_id);
    
    msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, topics.display_config, QOS_COMMANDS);
    ESP_LOGI(TAG, "Subscribed to display/config (msg_id=%d)", msg_id);
    
    // Estados de relés para exibir
    msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, "autocore/devices/+/relays/state", QOS_TELEMETRY);
    ESP_LOGI(TAG, "Subscribed to relays/state (msg_id=%d)", msg_id);
    
    // Telemetria (SEM UUID no tópico conforme v2.2.0!)
    msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, "autocore/telemetry/relays/data", QOS_TELEMETRY);
    ESP_LOGI(TAG, "Subscribed to telemetry/relays (msg_id=%d)", msg_id);
    
    msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, "autocore/telemetry/can/+", QOS_TELEMETRY);
    ESP_LOGI(TAG, "Subscribed to telemetry/can (msg_id=%d)", msg_id);
    
    msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, "autocore/telemetry/sensors/+", QOS_TELEMETRY);
    ESP_LOGI(TAG, "Subscribed to telemetry/sensors (msg_id=%d)", msg_id);
    
    // Sistema
    msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, "autocore/system/broadcast", QOS_TELEMETRY);
    ESP_LOGI(TAG, "Subscribed to system/broadcast (msg_id=%d)", msg_id);
    
    msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, "autocore/system/alert", QOS_COMMANDS);
    ESP_LOGI(TAG, "Subscribed to system/alert (msg_id=%d)", msg_id);
    
    // Erros para exibir
    msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, "autocore/errors/+/+", QOS_COMMANDS);
    ESP_LOGI(TAG, "Subscribed to errors (msg_id=%d)", msg_id);
    
    ESP_LOGI(TAG, "Subscribed to all v2.2.0 compliant topics");
}

esp_err_t mqtt_client_publish(const char* topic, const char* payload, int qos, bool retain) {
    if (!mqtt_ctx.initialized) {
        ESP_LOGW(TAG, "Cannot publish - client not initialized");
        return ESP_FAIL;
    }
    
    if (mqtt_ctx.state != MQTT_STATE_CONNECTED) {
        ESP_LOGW(TAG, "Cannot publish - not connected (state: %d)", mqtt_ctx.state);
        return ESP_FAIL;
    }
    
    if (!topic || !payload) {
        ESP_LOGE(TAG, "Invalid topic or payload");
        return ESP_ERR_INVALID_ARG;
    }
    
    int msg_id = esp_mqtt_client_publish(mqtt_ctx.client, topic, payload, 
                                        strlen(payload), qos, retain);
    
    if (msg_id < 0) {
        ESP_LOGE(TAG, "Failed to publish to %s", topic);
        mqtt_ctx.error_count++;
        return ESP_FAIL;
    }
    
    ESP_LOGD(TAG, "Published to %s (msg_id: %d)", topic, msg_id);
    return ESP_OK;
}

esp_err_t mqtt_client_subscribe(const char* topic, int qos) {
    if (!mqtt_ctx.initialized || mqtt_ctx.state != MQTT_STATE_CONNECTED) {
        ESP_LOGW(TAG, "Cannot subscribe - not connected");
        return ESP_FAIL;
    }
    
    int msg_id = esp_mqtt_client_subscribe(mqtt_ctx.client, topic, qos);
    if (msg_id < 0) {
        ESP_LOGE(TAG, "Failed to subscribe to %s", topic);
        return ESP_FAIL;
    }
    
    ESP_LOGI(TAG, "Subscribed to %s (msg_id: %d)", topic, msg_id);
    return ESP_OK;
}

esp_err_t mqtt_client_stop(void) {
    if (!mqtt_ctx.initialized) {
        return ESP_OK;
    }
    
    if (mqtt_ctx.client) {
        esp_err_t ret = esp_mqtt_client_stop(mqtt_ctx.client);
        if (ret != ESP_OK) {
            ESP_LOGW(TAG, "Error stopping MQTT client: %s", esp_err_to_name(ret));
        }
    }
    
    mqtt_ctx.state = MQTT_STATE_DISCONNECTED;
    ESP_LOGI(TAG, "MQTT client stopped");
    return ESP_OK;
}

esp_err_t mqtt_client_deinit(void) {
    mqtt_client_stop();
    
    if (mqtt_ctx.client) {
        esp_err_t ret = esp_mqtt_client_destroy(mqtt_ctx.client);
        if (ret != ESP_OK) {
            ESP_LOGW(TAG, "Error destroying MQTT client: %s", esp_err_to_name(ret));
        }
        mqtt_ctx.client = NULL;
    }
    
    mqtt_ctx.initialized = false;
    memset(&mqtt_ctx, 0, sizeof(mqtt_ctx));
    
    ESP_LOGI(TAG, "MQTT client deinitialized");
    return ESP_OK;
}

// Getters
mqtt_state_t mqtt_client_get_state(void) {
    return mqtt_ctx.state;
}

const char* mqtt_client_get_device_uuid(void) {
    return mqtt_ctx.device_uuid;
}

uint32_t mqtt_client_get_message_count(void) {
    return mqtt_ctx.message_count;
}

uint32_t mqtt_client_get_error_count(void) {
    return mqtt_ctx.error_count;
}

void mqtt_client_register_callback(mqtt_message_callback_t callback) {
    message_callback = callback;
    ESP_LOGI(TAG, "Message callback registered");
}

// Funções específicas do display
esp_err_t mqtt_publish_display_status(const char* status) {
    cJSON* json = cJSON_CreateObject();
    if (!json) {
        return ESP_ERR_NO_MEM;
    }
    
    mqtt_add_protocol_fields(json, mqtt_ctx.device_uuid);
    cJSON_AddStringToObject(json, "display_status", status);
    
    char* payload = cJSON_PrintUnformatted(json);
    cJSON_Delete(json);
    
    if (!payload) {
        return ESP_ERR_NO_MEM;
    }
    
    esp_err_t ret = mqtt_client_publish(topics.device_status, payload, QOS_STATUS, true);
    free(payload);
    
    return ret;
}

esp_err_t mqtt_publish_touch_event(int x, int y, const char* action) {
    cJSON* event = cJSON_CreateObject();
    if (!event) {
        return ESP_ERR_NO_MEM;
    }
    
    mqtt_add_protocol_fields(event, mqtt_ctx.device_uuid);
    cJSON_AddStringToObject(event, "action", action);
    
    cJSON* position = cJSON_CreateObject();
    if (position) {
        cJSON_AddNumberToObject(position, "x", x);
        cJSON_AddNumberToObject(position, "y", y);
        cJSON_AddItemToObject(event, "position", position);
    }
    
    char* payload = cJSON_PrintUnformatted(event);
    cJSON_Delete(event);
    
    if (!payload) {
        return ESP_ERR_NO_MEM;
    }
    
    esp_err_t ret = mqtt_client_publish(topics.display_touch, payload, QOS_TELEMETRY, false);
    free(payload);
    
    ESP_LOGD(TAG, "Published touch event: %s at (%d, %d)", action, x, y);
    return ret;
}