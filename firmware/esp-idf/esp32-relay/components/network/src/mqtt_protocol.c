/**
 * MQTT Protocol v2.2.0 Implementation for ESP32 Relay
 * Implementação do protocolo MQTT v2.2.0 para conformidade com AutoCore
 */

#include "mqtt_protocol.h"
#include "esp_log.h"
#include <string.h>
#include <time.h>

static const char *TAG = "MQTT_PROTOCOL";

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

// Implementações das funções definidas no header

/**
 * Inicializa mensagem base com protocolo v2.2.0
 */
void mqtt_init_base_message(mqtt_base_message_t *msg, const char *uuid) {
    if (!msg || !uuid) return;
    
    msg->protocol_version = MQTT_PROTOCOL_VERSION;
    msg->uuid = uuid;
    strcpy(msg->timestamp, get_iso_timestamp());
}

/**
 * Cria JSON base com campos obrigatórios v2.2.0
 */
cJSON* mqtt_create_base_json(const mqtt_base_message_t *msg) {
    if (!msg) return NULL;
    
    cJSON *root = cJSON_CreateObject();
    if (!root) return NULL;
    
    cJSON_AddStringToObject(root, "protocol_version", msg->protocol_version);
    cJSON_AddStringToObject(root, "uuid", msg->uuid);
    cJSON_AddStringToObject(root, "timestamp", msg->timestamp);
    
    return root;
}

/**
 * Valida versão do protocolo em mensagem recebida
 */
bool mqtt_validate_protocol_version(cJSON *root) {
    if (!root) {
        ESP_LOGE(TAG, "JSON root is NULL");
        return false;
    }
    
    cJSON *version = cJSON_GetObjectItem(root, "protocol_version");
    if (!version || !cJSON_IsString(version)) {
        ESP_LOGE(TAG, "Missing protocol_version field");
        return false;
    }
    
    // Verificar se é versão 2.x.x
    if (strncmp(version->valuestring, "2.", 2) != 0) {
        ESP_LOGE(TAG, "Incompatible protocol version: %s", version->valuestring);
        return false;
    }
    
    ESP_LOGD(TAG, "Protocol version validated: %s", version->valuestring);
    return true;
}

/**
 * Gera timestamp ISO 8601 atual
 */
char* get_iso_timestamp(void) {
    static char timestamp[32];
    time_t now;
    time(&now);
    struct tm *tm_info = gmtime(&now);
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%dT%H:%M:%SZ", tm_info);
    return timestamp;
}

/**
 * Gera timestamp ISO 8601 de um time_t específico
 */
char* get_iso_timestamp_from_time(time_t timestamp) {
    static char iso_timestamp[32];
    struct tm *tm_info = gmtime(&timestamp);
    strftime(iso_timestamp, sizeof(iso_timestamp), "%Y-%m-%dT%H:%M:%SZ", tm_info);
    return iso_timestamp;
}

/**
 * Converte código de erro para string
 */
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

/**
 * Converte código de erro para tipo de erro
 */
const char* mqtt_error_type_to_string(mqtt_error_code_t code) {
    switch (code) {
        case MQTT_ERR_COMMAND_FAILED: return "command";
        case MQTT_ERR_INVALID_PAYLOAD: return "payload";
        case MQTT_ERR_TIMEOUT: return "timeout";
        case MQTT_ERR_UNAUTHORIZED: return "auth";
        case MQTT_ERR_DEVICE_BUSY: return "busy";
        case MQTT_ERR_HARDWARE_FAULT: return "hardware";
        case MQTT_ERR_NETWORK_ERROR: return "network";
        case MQTT_ERR_PROTOCOL_MISMATCH: return "protocol";
        default: return "unknown";
    }
}

/**
 * Valida UUID no formato esperado
 */
bool mqtt_validate_uuid(const char *uuid) {
    if (!uuid) return false;
    
    size_t len = strlen(uuid);
    if (len < 8 || len > 64) {
        ESP_LOGE(TAG, "UUID length invalid: %zu", len);
        return false;
    }
    
    // Verificar caracteres válidos (alfanuméricos, hífen, underscore)
    for (size_t i = 0; i < len; i++) {
        char c = uuid[i];
        if (!((c >= 'a' && c <= 'z') || 
              (c >= 'A' && c <= 'Z') || 
              (c >= '0' && c <= '9') || 
              c == '-' || c == '_')) {
            ESP_LOGE(TAG, "UUID contains invalid character: %c", c);
            return false;
        }
    }
    
    return true;
}

/**
 * Valida timestamp ISO 8601
 */
