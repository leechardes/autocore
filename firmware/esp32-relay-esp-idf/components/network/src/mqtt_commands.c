#include "mqtt_protocol.h"
#include "mqtt_handler.h"
#include "mqtt_momentary.h"
#include "mqtt_telemetry.h"
#include "relay_control.h"
#include "config_manager.h"
#include "esp_log.h"
#include "esp_system.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <string.h>
#include <time.h>

static const char *TAG = "MQTT_COMMANDS";

// Parser principal de comandos
esp_err_t mqtt_parse_command(const char* topic, const char* payload, mqtt_command_struct_t* cmd)
{
    if (!topic || !payload || !cmd) {
        ESP_LOGE(TAG, "Parâmetros inválidos para parse_command");
        return ESP_ERR_INVALID_ARG;
    }

    ESP_LOGI(TAG, "Parsing comando: %s", topic);
    ESP_LOGD(TAG, "Payload: %s", payload);

    // Parse JSON
    cJSON *json = cJSON_Parse(payload);
    if (!json) {
        ESP_LOGE(TAG, "Erro parsing JSON: %s", payload);
        return ESP_ERR_INVALID_ARG;
    }

    esp_err_t ret = ESP_OK;

    // Determinar tipo de comando baseado no tópico
    if (strstr(topic, "/relay/command")) {
        cmd->type = MQTT_CMD_RELAY;
        ret = mqtt_parse_relay_command(json, cmd);
    } else if (strstr(topic, "/relay/heartbeat")) {
        // Processa heartbeat de relé momentâneo
        cJSON *channel_json = cJSON_GetObjectItem(json, "channel");
        if (channel_json && cJSON_IsNumber(channel_json)) {
            int channel = cJSON_GetNumberValue(channel_json);
            ESP_LOGD(TAG, "💓 Heartbeat recebido para canal %d", channel);
            mqtt_momentary_heartbeat(channel);
        }
        cJSON_Delete(json);
        return ESP_OK; // Retorna direto, não precisa processar mais
    } else if (strstr(topic, "/commands/")) {
        cmd->type = MQTT_CMD_GENERAL;
        ret = mqtt_parse_general_command(json, cmd);
    } else {
        ESP_LOGE(TAG, "Tópico de comando não reconhecido: %s", topic);
        ret = ESP_ERR_NOT_SUPPORTED;
    }

    cJSON_Delete(json);
    return ret;
}

// Parser de comandos de relé
esp_err_t mqtt_parse_relay_command(cJSON* json, mqtt_command_struct_t* cmd)
{
    if (!json || !cmd) {
        return ESP_ERR_INVALID_ARG;
    }

    // Canal
    cJSON *channel_json = cJSON_GetObjectItem(json, "channel");
    if (!channel_json) {
        ESP_LOGE(TAG, "Campo 'channel' obrigatório não encontrado");
        return ESP_ERR_INVALID_ARG;
    }

    // Canal pode ser número ou string "all"
    if (cJSON_IsString(channel_json)) {
        const char* channel_str = cJSON_GetStringValue(channel_json);
        if (strcmp(channel_str, "all") == 0) {
            cmd->data.relay.channel = -1;  // -1 significa "all"
        } else {
            ESP_LOGE(TAG, "Valor de canal inválido: %s", channel_str);
            return ESP_ERR_INVALID_ARG;
        }
    } else if (cJSON_IsNumber(channel_json)) {
        int channel = cJSON_GetNumberValue(channel_json);
        if (channel < 1 || channel > 16) {
            ESP_LOGE(TAG, "Canal fora do range (1-16): %d", channel);
            return ESP_ERR_INVALID_ARG;
        }
        cmd->data.relay.channel = channel;
    } else {
        ESP_LOGE(TAG, "Campo 'channel' deve ser número ou 'all'");
        return ESP_ERR_INVALID_ARG;
    }

    // Comando
    cJSON *command_json = cJSON_GetObjectItem(json, "command");
    if (!command_json || !cJSON_IsString(command_json)) {
        ESP_LOGE(TAG, "Campo 'command' obrigatório não encontrado ou inválido");
        return ESP_ERR_INVALID_ARG;
    }

    const char* command_str = cJSON_GetStringValue(command_json);
    cmd->data.relay.cmd = string_to_relay_cmd(command_str);
    if (cmd->data.relay.cmd == -1) {
        ESP_LOGE(TAG, "Comando inválido: %s", command_str);
        return ESP_ERR_INVALID_ARG;
    }

    // Campos opcionais
    cJSON *source_json = cJSON_GetObjectItem(json, "source");
    if (source_json && cJSON_IsString(source_json)) {
        strncpy(cmd->data.relay.source, cJSON_GetStringValue(source_json), sizeof(cmd->data.relay.source) - 1);
        cmd->data.relay.source[sizeof(cmd->data.relay.source) - 1] = '\0';
    } else {
        strcpy(cmd->data.relay.source, "unknown");
    }

    cJSON *user_json = cJSON_GetObjectItem(json, "user");
    if (user_json && cJSON_IsString(user_json)) {
        strncpy(cmd->data.relay.user, cJSON_GetStringValue(user_json), sizeof(cmd->data.relay.user) - 1);
        cmd->data.relay.user[sizeof(cmd->data.relay.user) - 1] = '\0';
    } else {
        strcpy(cmd->data.relay.user, "system");
    }

    // Tenta ambos os formatos: "momentary" e "is_momentary"
    cJSON *momentary_json = cJSON_GetObjectItem(json, "momentary");
    if (!momentary_json) {
        momentary_json = cJSON_GetObjectItem(json, "is_momentary");
    }
    cmd->data.relay.is_momentary = (momentary_json && cJSON_IsBool(momentary_json)) ? cJSON_IsTrue(momentary_json) : false;

    ESP_LOGI(TAG, "Comando de relé parsed: canal=%d, cmd=%s, source=%s, momentary=%s",
             cmd->data.relay.channel,
             relay_cmd_to_string(cmd->data.relay.cmd),
             cmd->data.relay.source,
             cmd->data.relay.is_momentary ? "true" : "false");

    return ESP_OK;
}

