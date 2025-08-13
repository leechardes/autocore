/**
 * MQTT Error Handling Header for ESP32 Relay v2.2.0
 * Cabeçalho para tratamento de erros MQTT conforme protocolo v2.2.0
 */

#pragma once

#include <stdint.h>
#include "esp_err.h"
#include "cJSON.h"
#include "mqtt_protocol.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Publica erro simples sem contexto adicional
 * 
 * @param code Código do erro conforme mqtt_error_code_t
 * @param message Mensagem descritiva do erro
 */
void mqtt_publish_error(mqtt_error_code_t code, const char *message);

/**
 * Publica erro com contexto JSON adicional
 * 
 * @param code Código do erro conforme mqtt_error_code_t
 * @param message Mensagem descritiva do erro
 * @param context JSON com informações adicionais do erro (pode ser NULL)
 */
void mqtt_publish_error_with_context(mqtt_error_code_t code, 
                                    const char *message, 
                                    cJSON *context);

/**
 * Publica evento de safety shutoff quando heartbeat expira
 * 
 * @param channel Canal do relé (1-16)
 * @param source_uuid UUID da fonte que enviava heartbeat
 * @param last_heartbeat Timestamp do último heartbeat em ms
 */
void mqtt_publish_safety_shutoff_event(uint8_t channel, const char *source_uuid, 
                                      uint32_t last_heartbeat);

/**
 * Publica erro específico para comando MQTT inválido
 * 
 * @param command Comando que causou o erro
 * @param reason Razão do erro
 */
void mqtt_publish_invalid_command_error(const char *command, const char *reason);

/**
 * Publica erro específico para canal de relé inválido
 * 
 * @param channel Canal inválido recebido
 */
void mqtt_publish_invalid_channel_error(int channel);

/**
 * Publica erro específico para timeout de heartbeat
 * 
 * @param channel Canal que sofreu timeout
 * @param elapsed_ms Tempo decorrido desde último heartbeat
 */
void mqtt_publish_heartbeat_timeout_error(int channel, uint32_t elapsed_ms);

/**
 * Publica erro específico para versão de protocolo incompatível
 * 
 * @param received_version Versão recebida na mensagem
 */
void mqtt_publish_protocol_mismatch_error(const char *received_version);

/**
 * Publica erro específico para falha de hardware
 * 
 * @param channel Canal que apresentou falha
 * @param error_detail Detalhes do erro de hardware
 */
void mqtt_publish_hardware_error(int channel, const char *error_detail);

#ifdef __cplusplus
}
#endif