bool mqtt_validate_timestamp(const char *timestamp) {
    if (!timestamp) return false;
    
    size_t len = strlen(timestamp);
    if (len < 19 || len > 24) {
        ESP_LOGE(TAG, "Timestamp length invalid: %zu", len);
        return false;
    }
    
    // Verificação básica do formato YYYY-MM-DDTHH:MM:SSZ
    if (timestamp[4] != '-' || timestamp[7] != '-' || 
        timestamp[10] != 'T' || timestamp[13] != ':' || 
        timestamp[16] != ':') {
        ESP_LOGE(TAG, "Timestamp format invalid: %s", timestamp);
        return false;
    }
    
    return true;
}

/**
 * Cria payload de status online conforme v2.2.0
 */
cJSON* mqtt_create_online_status(const char *uuid, const char *firmware_version, 
                                const char *ip_address, int wifi_signal, 
                                size_t free_memory, uint64_t uptime) {
    mqtt_base_message_t msg;
    mqtt_init_base_message(&msg, uuid);
    
    cJSON *root = mqtt_create_base_json(&msg);
    if (!root) return NULL;
    
    cJSON_AddStringToObject(root, "status", "online");
    cJSON_AddStringToObject(root, "firmware_version", firmware_version);
    cJSON_AddStringToObject(root, "ip_address", ip_address);
    cJSON_AddNumberToObject(root, "wifi_signal", wifi_signal);
    cJSON_AddNumberToObject(root, "free_memory", (double)free_memory);
    cJSON_AddNumberToObject(root, "uptime", (double)uptime);
    
    return root;
}

/**
 * Cria payload de Last Will Testament conforme v2.2.0
 */
cJSON* mqtt_create_lwt_payload(const char *uuid, const char *reason) {
    mqtt_base_message_t msg;
    mqtt_init_base_message(&msg, uuid);
    
    cJSON *root = mqtt_create_base_json(&msg);
    if (!root) return NULL;
    
    cJSON_AddStringToObject(root, "status", "offline");
    cJSON_AddStringToObject(root, "reason", reason ? reason : "unexpected_disconnect");
    cJSON_AddStringToObject(root, "last_seen", msg.timestamp);
    
    return root;
}

/**
 * Parser principal de comandos MQTT v2.2.0
 */
esp_err_t mqtt_parse_command(const char* topic, const char* payload, mqtt_command_struct_t* cmd) {
    if (!topic || !payload || !cmd) {
        ESP_LOGE(TAG, "Invalid parameters for command parser");
        return ESP_ERR_INVALID_ARG;
    }
    
    // Inicializar estrutura
    memset(cmd, 0, sizeof(mqtt_command_struct_t));
    
    // Parse JSON
    cJSON *json = cJSON_Parse(payload);
    if (!json) {
        ESP_LOGE(TAG, "Failed to parse JSON payload");
        return ESP_ERR_INVALID_ARG;
    }
    
    // Validar protocol version
    if (!mqtt_validate_protocol_version(json)) {
        ESP_LOGE(TAG, "Invalid protocol version");
        cJSON_Delete(json);
        return ESP_ERR_INVALID_ARG;
    }
    
    esp_err_t ret = ESP_OK;
    
    // Determinar tipo de comando baseado no tópico
    if (strstr(topic, "/relays/set") != NULL) {
        cmd->type = MQTT_CMD_RELAY;
        ret = mqtt_parse_relay_command(json, cmd);
    } else if (strstr(topic, "/commands/") != NULL) {
        cmd->type = MQTT_CMD_GENERAL;
        ret = mqtt_parse_general_command(json, cmd);
    } else {
        ESP_LOGE(TAG, "Unknown command topic: %s", topic);
        ret = ESP_ERR_NOT_SUPPORTED;
    }
    
    cJSON_Delete(json);
    return ret;
}

/**
 * Parser de comandos de relé
 */
