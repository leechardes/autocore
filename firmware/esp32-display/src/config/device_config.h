/**
 * AutoCore ESP32 Display - Device Configuration
 * 
 * Define as estruturas de configuração e constantes do sistema
 * Baseado no padrão do firmware de relé, adaptado para displays touch
 */

#pragma once

#include <Arduino.h>
#include <ArduinoJson.h>

// ============================================
// CONFIGURAÇÕES DE HARDWARE
// ============================================

// Display TFT (ILI9341/ST7789)
#define TFT_WIDTH 320
#define TFT_HEIGHT 240
#define TFT_CS 15
#define TFT_DC 2
#define TFT_RST 4
#define TFT_MOSI 23
#define TFT_CLK 18
#define TFT_MISO 19
#define SPI_FREQUENCY 40000000

// Touch Controller (XPT2046/FT6236)
#define TOUCH_CS 5
#define TOUCH_IRQ 27
#define TOUCH_FREQUENCY 2500000

// Botões físicos (opcional)
#define BTN_PREV 32
#define BTN_SELECT 33
#define BTN_NEXT 25

// Emergency stop
#define EMERGENCY_SHUTOFF_PIN 0

// ============================================
// CONFIGURAÇÕES DE SOFTWARE
// ============================================

// Versioning
#define FIRMWARE_VERSION "1.0.0"
#define DEVICE_TYPE "display_touch"
#define MANUFACTURER "AutoCore"

// Logging
#define SERIAL_BAUDRATE 115200
#define LOG_LEVEL LOG_LEVEL_INFO

// Network
#define AP_SSID_PREFIX "ESP32_Display_"
#define AP_PASSWORD "autocore123"
#define WEB_SERVER_PORT 80
#define CONFIG_TIMEOUT_MS 300000  // 5 minutos

// MQTT
#define MQTT_DEVICE_TOPIC_PREFIX "autocore/display"
#define MQTT_KEEPALIVE 60
#define MQTT_BUFFER_SIZE 1024
#define MQTT_RECONNECT_INTERVAL 5000

// Display e UI
#define LVGL_TICK_PERIOD 5
#define SCREEN_TIMEOUT_MS 30000
#define UI_REFRESH_RATE 30  // FPS

// Sistema
#define WATCHDOG_TIMEOUT_S 30
#define HEARTBEAT_INTERVAL_MS 30000
#define TELEMETRY_INTERVAL_MS 5000
#define MAX_CONFIG_RETRIES 3

// ============================================
// ESTRUTURAS DE CONFIGURAÇÃO
// ============================================

/**
 * Configuração de tema visual
 */
struct DisplayTheme {
    String name;
    uint32_t primary_color;         // Cor primária (botões ativos)
    uint32_t secondary_color;       // Cor secundária (status positivo)
    uint32_t warning_color;         // Cor de aviso (ações momentâneas)
    uint32_t danger_color;          // Cor de perigo (emergency)
    uint32_t background_color;      // Cor do background
    uint32_t surface_color;         // Cor de superfícies elevadas
    uint32_t text_primary_color;    // Texto principal
    uint32_t text_secondary_color;  // Texto secundário
    
    int border_radius;              // Raio da borda (px)
    bool shadow_enabled;            // Habilitar sombras
    int animation_speed;            // Velocidade de animação (ms)
    int font_size_base;             // Tamanho base da fonte
    
    DisplayTheme() {
        // Tema dark neumorphic padrão
        name = "dark_neumorphic";
        primary_color = 0x007AFF;       // #007AFF
        secondary_color = 0x32D74B;     // #32D74B
        warning_color = 0xFF9500;       // #FF9500
        danger_color = 0xFF3B30;        // #FF3B30
        background_color = 0x1C1C1E;    // #1C1C1E
        surface_color = 0x2C2C2E;       // #2C2C2E
        text_primary_color = 0xFFFFFF;  // #FFFFFF
        text_secondary_color = 0x8E8E93;// #8E8E93
        
        border_radius = 10;
        shadow_enabled = true;
        animation_speed = 200;
        font_size_base = 11;
    }
};

/**
 * Configuração de um botão da interface
 */
