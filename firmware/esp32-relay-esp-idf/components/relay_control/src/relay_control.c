/**
 * ESP32 Relay Control Implementation
 * High-performance GPIO control for AutoCore ecosystem
 */

#include <string.h>
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_system.h"
#include "esp_timer.h"
#include "driver/gpio.h"

#include "relay_control.h"
#include "config_manager.h"

static const char *TAG = "RELAY_CONTROL";

// GPIO pin mapping (based on FUNCTIONAL_SPECIFICATION.md)
static const gpio_num_t relay_gpio_pins[RELAY_MAX_CHANNELS] = RELAY_GPIO_PINS;

// Relay status tracking
static relay_status_t relay_status[RELAY_MAX_CHANNELS];
static bool relay_control_initialized = false;
static uint32_t total_switch_count = 0;

// Forward declarations
static esp_err_t relay_configure_gpio(uint8_t channel);
static void relay_update_switch_count(uint8_t channel);

/**
 * Initialize relay control system
 */
esp_err_t relay_control_init(void) {
    esp_err_t ret = ESP_OK;
    
    // Initialize relay status structures
    for (int i = 0; i < RELAY_MAX_CHANNELS; i++) {
        relay_status[i].channel = i;
        relay_status[i].state = RELAY_STATE_OFF;
        relay_status[i].gpio_pin = relay_gpio_pins[i];
        relay_status[i].gpio_active = false;
        relay_status[i].switch_count = 0;
        relay_status[i].last_switch_time = 0;
        
        // Configure GPIO
        esp_err_t gpio_ret = relay_configure_gpio(i);
        if (gpio_ret == ESP_OK) {
            relay_status[i].gpio_active = true;
        } else {
            ESP_LOGE(TAG, "Failed to configure GPIO for channel %d: %s", 
                    i, esp_err_to_name(gpio_ret));
            ret = gpio_ret; // Keep the last error
        }
    }
    
    relay_control_initialized = true;
    
    ESP_LOGI(TAG, "Relay control initialized with %d channels", RELAY_MAX_CHANNELS);
    
    // Print GPIO mapping
    for (int i = 0; i < RELAY_MAX_CHANNELS; i++) {
        if (relay_status[i].gpio_active) {
            ESP_LOGI(TAG, "Channel %d -> GPIO %d (Active)", i, relay_gpio_pins[i]);
        } else {
            ESP_LOGW(TAG, "Channel %d -> GPIO %d (Failed)", i, relay_gpio_pins[i]);
        }
    }
    
    return ret;
}

/**
 * Configure GPIO for relay channel
 */
static esp_err_t relay_configure_gpio(uint8_t channel) {
    if (channel >= RELAY_MAX_CHANNELS) {
        return ESP_ERR_INVALID_ARG;
    }
    
    gpio_num_t gpio_pin = relay_gpio_pins[channel];
    
    // Configure GPIO as output
    gpio_config_t io_conf = {
        .intr_type = GPIO_INTR_DISABLE,
        .mode = GPIO_MODE_OUTPUT,
        .pin_bit_mask = (1ULL << gpio_pin),
        .pull_down_en = 0,
        .pull_up_en = 0,
    };
    
    esp_err_t ret = gpio_config(&io_conf);
    if (ret != ESP_OK) {
        return ret;
    }
    
    // Set initial state to OFF (LOW)
    ret = gpio_set_level(gpio_pin, RELAY_STATE_OFF);
    if (ret != ESP_OK) {
        return ret;
    }
    
    ESP_LOGD(TAG, "GPIO %d configured for relay channel %d", gpio_pin, channel);
    return ESP_OK;
}

/**
 * Set relay state
 */
