/**
 * UI Manager Implementation
 * Simple button interface for ESP32 Display
 */

#include <string.h>
#include <stdio.h>
#include "ui_manager.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static const char *TAG = "UI_MANAGER";

// Global UI manager instance
static ui_manager_t ui = {0};

// Simple font data (5x7 font for basic text)
static const uint8_t font5x7[][5] = {
    {0x00, 0x00, 0x00, 0x00, 0x00}, // Space
    {0x00, 0x00, 0x5F, 0x00, 0x00}, // !
    {0x00, 0x07, 0x00, 0x07, 0x00}, // "
    {0x14, 0x7F, 0x14, 0x7F, 0x14}, // #
    // Add more characters as needed
    {0x3E, 0x51, 0x49, 0x45, 0x3E}, // 0
    {0x00, 0x42, 0x7F, 0x40, 0x00}, // 1
    {0x42, 0x61, 0x51, 0x49, 0x46}, // 2
    {0x21, 0x41, 0x45, 0x4B, 0x31}, // 3
    {0x18, 0x14, 0x12, 0x7F, 0x10}, // 4
    {0x27, 0x45, 0x45, 0x45, 0x39}, // 5
    {0x3C, 0x4A, 0x49, 0x49, 0x30}, // 6
    {0x01, 0x71, 0x09, 0x05, 0x03}, // 7
    {0x36, 0x49, 0x49, 0x49, 0x36}, // 8
    {0x06, 0x49, 0x49, 0x29, 0x1E}, // 9
};

// Button colors
static const uint16_t button_colors[NUM_BUTTONS] = {
    COLOR_RED,        // Button 1
    COLOR_GREEN,      // Button 2
    COLOR_BLUE,       // Button 3
    COLOR_YELLOW,     // Button 4
    COLOR_PURPLE,     // Button 5
    COLOR_ORANGE      // Button 6
};

// Button pressed colors (darker versions)
static const uint16_t button_pressed_colors[NUM_BUTTONS] = {
    0x8000,  // Dark Red
    0x03E0,  // Dark Green
    0x0010,  // Dark Blue
    0x8400,  // Dark Yellow
    0x4008,  // Dark Purple
    0x8200   // Dark Orange
};

// Button labels
static const char* button_labels[NUM_BUTTONS] = {
    "BTN 1",
    "BTN 2", 
    "BTN 3",
    "BTN 4",
    "BTN 5",
    "BTN 6"
};

/**
 * Draw a single character
 */
static void draw_char(uint16_t x, uint16_t y, char c, uint16_t color, uint16_t bg_color, uint8_t size) {
    if (!ui.display) return;
    
    // Simple character drawing (limited to numbers and basic chars)
    for (int8_t i = 0; i < 5; i++) {
        uint8_t line = 0;
        
        // Get font data for character
        if (c >= '0' && c <= '9') {
            line = font5x7[c - '0' + 5][i];
        } else if (c == ' ') {
            line = font5x7[0][i];
        } else {
            // Default to a block for unknown chars
            line = 0x7F;
        }
        
        for (int8_t j = 0; j < 7; j++) {
            if (line & 0x01) {
                if (size == 1) {
                    display_draw_pixel(ui.display, x + i, y + j, color);
                } else {
                    display_fill_rect(ui.display, x + i * size, y + j * size, 
                                    size, size, color);
                }
            } else if (bg_color != color) {
                if (size == 1) {
                    display_draw_pixel(ui.display, x + i, y + j, bg_color);
                } else {
                    display_fill_rect(ui.display, x + i * size, y + j * size, 
                                    size, size, bg_color);
                }
            }
            line >>= 1;
        }
    }
}

/**
 * Draw a string
 */
static void draw_string(uint16_t x, uint16_t y, const char* str, uint16_t color, uint16_t bg_color, uint8_t size) {
    if (!ui.display || !str) return;
    
    uint16_t cursor_x = x;
    while (*str) {
        draw_char(cursor_x, y, *str, color, bg_color, size);
        cursor_x += 6 * size; // Character width + spacing
        str++;
    }
}

/**
 * Draw a single button
 */