struct ButtonConfig {
    String id;                      // ID único do botão
    String label;                   // Texto exibido
    String icon;                    // Ícone (unicode emoji)
    String type;                    // toggle, momentary, switch, pulse, navigation
    
    // Posição e layout
    int col;                        // Coluna no grid (0-based)
    int row;                        // Linha no grid (0-based)
    int width;                      // Largura personalizada (0 = automático)
    int height;                     // Altura personalizada (0 = automático)
    
    // Ação
    String action_type;             // relay, navigation, custom
    int action_channel;             // Canal do relé ou ID da tela
    String action_data;             // Dados extras da ação
    
    // Proteção e segurança
    bool requires_heartbeat;        // Requer heartbeat para ação momentânea
    int heartbeat_interval;         // Intervalo do heartbeat (ms)
    int timeout_ms;                 // Timeout da ação (ms)
    String protection_type;         // none, confirmation, password
    String protection_message;      // Mensagem de proteção
    
    // Visual
    uint32_t color_active;          // Cor quando ativo
    uint32_t color_inactive;        // Cor quando inativo
    bool custom_colors;             // Usar cores personalizadas
    
    ButtonConfig() {
        col = 0;
        row = 0;
        width = 0;
        height = 0;
        action_channel = 0;
        requires_heartbeat = false;
        heartbeat_interval = 500;
        timeout_ms = 1000;
        protection_type = "none";
        custom_colors = false;
        color_active = 0x007AFF;
        color_inactive = 0x2C2C2E;
    }
};

/**
 * Configuração de uma tela
 */
struct ScreenConfig {
    String id;                      // ID único da tela
    String title;                   // Título da tela
    String layout_type;             // grid, list, custom
    int layout_cols;                // Colunas do grid
    int layout_rows;                // Linhas do grid
    int layout_spacing;             // Espaçamento entre elementos
    int item_height;                // Altura dos itens (para lista)
    
    std::vector<ButtonConfig> buttons;  // Botões da tela
    
    ScreenConfig() {
        layout_type = "grid";
        layout_cols = 3;
        layout_rows = 2;
        layout_spacing = 4;
        item_height = 44;
    }
};

/**
 * Configuração principal do dispositivo
 */
struct DeviceConfig {
    // Identificação
    String device_uuid;             // UUID único do dispositivo
    String device_name;             // Nome amigável
    String device_type;             // Tipo do dispositivo
    
    // Rede
    String wifi_ssid;               // SSID da rede WiFi
    String wifi_password;           // Senha da rede WiFi
    bool wifi_static_ip;            // Usar IP estático
    String wifi_ip;                 // IP estático
    String wifi_gateway;            // Gateway
    String wifi_subnet;             // Máscara de sub-rede
    String wifi_dns1;               // DNS primário
    String wifi_dns2;               // DNS secundário
    
    // Backend API
    String backend_host;            // Host do backend
    int backend_port;               // Porta do backend
    String backend_api_key;         // Chave de API (se necessário)
    
    // MQTT
    String mqtt_broker;             // Broker MQTT
    int mqtt_port;                  // Porta MQTT
    String mqtt_user;               // Usuário MQTT
    String mqtt_password;           // Senha MQTT
    String mqtt_client_id;          // ID do cliente MQTT
    bool mqtt_use_ssl;              // Usar SSL/TLS
    
    // Display e UI
    DisplayTheme theme;             // Tema visual
    std::vector<ScreenConfig> screens;  // Configuração das telas
    String default_screen;          // Tela padrão
    int screen_timeout;             // Timeout da tela (ms)
    int brightness;                 // Brilho (0-100)
    bool auto_brightness;           // Ajuste automático de brilho
    
    // Sistema
    bool debug_enabled;             // Habilitar debug
    String timezone;                // Timezone
    bool ntp_enabled;               // Sincronização NTP
    String ntp_server;              // Servidor NTP
    
    // Flags de estado
    bool configured;                // Sistema configurado
    bool factory_reset_requested;   // Reset de fábrica solicitado
    unsigned long last_config_update;   // Última atualização da configuração
    
