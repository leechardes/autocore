#include "xpt2046.h"
#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"

static const char *TAG = "XPT2046";

// XPT2046 Commands
#define XPT2046_CMD_X_POS   0x90    // Single-ended, 12-bit, VREF on
#define XPT2046_CMD_Y_POS   0xD0    // Single-ended, 12-bit, VREF on  
#define XPT2046_CMD_Z1_POS  0xB0    // Z1 position (pressure)
#define XPT2046_CMD_Z2_POS  0xC0    // Z2 position (pressure)

// XPT2046 handle structure
typedef struct xpt2046_s {
    spi_device_handle_t spi;
    xpt2046_config_t config;
    xpt2046_touch_cb_t callback;
    void *user_data;
    SemaphoreHandle_t mutex;
    bool initialized;
} xpt2046_t;

// Static function prototypes
static esp_err_t xpt2046_spi_read_data(xpt2046_handle_t handle, uint8_t cmd, uint16_t *data);
static uint16_t xpt2046_filter_data(uint16_t *data, int len);
static esp_err_t xpt2046_read_raw(xpt2046_handle_t handle, uint16_t *x, uint16_t *y, uint16_t *z);
static esp_err_t xpt2046_map_coordinates(xpt2046_handle_t handle, uint16_t raw_x, uint16_t raw_y, xpt2046_touch_t *touch);

esp_err_t xpt2046_init(const xpt2046_config_t *config, xpt2046_handle_t *handle)
{
    if (!config || !handle) {
        ESP_LOGE(TAG, "Invalid parameters");
        return ESP_ERR_INVALID_ARG;
    }

    // Allocate handle
    xpt2046_t *dev = calloc(1, sizeof(xpt2046_t));
    if (!dev) {
        ESP_LOGE(TAG, "Failed to allocate memory");
        return ESP_ERR_NO_MEM;
    }

    // Copy configuration
    dev->config = *config;
    
    // Create mutex
    dev->mutex = xSemaphoreCreateMutex();
    if (!dev->mutex) {
        ESP_LOGE(TAG, "Failed to create mutex");
        free(dev);
        return ESP_ERR_NO_MEM;
    }

    // Configure SPI bus
    spi_bus_config_t buscfg = {
        .mosi_io_num = config->mosi_gpio,
        .miso_io_num = config->miso_gpio,
        .sclk_io_num = config->clk_gpio,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
        .max_transfer_sz = 4092,
    };

    // Initialize SPI bus (use VSPI_HOST)
    esp_err_t ret = spi_bus_initialize(VSPI_HOST, &buscfg, SPI_DMA_CH_AUTO);
    if (ret != ESP_OK && ret != ESP_ERR_INVALID_STATE) {
        ESP_LOGE(TAG, "Failed to initialize SPI bus: %s", esp_err_to_name(ret));
        vSemaphoreDelete(dev->mutex);
        free(dev);
        return ret;
    }

    // Configure SPI device
    spi_device_interface_config_t devcfg = {
        .clock_speed_hz = config->spi_freq,
        .mode = 0,
        .spics_io_num = config->cs_gpio,
        .queue_size = 1,
        .flags = 0,
        .pre_cb = NULL,
    };

    // Add device to SPI bus
    ret = spi_bus_add_device(VSPI_HOST, &devcfg, &dev->spi);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to add SPI device: %s", esp_err_to_name(ret));
        spi_bus_free(VSPI_HOST);
        vSemaphoreDelete(dev->mutex);
        free(dev);
        return ret;
    }

    // Configure IRQ pin if provided
    if (config->irq_gpio >= 0) {
        gpio_config_t irq_conf = {
            .intr_type = GPIO_INTR_NEGEDGE,
            .mode = GPIO_MODE_INPUT,
            .pin_bit_mask = (1ULL << config->irq_gpio),
            .pull_down_en = GPIO_PULLDOWN_DISABLE,
            .pull_up_en = GPIO_PULLUP_ENABLE,
        };
        
        ret = gpio_config(&irq_conf);
        if (ret != ESP_OK) {
            ESP_LOGW(TAG, "Failed to configure IRQ pin: %s", esp_err_to_name(ret));
        }
    }

    dev->initialized = true;
    *handle = dev;

    ESP_LOGI(TAG, "XPT2046 initialized successfully");
    return ESP_OK;
}