static void draw_button(button_t *btn) {
    if (!ui.display || !btn) return;
    
    uint16_t fill_color = (btn->state == BUTTON_STATE_PRESSED) ? 
                         btn->pressed_color : btn->color;
    
    // Draw button background
    display_fill_rect(ui.display, btn->x, btn->y, 
                     btn->width, btn->height, fill_color);
    
    // Draw border
    display_draw_rect(ui.display, btn->x, btn->y, 
                     btn->width, btn->height, btn->border_color);
    display_draw_rect(ui.display, btn->x + 1, btn->y + 1, 
                     btn->width - 2, btn->height - 2, btn->border_color);
    
    // Draw label (centered)
    if (btn->label) {
        uint16_t text_width = strlen(btn->label) * 6 * 2; // Size 2 text
        uint16_t text_height = 7 * 2;
        uint16_t text_x = btn->x + (btn->width - text_width) / 2;
        uint16_t text_y = btn->y + (btn->height - text_height) / 2;
        
        draw_string(text_x, text_y, btn->label, COLOR_WHITE, fill_color, 2);
    }
    
    // Draw press count in corner
    if (btn->press_count > 0) {
        char count_str[16];
        snprintf(count_str, sizeof(count_str), "%lu", (unsigned long)btn->press_count);
        draw_string(btn->x + 5, btn->y + 5, count_str, COLOR_WHITE, fill_color, 1);
    }
}

/**
 * Default button callbacks
 */
static void button1_callback(uint8_t id) {
    ESP_LOGI(TAG, "Button 1 pressed! Toggle backlight");
    static uint8_t backlight = 100;
    backlight = (backlight == 100) ? 20 : 100;
    display_set_backlight(ui.display, backlight);
}

static void button2_callback(uint8_t id) {
    ESP_LOGI(TAG, "Button 2 pressed! Change background");
    static uint8_t bg_index = 0;
    uint16_t colors[] = {COLOR_BLACK, COLOR_WHITE, COLOR_GRAY, COLOR_DARK_GRAY};
    bg_index = (bg_index + 1) % 4;
    ui.bg_color = colors[bg_index];
    ui_manager_draw();
}

static void button3_callback(uint8_t id) {
    ESP_LOGI(TAG, "Button 3 pressed! Show touch count: %lu", ui.total_touches);
}

static void button4_callback(uint8_t id) {
    ESP_LOGI(TAG, "Button 4 pressed! Draw test pattern");
    // Draw some test patterns
    for (int i = 0; i < 10; i++) {
        display_draw_line(ui.display, 160, 120, 
                         160 + i * 10, 0, COLOR_CYAN);
        display_draw_line(ui.display, 160, 120, 
                         160 + i * 10, 240, COLOR_MAGENTA);
    }
}

static void button5_callback(uint8_t id) {
    ESP_LOGI(TAG, "Button 5 pressed! System info");
    ESP_LOGI(TAG, "Free heap: %lu bytes", esp_get_free_heap_size());
    ESP_LOGI(TAG, "Total touches: %lu", ui.total_touches);
}

static void button6_callback(uint8_t id) {
    ESP_LOGI(TAG, "Button 6 pressed! Clear screen");
    ui_manager_clear_screen();
    ui_manager_draw();
}

/**
 * Initialize UI Manager
 */