    DeviceConfig() {
        device_type = DEVICE_TYPE;
        device_name = "AutoCore Display";
        wifi_static_ip = false;
        backend_port = 8000;
        mqtt_port = 1883;
        mqtt_use_ssl = false;
        default_screen = "dashboard";
        screen_timeout = SCREEN_TIMEOUT_MS;
        brightness = 80;
        auto_brightness = false;
        debug_enabled = true;
        timezone = "America/Sao_Paulo";
        ntp_enabled = true;
        ntp_server = "pool.ntp.org";
        configured = false;
        factory_reset_requested = false;
        last_config_update = 0;
        
        // Gerar UUID baseado no MAC address se não existir
        if (device_uuid.length() == 0) {
            uint64_t mac = ESP.getEfuseMac();
            device_uuid = String(DEVICE_TYPE) + "-" + String((uint32_t)(mac >> 32), HEX) + String((uint32_t)mac, HEX);
        }
        
        // MQTT client ID padrão
        mqtt_client_id = device_uuid;
    }
};

// ============================================
// LOGS DE SISTEMA
// ============================================

enum LogLevel {
    LOG_LEVEL_NONE = 0,
    LOG_LEVEL_ERROR = 1,
    LOG_LEVEL_WARN = 2,
    LOG_LEVEL_INFO = 3,
    LOG_LEVEL_DEBUG = 4,
    LOG_LEVEL_VERBOSE = 5
};

// Macros de logging compatíveis com o firmware de relé
#define LOG_ERROR(format, ...) if(LOG_LEVEL >= LOG_LEVEL_ERROR) Serial.printf("[ERROR] " format "\n", ##__VA_ARGS__)
#define LOG_WARN(format, ...)  if(LOG_LEVEL >= LOG_LEVEL_WARN)  Serial.printf("[WARN]  " format "\n", ##__VA_ARGS__)
#define LOG_INFO(format, ...)  if(LOG_LEVEL >= LOG_LEVEL_INFO)  Serial.printf("[INFO]  " format "\n", ##__VA_ARGS__)
#define LOG_DEBUG(format, ...) if(LOG_LEVEL >= LOG_LEVEL_DEBUG) Serial.printf("[DEBUG] " format "\n", ##__VA_ARGS__)

// Macros contextualizadas
#define LOG_ERROR_CTX(ctx, format, ...) LOG_ERROR("[%s] " format, ctx, ##__VA_ARGS__)
#define LOG_WARN_CTX(ctx, format, ...)  LOG_WARN("[%s] " format, ctx, ##__VA_ARGS__)
#define LOG_INFO_CTX(ctx, format, ...)  LOG_INFO("[%s] " format, ctx, ##__VA_ARGS__)
#define LOG_DEBUG_CTX(ctx, format, ...) LOG_DEBUG("[%s] " format, ctx, ##__VA_ARGS__)

// Macros de sistema
#define LOG_MEMORY() LOG_DEBUG("Free heap: %d bytes", ESP.getFreeHeap())
#define LOG_SYSTEM() LOG_DEBUG("Uptime: %lu s, CPU: %d MHz", millis()/1000, ESP.getCpuFreqMHz())

// ============================================
// CONSTANTES DE STATUS
// ============================================

// Estados do sistema (compatível com firmware de relé)
enum SystemState {
    STATE_BOOTING = 0,
    STATE_CONFIGURING = 1,
    STATE_CONNECTING = 2,
    STATE_RUNNING = 3,
    STATE_ERROR = 4,
    STATE_RECOVERY = 5,
    STATE_SLEEPING = 6,
    STATE_UPDATING = 7
};

// Estados da UI
enum UIState {
    UI_INITIALIZING = 0,
    UI_READY = 1,
    UI_LOADING = 2,
    UI_ERROR = 3,
    UI_SLEEPING = 4
};

// Tipos de eventos MQTT
enum MQTTEventType {
    MQTT_BUTTON_PRESS = 0,
    MQTT_BUTTON_RELEASE = 1,
    MQTT_SCREEN_CHANGE = 2,
    MQTT_SYSTEM_ALERT = 3,
    MQTT_USER_INTERACTION = 4
};