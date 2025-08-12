#ifndef UI_MANAGER_H
#define UI_MANAGER_H

#include <stdint.h>
#include <stdbool.h>
#include "esp_err.h"
#include "display_driver.h"
#include "xpt2046.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * UI Manager - Simple Button Interface
 * Creates 6 colorful buttons for testing display and touch
 */

// Button dimensions
#define BUTTON_WIDTH    100
#define BUTTON_HEIGHT   60
#define BUTTON_SPACING  10
#define BUTTON_BORDER   2

// Number of buttons
#define NUM_BUTTONS     6
#define BUTTONS_PER_ROW 3  // 3 buttons per row for landscape mode (3x2 grid)

// Button states
typedef enum {
    BUTTON_STATE_NORMAL = 0,
    BUTTON_STATE_PRESSED,
    BUTTON_STATE_DISABLED
} button_state_t;

// Button structure
typedef struct {
    uint16_t x;                 // X position
    uint16_t y;                 // Y position
    uint16_t width;             // Width
    uint16_t height;            // Height
    uint16_t color;             // Normal color
    uint16_t pressed_color;     // Pressed color
    uint16_t border_color;      // Border color
    const char* label;          // Button label
    button_state_t state;       // Current state
    uint32_t press_count;       // Press counter
    void (*callback)(uint8_t);  // Button callback
} button_t;

// UI Manager structure
typedef struct {
    display_handle_t display;
    xpt2046_handle_t touch;
    button_t buttons[NUM_BUTTONS];
    uint16_t bg_color;
    bool initialized;
    uint32_t total_touches;
} ui_manager_t;

/**
 * Initialize UI Manager
 * @param display Display handle
 * @param touch Touch handle (can be NULL)
 * @return ESP_OK on success
 */
esp_err_t ui_manager_init(display_handle_t display, xpt2046_handle_t touch);

/**
 * Deinitialize UI Manager
 * @return ESP_OK on success
 */
esp_err_t ui_manager_deinit(void);

/**
 * Draw all UI elements
 * @return ESP_OK on success
 */
esp_err_t ui_manager_draw(void);

/**
 * Update UI (check for touches and update display)
 * @return ESP_OK on success
 */
esp_err_t ui_manager_update(void);

/**
 * Handle touch event
 * @param x X coordinate
 * @param y Y coordinate
 * @param pressed True if pressed, false if released
 * @return ESP_OK on success
 */
esp_err_t ui_manager_handle_touch(uint16_t x, uint16_t y, bool pressed);

/**
 * Set button callback
 * @param button_id Button ID (0-5)
 * @param callback Callback function
 * @return ESP_OK on success
 */
esp_err_t ui_manager_set_button_callback(uint8_t button_id, void (*callback)(uint8_t));

/**
 * Set background color
 * @param color RGB565 color
 * @return ESP_OK on success
 */
esp_err_t ui_manager_set_background(uint16_t color);

/**
 * Clear screen
 * @return ESP_OK on success
 */
esp_err_t ui_manager_clear_screen(void);

/**
 * Draw text on screen
 * @param x X coordinate
 * @param y Y coordinate
 * @param text Text to draw
 * @param color Text color
 * @param bg_color Background color
 * @return ESP_OK on success
 */
esp_err_t ui_manager_draw_text(uint16_t x, uint16_t y, const char* text, 
                               uint16_t color, uint16_t bg_color);

/**
 * Get button press count
 * @param button_id Button ID (0-5)
 * @return Press count
 */
uint32_t ui_manager_get_press_count(uint8_t button_id);

/**
 * Get total touch count
 * @return Total touches
 */
uint32_t ui_manager_get_total_touches(void);

#ifdef __cplusplus
}
#endif

#endif // UI_MANAGER_H