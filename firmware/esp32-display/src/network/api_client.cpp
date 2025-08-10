/**
 * AutoCore ESP32 Display - API Client Implementation
 */

#include "api_client.h"

// Instância global
APIClient apiClient;

APIClient::APIClient() 
    : currentState(API_DISCONNECTED),
      lastRequest(0),
      requestTimeout(DEFAULT_TIMEOUT),
      retryCount(0),
      initialized(false) {
}

APIClient::~APIClient() {
    http.end();
}

bool APIClient::begin(const String& host, int port, const String& key) {
    LOG_INFO_CTX("APIClient", "Inicializando cliente API");
    LOG_INFO_CTX("APIClient", "Backend: %s:%d", host.c_str(), port);
    
    // Construir URL base
    baseURL = "http://" + host + ":" + String(port) + "/api";
    apiKey = key;
    
    // Configurar timeout
    setTimeout(DEFAULT_TIMEOUT);
    
    initialized = true;
    currentState = API_DISCONNECTED;
    
    LOG_INFO_CTX("APIClient", "Cliente API inicializado: %s", baseURL.c_str());
    return true;
}

void APIClient::setDefaultHeaders() {
    http.addHeader("Content-Type", "application/json");
    http.addHeader("User-Agent", "AutoCore-Display/" + String(FIRMWARE_VERSION));
    http.addHeader("X-Device-Type", DEVICE_TYPE);
    
    if (apiKey.length() > 0) {
        addAuthHeader();
    }
}

void APIClient::addAuthHeader() {
    if (apiKey.length() > 0) {
        http.addHeader("Authorization", "Bearer " + apiKey);
    }
}

String APIClient::buildURL(const String& endpoint) {
    String url = baseURL;
    if (!endpoint.startsWith("/")) {
        url += "/";
    }
    url += endpoint;
    return url;
}

String APIClient::getStateString() const {
    switch (currentState) {
        case API_DISCONNECTED: return "DESCONECTADO";
        case API_CONNECTING: return "CONECTANDO";
        case API_CONNECTED: return "CONECTADO";
        case API_ERROR: return "ERRO";
        case API_TIMEOUT: return "TIMEOUT";
        default: return "DESCONHECIDO";
    }
}

APIResponse APIClient::testConnection() {
    LOG_INFO_CTX("APIClient", "Testando conexão com backend");
    
    APIResponse response;
    
    if (!WiFi.isConnected()) {
        response.error = "WiFi não conectado";
        currentState = API_ERROR;
        return response;
    }
    
    String url = buildURL("/status");
    
    http.begin(url);
    setDefaultHeaders();
    
    unsigned long startTime = millis();
    int httpCode = http.GET();
    response.responseTime = millis() - startTime;
    response.httpCode = httpCode;
    
    if (httpCode == HTTP_CODE_OK) {
        response.data = http.getString();
        response.success = true;
        currentState = API_CONNECTED;
        
        LOG_INFO_CTX("APIClient", "Conexão com backend OK (%lu ms)", response.responseTime);
    } else {
        response.error = "HTTP " + String(httpCode) + ": " + http.errorToString(httpCode);
        currentState = API_ERROR;
        
        LOG_ERROR_CTX("APIClient", "Falha na conexão: %s", response.error.c_str());
    }
    
    http.end();
    lastRequest = millis();
    
    return response;
}

APIResponse APIClient::getDeviceConfig(const String& deviceUUID) {
    LOG_INFO_CTX("APIClient", "Buscando configuração do dispositivo: %s", deviceUUID.c_str());
    
    String endpoint = "/config/generate/" + deviceUUID;
    return get(endpoint);
}

APIResponse APIClient::getDisplayConfig(const String& displayUUID) {
    LOG_INFO_CTX("APIClient", "Buscando configuração específica do display");
    
    return getDeviceConfig(displayUUID);
}

APIResponse APIClient::getThemeConfig(const String& themeId) {
    LOG_DEBUG_CTX("APIClient", "Buscando configuração de tema: %s", themeId.c_str());
    
    String endpoint = "/themes/" + themeId;
    return get(endpoint);
}

APIResponse APIClient::getScreensConfig(const String& displayUUID) {
    LOG_DEBUG_CTX("APIClient", "Buscando configuração de telas para display: %s", displayUUID.c_str());
    
    String endpoint = "/displays/" + displayUUID + "/screens";
    return get(endpoint);
}

