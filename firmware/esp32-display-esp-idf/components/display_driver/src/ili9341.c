/**
 * ILI9341 Display Driver Implementation
 * Based on AutoTech HMI Display v2 configuration
 * 
 * Optimized for ESP32-2432S028R board
 * - 240x320 native resolution (320x240 in landscape)
 * - 65MHz SPI for maximum performance
 * - Color inversion enabled for proper colors
 */

#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "driver/ledc.h"
#include "display_driver.h"

static const char *TAG = "ILI9341";

// ILI9341 Commands
#define ILI9341_NOP         0x00
#define ILI9341_SWRESET     0x01
#define ILI9341_RDDID       0x04
#define ILI9341_RDDST       0x09
#define ILI9341_SLPIN       0x10
#define ILI9341_SLPOUT      0x11
#define ILI9341_PTLON       0x12
#define ILI9341_NORON       0x13
#define ILI9341_INVOFF      0x20
#define ILI9341_INVON       0x21
#define ILI9341_GAMMASET    0x26
#define ILI9341_DISPOFF     0x28
#define ILI9341_DISPON      0x29
#define ILI9341_CASET       0x2A
#define ILI9341_PASET       0x2B
#define ILI9341_RAMWR       0x2C
#define ILI9341_RAMRD       0x2E
#define ILI9341_PTLAR       0x30
#define ILI9341_VSCRDEF     0x33
#define ILI9341_MADCTL      0x36
#define ILI9341_VSCRSADD    0x37
#define ILI9341_PIXFMT      0x3A
#define ILI9341_FRMCTR1     0xB1
#define ILI9341_FRMCTR2     0xB2
#define ILI9341_FRMCTR3     0xB3
#define ILI9341_INVCTR      0xB4
#define ILI9341_DFUNCTR     0xB6
#define ILI9341_PWCTR1      0xC0
#define ILI9341_PWCTR2      0xC1
#define ILI9341_PWCTR3      0xC2
#define ILI9341_PWCTR4      0xC3
#define ILI9341_PWCTR5      0xC4
#define ILI9341_VMCTR1      0xC5
#define ILI9341_VMCTR2      0xC7
#define ILI9341_RDID1       0xDA
#define ILI9341_RDID2       0xDB
#define ILI9341_RDID3       0xDC
#define ILI9341_RDID4       0xDD
#define ILI9341_GMCTRP1     0xE0
#define ILI9341_GMCTRN1     0xE1

// MADCTL bits
#define MADCTL_MY  0x80  // Row Address Order
#define MADCTL_MX  0x40  // Column Address Order
#define MADCTL_MV  0x20  // Row/Column Exchange
#define MADCTL_ML  0x10  // Vertical Refresh Order
#define MADCTL_RGB 0x00  // RGB Order
#define MADCTL_BGR 0x08  // BGR Order
#define MADCTL_MH  0x04  // Horizontal Refresh Order

// Display structure
typedef struct {
    spi_device_handle_t spi;
    int dc_gpio;
    int rst_gpio;
    int bl_gpio;
    uint16_t width;
    uint16_t height;
    uint8_t rotation;
    bool color_invert;
    ledc_channel_t bl_channel;
} ili9341_t;

// Transaction helper
typedef struct {
    uint8_t cmd;
    uint8_t data[16];
    uint8_t databytes;
} lcd_init_cmd_t;

