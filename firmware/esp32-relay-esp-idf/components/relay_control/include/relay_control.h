/**
 * ESP32 Relay Control
 * GPIO-based relay control with state persistence
 * 
 * Compatible with AutoCore ecosystem
 * Based on FUNCTIONAL_SPECIFICATION.md
 */

#ifndef RELAY_CONTROL_H
#define RELAY_CONTROL_H

#include <stdbool.h>
#include <stdint.h>
#include "driver/gpio.h"

#ifdef __cplusplus
extern "C" {
#endif

// Relay control constants
#define RELAY_MAX_CHANNELS CONFIG_ESP32_RELAY_MAX_CHANNELS
#define RELAY_STATE_OFF 0
#define RELAY_STATE_ON 1

// GPIO pin mapping for relays (based on specification)
#define RELAY_GPIO_PINS { \
    GPIO_NUM_2,  GPIO_NUM_4,  GPIO_NUM_5,  GPIO_NUM_12, \
    GPIO_NUM_13, GPIO_NUM_14, GPIO_NUM_15, GPIO_NUM_16, \
    GPIO_NUM_17, GPIO_NUM_18, GPIO_NUM_19, GPIO_NUM_21, \
    GPIO_NUM_22, GPIO_NUM_23, GPIO_NUM_25, GPIO_NUM_26  \
}

// Relay status structure
typedef struct {
    uint8_t channel;
    uint8_t state;
    gpio_num_t gpio_pin;
    bool gpio_active;
    uint32_t switch_count;
    uint32_t last_switch_time;
} relay_status_t;

/**
 * Initialize relay control system
 * Configures GPIO pins and restores states
 * @return ESP_OK on success
 */
esp_err_t relay_control_init(void);

/**
 * Set relay state
 * Controls relay and updates persistent state
 * @param channel Relay channel (0-15)
 * @param state Relay state (0 or 1)
 * @return ESP_OK on success
 */
esp_err_t relay_set_state(uint8_t channel, uint8_t state);

/**
 * Get relay state
 * Returns current relay state
 * @param channel Relay channel (0-15)
 * @return Relay state (0 or 1), -1 on error
 */
int relay_get_state(uint8_t channel);

/**
 * Toggle relay state
 * Switches relay between on and off
 * @param channel Relay channel (0-15)
 * @return ESP_OK on success
 */
esp_err_t relay_toggle_state(uint8_t channel);

/**
 * Turn on relay
 * Convenience function to turn relay on
 * @param channel Relay channel (0-15)
 * @return ESP_OK on success
 */
esp_err_t relay_turn_on(uint8_t channel);

/**
 * Turn off relay
 * Convenience function to turn relay off
 * @param channel Relay channel (0-15)
 * @return ESP_OK on success
 */
esp_err_t relay_turn_off(uint8_t channel);

/**
 * Get all relay states
 * Returns array of all relay states
 * @param states Output array (must be at least RELAY_MAX_CHANNELS)
 * @return ESP_OK on success
 */
esp_err_t relay_get_all_states(uint8_t* states);

/**
 * Set all relay states
 * Sets multiple relay states at once
 * @param states Input array of states
 * @param count Number of states to set
 * @return ESP_OK on success
 */
esp_err_t relay_set_all_states(const uint8_t* states, uint8_t count);

/**
 * Get relay status information
 * Returns detailed status including GPIO info
 * @param channel Relay channel (0-15)
 * @param status Output status structure
 * @return ESP_OK on success
 */
esp_err_t relay_get_status(uint8_t channel, relay_status_t* status);

/**
 * Validate relay channel
 * Checks if channel number is valid
 * @param channel Relay channel to validate
 * @return true if valid
 */
bool relay_is_valid_channel(uint8_t channel);

/**
 * Get GPIO pin for channel
 * Returns GPIO pin number for relay channel
 * @param channel Relay channel (0-15)
 * @return GPIO pin number, GPIO_NUM_NC on error
 */
gpio_num_t relay_get_gpio_pin(uint8_t channel);

/**
 * Test relay GPIO
 * Tests if GPIO is functional
 * @param channel Relay channel (0-15)
 * @return ESP_OK if GPIO is working
 */
esp_err_t relay_test_gpio(uint8_t channel);

/**
 * Save relay states to persistent storage
 * Updates configuration with current states
 * @return ESP_OK on success
 */
esp_err_t relay_save_states(void);

/**
 * Restore relay states from persistent storage
 * Loads states from configuration and applies them
 * @return ESP_OK on success
 */
esp_err_t relay_restore_states(void);

/**
 * Reset all relays to off state
 * Turns off all relays and saves state
 * @return ESP_OK on success
 */
esp_err_t relay_reset_all(void);

/**
 * Get active relay count
 * Returns number of currently active relays
 * @return Number of active relays
 */
uint8_t relay_get_active_count(void);

/**
 * Get total switch count
 * Returns total number of relay switches since boot
 * @return Total switch count
 */
uint32_t relay_get_total_switches(void);

#ifdef __cplusplus
}
#endif

#endif // RELAY_CONTROL_H