APIResponse APIClient::updateDeviceStatus(const String& deviceUUID, const String& status) {
    LOG_DEBUG_CTX("APIClient", "Atualizando status do dispositivo");
    
    DynamicJsonDocument doc(512);
    doc["device_uuid"] = deviceUUID;
    doc["timestamp"] = millis();
    doc["status"] = status;
    
    String payload;
    serializeJson(doc, payload);
    
    String endpoint = "/devices/" + deviceUUID + "/status";
    return post(endpoint, payload);
}

APIResponse APIClient::sendTelemetry(const String& deviceUUID, const String& telemetry) {
    if (debugEnabled) {
        LOG_DEBUG_CTX("APIClient", "Enviando telemetria do dispositivo");
    }
    
    String endpoint = "/devices/" + deviceUUID + "/telemetry";
    return post(endpoint, telemetry);
}

APIResponse APIClient::get(const String& endpoint) {
    APIResponse response;
    String url = buildURL(endpoint);
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("APIClient", "GET %s", url.c_str());
    }
    
    http.begin(url);
    setDefaultHeaders();
    http.setTimeout(requestTimeout);
    
    unsigned long startTime = millis();
    int httpCode = http.GET();
    response.responseTime = millis() - startTime;
    response.httpCode = httpCode;
    
    if (httpCode == HTTP_CODE_OK) {
        response.data = http.getString();
        response.success = true;
        currentState = API_CONNECTED;
        
        if (debugEnabled) {
            LOG_DEBUG_CTX("APIClient", "GET OK - %d bytes (%lu ms)", 
                         response.data.length(), response.responseTime);
        }
    } else if (httpCode > 0) {
        response.error = "HTTP " + String(httpCode) + ": " + http.getString();
        currentState = API_ERROR;
        
        LOG_ERROR_CTX("APIClient", "GET failed: %s", response.error.c_str());
    } else {
        response.error = "Conexão falhou: " + http.errorToString(httpCode);
        currentState = API_TIMEOUT;
        
        LOG_ERROR_CTX("APIClient", "GET timeout/error: %s", response.error.c_str());
    }
    
    http.end();
    lastRequest = millis();
    
    return response;
}

APIResponse APIClient::post(const String& endpoint, const String& data) {
    APIResponse response;
    String url = buildURL(endpoint);
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("APIClient", "POST %s (%d bytes)", url.c_str(), data.length());
    }
    
    http.begin(url);
    setDefaultHeaders();
    http.setTimeout(requestTimeout);
    
    unsigned long startTime = millis();
    int httpCode = http.POST(data);
    response.responseTime = millis() - startTime;
    response.httpCode = httpCode;
    
    if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_CREATED) {
        response.data = http.getString();
        response.success = true;
        currentState = API_CONNECTED;
        
        if (debugEnabled) {
            LOG_DEBUG_CTX("APIClient", "POST OK (%lu ms)", response.responseTime);
        }
    } else if (httpCode > 0) {
        response.error = "HTTP " + String(httpCode) + ": " + http.getString();
        currentState = API_ERROR;
        
        LOG_ERROR_CTX("APIClient", "POST failed: %s", response.error.c_str());
    } else {
        response.error = "Conexão falhou: " + http.errorToString(httpCode);
        currentState = API_TIMEOUT;
        
        LOG_ERROR_CTX("APIClient", "POST timeout/error: %s", response.error.c_str());
    }
    
    http.end();
    lastRequest = millis();
    
    return response;
}

APIResponse APIClient::put(const String& endpoint, const String& data) {
    APIResponse response;
    String url = buildURL(endpoint);
    
    http.begin(url);
    setDefaultHeaders();
    http.setTimeout(requestTimeout);
    
    unsigned long startTime = millis();
    int httpCode = http.PUT(data);
    response.responseTime = millis() - startTime;
    response.httpCode = httpCode;
    
    if (httpCode == HTTP_CODE_OK) {
        response.data = http.getString();
        response.success = true;
        currentState = API_CONNECTED;
    } else {
        response.error = "HTTP " + String(httpCode);
        currentState = API_ERROR;
    }
    
    http.end();
    lastRequest = millis();
    
    return response;
}

APIResponse APIClient::del(const String& endpoint) {
    APIResponse response;
    String url = buildURL(endpoint);
    
    http.begin(url);
    setDefaultHeaders();
    http.setTimeout(requestTimeout);
    
    unsigned long startTime = millis();
    int httpCode = http.sendRequest("DELETE");
    response.responseTime = millis() - startTime;
    response.httpCode = httpCode;
    
    if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_NO_CONTENT) {
        response.data = http.getString();
        response.success = true;
        currentState = API_CONNECTED;
    } else {
        response.error = "HTTP " + String(httpCode);
        currentState = API_ERROR;
    }
    
    http.end();
    lastRequest = millis();
    
    return response;
}