// Initialization sequence based on HMI Display v2
static const lcd_init_cmd_t ili9341_init_cmds[] = {
    // Software Reset
    {ILI9341_SWRESET, {0}, 0},
    
    // Power Control A
    {0xCB, {0x39, 0x2C, 0x00, 0x34, 0x02}, 5},
    
    // Power Control B
    {0xCF, {0x00, 0xC1, 0x30}, 3},
    
    // Driver Timing Control A
    {0xE8, {0x85, 0x00, 0x78}, 3},
    
    // Driver Timing Control B
    {0xEA, {0x00, 0x00}, 2},
    
    // Power On Sequence Control
    {0xED, {0x64, 0x03, 0x12, 0x81}, 4},
    
    // Pump Ratio Control
    {0xF7, {0x20}, 1},
    
    // Power Control 1
    {ILI9341_PWCTR1, {0x23}, 1},
    
    // Power Control 2
    {ILI9341_PWCTR2, {0x10}, 1},
    
    // VCOM Control 1
    {ILI9341_VMCTR1, {0x3E, 0x28}, 2},
    
    // VCOM Control 2
    {ILI9341_VMCTR2, {0x86}, 1},
    
    // Memory Access Control - não definir aqui, será configurado depois baseado na rotação
    // {ILI9341_MADCTL, {MADCTL_BGR}, 1},
    
    // Pixel Format Set - 16 bits per pixel
    {ILI9341_PIXFMT, {0x55}, 1},
    
    // Frame Rate Control
    {ILI9341_FRMCTR1, {0x00, 0x18}, 2},
    
    // Display Function Control
    {ILI9341_DFUNCTR, {0x08, 0x82, 0x27}, 3},
    
    // 3Gamma Function Disable
    {0xF2, {0x00}, 1},
    
    // Gamma Set
    {ILI9341_GAMMASET, {0x01}, 1},
    
    // Positive Gamma Correction
    {ILI9341_GMCTRP1, {0x0F, 0x31, 0x2B, 0x0C, 0x0E, 0x08,
                       0x4E, 0xF1, 0x37, 0x07, 0x10, 0x03,
                       0x0E, 0x09, 0x00}, 15},
    
    // Negative Gamma Correction
    {ILI9341_GMCTRN1, {0x00, 0x0E, 0x14, 0x03, 0x11, 0x07,
                       0x31, 0xC1, 0x48, 0x08, 0x0F, 0x0C,
                       0x31, 0x36, 0x0F}, 15},
    
    // Sleep Out
    {ILI9341_SLPOUT, {0}, 0},
    
    // Display Inversion OFF - desativando inversão
    {ILI9341_INVOFF, {0}, 0},
    
    // Display ON
    {ILI9341_DISPON, {0}, 0},
    
    {0, {0}, 0xff}  // End marker
};

/**
 * Send command to display
 */
static void ili9341_send_cmd(ili9341_t *dev, uint8_t cmd) {
    gpio_set_level(dev->dc_gpio, 0);  // Command mode
    
    spi_transaction_t t = {
        .length = 8,
        .tx_buffer = &cmd,
    };
    
    ESP_ERROR_CHECK(spi_device_polling_transmit(dev->spi, &t));
}

/**
 * Send data to display
 */
static void ili9341_send_data(ili9341_t *dev, const uint8_t *data, size_t len) {
    if (len == 0) return;
    
    gpio_set_level(dev->dc_gpio, 1);  // Data mode
    
    spi_transaction_t t = {
        .length = len * 8,
        .tx_buffer = data,
    };
    
    ESP_ERROR_CHECK(spi_device_polling_transmit(dev->spi, &t));
}

/**
 * Send color data (16-bit RGB565)
 */
static void ili9341_send_color(ili9341_t *dev, uint16_t color, size_t count) {
    gpio_set_level(dev->dc_gpio, 1);  // Data mode
    
    // Prepare buffer with repeated color
    #define CHUNK_SIZE 512
    uint16_t buffer[CHUNK_SIZE];
    
    // Swap bytes for SPI transmission
    uint16_t swapped = (color >> 8) | (color << 8);
    for (int i = 0; i < CHUNK_SIZE && i < count; i++) {
        buffer[i] = swapped;
    }
    
    // Send in chunks
    while (count > 0) {
        size_t to_send = (count > CHUNK_SIZE) ? CHUNK_SIZE : count;
        
        spi_transaction_t t = {
            .length = to_send * 16,
            .tx_buffer = buffer,
        };
        
        ESP_ERROR_CHECK(spi_device_polling_transmit(dev->spi, &t));
        count -= to_send;
    }
}