// Parser de comandos gerais
esp_err_t mqtt_parse_general_command(cJSON* json, mqtt_command_struct_t* cmd)
{
    if (!json || !cmd) {
        return ESP_ERR_INVALID_ARG;
    }

    // Comando
    cJSON *command_json = cJSON_GetObjectItem(json, "command");
    if (!command_json || !cJSON_IsString(command_json)) {
        ESP_LOGE(TAG, "Campo 'command' obrigatório não encontrado");
        return ESP_ERR_INVALID_ARG;
    }

    const char* command_str = cJSON_GetStringValue(command_json);
    cmd->data.general.cmd = string_to_general_cmd(command_str);
    if (cmd->data.general.cmd == -1) {
        ESP_LOGE(TAG, "Comando geral inválido: %s", command_str);
        return ESP_ERR_INVALID_ARG;
    }

    // Campos específicos por comando
    switch (cmd->data.general.cmd) {
        case GENERAL_CMD_RESET:
            {
                cJSON *type_json = cJSON_GetObjectItem(json, "type");
                if (type_json && cJSON_IsString(type_json)) {
                    strncpy(cmd->data.general.type, cJSON_GetStringValue(type_json), sizeof(cmd->data.general.type) - 1);
                    cmd->data.general.type[sizeof(cmd->data.general.type) - 1] = '\0';
                } else {
                    strcpy(cmd->data.general.type, "all");
                }
            }
            break;

        case GENERAL_CMD_REBOOT:
            {
                cJSON *delay_json = cJSON_GetObjectItem(json, "delay");
                cmd->data.general.delay = (delay_json && cJSON_IsNumber(delay_json)) ? 
                                         cJSON_GetNumberValue(delay_json) : 5;
                if (cmd->data.general.delay < 0 || cmd->data.general.delay > 300) {
                    ESP_LOGW(TAG, "Delay inválido, usando 5s: %d", cmd->data.general.delay);
                    cmd->data.general.delay = 5;
                }
            }
            break;

        case GENERAL_CMD_OTA:
            {
                cJSON *url_json = cJSON_GetObjectItem(json, "url");
                if (url_json && cJSON_IsString(url_json)) {
                    strncpy(cmd->data.general.data, cJSON_GetStringValue(url_json), sizeof(cmd->data.general.data) - 1);
                    cmd->data.general.data[sizeof(cmd->data.general.data) - 1] = '\0';
                } else {
                    ESP_LOGE(TAG, "URL obrigatória para comando OTA");
                    return ESP_ERR_INVALID_ARG;
                }
            }
            break;

        case GENERAL_CMD_STATUS:
        default:
            break;
    }

    ESP_LOGI(TAG, "Comando geral parsed: %s", general_cmd_to_string(cmd->data.general.cmd));
    return ESP_OK;
}