bool APIClient::ping() {
    APIResponse response = testConnection();
    return response.success;
}

bool APIClient::validateBackend() {
    LOG_INFO_CTX("APIClient", "Validando compatibilidade do backend");
    
    APIResponse response = get("/info");
    
    if (!response.success) {
        LOG_ERROR_CTX("APIClient", "Backend não responde");
        return false;
    }
    
    // Validar estrutura da resposta
    DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, response.data);
    
    if (error) {
        LOG_ERROR_CTX("APIClient", "Resposta JSON inválida do backend");
        return false;
    }
    
    // Verificar se é um backend AutoCore
    if (doc.containsKey("system") && doc["system"].as<String>().indexOf("AutoCore") >= 0) {
        LOG_INFO_CTX("APIClient", "Backend AutoCore validado");
        return true;
    }
    
    LOG_WARN_CTX("APIClient", "Backend pode não ser compatível");
    return false;
}

bool APIClient::parseDisplayConfig(const String& json, DeviceConfig& config) {
    LOG_DEBUG_CTX("APIClient", "Parseando configuração completa do display");
    
    DynamicJsonDocument doc(8192);  // Buffer grande para configuração completa
    DeserializationError error = deserializeJson(doc, json);
    
    if (error) {
        LOG_ERROR_CTX("APIClient", "Erro ao parsear JSON de configuração: %s", error.c_str());
        return false;
    }
    
    // Parsear configuração do dispositivo
    if (doc.containsKey("device")) {
        JsonObject device = doc["device"];
        if (device.containsKey("name")) {
            config.device_name = device["name"].as<String>();
        }
    }
    
    // Parsear configuração MQTT
    if (doc.containsKey("mqtt")) {
        JsonObject mqtt = doc["mqtt"];
        if (mqtt.containsKey("broker")) config.mqtt_broker = mqtt["broker"].as<String>();
        if (mqtt.containsKey("port")) config.mqtt_port = mqtt["port"].as<int>();
        if (mqtt.containsKey("username")) config.mqtt_user = mqtt["username"].as<String>();
        if (mqtt.containsKey("password")) config.mqtt_password = mqtt["password"].as<String>();
    }
    
    // Parsear tema
    if (doc.containsKey("theme")) {
        String themeJSON;
        serializeJson(doc["theme"], themeJSON);
        parseThemeConfig(themeJSON, config.theme);
    }
    
    // Parsear telas
    if (doc.containsKey("screens")) {
        String screensJSON;
        serializeJson(doc["screens"], screensJSON);
        parseScreensConfig(screensJSON, config.screens);
    }
    
    LOG_INFO_CTX("APIClient", "Configuração parseada com sucesso");
    return true;
}

