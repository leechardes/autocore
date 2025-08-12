#ifndef DISPLAY_DRIVER_H
#define DISPLAY_DRIVER_H

#include <stdint.h>
#include <stdbool.h>
#include "esp_err.h"
#include "driver/spi_master.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Display color formats
 */
typedef enum {
    DISPLAY_COLOR_MODE_RGB565,
    DISPLAY_COLOR_MODE_RGB666,
    DISPLAY_COLOR_MODE_RGB888,
    DISPLAY_COLOR_MODE_MONO,
} display_color_mode_t;

/**
 * Display rotation
 */
typedef enum {
    DISPLAY_ROTATION_0 = 0,
    DISPLAY_ROTATION_90 = 1,
    DISPLAY_ROTATION_180 = 2,
    DISPLAY_ROTATION_270 = 3,
} display_rotation_t;

/**
 * Display configuration
 */
typedef struct {
    uint16_t width;
    uint16_t height;
    uint8_t mosi_gpio;
    uint8_t sclk_gpio;
    uint8_t cs_gpio;
    uint8_t dc_gpio;
    int8_t rst_gpio;        // -1 if not used
    int8_t backlight_gpio;  // -1 if not used
    display_rotation_t rotation;
    display_color_mode_t color_mode;
    uint32_t spi_clock_speed;
    uint16_t buffer_size;   // Number of lines for partial buffer
} display_config_t;

/**
 * Display driver handle
 */
typedef struct display_driver_s* display_handle_t;

/**
 * Initialize display driver
 * @param config Display configuration
 * @param handle Pointer to store display handle
 * @return ESP_OK on success
 */
esp_err_t display_driver_init(const display_config_t* config, display_handle_t* handle);

/**
 * Deinitialize display driver
 * @param handle Display handle
 * @return ESP_OK on success
 */
esp_err_t display_driver_deinit(display_handle_t handle);

/**
 * Clear display with color
 * @param handle Display handle
 * @param color 16-bit color value (RGB565)
 * @return ESP_OK on success
 */
esp_err_t display_clear(display_handle_t handle, uint16_t color);

/**
 * Draw pixel
 * @param handle Display handle
 * @param x X coordinate
 * @param y Y coordinate
 * @param color 16-bit color value (RGB565)
 * @return ESP_OK on success
 */
esp_err_t display_draw_pixel(display_handle_t handle, int16_t x, int16_t y, uint16_t color);

/**
 * Draw line
 * @param handle Display handle
 * @param x0 Start X coordinate
 * @param y0 Start Y coordinate
 * @param x1 End X coordinate
 * @param y1 End Y coordinate
 * @param color 16-bit color value (RGB565)
 * @return ESP_OK on success
 */
esp_err_t display_draw_line(display_handle_t handle, int16_t x0, int16_t y0, 
                           int16_t x1, int16_t y1, uint16_t color);

/**
 * Draw rectangle
 * @param handle Display handle
 * @param x X coordinate
 * @param y Y coordinate
 * @param w Width
 * @param h Height
 * @param color 16-bit color value (RGB565)
 * @return ESP_OK on success
 */
esp_err_t display_draw_rect(display_handle_t handle, int16_t x, int16_t y, 
                           int16_t w, int16_t h, uint16_t color);

/**
 * Fill rectangle
 * @param handle Display handle
 * @param x X coordinate
 * @param y Y coordinate
 * @param w Width
 * @param h Height
 * @param color 16-bit color value (RGB565)
 * @return ESP_OK on success
 */
esp_err_t display_fill_rect(display_handle_t handle, int16_t x, int16_t y, 
                           int16_t w, int16_t h, uint16_t color);

/**
 * Draw bitmap
 * @param handle Display handle
 * @param x X coordinate
 * @param y Y coordinate
 * @param w Width
 * @param h Height
 * @param bitmap Bitmap data (RGB565)
 * @return ESP_OK on success
 */
esp_err_t display_draw_bitmap(display_handle_t handle, int16_t x, int16_t y, 
                             int16_t w, int16_t h, const uint16_t* bitmap);

/**
 * Set display rotation
 * @param handle Display handle
 * @param rotation Rotation value
 * @return ESP_OK on success
 */
esp_err_t display_set_rotation(display_handle_t handle, display_rotation_t rotation);

/**
 * Set backlight level
 * @param handle Display handle
 * @param level Backlight level (0-100)
 * @return ESP_OK on success
 */
esp_err_t display_set_backlight(display_handle_t handle, uint8_t level);

/**
 * Flush display buffer (for buffered displays)
 * @param handle Display handle
 * @return ESP_OK on success
 */
esp_err_t display_flush(display_handle_t handle);

/**
 * Get display width
 * @param handle Display handle
 * @return Display width in pixels
 */
uint16_t display_get_width(display_handle_t handle);

/**
 * Get display height
 * @param handle Display handle
 * @return Display height in pixels
 */
uint16_t display_get_height(display_handle_t handle);

/**
 * Common color definitions (RGB565 padrão)
 */
#define COLOR_BLACK       0x0000
#define COLOR_WHITE       0xFFFF
#define COLOR_RED         0xF800
#define COLOR_GREEN       0x07E0
#define COLOR_BLUE        0x001F
#define COLOR_YELLOW      0xFFE0
#define COLOR_CYAN        0x07FF
#define COLOR_MAGENTA     0xF81F
#define COLOR_ORANGE      0xFD20
#define COLOR_PURPLE      0x780F
#define COLOR_GRAY        0x8410
#define COLOR_DARK_GRAY   0x4208
#define COLOR_LIGHT_GRAY  0xC618

/**
 * Convert RGB888 to RGB565
 */
#define RGB888_TO_RGB565(r, g, b) (((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3))

#ifdef __cplusplus
}
#endif

#endif // DISPLAY_DRIVER_H