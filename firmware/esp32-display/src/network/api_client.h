/**
 * AutoCore ESP32 Display - API Client
 * 
 * Cliente para comunicação com o backend AutoCore
 * Busca configurações dinâmicas de telas e botões
 */

#pragma once

#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "../config/device_config.h"

/**
 * Estados do cliente API
 */
enum APIClientState {
    API_DISCONNECTED = 0,
    API_CONNECTING = 1,
    API_CONNECTED = 2,
    API_ERROR = 3,
    API_TIMEOUT = 4
};

/**
 * Resultado de operações API
 */
struct APIResponse {
    bool success;
    int httpCode;
    String data;
    String error;
    unsigned long responseTime;
    
    APIResponse() {
        success = false;
        httpCode = 0;
        responseTime = 0;
    }
};

/**
 * Cliente HTTP para comunicação com backend
 * Responsável por buscar configurações e enviar telemetria
 */
class APIClient {
private:
    HTTPClient http;
    APIClientState currentState;
    String baseURL;
    String apiKey;
    unsigned long lastRequest;
    unsigned long requestTimeout;
    int retryCount;
    bool initialized;
    
    // Configurações de timeout
    static constexpr unsigned long DEFAULT_TIMEOUT = 10000;  // 10 segundos
    static constexpr unsigned long RETRY_DELAY = 5000;       // 5 segundos
    static constexpr int MAX_RETRIES = 3;
    
    // Headers HTTP
    void setDefaultHeaders();
    void addAuthHeader();
    
    // Utilitários
    String buildURL(const String& endpoint);
    APIResponse processResponse();
    bool validateResponse(const String& data);
    
public:
    APIClient();
    ~APIClient();
    
    // Inicialização
    bool begin(const String& host, int port, const String& key = "");
    bool isInitialized() const { return initialized; }
    
    // Configuração
    void setBaseURL(const String& url);
    void setAPIKey(const String& key);
    void setTimeout(unsigned long timeout);
    
    // Estado
    APIClientState getState() const { return currentState; }
    String getStateString() const;
    bool isConnected() const { return currentState == API_CONNECTED; }
    
    // Operações principais
    APIResponse testConnection();
    APIResponse getDeviceConfig(const String& deviceUUID);
    APIResponse updateDeviceStatus(const String& deviceUUID, const String& status);
    APIResponse sendTelemetry(const String& deviceUUID, const String& telemetry);
    
    // Configuração específica do display
    APIResponse getDisplayConfig(const String& displayUUID);
    APIResponse getThemeConfig(const String& themeId = "default");
    APIResponse getScreensConfig(const String& displayUUID);
    
    // Operações genéricas
    APIResponse get(const String& endpoint);
    APIResponse post(const String& endpoint, const String& data);
    APIResponse put(const String& endpoint, const String& data);
    APIResponse del(const String& endpoint);
    
    // Validação de endpoints
    bool ping();
    bool validateBackend();
    
    // Parsers específicos
    bool parseDisplayConfig(const String& json, DeviceConfig& config);
    bool parseThemeConfig(const String& json, DisplayTheme& theme);
    bool parseScreensConfig(const String& json, std::vector<ScreenConfig>& screens);
    
    // Monitoramento
    void update();
    unsigned long getLastRequestTime() const { return lastRequest; }
    String getConnectionInfo() const;
    
    // Debug e diagnóstico
    void printStatus() const;
    void printConnectionInfo() const;
    String getStatusJSON() const;
    
    // Debug
    bool debugEnabled = true;
};

// Instância global
extern APIClient apiClient;