/**
 * ESP32 Relay HTTP Configuration Server
 * Complete web interface for device configuration
 */

#include "http_server.h"
#include "esp_log.h"
#include "esp_http_server.h"
#include "config_manager.h"
#include "wifi_manager.h"
#include "relay_control.h"
#include <string.h>
#include <stdlib.h>
#include "esp_system.h"
#include "nvs_flash.h"

static const char *TAG = "HTTP_CONFIG";
static httpd_handle_t server = NULL;

// Simple success/error response
static const char RESPONSE_HTML[] = 
"<!DOCTYPE html>"
"<html>"
"<head>"
"<meta charset='UTF-8'>"
"<title>ESP32 Relay</title>"
"<style>"
"body { font-family: sans-serif; text-align: center; padding: 50px; }"
".success { color: #00d68f; }"
".error { color: #ff4757; }"
"</style>"
"</head>"
"<body>"
"<h1 class='%s'>%s</h1>"
"<p>%s</p>"
"<p>Redirecionando em 3 segundos...</p>"
"<script>setTimeout(() => location.href = '/', 3000);</script>"
"</body>"
"</html>";

/**
 * Root handler - Configuration page
 */
static esp_err_t config_page_handler(httpd_req_t *req) {
    device_config_t* config = config_get();
    if (!config) {
        httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Config error");
        return ESP_FAIL;
    }
    
    // Get WiFi status
    const char* wifi_status = "Desconectado";
    const char* wifi_class = "disconnected";
    const char* wifi_mode = "Não configurado";
    char ip_str[16] = "0.0.0.0";
    
    if (wifi_manager_is_connected()) {
        wifi_status = "Conectado";
        wifi_class = "connected";
        wifi_mode = "Estação (STA)";
        wifi_manager_get_ip(ip_str, sizeof(ip_str));
    } else if (wifi_manager_get_state() == WIFI_STATE_AP_MODE) {
        wifi_status = "Modo AP";
        wifi_class = "disconnected";
        wifi_mode = "Ponto de Acesso";
        strcpy(ip_str, "192.168.4.1");
    }
    
    // Build response
    char* response = malloc(16384);
    if (!response) {
        httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Memory error");
        return ESP_FAIL;
    }
    
    // Build HTML response dynamically to avoid format string issues
    int offset = 0;
    offset += snprintf(response + offset, 16384 - offset,
        "<!DOCTYPE html>"
        "<html lang='pt-BR'>"
        "<head>"
        "<meta charset='UTF-8'>"
        "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        "<title>ESP32 Relay - Configuração</title>"
        "<style>"
        "* { margin: 0; padding: 0; box-sizing: border-box; }"
        "body {"
        "  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;"
        "  background: #667eea;"
        "  min-height: 100vh;"
        "  padding: 20px;"
        "}"
        ".container {"
        "  max-width: 600px;"
        "  margin: 0 auto;"
        "  background: white;"
        "  border-radius: 20px;"
        "  box-shadow: 0 20px 60px rgba(0,0,0,0.3);"
        "  overflow: hidden;"
        "}"
        ".header {"
        "  background: #5e72e4;"
        "  color: white;"
        "  padding: 30px;"
        "  text-align: center;"
        "}"
        ".header h1 { font-size: 28px; margin-bottom: 10px; }"
        ".header p { opacity: 0.9; }"
    );
    
    offset += snprintf(response + offset, 16384 - offset,
        ".status {"
        "  background: #f8f9fa;"
        "  padding: 20px 30px;"
        "  border-bottom: 1px solid #e1e4e8;"
        "}"
        ".status-grid {"
        "  display: grid;"
        "  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));"
        "  gap: 15px;"
        "}"
        ".status-item {"
        "  display: flex;"
        "  flex-direction: column;"
        "  gap: 5px;"
        "}"
        ".status-label {"
        "  font-size: 12px;"
        "  color: #666;"
        "  text-transform: uppercase;"
        "  letter-spacing: 0.5px;"
        "}"
        ".status-value {"
        "  font-size: 16px;"
        "  font-weight: 600;"
        "  color: #333;"
        "}"
        ".status-value.connected { color: #00d68f; }"
        ".status-value.disconnected { color: #ff4757; }"
    );
    
    offset += snprintf(response + offset, 16384 - offset,
        ".form-section {"
        "  padding: 30px;"
        "}"
        ".form-group {"
        "  margin-bottom: 25px;"
        "}"
        ".form-label {"
        "  display: block;"
        "  margin-bottom: 8px;"
        "  font-weight: 600;"
        "  color: #333;"
        "  font-size: 14px;"
        "}"
        ".form-input {"
        "  width: 100%%;"
        "  padding: 12px 15px;"
        "  border: 2px solid #e1e4e8;"
        "  border-radius: 10px;"
        "  font-size: 16px;"
        "  transition: all 0.3s ease;"
        "}"
        ".form-input:focus {"
        "  outline: none;"
        "  border-color: #5e72e4;"
        "  box-shadow: 0 0 0 3px rgba(94, 114, 228, 0.1);"
        "}"
        ".form-input:invalid {"
        "  border-color: #ff4757;"
        "}"
        ".form-hint {"
        "  margin-top: 5px;"
        "  font-size: 12px;"
        "  color: #666;"
        "}"
    );
    
    offset += snprintf(response + offset, 16384 - offset,
        ".button-group {"
        "  display: flex;"
        "  gap: 10px;"
        "  margin-top: 30px;"
        "  flex-wrap: wrap;"
        "}"
        ".btn {"
        "  flex: 1;"
        "  min-width: 140px;"
        "  padding: 14px 24px;"
        "  border: none;"
        "  border-radius: 10px;"
        "  font-size: 16px;"
        "  font-weight: 600;"
        "  cursor: pointer;"
        "  transition: all 0.3s ease;"
        "  text-decoration: none;"
        "  text-align: center;"
        "  display: inline-block;"
        "}"
        ".btn:hover {"
        "  transform: translateY(-2px);"
        "  box-shadow: 0 10px 20px rgba(0,0,0,0.2);"
        "}"
        ".btn-primary {"
        "  background: #00d68f;"
        "  color: white;"
        "}"
        ".btn-secondary {"
        "  background: #5e72e4;"
        "  color: white;"
        "}"
        ".btn-danger {"
        "  background: #ff4757;"
        "  color: white;"
        "}"
    );
    
    offset += snprintf(response + offset, 16384 - offset,
        ".alert {"
        "  padding: 15px 20px;"
        "  border-radius: 10px;"
        "  margin-bottom: 20px;"
        "}"
        ".alert-success {"
        "  background: #d4f4e2;"
        "  color: #00a76f;"
        "  border: 1px solid #00d68f;"
        "}"
        ".alert-error {"
        "  background: #ffe5e9;"
        "  color: #ff3838;"
        "  border: 1px solid #ff4757;"
        "}"
        ".spinner {"
        "  display: none;"
        "  width: 20px;"
        "  height: 20px;"
        "  border: 3px solid #f3f3f3;"
        "  border-top: 3px solid #5e72e4;"
        "  border-radius: 50%%;"
        "  animation: spin 1s linear infinite;"
        "  margin: 0 auto;"
        "}"
        "@keyframes spin {"
        "  0%% { transform: rotate(0deg); }"
        "  100%% { transform: rotate(360deg); }"
        "}"
        ".loading .spinner { display: block; }"
        ".loading .form-input { opacity: 0.5; }"
        "@media (max-width: 480px) {"
        "  .button-group { flex-direction: column; }"
        "  .btn { width: 100%%; }"
        "}"
        "</style>"
        "</head>"
    );
    
    offset += snprintf(response + offset, 16384 - offset,
        "<body>"
        "<div class='container'>"
        "  <div class='header'>"
        "    <h1>⚡ ESP32 Relay Control</h1>"
        "    <p>Sistema de Configuração v2.0</p>"
        "  </div>"
        "  <div class='status'>"
        "    <div class='status-grid'>"
        "      <div class='status-item'>"
        "        <span class='status-label'>Dispositivo</span>"
        "        <span class='status-value'>%s</span>"
        "      </div>"
        "      <div class='status-item'>"
        "        <span class='status-label'>Status WiFi</span>"
        "        <span class='status-value %s'>%s</span>"
        "      </div>"
        "      <div class='status-item'>"
        "        <span class='status-label'>IP</span>"
        "        <span class='status-value'>%s</span>"
        "      </div>"
        "      <div class='status-item'>"
        "        <span class='status-label'>Modo</span>"
        "        <span class='status-value'>%s</span>"
        "      </div>"
        "    </div>"
        "  </div>",
        config->device_name[0] ? config->device_name : "ESP32 Relay",
        wifi_class,
        wifi_status,
        ip_str,
        wifi_mode
    );
    
    offset += snprintf(response + offset, 16384 - offset,
        "  <div class='form-section'>"
        "    <form id='configForm' method='POST' action='/config'>"
        "      <div class='form-group'>"
        "        <label class='form-label'>📶 Rede WiFi (SSID)</label>"
        "        <input type='text' name='wifi_ssid' class='form-input' "
        "               value='%s' placeholder='Nome da rede WiFi' required>"
        "        <div class='form-hint'>Digite o nome da rede WiFi para conectar</div>"
        "      </div>"
        "      <div class='form-group'>"
        "        <label class='form-label'>🔐 Senha WiFi</label>"
        "        <input type='password' name='wifi_password' class='form-input' "
        "               placeholder='Senha da rede WiFi'>"
        "        <div class='form-hint'>Mínimo 8 caracteres (deixe vazio para manter atual)</div>"
        "      </div>",
        config->wifi_ssid[0] ? config->wifi_ssid : ""
    );
    
    offset += snprintf(response + offset, 16384 - offset,
        "      <div class='form-group'>"
        "        <label class='form-label'>🌐 IP do Backend</label>"
        "        <input type='text' name='backend_ip' class='form-input' "
        "               value='%s' placeholder='Ex: 192.168.1.100' "
        "               pattern='^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$' required>"
        "        <div class='form-hint'>Endereço IP do servidor AutoCore</div>"
        "      </div>"
        "      <div class='form-group'>"
        "        <label class='form-label'>🔌 Porta do Backend</label>"
        "        <input type='number' name='backend_port' class='form-input' "
        "               value='%d' placeholder='Ex: 8081' min='1' max='65535' required>"
        "        <div class='form-hint'>Porta do servidor (padrão: 8081)</div>"
        "      </div>"
        "      <div class='form-group'>"
        "        <label class='form-label'>⚡ Canais de Relé</label>"
        "        <input type='number' name='relay_channels' class='form-input' "
        "               value='%d' min='1' max='16' required>"
        "        <div class='form-hint'>Quantidade de canais disponíveis (1-16)</div>"
        "      </div>",
        config->backend_ip[0] ? config->backend_ip : "",
        config->backend_port > 0 ? config->backend_port : 8081,
        config->relay_channels > 0 ? config->relay_channels : 8
    );
    
    offset += snprintf(response + offset, 16384 - offset,
        "      <div class='button-group'>"
        "        <button type='submit' class='btn btn-primary'>💾 Salvar Configuração</button>"
        "        <button type='button' class='btn btn-secondary' onclick='restart()'>🔄 Reiniciar</button>"
        "        <button type='button' class='btn btn-danger' onclick='factoryReset()'>⚠️ Restaurar Padrões</button>"
        "      </div>"
        "    </form>"
        "    <div id='loading' class='spinner'></div>"
        "  </div>"
        "</div>"
        "<script>"
        "function restart() {"
        "  if(confirm('Deseja reiniciar o dispositivo?')) {"
        "    fetch('/restart', {method: 'POST'})"
        "      .then(function() {"
        "        alert('Dispositivo reiniciando... Aguarde 10 segundos.');"
        "        setTimeout(function() { location.reload(); }, 10000);"
        "      });"
        "  }"
        "}"
        "function factoryReset() {"
        "  if(confirm('ATENÇÃO: Isso apagará todas as configurações. Continuar?')) {"
        "    if(confirm('Tem certeza? Esta ação não pode ser desfeita!')) {"
        "      fetch('/reset', {method: 'POST'})"
        "        .then(function() {"
        "          alert('Configurações restauradas. O dispositivo será reiniciado.');"
        "          setTimeout(function() { location.reload(); }, 10000);"
        "        });"
        "    }"
        "  }"
        "}"
        "document.getElementById('configForm').addEventListener('submit', function(e) {"
        "  document.getElementById('loading').style.display = 'block';"
        "});"
        "</script>"
        "</body>"
        "</html>"
    );
    
    httpd_resp_set_type(req, "text/html");
    httpd_resp_send(req, response, strlen(response));
    
    free(response);
    ESP_LOGI(TAG, "Configuration page served");
    return ESP_OK;
}

