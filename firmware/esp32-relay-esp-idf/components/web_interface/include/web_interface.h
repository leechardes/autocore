#ifndef WEB_INTERFACE_H
#define WEB_INTERFACE_H

#include "esp_err.h"
#include "esp_http_server.h"

/**
 * Initialize the web interface component
 * This sets up all the web routes and handlers
 * 
 * @param server HTTP server handle
 * @return ESP_OK on success
 */
esp_err_t web_interface_init(httpd_handle_t server);

/**
 * Get embedded file content
 * 
 * @param path File path (e.g., "/index.html")
 * @param content Pointer to store content
 * @param length Pointer to store content length
 * @return ESP_OK if file found
 */
esp_err_t web_interface_get_file(const char* path, const char** content, size_t* length);

#endif // WEB_INTERFACE_H