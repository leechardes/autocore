#ifndef XPT2046_H
#define XPT2046_H

#include <stdint.h>
#include <stdbool.h>
#include "esp_err.h"
#include "driver/spi_master.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * XPT2046 Touch Controller Driver
 * Based on AutoTech HMI Display v2 configuration
 */

// Touch calibration values (from HMI Display v2)
#define XPT2046_MIN_X 200
#define XPT2046_MAX_X 3700
#define XPT2046_MIN_Y 240
#define XPT2046_MAX_Y 3800

// Touch pressure threshold
#define XPT2046_MIN_PRESSURE 200
#define XPT2046_MAX_PRESSURE 3000

/**
 * Touch point structure
 */
typedef struct {
    uint16_t x;        // X coordinate (0-screen_width)
    uint16_t y;        // Y coordinate (0-screen_height)
    uint16_t z;        // Pressure (z-axis)
    bool pressed;      // Touch state
} xpt2046_touch_t;

/**
 * Touch configuration
 */
typedef struct {
    // SPI pins (VSPI)
    int mosi_gpio;     // Default: 32
    int miso_gpio;     // Default: 39
    int clk_gpio;      // Default: 25
    int cs_gpio;       // Default: 33
    int irq_gpio;      // Default: 36
    
    // Screen dimensions for mapping
    uint16_t screen_width;
    uint16_t screen_height;
    
    // Calibration values
    uint16_t min_x;
    uint16_t max_x;
    uint16_t min_y;
    uint16_t max_y;
    
    // SPI configuration
    uint32_t spi_freq;  // Default: 2.5MHz
    
    // Touch parameters
    uint16_t min_pressure;
    uint16_t max_pressure;
    uint8_t samples;     // Number of samples for averaging
    
    // Screen rotation (0-3)
    uint8_t rotation;
} xpt2046_config_t;

/**
 * Touch driver handle
 */
typedef struct xpt2046_s* xpt2046_handle_t;

/**
 * Touch event callback
 */
typedef void (*xpt2046_touch_cb_t)(xpt2046_touch_t *touch, void *user_data);

/**
 * Initialize XPT2046 touch controller
 * @param config Touch configuration
 * @param handle Pointer to store touch handle
 * @return ESP_OK on success
 */
esp_err_t xpt2046_init(const xpt2046_config_t *config, xpt2046_handle_t *handle);

/**
 * Deinitialize touch controller
 * @param handle Touch handle
 * @return ESP_OK on success
 */
esp_err_t xpt2046_deinit(xpt2046_handle_t handle);

/**
 * Read touch point
 * @param handle Touch handle
 * @param touch Pointer to store touch data
 * @return ESP_OK on success
 */
esp_err_t xpt2046_read_touch(xpt2046_handle_t handle, xpt2046_touch_t *touch);

/**
 * Check if touch is pressed (using IRQ pin)
 * @param handle Touch handle
 * @return true if pressed
 */
bool xpt2046_is_pressed(xpt2046_handle_t handle);

/**
 * Set touch callback (called from ISR)
 * @param handle Touch handle
 * @param callback Callback function
 * @param user_data User data for callback
 * @return ESP_OK on success
 */
esp_err_t xpt2046_set_callback(xpt2046_handle_t handle, 
                               xpt2046_touch_cb_t callback, 
                               void *user_data);

/**
 * Calibrate touch screen
 * @param handle Touch handle
 * @param points Calibration points (min 3)
 * @param count Number of calibration points
 * @return ESP_OK on success
 */
esp_err_t xpt2046_calibrate(xpt2046_handle_t handle, 
                            const xpt2046_touch_t *points, 
                            size_t count);

/**
 * Get raw touch values (for debugging)
 * @param handle Touch handle
 * @param x Raw X value
 * @param y Raw Y value
 * @param z Raw Z value (pressure)
 * @return ESP_OK on success
 */
esp_err_t xpt2046_get_raw(xpt2046_handle_t handle, 
                          uint16_t *x, uint16_t *y, uint16_t *z);

/**
 * Default configuration for ESP32-2432S028R
 */
#define XPT2046_DEFAULT_CONFIG() {          \
    .mosi_gpio = 32,                        \
    .miso_gpio = 39,                        \
    .clk_gpio = 25,                         \
    .cs_gpio = 33,                          \
    .irq_gpio = 36,                         \
    .screen_width = 320,                    \
    .screen_height = 240,                   \
    .min_x = XPT2046_MIN_X,                 \
    .max_x = XPT2046_MAX_X,                 \
    .min_y = XPT2046_MIN_Y,                 \
    .max_y = XPT2046_MAX_Y,                 \
    .spi_freq = 2500000,                    \
    .min_pressure = XPT2046_MIN_PRESSURE,   \
    .max_pressure = XPT2046_MAX_PRESSURE,   \
    .samples = 3,                           \
    .rotation = 1                           \
}

#ifdef __cplusplus
}
#endif

#endif // XPT2046_H