/**
 * Configuration save handler
 */
static esp_err_t config_save_handler(httpd_req_t *req) {
    char buffer[512];
    int ret = httpd_req_recv(req, buffer, sizeof(buffer) - 1);
    
    if (ret <= 0) {
        httpd_resp_send_err(req, HTTPD_400_BAD_REQUEST, "No data");
        return ESP_FAIL;
    }
    
    buffer[ret] = '\0';
    ESP_LOGI(TAG, "Config data received: %d bytes", ret);
    
    // Parse form data
    device_config_t* config = config_get();
    if (!config) {
        httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Config error");
        return ESP_FAIL;
    }
    
    // Extract fields
    char wifi_ssid[65] = {0};
    char wifi_password[65] = {0};
    char backend_ip[16] = {0};
    char backend_port_str[6] = {0};
    char relay_channels_str[3] = {0};
    
    // Simple form parsing (field=value&field=value)
    char* token = strtok(buffer, "&");
    while (token) {
        char* eq = strchr(token, '=');
        if (eq) {
            *eq = '\0';
            char* key = token;
            char* value = eq + 1;
            
            // URL decode value (basic)
            char decoded[128];
            int j = 0;
            for (int i = 0; value[i] && j < sizeof(decoded) - 1; i++) {
                if (value[i] == '+') {
                    decoded[j++] = ' ';
                } else if (value[i] == '%' && value[i+1] && value[i+2]) {
                    char hex[3] = {value[i+1], value[i+2], 0};
                    decoded[j++] = (char)strtol(hex, NULL, 16);
                    i += 2;
                } else {
                    decoded[j++] = value[i];
                }
            }
            decoded[j] = '\0';
            
            // Store values
            if (strcmp(key, "wifi_ssid") == 0) {
                strncpy(wifi_ssid, decoded, sizeof(wifi_ssid) - 1);
            } else if (strcmp(key, "wifi_password") == 0) {
                strncpy(wifi_password, decoded, sizeof(wifi_password) - 1);
            } else if (strcmp(key, "backend_ip") == 0) {
                strncpy(backend_ip, decoded, sizeof(backend_ip) - 1);
            } else if (strcmp(key, "backend_port") == 0) {
                strncpy(backend_port_str, decoded, sizeof(backend_port_str) - 1);
            } else if (strcmp(key, "relay_channels") == 0) {
                strncpy(relay_channels_str, decoded, sizeof(relay_channels_str) - 1);
            }
        }
        token = strtok(NULL, "&");
    }
    
    // Validate and update config
    bool success = false;
    const char* message = "";
    
    if (strlen(wifi_ssid) > 0) {
        strncpy(config->wifi_ssid, wifi_ssid, sizeof(config->wifi_ssid) - 1);
        if (strlen(wifi_password) >= 8) {
            strncpy(config->wifi_password, wifi_password, sizeof(config->wifi_password) - 1);
        }
        
        if (strlen(backend_ip) > 0) {
            strncpy(config->backend_ip, backend_ip, sizeof(config->backend_ip) - 1);
        }
        
        int port = atoi(backend_port_str);
        if (port > 0 && port <= 65535) {
            config->backend_port = port;
        }
        
        int channels = atoi(relay_channels_str);
        if (channels > 0 && channels <= 16) {
            config->relay_channels = channels;
        }
        
        config->configured = true;
        
        // Save configuration
        if (config_save() == ESP_OK) {
            success = true;
            message = "Configuração salva! Conectando ao WiFi...";
            
            // Try to connect to WiFi
            ESP_LOGI(TAG, "Attempting WiFi connection to: %s", config->wifi_ssid);
            wifi_manager_connect(config->wifi_ssid, config->wifi_password);
        } else {
            message = "Erro ao salvar configuração";
        }
    } else {
        message = "SSID não pode estar vazio";
    }
    
    // Send response
    char* response = malloc(2048);
    if (response) {
        snprintf(response, 2048, RESPONSE_HTML,
            success ? "success" : "error",
            success ? "✅ Sucesso!" : "❌ Erro",
            message
        );
        
        httpd_resp_set_type(req, "text/html");
        httpd_resp_send(req, response, strlen(response));
        free(response);
    }
    
    return ESP_OK;
}

