/**
 * ESP32 Relay HTTP Server
 * Provides web interface for configuration and monitoring
 * 
 * Compatible with AutoCore ecosystem
 * Based on FUNCTIONAL_SPECIFICATION.md
 */

#ifndef HTTP_SERVER_H
#define HTTP_SERVER_H

#include <stdbool.h>
#include <stdint.h>
#include "esp_http_server.h"

#ifdef __cplusplus
extern "C" {
#endif

// HTTP Server configuration
#define HTTP_SERVER_PORT 80
#define HTTP_SERVER_MAX_CLIENTS 4
#define HTTP_SERVER_TIMEOUT_MS 10000
#define HTTP_SERVER_BUFFER_SIZE 2048

// HTTP response codes
#define HTTP_RESPONSE_OK 200
#define HTTP_RESPONSE_BAD_REQUEST 400
#define HTTP_RESPONSE_NOT_FOUND 404
#define HTTP_RESPONSE_INTERNAL_ERROR 500

/**
 * Initialize and start HTTP server
 * @return ESP_OK on success
 */
esp_err_t http_server_init(void);

/**
 * Stop HTTP server
 * @return ESP_OK on success
 */
esp_err_t http_server_stop(void);

// Configuration server version with full UI
esp_err_t http_server_init_simple(void);
esp_err_t http_server_stop_simple(void);

// Use the configuration server with full UI
#define http_server_init http_server_init_simple
#define http_server_stop http_server_stop_simple

/**
 * Check if HTTP server is running
 * @return true if running
 */
bool http_server_is_running(void);

/**
 * Get main configuration page HTML
 * Generates dynamic HTML with current configuration
 * @param buffer Output buffer for HTML
 * @param max_len Maximum buffer length
 * @return ESP_OK on success
 */
esp_err_t http_generate_main_page(char* buffer, size_t max_len);

/**
 * Generate device status JSON
 * @param buffer Output buffer for JSON
 * @param max_len Maximum buffer length
 * @return ESP_OK on success
 */
esp_err_t http_generate_status_json(char* buffer, size_t max_len);

/**
 * Parse configuration form data
 * Extracts configuration from POST request
 * @param data Form data string
 * @param data_len Data length
 * @return ESP_OK on success
 */
esp_err_t http_parse_config_form(const char* data, size_t data_len);

/**
 * Generate configuration response HTML
 * Shows result of configuration update
 * @param buffer Output buffer for HTML
 * @param max_len Maximum buffer length
 * @param success Configuration update success status
 * @param message Status message
 * @return ESP_OK on success
 */
esp_err_t http_generate_config_response(char* buffer, size_t max_len, 
                                       bool success, const char* message);

/**
 * Generate reboot response HTML
 * Shows reboot confirmation with auto-refresh
 * @param buffer Output buffer for HTML
 * @param max_len Maximum buffer length
 * @return ESP_OK on success
 */
esp_err_t http_generate_reboot_response(char* buffer, size_t max_len);

/**
 * Generate reset response HTML
 * Shows factory reset confirmation
 * @param buffer Output buffer for HTML
 * @param max_len Maximum buffer length
 * @return ESP_OK on success
 */
esp_err_t http_generate_reset_response(char* buffer, size_t max_len);

/**
 * URL decode utility function
 * Decodes URL-encoded strings
 * @param dst Destination buffer
 * @param src Source string
 * @return ESP_OK on success
 */
esp_err_t http_url_decode(char* dst, const char* src);

/**
 * Extract form field value
 * Gets value from form data by field name
 * @param data Form data
 * @param field_name Field name to search
 * @param value Output buffer for value
 * @param max_len Maximum value length
 * @return ESP_OK on success
 */
esp_err_t http_extract_form_field(const char* data, const char* field_name,
                                 char* value, size_t max_len);

// HTTP handler functions (internal)
esp_err_t http_handler_root(httpd_req_t *req);
esp_err_t http_handler_config(httpd_req_t *req);
esp_err_t http_handler_status(httpd_req_t *req);
esp_err_t http_handler_reboot(httpd_req_t *req);
esp_err_t http_handler_reset(httpd_req_t *req);

#ifdef __cplusplus
}
#endif

#endif // HTTP_SERVER_H