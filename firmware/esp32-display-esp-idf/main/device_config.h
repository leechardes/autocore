#ifndef DEVICE_CONFIG_H
#define DEVICE_CONFIG_H

/**
 * Device Configuration
 * Based on AutoTech HMI Display v2
 * 
 * Central configuration file for ESP32-2432S028R board
 */

// ==================== Device Information ====================
#define DEVICE_ID "esp32_display_1"
#define DEVICE_TYPE "hmi_display"
#define DEVICE_VERSION "1.0.0"
#define DEVICE_NAME "ESP32 Display Controller"

// ==================== Network Configuration ====================
// WiFi Settings
#define DEFAULT_WIFI_SSID ""
#define DEFAULT_WIFI_PASSWORD ""
#define WIFI_TIMEOUT 30000           // Connection timeout (ms)
#define WIFI_RETRY_DELAY 5000        // Retry delay (ms)
#define WIFI_MAX_RETRIES 3

// MQTT Settings
#define DEFAULT_MQTT_BROKER ""
#define DEFAULT_MQTT_PORT 1883
#define MQTT_USER ""
#define MQTT_PASSWORD ""
#define MQTT_KEEPALIVE_SECONDS 60
#define MQTT_BUFFER_SIZE 20480       // 20KB buffer
#define MQTT_RECONNECT_DELAY 5000    // Reconnect delay (ms)

// MQTT Topics
#define MQTT_TOPIC_PREFIX "autocore/"
#define MQTT_TOPIC_COMMAND "/display/command"
#define MQTT_TOPIC_STATUS "/display/status"
#define MQTT_TOPIC_TELEMETRY "/display/telemetry"
#define MQTT_TOPIC_CONFIG "/display/config"

// ==================== Hardware Configuration ====================
// Display Hardware (ILI9341 - ESP32-2432S028R)
#define DISPLAY_WIDTH_NATIVE 240     // Native width
#define DISPLAY_HEIGHT_NATIVE 320    // Native height
#define DISPLAY_WIDTH 320            // After rotation (landscape)
#define DISPLAY_HEIGHT 240           // After rotation (landscape)
#define DISPLAY_ROTATION 1           // 0=0°, 1=90°, 2=180°, 3=270°

// Display SPI Pins (HSPI)
#define TFT_MISO 12                  // Can share with RST
#define TFT_MOSI 13
#define TFT_SCLK 14
#define TFT_CS 15
#define TFT_DC 2
#define TFT_RST 12                   // Shares with MISO
#define TFT_BL 21                    // Backlight PWM

// Display SPI Configuration
#define TFT_SPI_FREQUENCY 65000000   // 65 MHz (optimal for ESP32-2432S028R)
#define TFT_SPI_READ_FREQ 20000000   // 20 MHz for reading
#define TFT_COLOR_INVERT true        // Fix for white background

// Touch Controller (XPT2046 - VSPI)
#define TOUCH_CS 33
#define TOUCH_IRQ 36
#define TOUCH_MOSI 32                // VSPI MOSI
#define TOUCH_MISO 39                // VSPI MISO
#define TOUCH_CLK 25                 // VSPI Clock
#define TOUCH_SPI_FREQ 2500000       // 2.5 MHz

// Touch Calibration (ESP32-2432S028R specific)
#define TOUCH_MIN_X 200
#define TOUCH_MAX_X 3700
#define TOUCH_MIN_Y 240
#define TOUCH_MAX_Y 3800
#define TOUCH_PRESSURE_MIN 200
#define TOUCH_PRESSURE_MAX 3000

// Buttons (if available)
#define BTN_PREV_PIN 35              // Previous button
#define BTN_SELECT_PIN 0             // Select/Boot button
#define BTN_NEXT_PIN 34              // Next button

// Status LEDs (if available)
#define LED_R_PIN 4                  // Red LED
#define LED_G_PIN 16                 // Green LED
#define LED_B_PIN 17                 // Blue LED

// ==================== Performance Configuration ====================
// Memory Allocation
#define JSON_DOCUMENT_SIZE 20480     // 20KB for JSON parsing
#define LVGL_MEM_SIZE (64 * 1024)    // 64KB for LVGL
#define LVGL_BUFFER_SIZE (DISPLAY_WIDTH * 10)  // 3200 pixels

