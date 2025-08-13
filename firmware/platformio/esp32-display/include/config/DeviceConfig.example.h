/**
 * @file DeviceConfig.example.h
 * @brief Exemplos de configurações para diferentes cenários
 * 
 * Copie as configurações desejadas para DeviceConfig.h
 */

// ============================================================================
// EXEMPLO 1: Produção com Servidor MQTT Remoto
// ============================================================================
/*
#define DEVICE_ID "hmi_prod_01"
#define WIFI_SSID "AutoCore_Producao"
#define WIFI_PASSWORD "senha_forte_123"
#define MQTT_BROKER "mqtt.autotech.com.br"
#define MQTT_PORT 8883  // TLS
#define MQTT_USER "hmi_user"
#define MQTT_PASSWORD "mqtt_password"
#define DEBUG_LEVEL 0  // Sem debug
#define STATUS_REPORT_INTERVAL 300000  // 5 minutos
*/

// ============================================================================
// EXEMPLO 2: Desenvolvimento Local
// ============================================================================
/*
#define DEVICE_ID "hmi_dev_test"
#define WIFI_SSID "DevNetwork"
#define WIFI_PASSWORD "dev123"
#define MQTT_BROKER "localhost"
#define MQTT_PORT 1883
#define DEBUG_LEVEL 3  // Debug completo
#define CONFIG_REQUEST_INTERVAL 5000  // 5 segundos
*/

// ============================================================================
// EXEMPLO 3: Modo Access Point (ESP32 cria própria rede)
// ============================================================================
/*
#define DEVICE_ID "hmi_ap_mode"
#define WIFI_MODE_AP true
#define WIFI_AP_SSID "AutoCore-Config"
#define WIFI_AP_PASS "12345678"
#define MQTT_BROKER "192.168.4.1"  // IP do AP
#define ENABLE_WEB_CONFIG true
*/

// ============================================================================
// EXEMPLO 4: Múltiplos Displays (cada um com ID único)
// ============================================================================
/*
// Display 1 - Painel Principal
#define DEVICE_ID "hmi_main_panel"
#define BTN_PREV_PIN 32
#define BTN_SELECT_PIN 33
#define BTN_NEXT_PIN 25

// Display 2 - Painel Secundário
#define DEVICE_ID "hmi_secondary_panel"
#define BTN_PREV_PIN 26
#define BTN_SELECT_PIN 27
#define BTN_NEXT_PIN 14
*/

// ============================================================================
// EXEMPLO 5: Hardware Customizado
// ============================================================================
/*
#define DEVICE_ID "hmi_custom_hw"
// Botões em pinos diferentes
#define BTN_PREV_PIN 5
#define BTN_SELECT_PIN 18
#define BTN_NEXT_PIN 19
// Sem LEDs RGB
#define LED_R_PIN -1
#define LED_G_PIN -1
#define LED_B_PIN -1
// Display diferente
#define SCREEN_WIDTH 480
#define SCREEN_HEIGHT 320
*/

// ============================================================================
// EXEMPLO 6: Baixo Consumo de Energia
// ============================================================================
/*
#define DEVICE_ID "hmi_low_power"
#define STATUS_REPORT_INTERVAL 600000  // 10 minutos
#define HEARTBEAT_INTERVAL 1800000     // 30 minutos
#define DEFAULT_BACKLIGHT 50           // 50% brilho
#define ENABLE_AUTO_DIM true
#define AUTO_DIM_TIMEOUT 30000         // Dim após 30s
*/

// ============================================================================
// EXEMPLO 7: Alta Performance
// ============================================================================
/*
#define DEVICE_ID "hmi_high_perf"
#define MQTT_BUFFER_SIZE 4096          // Buffer maior
#define JSON_DOCUMENT_SIZE 8192        // JSON maior
#define MAX_SCREENS 50                 // Mais telas
#define LVGL_BUFFER_SIZE (320 * 40)    // Buffer maior
#define LVGL_TICK_PERIOD 2             // Update mais rápido
*/

// ============================================================================
// EXEMPLO 8: Tópicos MQTT Customizados
// ============================================================================
/*
#define DEVICE_ID "hmi_custom_topics"
#define CUSTOM_STATUS_TOPIC "empresa/fabrica/linha1/hmi/status"
#define CUSTOM_CONFIG_TOPIC "empresa/fabrica/linha1/hmi/config"
#define CUSTOM_COMMAND_TOPIC "empresa/fabrica/linha1/hmi/cmd"
*/