/**
 * @file DeviceConfig.h
 * @brief Configurações do dispositivo - MODIFIQUE ESTE ARQUIVO CONFORME NECESSÁRIO
 * 
 * Este arquivo contém todas as configurações parametrizáveis do dispositivo.
 * Altere os valores conforme sua necessidade antes de compilar.
 */

#ifndef DEVICE_CONFIG_H
#define DEVICE_CONFIG_H

// ============================================================================
// IDENTIFICAÇÃO DO DISPOSITIVO
// ============================================================================
// UUID será gerado automaticamente baseado no MAC address
// Formato: "esp32-display-AABBCCDDEEFF" onde AABBCCDDEEFF são os últimos 6 bytes do MAC
#define DEVICE_UUID_PREFIX "esp32-display-"     // Prefixo do UUID
#define DEVICE_TYPE "esp32_display"            // Tipo do dispositivo
#define DEVICE_VERSION "2.2.0"                 // Versão do firmware (atualizado para v2.2.0)
#define PROTOCOL_VERSION "2.2.0"               // Versão do protocolo MQTT
#define GENERATE_UUID_FROM_MAC true            // Gerar UUID a partir do MAC address
// DEVICE_ID será gerado dinamicamente: hmi_display_[últimos_6_chars_do_UUID]

// ============================================================================
// CONFIGURAÇÕES DE REDE WiFi
// ============================================================================
#define WIFI_SSID "Lee"                        // Nome da rede WiFi
#define WIFI_PASSWORD "lee159753"              // Senha da rede WiFi
#define WIFI_TIMEOUT 30000                     // Timeout de conexão WiFi (ms)
#define WIFI_RETRY_DELAY 5000                  // Delay entre tentativas (ms)

// ============================================================================
// CONFIGURAÇÕES MQTT
// ============================================================================
#define MQTT_BROKER "10.0.10.100"              // IP do broker MQTT
#define MQTT_PORT 1883                         // Porta do broker MQTT
#define MQTT_USER "autocore"                   // Usuário MQTT (deixe vazio se não usar)
#define MQTT_PASSWORD "kskLrz8uqg9K4WY8BsIUQYV6Cu07UDqr" // Senha MQTT (deixe vazio se não usar)
#define MQTT_KEEPALIVE_SECONDS 60              // Keep alive em segundos
#define MQTT_BUFFER_SIZE 20480                 // Tamanho do buffer MQTT (20KB para suportar config grande)
#define MQTT_RECONNECT_DELAY 5000              // Delay reconexão MQTT (ms)

// ============================================================================
// CONFIGURAÇÕES API REST
// ============================================================================
#define API_SERVER "10.0.10.100"               // IP do servidor API
#define API_PORT 8081                          // Porta do servidor API
#define API_PROTOCOL "http"                    // Protocolo (http ou https)
#define API_BASE_PATH "/api"                   // Path base da API
#define API_TIMEOUT 10000                      // Timeout das requisições API (ms)
#define API_RETRY_COUNT 3                      // Número de tentativas em caso de falha
#define API_RETRY_DELAY 2000                   // Delay entre tentativas (ms)
#define API_CACHE_TTL 300000                   // Tempo de vida do cache (5 minutos em ms)
#define API_USE_AUTH false                     // Usar autenticação na API
#define API_AUTH_TOKEN ""                      // Token de autenticação (se API_USE_AUTH = true)

// ============================================================================
// CONFIGURAÇÕES DE HARDWARE
// ============================================================================
// Pinos dos botões
#define BTN_PREV_PIN 35                        // Botão Previous/Anterior
#define BTN_SELECT_PIN 0                       // Botão Select/OK
#define BTN_NEXT_PIN 34                        // Botão Next/Próximo

// Pinos dos LEDs RGB
#define LED_R_PIN 4                            // LED Vermelho
#define LED_G_PIN 16                           // LED Verde  
#define LED_B_PIN 17                           // LED Azul

