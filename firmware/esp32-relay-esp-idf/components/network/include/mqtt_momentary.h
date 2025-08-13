#pragma once

#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

// Funções principais de heartbeat v2.2.0
void mqtt_momentary_init(void);
void mqtt_momentary_handle_heartbeat(const char *payload);
void mqtt_momentary_check_timeouts(void);
void mqtt_momentary_reset_channel(uint8_t channel);

// Funções de compatibilidade
esp_err_t mqtt_momentary_start(int channel);
esp_err_t mqtt_momentary_stop(int channel);
esp_err_t mqtt_momentary_heartbeat(int channel);

#ifdef __cplusplus
}
#endif