esp_err_t ui_manager_init(display_handle_t display, xpt2046_handle_t touch) {
    if (!display) {
        ESP_LOGE(TAG, "Invalid display handle");
        return ESP_ERR_INVALID_ARG;
    }
    
    ESP_LOGI(TAG, "Initializing UI Manager");
    
    // Store handles
    ui.display = display;
    ui.touch = touch;
    ui.bg_color = COLOR_GRAY;  // Mudando para cinza para visualizar melhor
    ui.total_touches = 0;
    
    // Get display dimensions (landscape mode: 320x240)
    uint16_t screen_width = 320;
    uint16_t screen_height = 240;
    
    // Calculate button positions (3x2 grid for landscape, centered)
    uint16_t total_width = (BUTTON_WIDTH * BUTTONS_PER_ROW) + 
                          (BUTTON_SPACING * (BUTTONS_PER_ROW - 1));
    uint16_t total_height = (BUTTON_HEIGHT * 2) + (BUTTON_SPACING * 1);  // 2 rows for landscape
    
    uint16_t start_x = (screen_width - total_width) / 2;
    uint16_t start_y = (screen_height - total_height) / 2;
    
    // Initialize buttons
    for (int i = 0; i < NUM_BUTTONS; i++) {
        int row = i / BUTTONS_PER_ROW;
        int col = i % BUTTONS_PER_ROW;
        
        ui.buttons[i].x = start_x + col * (BUTTON_WIDTH + BUTTON_SPACING);
        ui.buttons[i].y = start_y + row * (BUTTON_HEIGHT + BUTTON_SPACING);
        ui.buttons[i].width = BUTTON_WIDTH;
        ui.buttons[i].height = BUTTON_HEIGHT;
        ui.buttons[i].color = button_colors[i];
        ui.buttons[i].pressed_color = button_pressed_colors[i];
        ui.buttons[i].border_color = COLOR_WHITE;
        ui.buttons[i].label = button_labels[i];
        ui.buttons[i].state = BUTTON_STATE_NORMAL;
        ui.buttons[i].press_count = 0;
        ui.buttons[i].callback = NULL;
        
        ESP_LOGI(TAG, "Button %d at (%d, %d)", i, ui.buttons[i].x, ui.buttons[i].y);
    }
    
    // Set default callbacks
    ui.buttons[0].callback = button1_callback;
    ui.buttons[1].callback = button2_callback;
    ui.buttons[2].callback = button3_callback;
    ui.buttons[3].callback = button4_callback;
    ui.buttons[4].callback = button5_callback;
    ui.buttons[5].callback = button6_callback;
    
    ui.initialized = true;
    
    ESP_LOGI(TAG, "UI Manager initialized successfully");
    return ESP_OK;
}

/**
 * Deinitialize UI Manager
 */
esp_err_t ui_manager_deinit(void) {
    ui.initialized = false;
    ui.display = NULL;
    ui.touch = NULL;
    
    ESP_LOGI(TAG, "UI Manager deinitialized");
    return ESP_OK;
}

/**
 * Draw all UI elements
 */
esp_err_t ui_manager_draw(void) {
    if (!ui.initialized || !ui.display) {
        return ESP_ERR_INVALID_STATE;
    }
    
    ESP_LOGI(TAG, "Drawing orientation test screen...");
    
    // Clear entire screen to black first
    display_clear(ui.display, COLOR_BLACK);
    vTaskDelay(pdMS_TO_TICKS(100));
    
    // Draw three color bands:
    // Top third - WHITE (0 to 80)
    display_fill_rect(ui.display, 0, 0, 320, 80, COLOR_WHITE);
    
    // Middle third - GREEN (80 to 160)
    display_fill_rect(ui.display, 0, 80, 320, 80, COLOR_GREEN);
    
    // Bottom third - BLUE (160 to 240)
    display_fill_rect(ui.display, 0, 160, 320, 80, COLOR_BLUE);
    
    // Draw RIGHT arrow in the top (white) section
    // Arrow shaft - horizontal line
    for(int i = -5; i <= 5; i++) {
        display_draw_line(ui.display, 140, 40 + i, 180, 40 + i, COLOR_BLACK);
    }
    
    // Arrow head (pointing right) - draw > shape
    for(int i = 0; i < 20; i++) {
        display_draw_pixel(ui.display, 180 - i, 40 - i, COLOR_BLACK);
        display_draw_pixel(ui.display, 180 - i, 40 + i, COLOR_BLACK);
        // Make arrow thicker
        display_draw_pixel(ui.display, 180 - i - 1, 40 - i, COLOR_BLACK);
        display_draw_pixel(ui.display, 180 - i - 1, 40 + i, COLOR_BLACK);
        display_draw_pixel(ui.display, 180 - i, 40 - i - 1, COLOR_BLACK);
        display_draw_pixel(ui.display, 180 - i, 40 + i + 1, COLOR_BLACK);
    }
    
    // Draw UP arrow in the middle (green) section
    // Arrow shaft - vertical line
    for(int i = -5; i <= 5; i++) {
        display_draw_line(ui.display, 160 + i, 140, 160 + i, 100, COLOR_BLACK);
    }
    
    // Arrow head (pointing up) - draw V shape
    for(int i = 0; i < 20; i++) {
        display_draw_pixel(ui.display, 160 - i, 100 + i, COLOR_BLACK);
        display_draw_pixel(ui.display, 160 + i, 100 + i, COLOR_BLACK);
        // Make arrow thicker
        display_draw_pixel(ui.display, 160 - i - 1, 100 + i, COLOR_BLACK);
        display_draw_pixel(ui.display, 160 + i + 1, 100 + i, COLOR_BLACK);
        display_draw_pixel(ui.display, 160 - i, 100 + i + 1, COLOR_BLACK);
        display_draw_pixel(ui.display, 160 + i, 100 + i + 1, COLOR_BLACK);
    }
    
    ESP_LOGI(TAG, "Orientation test screen drawn");
    
    return ESP_OK;
}