/**
 * Set address window for pixel operations
 */
static void ili9341_set_window(ili9341_t *dev, uint16_t x0, uint16_t y0, 
                               uint16_t x1, uint16_t y1) {
    // Column Address Set
    ili9341_send_cmd(dev, ILI9341_CASET);
    uint8_t col_data[] = {
        (x0 >> 8) & 0xFF,
        x0 & 0xFF,
        (x1 >> 8) & 0xFF,
        x1 & 0xFF
    };
    ili9341_send_data(dev, col_data, 4);
    
    // Page Address Set
    ili9341_send_cmd(dev, ILI9341_PASET);
    uint8_t page_data[] = {
        (y0 >> 8) & 0xFF,
        y0 & 0xFF,
        (y1 >> 8) & 0xFF,
        y1 & 0xFF
    };
    ili9341_send_data(dev, page_data, 4);
    
    // Memory Write
    ili9341_send_cmd(dev, ILI9341_RAMWR);
}

/**
 * Initialize ILI9341 display
 */
esp_err_t display_driver_init(const display_config_t *config, display_handle_t *handle) {
    ESP_LOGI(TAG, "Initializing ILI9341 display");
    
    // Allocate driver structure
    ili9341_t *dev = calloc(1, sizeof(ili9341_t));
    if (dev == NULL) {
        ESP_LOGE(TAG, "Failed to allocate memory");
        return ESP_ERR_NO_MEM;
    }
    
    // Store configuration
    dev->dc_gpio = config->dc_gpio;
    dev->rst_gpio = config->rst_gpio;
    dev->bl_gpio = config->backlight_gpio;
    
    // Configurar dimensões baseado na rotação
    if (config->rotation == 1 || config->rotation == 3) {
        // Landscape mode
        dev->width = 320;
        dev->height = 240;
    } else {
        // Portrait mode
        dev->width = 240;
        dev->height = 320;
    }
    
    dev->rotation = config->rotation;
    dev->color_invert = true;  // Always enabled for ESP32-2432S028R
    dev->bl_channel = LEDC_CHANNEL_0;
    
    // Configure DC pin
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << dev->dc_gpio),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };
    ESP_ERROR_CHECK(gpio_config(&io_conf));
    
    // Configure Reset pin if available
    if (dev->rst_gpio >= 0) {
        io_conf.pin_bit_mask = (1ULL << dev->rst_gpio);
        ESP_ERROR_CHECK(gpio_config(&io_conf));
        
        // Hardware reset
        gpio_set_level(dev->rst_gpio, 0);
        vTaskDelay(pdMS_TO_TICKS(10));
        gpio_set_level(dev->rst_gpio, 1);
        vTaskDelay(pdMS_TO_TICKS(120));
    }
    
    // Configure backlight PWM
    if (dev->bl_gpio >= 0) {
        ledc_timer_config_t ledc_timer = {
            .speed_mode = LEDC_LOW_SPEED_MODE,
            .timer_num = LEDC_TIMER_0,
            .duty_resolution = LEDC_TIMER_8_BIT,
            .freq_hz = 5000,  // 5 KHz
            .clk_cfg = LEDC_AUTO_CLK
        };
        ESP_ERROR_CHECK(ledc_timer_config(&ledc_timer));
        
        ledc_channel_config_t ledc_channel = {
            .speed_mode = LEDC_LOW_SPEED_MODE,
            .channel = dev->bl_channel,
            .timer_sel = LEDC_TIMER_0,
            .intr_type = LEDC_INTR_DISABLE,
            .gpio_num = dev->bl_gpio,
            .duty = 0,
            .hpoint = 0
        };
        ESP_ERROR_CHECK(ledc_channel_config(&ledc_channel));
    }
    
    // Configure SPI
    spi_bus_config_t buscfg = {
        .mosi_io_num = config->mosi_gpio,
        .miso_io_num = CONFIG_ESP32_DISPLAY_MISO_GPIO,  // Use MISO from config (mesmo que não seja usado para escrita)
        .sclk_io_num = config->sclk_gpio,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
        .max_transfer_sz = config->width * config->height * 2 + 8,
        .flags = SPICOMMON_BUSFLAG_MASTER | SPICOMMON_BUSFLAG_SCLK | 
                 SPICOMMON_BUSFLAG_MOSI
    };
    
    ESP_ERROR_CHECK(spi_bus_initialize(HSPI_HOST, &buscfg, SPI_DMA_CH_AUTO));
    
    spi_device_interface_config_t devcfg = {
        .clock_speed_hz = config->spi_clock_speed,  // 65 MHz
        .mode = 0,
        .spics_io_num = config->cs_gpio,
        .queue_size = 7,
        .pre_cb = NULL,
        .post_cb = NULL,
        .flags = SPI_DEVICE_NO_DUMMY,
    };
    
    ESP_ERROR_CHECK(spi_bus_add_device(HSPI_HOST, &devcfg, &dev->spi));
    
    // Send initialization commands
    ESP_LOGI(TAG, "Sending init commands");
    int cmd = 0;
    while (ili9341_init_cmds[cmd].databytes != 0xff) {
        ili9341_send_cmd(dev, ili9341_init_cmds[cmd].cmd);
        ili9341_send_data(dev, ili9341_init_cmds[cmd].data, 
                         ili9341_init_cmds[cmd].databytes & 0x1F);
        
        if (ili9341_init_cmds[cmd].cmd == ILI9341_SLPOUT) {
            vTaskDelay(pdMS_TO_TICKS(120));  // Wait after sleep out
        }
        cmd++;
    }
    
    // Set rotation - ESP32-2432S028R landscape mode
    uint8_t madctl = 0;
    
    ESP_LOGI(TAG, "=== CONFIGURANDO ROTAÇÃO ===");
    ESP_LOGI(TAG, "Rotação solicitada: %d", config->rotation);
    
    // Configuração para ESP32-2432S028R
    // Display nativo é 240x320 (portrait), rotacionado para 320x240 (landscape)
    switch(config->rotation) {
        case 0:  // Portrait (240x320)
            madctl = MADCTL_MY | MADCTL_MX;
            break;
        case 1:  // Landscape 90 graus (320x240) 
            // ESP32-2432S028R: Configuração final correta
            // - MY (0x80) para orientação correta
            // - RGB mode (sem BGR) para cores corretas
            // - Sem MX (sem espelhamento horizontal)
            madctl = 0x80;  // MY apenas - configuração perfeita
            break;
        case 2:  // Portrait inverted (240x320)
            madctl = 0x00;
            break;
        case 3:  // Landscape 270 graus (320x240)
            madctl = MADCTL_MY | MADCTL_MX;
            break;
        default:
            madctl = 0x00;
            break;
    }
    
    ESP_LOGI(TAG, "ENVIANDO MADCTL: 0x%02X para rotação %d", madctl, config->rotation);
    ili9341_send_cmd(dev, ILI9341_MADCTL);
    ili9341_send_data(dev, &madctl, 1);
    ESP_LOGI(TAG, "MADCTL ENVIADO COM SUCESSO!");
    
    // Clear screen to black
    ili9341_set_window(dev, 0, 0, dev->width - 1, dev->height - 1);
    ili9341_send_color(dev, 0x0000, dev->width * dev->height);
    
    // Turn on backlight at 100%
    if (dev->bl_gpio >= 0) {
        ESP_ERROR_CHECK(ledc_set_duty(LEDC_LOW_SPEED_MODE, dev->bl_channel, 255));
        ESP_ERROR_CHECK(ledc_update_duty(LEDC_LOW_SPEED_MODE, dev->bl_channel));
    }
    
    *handle = (display_handle_t)dev;
    
    ESP_LOGI(TAG, "ILI9341 initialized successfully (%dx%d, rotation=%d)", 
             dev->width, dev->height, config->rotation);
    
    return ESP_OK;
}