esp_err_t mqtt_parse_relay_command(cJSON* json, mqtt_command_struct_t* cmd) {
    if (!json || !cmd) return ESP_ERR_INVALID_ARG;
    
    // Extrair channel
    cJSON *channel_json = cJSON_GetObjectItem(json, "channel");
    if (!channel_json) {
        ESP_LOGE(TAG, "Missing channel field");
        return ESP_ERR_INVALID_ARG;
    }
    
    if (cJSON_IsNumber(channel_json)) {
        cmd->data.relay.channel = channel_json->valueint;
    } else if (cJSON_IsString(channel_json) && strcmp(channel_json->valuestring, "all") == 0) {
        cmd->data.relay.channel = -1; // Indica "all"
    } else {
        ESP_LOGE(TAG, "Invalid channel field");
        return ESP_ERR_INVALID_ARG;
    }
    
    // Extrair command
    cJSON *command_json = cJSON_GetObjectItem(json, "command");
    if (!command_json || !cJSON_IsString(command_json)) {
        ESP_LOGE(TAG, "Missing or invalid command field");
        return ESP_ERR_INVALID_ARG;
    }
    
    const char *cmd_str = command_json->valuestring;
    if (strcmp(cmd_str, "on") == 0) {
        cmd->data.relay.cmd = RELAY_CMD_ON;
    } else if (strcmp(cmd_str, "off") == 0) {
        cmd->data.relay.cmd = RELAY_CMD_OFF;
    } else if (strcmp(cmd_str, "toggle") == 0) {
        cmd->data.relay.cmd = RELAY_CMD_TOGGLE;
    } else {
        ESP_LOGE(TAG, "Unknown relay command: %s", cmd_str);
        return ESP_ERR_INVALID_ARG;
    }
    
    // Extrair campos opcionais
    cJSON *momentary_json = cJSON_GetObjectItem(json, "momentary");
    if (momentary_json && cJSON_IsBool(momentary_json)) {
        cmd->data.relay.is_momentary = cJSON_IsTrue(momentary_json);
    }
    
    cJSON *source_json = cJSON_GetObjectItem(json, "source");
    if (source_json && cJSON_IsString(source_json)) {
        strncpy(cmd->data.relay.source, source_json->valuestring, sizeof(cmd->data.relay.source) - 1);
    }
    
    cJSON *user_json = cJSON_GetObjectItem(json, "user");
    if (user_json && cJSON_IsString(user_json)) {
        strncpy(cmd->data.relay.user, user_json->valuestring, sizeof(cmd->data.relay.user) - 1);
    }
    
    return ESP_OK;
}

/**
 * Parser de comandos gerais
 */
esp_err_t mqtt_parse_general_command(cJSON* json, mqtt_command_struct_t* cmd) {
    if (!json || !cmd) return ESP_ERR_INVALID_ARG;
    
    // Extrair command
    cJSON *command_json = cJSON_GetObjectItem(json, "command");
    if (!command_json || !cJSON_IsString(command_json)) {
        ESP_LOGE(TAG, "Missing or invalid command field");
        return ESP_ERR_INVALID_ARG;
    }
    
    const char *cmd_str = command_json->valuestring;
    if (strcmp(cmd_str, "reset") == 0) {
        cmd->data.general.cmd = GENERAL_CMD_RESET;
    } else if (strcmp(cmd_str, "status") == 0) {
        cmd->data.general.cmd = GENERAL_CMD_STATUS;
    } else if (strcmp(cmd_str, "reboot") == 0) {
        cmd->data.general.cmd = GENERAL_CMD_REBOOT;
    } else if (strcmp(cmd_str, "ota") == 0) {
        cmd->data.general.cmd = GENERAL_CMD_OTA;
    } else {
        ESP_LOGE(TAG, "Unknown general command: %s", cmd_str);
        return ESP_ERR_INVALID_ARG;
    }
    
    // Extrair campos opcionais
    cJSON *delay_json = cJSON_GetObjectItem(json, "delay");
    if (delay_json && cJSON_IsNumber(delay_json)) {
        cmd->data.general.delay = delay_json->valueint;
    }
    
    cJSON *type_json = cJSON_GetObjectItem(json, "type");
    if (type_json && cJSON_IsString(type_json)) {
        strncpy(cmd->data.general.type, type_json->valuestring, sizeof(cmd->data.general.type) - 1);
    }
    
    cJSON *data_json = cJSON_GetObjectItem(json, "data");
    if (data_json && cJSON_IsString(data_json)) {
        strncpy(cmd->data.general.data, data_json->valuestring, sizeof(cmd->data.general.data) - 1);
    }
    
    return ESP_OK;
}

/**
 * Converte comando de relé para string
 */
const char* relay_cmd_to_string(relay_cmd_t cmd) {
    switch (cmd) {
        case RELAY_CMD_ON: return "on";
        case RELAY_CMD_OFF: return "off";
        case RELAY_CMD_TOGGLE: return "toggle";
        case RELAY_CMD_ALL: return "all";
        default: return "unknown";
    }
}

/**
 * Converte string para comando de relé
 */
relay_cmd_t string_to_relay_cmd(const char* str) {
    if (!str) return RELAY_CMD_OFF;
    
    if (strcmp(str, "on") == 0) return RELAY_CMD_ON;
    if (strcmp(str, "off") == 0) return RELAY_CMD_OFF;
    if (strcmp(str, "toggle") == 0) return RELAY_CMD_TOGGLE;
    if (strcmp(str, "all") == 0) return RELAY_CMD_ALL;
    
    return RELAY_CMD_OFF;
}

