#include "web_interface.h"
#include "esp_log.h"
#include <string.h>

static const char *TAG = "WEB_INTERFACE";

// Embedded files (will be populated by CMake EMBED_FILES)
extern const uint8_t index_html_start[] asm("_binary_index_html_start");
extern const uint8_t index_html_end[] asm("_binary_index_html_end");
extern const uint8_t style_css_start[] asm("_binary_style_css_start");
extern const uint8_t style_css_end[] asm("_binary_style_css_end");
extern const uint8_t app_js_start[] asm("_binary_app_js_start");
extern const uint8_t app_js_end[] asm("_binary_app_js_end");

// File structure for embedded content
typedef struct {
    const char* path;
    const uint8_t* start;
    const uint8_t* end;
    const char* content_type;
} embedded_file_t;

static const embedded_file_t embedded_files[] = {
    {"/", index_html_start, index_html_end, "text/html"},
    {"/index.html", index_html_start, index_html_end, "text/html"},
    {"/style.css", style_css_start, style_css_end, "text/css"},
    {"/app.js", app_js_start, app_js_end, "application/javascript"},
};

static const size_t num_embedded_files = sizeof(embedded_files) / sizeof(embedded_file_t);

esp_err_t web_interface_get_file(const char* path, const char** content, size_t* length) {
    for (size_t i = 0; i < num_embedded_files; i++) {
        if (strcmp(path, embedded_files[i].path) == 0) {
            *content = (const char*)embedded_files[i].start;
            *length = embedded_files[i].end - embedded_files[i].start;
            return ESP_OK;
        }
    }
    return ESP_ERR_NOT_FOUND;
}

esp_err_t web_interface_init(httpd_handle_t server) {
    ESP_LOGI(TAG, "Initializing web interface");
    
    // The HTTP server component will handle the routes
    // This component just provides the embedded files
    
    return ESP_OK;
}