/**
 * Clear display with color
 */
esp_err_t display_clear(display_handle_t handle, uint16_t color) {
    ili9341_t *dev = (ili9341_t *)handle;
    
    ili9341_set_window(dev, 0, 0, dev->width - 1, dev->height - 1);
    ili9341_send_color(dev, color, dev->width * dev->height);
    
    return ESP_OK;
}

/**
 * Draw pixel
 */
esp_err_t display_draw_pixel(display_handle_t handle, int16_t x, int16_t y, uint16_t color) {
    ili9341_t *dev = (ili9341_t *)handle;
    
    if (x < 0 || x >= dev->width || y < 0 || y >= dev->height) {
        return ESP_ERR_INVALID_ARG;
    }
    
    ili9341_set_window(dev, x, y, x, y);
    ili9341_send_color(dev, color, 1);
    
    return ESP_OK;
}

/**
 * Fill rectangle
 */
esp_err_t display_fill_rect(display_handle_t handle, int16_t x, int16_t y, 
                            int16_t w, int16_t h, uint16_t color) {
    ili9341_t *dev = (ili9341_t *)handle;
    
    // Clip to screen bounds
    if (x >= dev->width || y >= dev->height) return ESP_OK;
    if (x < 0) { w += x; x = 0; }
    if (y < 0) { h += y; y = 0; }
    if (x + w > dev->width) w = dev->width - x;
    if (y + h > dev->height) h = dev->height - y;
    if (w <= 0 || h <= 0) return ESP_OK;
    
    ili9341_set_window(dev, x, y, x + w - 1, y + h - 1);
    ili9341_send_color(dev, color, w * h);
    
    return ESP_OK;
}