// Processador principal de comandos
esp_err_t mqtt_process_command_struct(mqtt_command_struct_t* cmd)
{
    if (!cmd) {
        return ESP_ERR_INVALID_ARG;
    }

    esp_err_t ret = ESP_OK;

    switch (cmd->type) {
        case MQTT_CMD_RELAY:
            ret = mqtt_process_relay_command(cmd);
            break;

        case MQTT_CMD_GENERAL:
            ret = mqtt_process_general_command(cmd);
            break;

        default:
            ESP_LOGE(TAG, "Tipo de comando não suportado: %d", cmd->type);
            ret = ESP_ERR_NOT_SUPPORTED;
            break;
    }

    return ret;
}

// Processador de comandos de relé
esp_err_t mqtt_process_relay_command(mqtt_command_struct_t* cmd)
{
    if (!cmd || cmd->type != MQTT_CMD_RELAY) {
        return ESP_ERR_INVALID_ARG;
    }

    ESP_LOGI(TAG, "Processando comando de relé: canal=%d, cmd=%s",
             cmd->data.relay.channel, relay_cmd_to_string(cmd->data.relay.cmd));

    esp_err_t ret = ESP_OK;

    if (cmd->data.relay.channel == -1) {
        // Comando para todos os relés
        bool target_state = (cmd->data.relay.cmd == RELAY_CMD_ON);
        ESP_LOGI(TAG, "Comando ALL: definindo todos os relés para %s", target_state ? "ON" : "OFF");
        
        for (int i = 0; i < 16; i++) {
            if (cmd->data.relay.cmd == RELAY_CMD_ON) {
                relay_turn_on(i);
            } else if (cmd->data.relay.cmd == RELAY_CMD_OFF) {
                relay_turn_off(i);
            } else if (cmd->data.relay.cmd == RELAY_CMD_TOGGLE) {
                relay_toggle_state(i);
            }
            
            // Publicar telemetria para cada canal
            mqtt_publish_relay_telemetry(i + 1, relay_get_state(i), "mqtt", cmd->data.relay.source);
        }
    } else {
        // Comando para canal específico
        int channel_idx = cmd->data.relay.channel - 1;  // Converter para índice 0-15
        
        if (channel_idx < 0 || channel_idx >= 16) {
            ESP_LOGE(TAG, "Índice de canal inválido: %d", channel_idx);
            return ESP_ERR_INVALID_ARG;
        }

        ESP_LOGI(TAG, "Executando comando no canal %d (índice %d)%s", 
                 cmd->data.relay.channel, channel_idx,
                 cmd->data.relay.is_momentary ? " [MOMENTÂNEO]" : "");

        switch (cmd->data.relay.cmd) {
            case RELAY_CMD_ON:
                relay_turn_on(channel_idx);
                ESP_LOGI(TAG, "Relé %d ligado%s", cmd->data.relay.channel,
                        cmd->data.relay.is_momentary ? " (modo momentâneo)" : "");
                
                // Se for momentâneo, ativa monitoramento
                if (cmd->data.relay.is_momentary) {
                    ESP_LOGW(TAG, "⚠️ Relé %d em modo momentâneo - iniciando monitoramento", cmd->data.relay.channel);
                    mqtt_momentary_start(cmd->data.relay.channel);
                }
                break;

            case RELAY_CMD_OFF:
                relay_turn_off(channel_idx);
                ESP_LOGI(TAG, "Relé %d desligado", cmd->data.relay.channel);
                // Para monitoramento momentâneo se estiver ativo
                mqtt_momentary_stop(cmd->data.relay.channel);
                break;

            case RELAY_CMD_TOGGLE:
                relay_toggle_state(channel_idx);
                ESP_LOGI(TAG, "Relé %d alternado", cmd->data.relay.channel);
                break;

            default:
                ESP_LOGE(TAG, "Comando de relé inválido: %d", cmd->data.relay.cmd);
                return ESP_ERR_INVALID_ARG;
        }

        // Publicar telemetria
        bool current_state = relay_get_state(channel_idx);
        mqtt_publish_relay_telemetry(cmd->data.relay.channel, current_state, "mqtt", cmd->data.relay.source);
    }

    // Publicar estado atualizado
    mqtt_publish_status();
    
    return ret;
}

