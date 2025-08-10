#ifndef DEVICE_CONFIG_H
#define DEVICE_CONFIG_H

#include <Arduino.h>

// ============================================
// CONFIGURAÇÕES GERAIS DO DISPOSITIVO
// ============================================

// Informações do dispositivo
#define DEVICE_TYPE "esp32_relay"
#define FIRMWARE_VERSION "1.0.0-beta"
#define HARDWARE_VERSION "1.0"
#define MANUFACTURER "AutoCore"

// WiFi Access Point (modo configuração)
#define AP_SSID_PREFIX "ESP32_Relay_"
#define AP_PASSWORD "autocore123"
#define AP_IP "192.168.4.1"
#define AP_GATEWAY "192.168.4.1"
#define AP_SUBNET "255.255.255.0"

// Servidor web
#define WEB_SERVER_PORT 80
#define CONFIG_PORTAL_TIMEOUT 300000  // 5 minutos

// ============================================
// CONFIGURAÇÕES MQTT
// ============================================

// Tópicos MQTT base
#define MQTT_BASE_TOPIC "autocore"
#define MQTT_DEVICE_TOPIC_PREFIX "autocore/devices"

// Timeouts MQTT
#define MQTT_RECONNECT_INTERVAL 5000    // 5 segundos
#define MQTT_KEEPALIVE 60              // 60 segundos
#define MQTT_TIMEOUT 10000             // 10 segundos

// Heartbeat sistema
#define STATUS_PUBLISH_INTERVAL 30000   // 30 segundos
#define TELEMETRY_PUBLISH_INTERVAL 5000 // 5 segundos

// ============================================
// CONFIGURAÇÕES DE RELÉS
// ============================================

// Máximo de canais de relé suportados
#define MAX_RELAY_CHANNELS 32

// Heartbeat para relés momentâneos
#define HEARTBEAT_TIMEOUT_MS 1000      // 1 segundo
#define HEARTBEAT_CHECK_INTERVAL 100   // 100ms

// Proteções de segurança
#define MAX_ON_TIME_MS 300000          // 5 minutos máximo ligado
#define EMERGENCY_SHUTOFF_PIN 0        // Pino GPIO0 (BOOT button)
#define RELAY_COMMAND_TIMEOUT 5000     // 5 segundos para processar comando

// ============================================
// PINOS GPIO PADRÃO
// ============================================

// LEDs indicadores (se disponíveis)
#define STATUS_LED_PIN 2               // LED azul onboard
#define WIFI_LED_PIN -1                // Não usado
#define MQTT_LED_PIN -1                // Não usado

// Pinos de relé (configuráveis via web)
// Estes são os pinos padrão, mas podem ser alterados
static const int DEFAULT_RELAY_PINS[] = {
    4, 5, 12, 13, 14, 15, 16, 17,     // Canais 1-8
    18, 19, 21, 22, 23, 25, 26, 27,   // Canais 9-16
    32, 33, 34, 35, 36, 39            // Canais 17-22 (limitado pelos pinos disponíveis)
};

// ============================================
// CONFIGURAÇÕES DE WATCHDOG
// ============================================

#define WATCHDOG_TIMEOUT_S 30          // 30 segundos
#define TASK_WATCHDOG_TIMEOUT_S 10     // 10 segundos por task

// ============================================
// CONFIGURAÇÕES DE LOG
// ============================================

#define SERIAL_BAUDRATE 115200
#define DEBUG_ENABLED true

// Níveis de log
typedef enum {
    LOG_ERROR = 0,
    LOG_WARN  = 1, 
    LOG_INFO  = 2,
    LOG_DEBUG = 3
} log_level_t;

#define LOG_LEVEL LOG_DEBUG

// ============================================
// CONFIGURAÇÕES NVS
// ============================================

// Namespaces para armazenamento
#define NVS_NAMESPACE "autocore"
#define NVS_WIFI_NAMESPACE "wifi_config"
#define NVS_RELAY_NAMESPACE "relay_config" 
#define NVS_DEVICE_NAMESPACE "device_config"