// Task Configuration
#define DISPLAY_TASK_STACK 4096
#define DISPLAY_TASK_PRIORITY 5
#define DISPLAY_TASK_CORE 1          // Dedicated core for display

#define UI_TASK_STACK 4096
#define UI_TASK_PRIORITY 4
#define UI_TASK_CORE 0               // UI logic on core 0

#define NETWORK_TASK_STACK 4096
#define NETWORK_TASK_PRIORITY 3
#define NETWORK_TASK_CORE 0          // Network on core 0

// Timing Configuration
#define LVGL_TICK_PERIOD 5           // LVGL tick period (ms)
#define DISPLAY_REFRESH_PERIOD 30    // Display refresh (ms)
#define TOUCH_READ_PERIOD 30         // Touch read period (ms)
#define FPS_UPDATE_PERIOD 1000       // FPS counter update (ms)

// Update Intervals
#define CONFIG_REQUEST_INTERVAL 10000    // Request config (ms)
#define STATUS_REPORT_INTERVAL 30000     // Status report (ms)
#define HEARTBEAT_INTERVAL 60000         // Heartbeat (ms)
#define TELEMETRY_INTERVAL 30000         // Telemetry (ms)

// Button Configuration
#define BUTTON_DEBOUNCE_DELAY 50        // Debounce delay (ms)
#define BUTTON_LONG_PRESS_TIME 1000     // Long press time (ms)
#define BUTTON_REPEAT_DELAY 500         // Repeat delay (ms)
#define BUTTON_REPEAT_RATE 100          // Repeat rate (ms)

// ==================== Display Features ====================
#define ENABLE_ANIMATIONS true
#define ENABLE_ANTI_ALIASING true
#define ENABLE_SHADOWS false         // Disabled for performance
#define ENABLE_TRANSPARENCY false    // Disabled for performance
#define ENABLE_FPS_COUNTER true      // Show FPS in debug
#define ENABLE_TOUCH_FEEDBACK true   // Visual touch feedback

// Backlight Configuration
#define BACKLIGHT_PWM_FREQ 5000      // 5 KHz PWM
#define BACKLIGHT_PWM_RESOLUTION 8   // 8-bit (0-255)
#define BACKLIGHT_DEFAULT_LEVEL 100  // Default 100%
#define BACKLIGHT_MIN_LEVEL 10       // Minimum 10%
#define BACKLIGHT_FADE_TIME 500      // Fade time (ms)

// ==================== Debug Configuration ====================
#ifdef CONFIG_DEBUG_MODE
    #define DEBUG_SERIAL_BAUD 115200
    #define DEBUG_LOG_LEVEL ESP_LOG_DEBUG
    #define DEBUG_HEAP_CHECK_INTERVAL 10000  // Check heap every 10s
    #define DEBUG_PRINT_FPS true
    #define DEBUG_PRINT_TOUCH true
    #define DEBUG_PRINT_MEMORY true
#else
    #define DEBUG_LOG_LEVEL ESP_LOG_INFO
    #define DEBUG_PRINT_FPS false
    #define DEBUG_PRINT_TOUCH false
    #define DEBUG_PRINT_MEMORY false
#endif

// ==================== Safety Limits ====================
#define MAX_JSON_SIZE 32768          // Maximum JSON document (32KB)
#define MAX_MQTT_PAYLOAD 20480       // Maximum MQTT payload (20KB)
#define MIN_FREE_HEAP 10240          // Minimum free heap (10KB)
#define WATCHDOG_TIMEOUT 30000       // Watchdog timeout (30s)
#define MAX_RETRY_COUNT 5            // Maximum retry attempts

// ==================== Default Values ====================
#define DEFAULT_BRIGHTNESS 100       // Default brightness (%)
#define DEFAULT_VOLUME 50            // Default volume (%)
#define DEFAULT_TIMEOUT 60000        // Default timeout (ms)
#define DEFAULT_LANGUAGE "en"        // Default language

#endif // DEVICE_CONFIG_H