/**
 * Update UI (check for touches)
 */
esp_err_t ui_manager_update(void) {
    if (!ui.initialized) {
        return ESP_ERR_INVALID_STATE;
    }
    
    // Check for touch if touch controller is available
    if (ui.touch) {
        xpt2046_touch_t touch_data;
        if (xpt2046_read_touch(ui.touch, &touch_data) == ESP_OK) {
            if (touch_data.pressed) {
                ui_manager_handle_touch(touch_data.x, touch_data.y, true);
            } else {
                // Release all buttons
                for (int i = 0; i < NUM_BUTTONS; i++) {
                    if (ui.buttons[i].state == BUTTON_STATE_PRESSED) {
                        ui.buttons[i].state = BUTTON_STATE_NORMAL;
                        draw_button(&ui.buttons[i]);
                    }
                }
            }
        }
    }
    
    return ESP_OK;
}

/**
 * Handle touch event
 */
esp_err_t ui_manager_handle_touch(uint16_t x, uint16_t y, bool pressed) {
    if (!ui.initialized) {
        return ESP_ERR_INVALID_STATE;
    }
    
    if (pressed) {
        ui.total_touches++;
        
        // Check which button was pressed
        for (int i = 0; i < NUM_BUTTONS; i++) {
            button_t *btn = &ui.buttons[i];
            
            // Check if touch is within button bounds
            if (x >= btn->x && x < (btn->x + btn->width) &&
                y >= btn->y && y < (btn->y + btn->height)) {
                
                // Button pressed
                btn->state = BUTTON_STATE_PRESSED;
                btn->press_count++;
                draw_button(btn);
                
                // Call callback if set
                if (btn->callback) {
                    btn->callback(i);
                }
                
                ESP_LOGI(TAG, "Button %d pressed at (%d, %d), count: %lu", 
                        i, x, y, btn->press_count);
                break;
            }
        }
    }
    
    return ESP_OK;
}

/**
 * Set button callback
 */
esp_err_t ui_manager_set_button_callback(uint8_t button_id, void (*callback)(uint8_t)) {
    if (button_id >= NUM_BUTTONS) {
        return ESP_ERR_INVALID_ARG;
    }
    
    ui.buttons[button_id].callback = callback;
    return ESP_OK;
}

/**
 * Set background color
 */
esp_err_t ui_manager_set_background(uint16_t color) {
    ui.bg_color = color;
    return ESP_OK;
}

/**
 * Clear screen
 */
esp_err_t ui_manager_clear_screen(void) {
    if (!ui.display) {
        return ESP_ERR_INVALID_STATE;
    }
    
    display_clear(ui.display, ui.bg_color);
    return ESP_OK;
}

/**
 * Draw text
 */
esp_err_t ui_manager_draw_text(uint16_t x, uint16_t y, const char* text, 
                               uint16_t color, uint16_t bg_color) {
    if (!ui.display || !text) {
        return ESP_ERR_INVALID_ARG;
    }
    
    draw_string(x, y, text, color, bg_color, 1);
    return ESP_OK;
}

/**
 * Get button press count
 */
uint32_t ui_manager_get_press_count(uint8_t button_id) {
    if (button_id >= NUM_BUTTONS) {
        return 0;
    }
    
    return ui.buttons[button_id].press_count;
}

/**
 * Get total touch count
 */
uint32_t ui_manager_get_total_touches(void) {
    return ui.total_touches;
}