/**
 * Converte comando geral para string
 */
const char* general_cmd_to_string(general_cmd_t cmd) {
    switch (cmd) {
        case GENERAL_CMD_RESET: return "reset";
        case GENERAL_CMD_STATUS: return "status";
        case GENERAL_CMD_REBOOT: return "reboot";
        case GENERAL_CMD_OTA: return "ota";
        default: return "unknown";
    }
}

/**
 * Converte string para comando geral
 */
general_cmd_t string_to_general_cmd(const char* str) {
    if (!str) return GENERAL_CMD_STATUS;
    
    if (strcmp(str, "reset") == 0) return GENERAL_CMD_RESET;
    if (strcmp(str, "status") == 0) return GENERAL_CMD_STATUS;
    if (strcmp(str, "reboot") == 0) return GENERAL_CMD_REBOOT;
    if (strcmp(str, "ota") == 0) return GENERAL_CMD_OTA;
    
    return GENERAL_CMD_STATUS;
}

/**
 * Processa comando estruturado
 */
esp_err_t mqtt_process_command_struct(mqtt_command_struct_t* cmd) {
    if (!cmd) {
        ESP_LOGE(TAG, "Invalid command structure");
        return ESP_ERR_INVALID_ARG;
    }
    
    switch (cmd->type) {
        case MQTT_CMD_RELAY:
            return mqtt_process_relay_command(cmd);
        case MQTT_CMD_GENERAL:
            return mqtt_process_general_command(cmd);
        default:
            ESP_LOGE(TAG, "Unknown command type: %d", cmd->type);
            return ESP_ERR_NOT_SUPPORTED;
    }
}

/**
 * Processa comando de relé
 * Nota: Este arquivo implementa apenas o parsing. O processamento real
 * deve ser implementado em um módulo específico que tenha acesso ao 
 * controle de relés.
 */
esp_err_t mqtt_process_relay_command(mqtt_command_struct_t* cmd) {
    if (!cmd || cmd->type != MQTT_CMD_RELAY) {
        ESP_LOGE(TAG, "Invalid relay command");
        return ESP_ERR_INVALID_ARG;
    }
    
    ESP_LOGI(TAG, "Processing relay command: channel=%d, cmd=%s, momentary=%s", 
             cmd->data.relay.channel,
             relay_cmd_to_string(cmd->data.relay.cmd),
             cmd->data.relay.is_momentary ? "yes" : "no");
    
    // Validar canal
    if (cmd->data.relay.channel != -1 && 
        (cmd->data.relay.channel < 1 || cmd->data.relay.channel > 16)) {
        ESP_LOGE(TAG, "Invalid relay channel: %d", cmd->data.relay.channel);
        return ESP_ERR_INVALID_ARG;
    }
    
    // Log da origem do comando
    if (strlen(cmd->data.relay.source) > 0) {
        ESP_LOGI(TAG, "Command source: %s", cmd->data.relay.source);
    }
    if (strlen(cmd->data.relay.user) > 0) {
        ESP_LOGI(TAG, "Command user: %s", cmd->data.relay.user);
    }
    
    // Retornar ESP_OK - o processamento real deve ser feito pelo módulo que chama
    return ESP_OK;
}

/**
 * Processa comando geral
 */
esp_err_t mqtt_process_general_command(mqtt_command_struct_t* cmd) {
    if (!cmd || cmd->type != MQTT_CMD_GENERAL) {
        ESP_LOGE(TAG, "Invalid general command");
        return ESP_ERR_INVALID_ARG;
    }
    
    ESP_LOGI(TAG, "Processing general command: cmd=%s", 
             general_cmd_to_string(cmd->data.general.cmd));
    
    switch (cmd->data.general.cmd) {
        case GENERAL_CMD_STATUS:
            ESP_LOGI(TAG, "Status request received");
            break;
        case GENERAL_CMD_RESET:
            ESP_LOGI(TAG, "Reset request received, type: %s", 
                     strlen(cmd->data.general.type) > 0 ? cmd->data.general.type : "all");
            break;
        case GENERAL_CMD_REBOOT:
            ESP_LOGI(TAG, "Reboot request received, delay: %d seconds", 
                     cmd->data.general.delay);
            break;
        case GENERAL_CMD_OTA:
            ESP_LOGI(TAG, "OTA request received, data: %s", 
                     strlen(cmd->data.general.data) > 0 ? cmd->data.general.data : "none");
            break;
        default:
            ESP_LOGW(TAG, "Unknown general command: %d", cmd->data.general.cmd);
            return ESP_ERR_NOT_SUPPORTED;
    }
    
    // Retornar ESP_OK - o processamento real deve ser feito pelo módulo que chama
    return ESP_OK;
}