/**
 * Restart handler
 */
static esp_err_t restart_handler(httpd_req_t *req) {
    httpd_resp_send(req, "OK", 2);
    ESP_LOGI(TAG, "Restart requested - rebooting in 1 second");
    vTaskDelay(pdMS_TO_TICKS(1000));
    esp_restart();
    return ESP_OK;
}

/**
 * Factory reset handler
 */
static esp_err_t reset_handler(httpd_req_t *req) {
    httpd_resp_send(req, "OK", 2);
    ESP_LOGI(TAG, "Factory reset requested");
    
    // Erase NVS
    nvs_flash_erase();
    nvs_flash_init();
    
    // Restart
    vTaskDelay(pdMS_TO_TICKS(1000));
    esp_restart();
    return ESP_OK;
}

/**
 * Initialize HTTP server
 */
esp_err_t http_server_init_simple(void) {
    if (server != NULL) {
        ESP_LOGW(TAG, "HTTP server already running");
        return ESP_OK;
    }
    
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();
    config.lru_purge_enable = true;
    config.stack_size = 8192;
    config.max_uri_handlers = 8;
    
    ESP_LOGI(TAG, "Starting HTTP server on port %d", config.server_port);
    
    esp_err_t ret = httpd_start(&server, &config);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to start HTTP server: %s", esp_err_to_name(ret));
        return ret;
    }
    
    // Register URI handlers
    httpd_uri_t root_uri = {
        .uri = "/",
        .method = HTTP_GET,
        .handler = config_page_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(server, &root_uri);
    
    httpd_uri_t config_uri = {
        .uri = "/config",
        .method = HTTP_POST,
        .handler = config_save_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(server, &config_uri);
    
    httpd_uri_t restart_uri = {
        .uri = "/restart",
        .method = HTTP_POST,
        .handler = restart_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(server, &restart_uri);
    
    httpd_uri_t reset_uri = {
        .uri = "/reset",
        .method = HTTP_POST,
        .handler = reset_handler,
        .user_ctx = NULL
    };
    httpd_register_uri_handler(server, &reset_uri);
    
    ESP_LOGI(TAG, "HTTP Configuration server started successfully");
    return ESP_OK;
}

/**
 * Stop HTTP server
 */
esp_err_t http_server_stop_simple(void) {
    if (server == NULL) {
        return ESP_OK;
    }
    
    esp_err_t ret = httpd_stop(server);
    if (ret == ESP_OK) {
        server = NULL;
        ESP_LOGI(TAG, "HTTP server stopped");
    }
    
    return ret;
}