// Display
#define TFT_BACKLIGHT_PIN 21                   // Pino do backlight
#define SCREEN_WIDTH 320                       // Largura do display
#define SCREEN_HEIGHT 240                      // Altura do display
#define DEFAULT_BACKLIGHT 100                  // Backlight padrão (0-100)

// Touch Screen XPT2046
#define XPT2046_IRQ 36                         // Pino de interrupção do touch
#define XPT2046_MOSI 32                        // MOSI do touch (VSPI)
#define XPT2046_MISO 39                        // MISO do touch (VSPI)
#define XPT2046_CLK 25                         // Clock do touch (VSPI)
#define XPT2046_CS 33                          // Chip Select do touch

// Calibração do Touch Screen (valores específicos para ESP32-2432S028R)
#define TOUCH_MIN_X 200                        // Valor mínimo X
#define TOUCH_MAX_X 3700                       // Valor máximo X
#define TOUCH_MIN_Y 240                        // Valor mínimo Y
#define TOUCH_MAX_Y 3800                       // Valor máximo Y

// ============================================================================
// CONFIGURAÇÕES DE COMPORTAMENTO
// ============================================================================
// Timings
#define CONFIG_REQUEST_INTERVAL 10000          // Intervalo entre requests de config (ms)
#define STATUS_REPORT_INTERVAL 30000           // Intervalo de relatório de status (ms)
#define HEARTBEAT_INTERVAL 60000               // Intervalo de heartbeat (ms)
#define BUTTON_DEBOUNCE_DELAY 50               // Debounce dos botões (ms)
#define BUTTON_LONG_PRESS_TIME 1000            // Tempo para long press (ms)

// Touch Screen - Configurações melhoradas
#define TOUCH_MIN_PRESSURE 400          // Threshold maior para evitar ruído
#define TOUCH_DEBOUNCE_TIME 100         // Debounce maior
#define TOUCH_STATE_CONFIRM_TIME 150    // Tempo para confirmar mudança de estado

// Recursos
#define ENABLE_OTA true                        // Habilitar atualização OTA
#define ENABLE_WEB_CONFIG false                // Habilitar configuração via web
#define ENABLE_SD_CARD false                   // Habilitar cartão SD
#define ENABLE_SOUND true                      // Habilitar sons/beeps

// Debug
#define DEBUG_LEVEL 2                          // 0=OFF, 1=ERROR, 2=INFO, 3=DEBUG
#define SERIAL_BAUD_RATE 115200                // Velocidade da serial

// ============================================================================
// CONFIGURAÇÕES AVANÇADAS
// ============================================================================
// Memória
#define JSON_DOCUMENT_SIZE 20480               // Tamanho do documento JSON (20KB para suportar config grande)
#define MAX_SCREENS 20                         // Número máximo de telas
#define MAX_ITEMS_PER_SCREEN 50                // Máximo de itens por tela

// LVGL
#define LVGL_TICK_PERIOD 5                     // Período do tick LVGL (ms)
#define LVGL_BUFFER_SIZE (SCREEN_WIDTH * 10)  // Tamanho do buffer LVGL

// Tópicos MQTT personalizados (opcional)
#define CUSTOM_STATUS_TOPIC ""                 // Deixe vazio para usar padrão
#define CUSTOM_CONFIG_TOPIC ""                 // Deixe vazio para usar padrão
#define CUSTOM_COMMAND_TOPIC ""                // Deixe vazio para usar padrão

// ============================================================================
// NÃO MODIFIQUE ABAIXO DESTA LINHA
// ============================================================================

// Validações
#if MQTT_BUFFER_SIZE < 1024
    #error "MQTT_BUFFER_SIZE deve ser pelo menos 1024"
#endif

#if JSON_DOCUMENT_SIZE < 2048
    #error "JSON_DOCUMENT_SIZE deve ser pelo menos 2048"
#endif

// Macros auxiliares
#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)

#endif // DEVICE_CONFIG_H