// Keys para configurações
#define NVS_KEY_DEVICE_UUID "device_uuid"
#define NVS_KEY_DEVICE_NAME "device_name"
#define NVS_KEY_BACKEND_IP "backend_ip"
#define NVS_KEY_BACKEND_PORT "backend_port"
#define NVS_KEY_MQTT_BROKER "mqtt_broker"
#define NVS_KEY_MQTT_PORT "mqtt_port"
#define NVS_KEY_MQTT_USER "mqtt_user" 
#define NVS_KEY_MQTT_PASS "mqtt_pass"
#define NVS_KEY_WIFI_SSID "wifi_ssid"
#define NVS_KEY_WIFI_PASS "wifi_pass"
#define NVS_KEY_CONFIG_DONE "config_done"

// ============================================
// CONFIGURAÇÕES DE REDE
// ============================================

#define WIFI_CONNECT_TIMEOUT 30000     // 30 segundos
#define WIFI_RECONNECT_INTERVAL 10000  // 10 segundos
#define HTTP_REQUEST_TIMEOUT 10000     // 10 segundos

// ============================================
// ESTRUTURAS DE DADOS
// ============================================

// Estrutura para configuração de um canal de relé
struct RelayChannelConfig {
    bool enabled = false;
    int gpio_pin = -1;
    String name = "";
    String function_type = "toggle";  // toggle, momentary, pulse, timed
    bool require_password = false;
    String password_hash = "";
    bool require_confirmation = false;
    bool dual_action_enabled = false;
    int dual_action_channel = -1;
    int max_on_time_ms = 0;           // 0 = sem limite
    bool time_window_enabled = false;
    int time_window_start = 0;        // Minutos desde meia-noite
    int time_window_end = 1440;       // Minutos desde meia-noite
    bool allow_in_macro = true;
    bool inverted_logic = false;      // true = HIGH desliga, LOW liga
};

// Estrutura para configuração geral do dispositivo
struct DeviceConfig {
    String device_uuid = "";
    String device_name = "";
    String backend_ip = "";
    int backend_port = 8000;
    String mqtt_broker = "";
    int mqtt_port = 1883;
    String mqtt_user = "";
    String mqtt_password = "";
    String wifi_ssid = "";
    String wifi_password = "";
    bool config_completed = false;
    RelayChannelConfig channels[MAX_RELAY_CHANNELS];
    int total_channels = 16;          // Padrão: 16 canais
};

// Estrutura para estado de um canal
struct RelayChannelState {
    bool current_state = false;
    unsigned long last_state_change = 0;
    unsigned long last_heartbeat = 0;
    bool waiting_for_heartbeat = false;
    unsigned long turn_on_time = 0;
    int heartbeat_sequence = 0;
    bool safety_shutoff_triggered = false;
};

// ============================================
// MACROS UTILITÁRIAS
// ============================================

// Geração de UUID simples baseado no MAC
#define GENERATE_UUID_FROM_MAC() (String("esp32-relay-") + WiFi.macAddress().substring(12,17).toLowerCase().replace(":", ""))

// Validação de pino GPIO
#define IS_VALID_GPIO(pin) ((pin >= 0 && pin <= 39) && pin != 6 && pin != 7 && pin != 8 && pin != 9 && pin != 10 && pin != 11)

// Macros para log (implementadas em logger.cpp)
#define LOG_ERROR_F(format, ...) logPrint(LOG_ERROR, __FILE__, __LINE__, format, ##__VA_ARGS__)
#define LOG_WARN_F(format, ...)  logPrint(LOG_WARN, __FILE__, __LINE__, format, ##__VA_ARGS__)
#define LOG_INFO_F(format, ...)  logPrint(LOG_INFO, __FILE__, __LINE__, format, ##__VA_ARGS__)
#define LOG_DEBUG_F(format, ...) logPrint(LOG_DEBUG, __FILE__, __LINE__, format, ##__VA_ARGS__)

#endif // DEVICE_CONFIG_H