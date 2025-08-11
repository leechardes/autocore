#pragma once

#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

// Inicializa sistema de relés momentâneos
void mqtt_momentary_init(void);

// Ativa monitoramento de relé momentâneo
esp_err_t mqtt_momentary_start(int channel);

// Para monitoramento de relé momentâneo
esp_err_t mqtt_momentary_stop(int channel);

// Atualiza heartbeat de relé momentâneo
esp_err_t mqtt_momentary_heartbeat(int channel);

#ifdef __cplusplus
}
#endif