// Processador de comandos gerais
esp_err_t mqtt_process_general_command(mqtt_command_struct_t* cmd)
{
    if (!cmd || cmd->type != MQTT_CMD_GENERAL) {
        return ESP_ERR_INVALID_ARG;
    }

    ESP_LOGI(TAG, "Processando comando geral: %s", general_cmd_to_string(cmd->data.general.cmd));

    switch (cmd->data.general.cmd) {
        case GENERAL_CMD_RESET:
            {
                ESP_LOGI(TAG, "Executando reset: %s", cmd->data.general.type);
                
                if (strcmp(cmd->data.general.type, "all") == 0 || 
                    strcmp(cmd->data.general.type, "relays") == 0) {
                    // Reset todos os relés
                    for (int i = 0; i < 16; i++) {
                        relay_turn_off(i);
                    }
                    ESP_LOGI(TAG, "Todos os relés resetados para OFF");
                }
                
                if (strcmp(cmd->data.general.type, "all") == 0 || 
                    strcmp(cmd->data.general.type, "config") == 0) {
                    // TODO: Implementar reset de configuração se necessário
                    ESP_LOGI(TAG, "Reset de configuração não implementado");
                }
                
                // Publicar estado atualizado
                mqtt_publish_status();
            }
            break;

        case GENERAL_CMD_STATUS:
            {
                ESP_LOGI(TAG, "Solicitação de status recebida");
                // Publicar status atual
                mqtt_publish_status();
            }
            break;

        case GENERAL_CMD_REBOOT:
            {
                ESP_LOGW(TAG, "Reinicializando sistema em %d segundos...", cmd->data.general.delay);
                
                // Publicar telemetria de reboot
                telemetry_event_t event = {
                    .channel = 0,
                    .state = false,
                    .timestamp = time(NULL)
                };
                strcpy(event.event_type, "system_reboot");
                strcpy(event.trigger, "mqtt");
                strcpy(event.source, "command");
                mqtt_publish_telemetry_event(&event);
                
                // Salvar configurações antes de reiniciar
                config_save();
                
                // Aguardar delay e reiniciar
                vTaskDelay(pdMS_TO_TICKS(cmd->data.general.delay * 1000));
                esp_restart();
            }
            break;

        case GENERAL_CMD_OTA:
            {
                ESP_LOGW(TAG, "Comando OTA recebido, mas não implementado: %s", cmd->data.general.data);
                // TODO: Implementar OTA update
                return ESP_ERR_NOT_SUPPORTED;
            }
            break;

        default:
            ESP_LOGE(TAG, "Comando geral não suportado: %d", cmd->data.general.cmd);
            return ESP_ERR_NOT_SUPPORTED;
    }

    return ESP_OK;
}

// Utilitários de conversão
const char* relay_cmd_to_string(relay_cmd_t cmd)
{
    switch (cmd) {
        case RELAY_CMD_ON:     return "on";
        case RELAY_CMD_OFF:    return "off";
        case RELAY_CMD_TOGGLE: return "toggle";
        case RELAY_CMD_ALL:    return "all";
        default:               return "unknown";
    }
}

relay_cmd_t string_to_relay_cmd(const char* str)
{
    if (!str) return -1;
    
    if (strcmp(str, "on") == 0)     return RELAY_CMD_ON;
    if (strcmp(str, "off") == 0)    return RELAY_CMD_OFF;
    if (strcmp(str, "toggle") == 0) return RELAY_CMD_TOGGLE;
    if (strcmp(str, "all") == 0)    return RELAY_CMD_ALL;
    
    return -1;
}

const char* general_cmd_to_string(general_cmd_t cmd)
{
    switch (cmd) {
        case GENERAL_CMD_RESET:  return "reset";
        case GENERAL_CMD_STATUS: return "status";
        case GENERAL_CMD_REBOOT: return "reboot";
        case GENERAL_CMD_OTA:    return "ota";
        default:                 return "unknown";
    }
}

general_cmd_t string_to_general_cmd(const char* str)
{
    if (!str) return -1;
    
    if (strcmp(str, "reset") == 0)  return GENERAL_CMD_RESET;
    if (strcmp(str, "status") == 0) return GENERAL_CMD_STATUS;
    if (strcmp(str, "reboot") == 0) return GENERAL_CMD_REBOOT;
    if (strcmp(str, "ota") == 0)    return GENERAL_CMD_OTA;
    
    return -1;
}