esp_err_t xpt2046_deinit(xpt2046_handle_t handle)
{
    if (!handle || !handle->initialized) {
        return ESP_ERR_INVALID_ARG;
    }

    // Remove SPI device
    spi_bus_remove_device(handle->spi);
    spi_bus_free(VSPI_HOST);
    
    // Delete mutex
    vSemaphoreDelete(handle->mutex);
    
    // Free handle
    free(handle);
    
    ESP_LOGI(TAG, "XPT2046 deinitialized");
    return ESP_OK;
}

esp_err_t xpt2046_read_touch(xpt2046_handle_t handle, xpt2046_touch_t *touch)
{
    if (!handle || !handle->initialized || !touch) {
        return ESP_ERR_INVALID_ARG;
    }

    if (xSemaphoreTake(handle->mutex, pdMS_TO_TICKS(10)) != pdTRUE) {
        return ESP_ERR_TIMEOUT;
    }

    uint16_t raw_x, raw_y, raw_z;
    esp_err_t ret = xpt2046_read_raw(handle, &raw_x, &raw_y, &raw_z);
    
    if (ret == ESP_OK) {
        // Check pressure threshold
        if (raw_z >= handle->config.min_pressure && raw_z <= handle->config.max_pressure) {
            touch->pressed = true;
            ret = xpt2046_map_coordinates(handle, raw_x, raw_y, touch);
            touch->z = raw_z;
        } else {
            touch->pressed = false;
            touch->x = 0;
            touch->y = 0;
            touch->z = 0;
        }
    }

    xSemaphoreGive(handle->mutex);
    return ret;
}

bool xpt2046_is_pressed(xpt2046_handle_t handle)
{
    if (!handle || !handle->initialized || handle->config.irq_gpio < 0) {
        return false;
    }

    // IRQ is active low when touched
    return gpio_get_level(handle->config.irq_gpio) == 0;
}

esp_err_t xpt2046_set_callback(xpt2046_handle_t handle, 
                               xpt2046_touch_cb_t callback, 
                               void *user_data)
{
    if (!handle || !handle->initialized) {
        return ESP_ERR_INVALID_ARG;
    }

    handle->callback = callback;
    handle->user_data = user_data;
    
    return ESP_OK;
}

esp_err_t xpt2046_calibrate(xpt2046_handle_t handle, 
                            const xpt2046_touch_t *points, 
                            size_t count)
{
    // Basic implementation - just update config values
    if (!handle || !handle->initialized || !points || count < 2) {
        return ESP_ERR_INVALID_ARG;
    }

    // Find min/max values from calibration points
    uint16_t min_x = points[0].x, max_x = points[0].x;
    uint16_t min_y = points[0].y, max_y = points[0].y;
    
    for (size_t i = 1; i < count; i++) {
        if (points[i].x < min_x) min_x = points[i].x;
        if (points[i].x > max_x) max_x = points[i].x;
        if (points[i].y < min_y) min_y = points[i].y;
        if (points[i].y > max_y) max_y = points[i].y;
    }
    
    handle->config.min_x = min_x;
    handle->config.max_x = max_x;
    handle->config.min_y = min_y;
    handle->config.max_y = max_y;
    
    ESP_LOGI(TAG, "Calibration updated: X(%d-%d), Y(%d-%d)", min_x, max_x, min_y, max_y);
    return ESP_OK;
}

esp_err_t xpt2046_get_raw(xpt2046_handle_t handle, 
                          uint16_t *x, uint16_t *y, uint16_t *z)
{
    if (!handle || !handle->initialized || !x || !y || !z) {
        return ESP_ERR_INVALID_ARG;
    }

    if (xSemaphoreTake(handle->mutex, pdMS_TO_TICKS(10)) != pdTRUE) {
        return ESP_ERR_TIMEOUT;
    }

    esp_err_t ret = xpt2046_read_raw(handle, x, y, z);
    
    xSemaphoreGive(handle->mutex);
    return ret;
}