/**
 * Set backlight level
 */
esp_err_t display_set_backlight(display_handle_t handle, uint8_t level) {
    ili9341_t *dev = (ili9341_t *)handle;
    
    if (dev->bl_gpio >= 0) {
        uint32_t duty = (level * 255) / 100;  // Convert percentage to 8-bit duty
        ESP_ERROR_CHECK(ledc_set_duty(LEDC_LOW_SPEED_MODE, dev->bl_channel, duty));
        ESP_ERROR_CHECK(ledc_update_duty(LEDC_LOW_SPEED_MODE, dev->bl_channel));
    }
    
    return ESP_OK;
}

/**
 * Deinitialize display driver
 */
esp_err_t display_driver_deinit(display_handle_t handle) {
    if (!handle) return ESP_ERR_INVALID_ARG;
    
    ili9341_t *dev = (ili9341_t *)handle;
    
    // Turn off backlight
    if (dev->bl_gpio >= 0) {
        ESP_ERROR_CHECK(ledc_set_duty(LEDC_LOW_SPEED_MODE, dev->bl_channel, 0));
        ESP_ERROR_CHECK(ledc_update_duty(LEDC_LOW_SPEED_MODE, dev->bl_channel));
    }
    
    // Remove SPI device
    spi_bus_remove_device(dev->spi);
    spi_bus_free(HSPI_HOST);
    
    free(dev);
    return ESP_OK;
}

/**
 * Draw line
 */
esp_err_t display_draw_line(display_handle_t handle, int16_t x0, int16_t y0, 
                           int16_t x1, int16_t y1, uint16_t color) {
    // Simple line drawing using Bresenham's algorithm
    
    int16_t dx = abs(x1 - x0);
    int16_t dy = abs(y1 - y0);
    int16_t sx = (x0 < x1) ? 1 : -1;
    int16_t sy = (y0 < y1) ? 1 : -1;
    int16_t err = dx - dy;
    
    while (true) {
        display_draw_pixel(handle, x0, y0, color);
        
        if (x0 == x1 && y0 == y1) break;
        
        int16_t e2 = 2 * err;
        if (e2 > -dy) {
            err -= dy;
            x0 += sx;
        }
        if (e2 < dx) {
            err += dx;
            y0 += sy;
        }
    }
    
    return ESP_OK;
}