esp_err_t relay_set_state(uint8_t channel, uint8_t state) {
    if (!relay_control_initialized) {
        ESP_LOGE(TAG, "Relay control not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    if (channel >= RELAY_MAX_CHANNELS) {
        ESP_LOGE(TAG, "Invalid relay channel: %d", channel);
        return ESP_ERR_INVALID_ARG;
    }
    
    if (state > RELAY_STATE_ON) {
        ESP_LOGE(TAG, "Invalid relay state: %d", state);
        return ESP_ERR_INVALID_ARG;
    }
    
    // Check if GPIO is active
    if (!relay_status[channel].gpio_active) {
        ESP_LOGE(TAG, "GPIO not active for channel %d", channel);
        return ESP_ERR_INVALID_STATE;
    }
    
    // Only proceed if state is actually changing
    if (relay_status[channel].state != state) {
        // Set GPIO level
        esp_err_t ret = gpio_set_level(relay_gpio_pins[channel], state);
        if (ret != ESP_OK) {
            ESP_LOGE(TAG, "Failed to set GPIO %d: %s", relay_gpio_pins[channel], esp_err_to_name(ret));
            return ret;
        }
        
        // Update status
        relay_status[channel].state = state;
        relay_update_switch_count(channel);
        
        // Update configuration
        config_set_relay_state(channel, state);
        
        ESP_LOGI(TAG, "🔌 Channel %d (GPIO %d): %s", 
                channel, relay_gpio_pins[channel], 
                state == RELAY_STATE_ON ? "ON" : "OFF");
    } else {
        ESP_LOGD(TAG, "Channel %d already in state %d", channel, state);
    }
    
    return ESP_OK;
}

/**
 * Get relay state
 */
int relay_get_state(uint8_t channel) {
    if (!relay_control_initialized || channel >= RELAY_MAX_CHANNELS) {
        return -1;
    }
    
    return relay_status[channel].state;
}

/**
 * Toggle relay state
 */
esp_err_t relay_toggle_state(uint8_t channel) {
    int current_state = relay_get_state(channel);
    if (current_state < 0) {
        return ESP_ERR_INVALID_ARG;
    }
    
    uint8_t new_state = (current_state == RELAY_STATE_ON) ? RELAY_STATE_OFF : RELAY_STATE_ON;
    return relay_set_state(channel, new_state);
}

/**
 * Turn on relay
 */
esp_err_t relay_turn_on(uint8_t channel) {
    return relay_set_state(channel, RELAY_STATE_ON);
}

/**
 * Turn off relay
 */
esp_err_t relay_turn_off(uint8_t channel) {
    return relay_set_state(channel, RELAY_STATE_OFF);
}

/**
 * Get all relay states
 */
esp_err_t relay_get_all_states(uint8_t* states) {
    if (!states) {
        return ESP_ERR_INVALID_ARG;
    }
    
    if (!relay_control_initialized) {
        ESP_LOGE(TAG, "Relay control not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    for (int i = 0; i < RELAY_MAX_CHANNELS; i++) {
        states[i] = relay_status[i].state;
    }
    
    return ESP_OK;
}

/**
 * Set all relay states
 */
esp_err_t relay_set_all_states(const uint8_t* states, uint8_t count) {
    if (!states || count > RELAY_MAX_CHANNELS) {
        return ESP_ERR_INVALID_ARG;
    }
    
    if (!relay_control_initialized) {
        ESP_LOGE(TAG, "Relay control not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    esp_err_t ret = ESP_OK;
    
    for (int i = 0; i < count; i++) {
        esp_err_t channel_ret = relay_set_state(i, states[i]);
        if (channel_ret != ESP_OK) {
            ESP_LOGW(TAG, "Failed to set channel %d state: %s", i, esp_err_to_name(channel_ret));
            ret = channel_ret; // Keep last error
        }
    }
    
    ESP_LOGI(TAG, "Set states for %d channels", count);
    return ret;
}

/**
 * Get relay status information
 */
esp_err_t relay_get_status(uint8_t channel, relay_status_t* status) {
    if (!status) {
        return ESP_ERR_INVALID_ARG;
    }
    
    if (!relay_control_initialized || channel >= RELAY_MAX_CHANNELS) {
        return ESP_ERR_INVALID_ARG;
    }
    
    memcpy(status, &relay_status[channel], sizeof(relay_status_t));
    return ESP_OK;
}

/**
 * Validate relay channel
 */
bool relay_is_valid_channel(uint8_t channel) {
    return (channel < RELAY_MAX_CHANNELS);
}

/**
 * Get GPIO pin for channel
 */
gpio_num_t relay_get_gpio_pin(uint8_t channel) {
    if (channel >= RELAY_MAX_CHANNELS) {
        return GPIO_NUM_NC;
    }
    
    return relay_gpio_pins[channel];
}

/**
 * Test relay GPIO
 */
esp_err_t relay_test_gpio(uint8_t channel) {
    if (channel >= RELAY_MAX_CHANNELS) {
        return ESP_ERR_INVALID_ARG;
    }
    
    if (!relay_status[channel].gpio_active) {
        return ESP_ERR_INVALID_STATE;
    }
    
    gpio_num_t gpio_pin = relay_gpio_pins[channel];
    
    // Test by setting and reading back
    esp_err_t ret = gpio_set_level(gpio_pin, 1);
    if (ret != ESP_OK) {
        return ret;
    }
    
    vTaskDelay(pdMS_TO_TICKS(10)); // 10ms delay
    
    int level = gpio_get_level(gpio_pin);
    if (level != 1) {
        ESP_LOGE(TAG, "GPIO %d test failed: expected 1, got %d", gpio_pin, level);
        return ESP_FAIL;
    }
    
    // Reset to original state
    ret = gpio_set_level(gpio_pin, relay_status[channel].state);
    
    ESP_LOGI(TAG, "GPIO %d test passed", gpio_pin);
    return ret;
}

/**
 * Save relay states to persistent storage
 */
esp_err_t relay_save_states(void) {
    if (!relay_control_initialized) {
        ESP_LOGE(TAG, "Relay control not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    // Update configuration with current states
    for (int i = 0; i < RELAY_MAX_CHANNELS; i++) {
        config_set_relay_state(i, relay_status[i].state);
    }
    
    // Save configuration
    esp_err_t ret = config_save();
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "Relay states saved successfully");
    } else {
        ESP_LOGE(TAG, "Failed to save relay states: %s", esp_err_to_name(ret));
    }
    
    return ret;
}

/**
 * Restore relay states from persistent storage
 */
esp_err_t relay_restore_states(void) {
    if (!relay_control_initialized) {
        ESP_LOGE(TAG, "Relay control not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    device_config_t* config = config_get();
    if (!config) {
        ESP_LOGE(TAG, "Failed to get configuration");
        return ESP_ERR_INVALID_STATE;
    }
    
    esp_err_t ret = ESP_OK;
    int restored_count = 0;
    
    // Restore states from configuration
    for (int i = 0; i < RELAY_MAX_CHANNELS; i++) {
        uint8_t saved_state = config->relay_states[i];
        
        if (saved_state <= RELAY_STATE_ON) {
            esp_err_t channel_ret = relay_set_state(i, saved_state);
            if (channel_ret == ESP_OK) {
                restored_count++;
                ESP_LOGD(TAG, "Restored channel %d to state %d", i, saved_state);
            } else {
                ESP_LOGW(TAG, "Failed to restore channel %d: %s", i, esp_err_to_name(channel_ret));
                ret = channel_ret;
            }
        } else {
            ESP_LOGW(TAG, "Invalid saved state %d for channel %d, defaulting to OFF", saved_state, i);
            relay_set_state(i, RELAY_STATE_OFF);
        }
    }
    
    ESP_LOGI(TAG, "Restored %d relay states", restored_count);
    return ret;
}

/**
 * Reset all relays to off state
 */
esp_err_t relay_reset_all(void) {
    if (!relay_control_initialized) {
        ESP_LOGE(TAG, "Relay control not initialized");
        return ESP_ERR_INVALID_STATE;
    }
    
    esp_err_t ret = ESP_OK;
    int reset_count = 0;
    
    for (int i = 0; i < RELAY_MAX_CHANNELS; i++) {
        esp_err_t channel_ret = relay_set_state(i, RELAY_STATE_OFF);
        if (channel_ret == ESP_OK) {
            reset_count++;
        } else {
            ESP_LOGW(TAG, "Failed to reset channel %d: %s", i, esp_err_to_name(channel_ret));
            ret = channel_ret;
        }
    }
    
    // Save the reset states
    relay_save_states();
    
    ESP_LOGI(TAG, "Reset %d relay channels to OFF", reset_count);
    return ret;
}

/**
 * Get active relay count
 */
uint8_t relay_get_active_count(void) {
    if (!relay_control_initialized) {
        return 0;
    }
    
    uint8_t active_count = 0;
    
    for (int i = 0; i < RELAY_MAX_CHANNELS; i++) {
        if (relay_status[i].state == RELAY_STATE_ON) {
            active_count++;
        }
    }
    
    return active_count;
}

/**
 * Get total switch count
 */
uint32_t relay_get_total_switches(void) {
    return total_switch_count;
}

/**
 * Update switch count for channel
 */
static void relay_update_switch_count(uint8_t channel) {
    relay_status[channel].switch_count++;
    relay_status[channel].last_switch_time = esp_timer_get_time() / 1000; // Convert to milliseconds
    total_switch_count++;
    
    ESP_LOGD(TAG, "Channel %d switch count: %lu, total: %lu", 
            channel, relay_status[channel].switch_count, total_switch_count);
}