// Static functions implementation
static esp_err_t xpt2046_spi_read_data(xpt2046_handle_t handle, uint8_t cmd, uint16_t *data)
{
    if (!handle || !data) {
        return ESP_ERR_INVALID_ARG;
    }

    spi_transaction_t trans = {
        .length = 24,  // 3 bytes = 24 bits
        .tx_buffer = &cmd,
        .rx_buffer = data,
        .flags = SPI_TRANS_USE_RXDATA | SPI_TRANS_USE_TXDATA,
    };

    trans.tx_data[0] = cmd;
    trans.tx_data[1] = 0;
    trans.tx_data[2] = 0;

    esp_err_t ret = spi_device_transmit(handle->spi, &trans);
    if (ret != ESP_OK) {
        return ret;
    }

    // Extract 12-bit value from received data
    *data = ((trans.rx_data[1] << 8) | trans.rx_data[2]) >> 3;
    
    return ESP_OK;
}

static uint16_t xpt2046_filter_data(uint16_t *data, int len)
{
    if (!data || len <= 0) {
        return 0;
    }

    // Simple averaging filter
    uint32_t sum = 0;
    for (int i = 0; i < len; i++) {
        sum += data[i];
    }
    
    return sum / len;
}

static esp_err_t xpt2046_read_raw(xpt2046_handle_t handle, uint16_t *x, uint16_t *y, uint16_t *z)
{
    if (!handle || !x || !y || !z) {
        return ESP_ERR_INVALID_ARG;
    }

    uint16_t x_samples[3], y_samples[3], z1_samples[3], z2_samples[3];
    esp_err_t ret;

    // Read multiple samples for filtering
    for (int i = 0; i < 3; i++) {
        ret = xpt2046_spi_read_data(handle, XPT2046_CMD_X_POS, &x_samples[i]);
        if (ret != ESP_OK) return ret;
        
        ret = xpt2046_spi_read_data(handle, XPT2046_CMD_Y_POS, &y_samples[i]);
        if (ret != ESP_OK) return ret;
        
        ret = xpt2046_spi_read_data(handle, XPT2046_CMD_Z1_POS, &z1_samples[i]);
        if (ret != ESP_OK) return ret;
        
        ret = xpt2046_spi_read_data(handle, XPT2046_CMD_Z2_POS, &z2_samples[i]);
        if (ret != ESP_OK) return ret;
        
        vTaskDelay(pdMS_TO_TICKS(1));  // Small delay between samples
    }

    // Filter samples
    *x = xpt2046_filter_data(x_samples, 3);
    *y = xpt2046_filter_data(y_samples, 3);
    
    // Calculate pressure (simplified)
    uint16_t z1 = xpt2046_filter_data(z1_samples, 3);
    uint16_t z2 = xpt2046_filter_data(z2_samples, 3);
    
    if (z1 != 0 && z2 != 4095) {
        *z = (*x) * (z2 - z1) / z1;  // Pressure calculation
    } else {
        *z = 0;
    }

    return ESP_OK;
}

static esp_err_t xpt2046_map_coordinates(xpt2046_handle_t handle, uint16_t raw_x, uint16_t raw_y, xpt2046_touch_t *touch)
{
    if (!handle || !touch) {
        return ESP_ERR_INVALID_ARG;
    }

    // Map raw coordinates to screen coordinates
    int32_t x = raw_x - handle->config.min_x;
    int32_t y = raw_y - handle->config.min_y;
    
    x = x * handle->config.screen_width / (handle->config.max_x - handle->config.min_x);
    y = y * handle->config.screen_height / (handle->config.max_y - handle->config.min_y);
    
    // Clamp to screen bounds
    if (x < 0) x = 0;
    if (x >= handle->config.screen_width) x = handle->config.screen_width - 1;
    if (y < 0) y = 0;
    if (y >= handle->config.screen_height) y = handle->config.screen_height - 1;
    
    // Apply rotation
    uint16_t screen_x = x;
    uint16_t screen_y = y;
    
    switch (handle->config.rotation) {
        case 1:  // 90 degrees
            screen_x = handle->config.screen_height - 1 - y;
            screen_y = x;
            break;
        case 2:  // 180 degrees
            screen_x = handle->config.screen_width - 1 - x;
            screen_y = handle->config.screen_height - 1 - y;
            break;
        case 3:  // 270 degrees
            screen_x = y;
            screen_y = handle->config.screen_width - 1 - x;
            break;
        default: // 0 degrees (no rotation)
            break;
    }
    
    touch->x = screen_x;
    touch->y = screen_y;
    
    return ESP_OK;
}