/**
 * Draw rectangle (outline only)
 */
esp_err_t display_draw_rect(display_handle_t handle, int16_t x, int16_t y, 
                           int16_t w, int16_t h, uint16_t color) {
    // Draw four lines to form rectangle
    display_draw_line(handle, x, y, x + w - 1, y, color);           // Top
    display_draw_line(handle, x, y, x, y + h - 1, color);          // Left
    display_draw_line(handle, x + w - 1, y, x + w - 1, y + h - 1, color); // Right
    display_draw_line(handle, x, y + h - 1, x + w - 1, y + h - 1, color); // Bottom
    
    return ESP_OK;
}

/**
 * Draw bitmap
 */
esp_err_t display_draw_bitmap(display_handle_t handle, int16_t x, int16_t y, 
                             int16_t w, int16_t h, const uint16_t* bitmap) {
    ili9341_t *dev = (ili9341_t *)handle;
    
    // Clip to screen bounds
    if (x >= dev->width || y >= dev->height || !bitmap) return ESP_ERR_INVALID_ARG;
    if (x < 0) { w += x; bitmap += -x; x = 0; }
    if (y < 0) { h += y; bitmap += (-y * w); y = 0; }
    if (x + w > dev->width) w = dev->width - x;
    if (y + h > dev->height) h = dev->height - y;
    if (w <= 0 || h <= 0) return ESP_OK;
    
    ili9341_set_window(dev, x, y, x + w - 1, y + h - 1);
    
    gpio_set_level(dev->dc_gpio, 1);  // Data mode
    
    // Send bitmap data directly
    spi_transaction_t t = {
        .length = w * h * 16,
        .tx_buffer = bitmap,
    };
    
    ESP_ERROR_CHECK(spi_device_polling_transmit(dev->spi, &t));
    
    return ESP_OK;
}

/**
 * Set display rotation
 */
esp_err_t display_set_rotation(display_handle_t handle, display_rotation_t rotation) {
    ili9341_t *dev = (ili9341_t *)handle;
    
    dev->rotation = rotation;
    
    // Atualizar dimensões baseado na rotação
    if (rotation == 1 || rotation == 3) {
        // Landscape
        dev->width = 320;
        dev->height = 240;
    } else {
        // Portrait
        dev->width = 240;
        dev->height = 320;
    }
    
    uint8_t madctl = 0;
    switch (rotation) {
        case 0:  // Portrait (240x320)
            madctl = MADCTL_MY | MADCTL_MX;
            break;
        case 1:  // Landscape 90 graus (320x240)
            madctl = 0x80;  // MY apenas
            break;
        case 2:  // Portrait inverted (240x320)
            madctl = 0x00;
            break;
        case 3:  // Landscape 270 graus (320x240)
            madctl = MADCTL_MY | MADCTL_MX;
            break;
        default:
            madctl = 0x00;
            break;
    }
    
    ili9341_send_cmd(dev, ILI9341_MADCTL);
    ili9341_send_data(dev, &madctl, 1);
    
    return ESP_OK;
}

/**
 * Flush display buffer (no-op for ILI9341)
 */
esp_err_t display_flush(display_handle_t handle) {
    // ILI9341 has no buffer, all operations are immediate
    return ESP_OK;
}

/**
 * Get display width
 */
uint16_t display_get_width(display_handle_t handle) {
    ili9341_t *dev = (ili9341_t *)handle;
    return dev ? dev->width : 0;
}

/**
 * Get display height
 */
uint16_t display_get_height(display_handle_t handle) {
    ili9341_t *dev = (ili9341_t *)handle;
    return dev ? dev->height : 0;
}