bool APIClient::parseThemeConfig(const String& json, DisplayTheme& theme) {
    LOG_DEBUG_CTX("APIClient", "Parseando configuração de tema");
    
    DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, json);
    
    if (error) {
        LOG_ERROR_CTX("APIClient", "Erro ao parsear tema: %s", error.c_str());
        return false;
    }
    
    if (doc.containsKey("name")) {
        theme.name = doc["name"].as<String>();
    }
    
    if (doc.containsKey("colors")) {
        JsonObject colors = doc["colors"];
        
        // Converter cores hex para valores numéricos
        if (colors.containsKey("primary")) {
            String hex = colors["primary"].as<String>();
            theme.primary_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
        if (colors.containsKey("secondary")) {
            String hex = colors["secondary"].as<String>();
            theme.secondary_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
        if (colors.containsKey("warning")) {
            String hex = colors["warning"].as<String>();
            theme.warning_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
        if (colors.containsKey("danger")) {
            String hex = colors["danger"].as<String>();
            theme.danger_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
        if (colors.containsKey("background")) {
            String hex = colors["background"].as<String>();
            theme.background_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
        if (colors.containsKey("surface")) {
            String hex = colors["surface"].as<String>();
            theme.surface_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
    }
    
    return true;
}

bool APIClient::parseScreensConfig(const String& json, std::vector<ScreenConfig>& screens) {
    LOG_DEBUG_CTX("APIClient", "Parseando configuração de telas");
    
    DynamicJsonDocument doc(8192);
    DeserializationError error = deserializeJson(doc, json);
    
    if (error) {
        LOG_ERROR_CTX("APIClient", "Erro ao parsear telas: %s", error.c_str());
        return false;
    }
    
    screens.clear();
    
    if (doc.is<JsonArray>()) {
        JsonArray screensArray = doc.as<JsonArray>();
        
        for (JsonObject screenObj : screensArray) {
            ScreenConfig screen;
            
            screen.id = screenObj["id"].as<String>();
            screen.title = screenObj["title"].as<String>();
            
            // Layout
            if (screenObj.containsKey("layout")) {
                JsonObject layout = screenObj["layout"];
                screen.layout_type = layout["type"].as<String>();
                if (layout.containsKey("cols")) screen.layout_cols = layout["cols"];
                if (layout.containsKey("rows")) screen.layout_rows = layout["rows"];
                if (layout.containsKey("spacing")) screen.layout_spacing = layout["spacing"];
                if (layout.containsKey("item_height")) screen.item_height = layout["item_height"];
            }
            
            // Botões
            if (screenObj.containsKey("buttons")) {
                JsonArray buttonsArray = screenObj["buttons"];
                
                for (JsonObject buttonObj : buttonsArray) {
                    ButtonConfig button;
                    
                    button.id = buttonObj["id"].as<String>();
                    button.label = buttonObj["label"].as<String>();
                    button.icon = buttonObj["icon"].as<String>();
                    button.type = buttonObj["type"].as<String>();
                    
                    // Posição
                    if (buttonObj.containsKey("position")) {
                        JsonObject pos = buttonObj["position"];
                        button.col = pos["col"];
                        button.row = pos["row"];
                    }
                    
                    // Ação
                    if (buttonObj.containsKey("action")) {
                        JsonObject action = buttonObj["action"];
                        button.action_type = action["type"].as<String>();
                        if (action.containsKey("channel")) button.action_channel = action["channel"];
                        if (action.containsKey("data")) button.action_data = action["data"].as<String>();
                    }
                    
                    // Proteção
                    if (buttonObj.containsKey("protection")) {
                        JsonObject protection = buttonObj["protection"];
                        if (protection.containsKey("type")) button.protection_type = protection["type"].as<String>();
                        if (protection.containsKey("message")) button.protection_message = protection["message"].as<String>();
                    }
                    
                    // Cores personalizadas
                    if (buttonObj.containsKey("style")) {
                        JsonObject style = buttonObj["style"];
                        if (style.containsKey("color_active")) {
                            String hex = style["color_active"].as<String>();
                            button.color_active = strtol(hex.substring(1).c_str(), NULL, 16);
                            button.custom_colors = true;
                        }
                        if (style.containsKey("color_inactive")) {
                            String hex = style["color_inactive"].as<String>();
                            button.color_inactive = strtol(hex.substring(1).c_str(), NULL, 16);
                            button.custom_colors = true;
                        }
                    }
                    
                    screen.buttons.push_back(button);
                }
            }
            
            screens.push_back(screen);
        }
    }
    
    LOG_INFO_CTX("APIClient", "Parseadas %d telas com sucesso", screens.size());
    return true;
}

void APIClient::setTimeout(unsigned long timeout) {
    requestTimeout = timeout;
    LOG_DEBUG_CTX("APIClient", "Timeout definido para %lu ms", timeout);
}

void APIClient::update() {
    // Cliente HTTP não requer update contínuo
    // Apenas verificar estado de conectividade se necessário
}

String APIClient::getConnectionInfo() const {
    DynamicJsonDocument doc(512);
    
    doc["base_url"] = baseURL;
    doc["state"] = getStateString();
    doc["has_api_key"] = !apiKey.isEmpty();
    doc["timeout"] = requestTimeout;
    doc["last_request"] = lastRequest;
    doc["retry_count"] = retryCount;
    
    String info;
    serializeJson(doc, info);
    return info;
}

void APIClient::printStatus() const {
    LOG_INFO("=== STATUS API CLIENT ===");
    LOG_INFO("URL Base: %s", baseURL.c_str());
    LOG_INFO("Estado: %s", getStateString().c_str());
    LOG_INFO("API Key: %s", apiKey.length() > 0 ? "Configurada" : "Não configurada");
    LOG_INFO("Timeout: %lu ms", requestTimeout);
    LOG_INFO("Última requisição: %lu ms atrás", millis() - lastRequest);
    LOG_INFO("========================");
}

String APIClient::getStatusJSON() const {
    return getConnectionInfo();
}