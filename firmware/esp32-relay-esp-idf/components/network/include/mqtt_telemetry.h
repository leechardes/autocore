#pragma once

#include "mqtt_protocol.h"
#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

// Funções de telemetria
esp_err_t mqtt_publish_telemetry_event(telemetry_event_t* event);
esp_err_t mqtt_publish_relay_telemetry(int channel, bool state, const char* trigger, const char* source);
esp_err_t mqtt_publish_safety_shutoff(int channel, const char* reason, float timeout);

#ifdef __cplusplus
}
#endif