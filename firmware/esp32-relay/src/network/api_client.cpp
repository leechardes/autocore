#include "api_client.h"
#include "../utils/logger.h"
#include <WiFi.h>

// Instância global
APIClient apiClient;

APIClient::APIClient() : timeout(HTTP_REQUEST_TIMEOUT) {
    // Construtor
}

APIClient::~APIClient() {
    http.end();
}

bool APIClient::begin(const String& serverIP, int serverPort, int timeoutMs) {
    LOG_INFO_CTX("APIClient", "Inicializando cliente API: %s:%d", serverIP.c_str(), serverPort);
    
    setBaseURL(serverIP, serverPort);
    setTimeout(timeoutMs);
    
    // Testar conectividade básica
    if (!testConnection(serverIP, serverPort)) {
        LOG_ERROR_CTX("APIClient", "Falha no teste de conectividade");
        return false;
    }
    
    LOG_INFO_CTX("APIClient", "Cliente API inicializado com sucesso");
    return true;
}

void APIClient::setBaseURL(const String& ip, int port) {
    baseURL = "http://" + ip + ":" + String(port);
    LOG_DEBUG_CTX("APIClient", "Base URL configurada: %s", baseURL.c_str());
}

void APIClient::setTimeout(int timeoutMs) {
    timeout = timeoutMs;
    http.setTimeout(timeout);
}

bool APIClient::testConnection(const String& ip, int port) {
    LOG_DEBUG_CTX("APIClient", "Testando conexão com %s:%d", ip.c_str(), port);
    
    if (WiFi.status() != WL_CONNECTED) {
        LOG_ERROR_CTX("APIClient", "WiFi não conectado");
        return false;
    }
    
    HTTPClient testClient;
    testClient.setTimeout(5000); // 5 segundos timeout para teste
    
    String testURL = "http://" + ip + ":" + String(port) + "/api/status";
    testClient.begin(testURL);
    
    int httpCode = testClient.GET();
    testClient.end();
    
    bool success = (httpCode > 0 && httpCode < 500);
    
    if (success) {
        LOG_INFO_CTX("APIClient", "Conexão testada com sucesso (HTTP %d)", httpCode);
    } else {
        LOG_WARN_CTX("APIClient", "Teste de conexão falhou (HTTP %d)", httpCode);
    }
    
    return success;
}

bool APIClient::ping() {
    String response;
    return makeRequest("GET", "/api/status", "", response);
}

bool APIClient::announceDevice(const String& deviceUUID, const String& deviceType) {
    LOG_INFO_CTX("APIClient", "Anunciando dispositivo: %s (%s)", deviceUUID.c_str(), deviceType.c_str());
    
    JsonDocument doc;
    doc["uuid"] = deviceUUID;
    doc["type"] = deviceType;
    doc["firmware_version"] = FIRMWARE_VERSION;
    doc["timestamp"] = millis();
    doc["ip_address"] = WiFi.localIP().toString();
    
    String payload;
    serializeJson(doc, payload);
    
    String response;
    bool success = makeRequest("POST", "/api/devices/announce", payload, response);
    
    if (success) {
        LOG_INFO_CTX("APIClient", "Dispositivo anunciado com sucesso");
    } else {
        LOG_ERROR_CTX("APIClient", "Falha ao anunciar dispositivo");
    }
    
    return success;
}

bool APIClient::fetchConfig(const String& deviceUUID, String& configJson) {
    LOG_INFO_CTX("APIClient", "Buscando configuração para dispositivo: %s", deviceUUID.c_str());
    
    String endpoint = "/api/config/generate/" + deviceUUID;
    bool success = makeRequest("GET", endpoint, "", configJson);
    
    if (success) {
        LOG_INFO_CTX("APIClient", "Configuração recebida (%d bytes)", configJson.length());
        if (debugEnabled) {
            LOG_DEBUG_CTX("APIClient", "Config JSON: %s", configJson.c_str());
        }
    } else {
        LOG_ERROR_CTX("APIClient", "Falha ao buscar configuração");
    }
    
    return success;
}

bool APIClient::updateStatus(const String& deviceUUID, const String& statusJson) {
    LOG_DEBUG_CTX("APIClient", "Atualizando status do dispositivo: %s", deviceUUID.c_str());
    
    String endpoint = "/api/devices/" + deviceUUID + "/status";
    String response;
    bool success = makeRequest("PUT", endpoint, statusJson, response);
    
    if (success) {
        LOG_DEBUG_CTX("APIClient", "Status atualizado com sucesso");
    } else {
        LOG_WARN_CTX("APIClient", "Falha ao atualizar status");
    }
    
    return success;
}

bool APIClient::reportTelemetry(const String& deviceUUID, const String& telemetryJson) {
    LOG_DEBUG_CTX("APIClient", "Enviando telemetria do dispositivo: %s", deviceUUID.c_str());
    
    String endpoint = "/api/telemetry/" + deviceUUID;
    String response;
    bool success = makeRequest("POST", endpoint, telemetryJson, response);
    
    if (success) {
        LOG_DEBUG_CTX("APIClient", "Telemetria enviada com sucesso");
    } else {
        LOG_DEBUG_CTX("APIClient", "Falha ao enviar telemetria (não crítico)");
    }
    
    return success;
}

bool APIClient::discoverBackend(String& discoveredIP, int& discoveredPort) {
    LOG_INFO_CTX("APIClient", "Descobrindo backend AutoCore na rede...");
    
    // Lista de IPs comuns para tentar
    String commonIPs[] = {
        WiFi.gatewayIP().toString(),  // Gateway (provável Raspberry Pi)
        "192.168.1.100",             // IP comum
        "192.168.1.200",
        "192.168.0.100",
        "192.168.0.200",
        "10.0.0.100"
    };
    
    int commonPorts[] = { 8000, 8080, 3000, 5000 };
    
    for (String ip : commonIPs) {
        for (int port : commonPorts) {
            if (validateBackendAPI(ip, port)) {
                discoveredIP = ip;
                discoveredPort = port;
                LOG_INFO_CTX("APIClient", "Backend descoberto em: %s:%d", ip.c_str(), port);
                return true;
            }
        }
    }
    
    LOG_WARN_CTX("APIClient", "Nenhum backend descoberto automaticamente");
    return false;
}

bool APIClient::validateBackendAPI(const String& ip, int port) {
    HTTPClient testClient;
    testClient.setTimeout(3000); // 3 segundos timeout
    
    String testURL = "http://" + ip + ":" + String(port) + "/api/status";
    testClient.begin(testURL);
    testClient.addHeader("User-Agent", "AutoCore-ESP32-Relay");
    
    int httpCode = testClient.GET();
    
    if (httpCode == HTTP_CODE_OK) {
        String response = testClient.getString();
        testClient.end();
        
        // Verificar se a resposta parece ser do AutoCore
        if (response.indexOf("autocore") != -1 || response.indexOf("AutoCore") != -1) {
            return true;
        }
    }
    
    testClient.end();
    return false;
}

bool APIClient::makeRequest(const String& method, const String& endpoint, const String& payload, String& response) {
    if (WiFi.status() != WL_CONNECTED) {
        LOG_ERROR_CTX("APIClient", "WiFi desconectado");
        return false;
    }
    
    String fullURL = buildURL(endpoint);
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("APIClient", "%s %s", method.c_str(), fullURL.c_str());
        if (payload.length() > 0) {
            LOG_DEBUG_CTX("APIClient", "Payload: %s", payload.c_str());
        }
    }
    
    http.begin(fullURL);
    setRequestHeaders();
    
    int httpCode = -1;
    
    if (method == "GET") {
        httpCode = http.GET();
    } else if (method == "POST") {
        httpCode = http.POST(payload);
    } else if (method == "PUT") {
        httpCode = http.PUT(payload);
    } else if (method == "DELETE") {
        httpCode = http.sendRequest("DELETE", payload);
    }
    
    // Salvar o código HTTP para uso posterior
    lastHTTPCode = httpCode;
    
    if (httpCode > 0) {
        response = http.getString();
        
        if (debugEnabled) {
            LOG_DEBUG_CTX("APIClient", "HTTP %d - Response: %s", httpCode, response.c_str());
        }
        
        http.end();
        return (httpCode >= 200 && httpCode < 300);
    } else {
        LOG_ERROR_CTX("APIClient", "Erro na requisição HTTP: %d", httpCode);
        http.end();
        return false;
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

void APIClient::setRequestHeaders() {
    http.addHeader("Content-Type", "application/json");
    http.addHeader("User-Agent", "AutoCore-ESP32-Relay/" FIRMWARE_VERSION);
    http.addHeader("X-Device-Type", DEVICE_TYPE);
    http.setTimeout(timeout);
}

String APIClient::getLastError() {
    int code = lastHTTPCode;
    
    switch (code) {
        case HTTPC_ERROR_CONNECTION_REFUSED:
            return "Conexão recusada";
        case HTTPC_ERROR_SEND_HEADER_FAILED:
            return "Falha ao enviar header";
        case HTTPC_ERROR_SEND_PAYLOAD_FAILED:
            return "Falha ao enviar payload";
        case HTTPC_ERROR_NOT_CONNECTED:
            return "Não conectado";
        case HTTPC_ERROR_CONNECTION_LOST:
            return "Conexão perdida";
        case HTTPC_ERROR_NO_STREAM:
            return "Sem stream";
        case HTTPC_ERROR_NO_HTTP_SERVER:
            return "Servidor HTTP não encontrado";
        case HTTPC_ERROR_TOO_LESS_RAM:
            return "Pouca RAM";
        case HTTPC_ERROR_ENCODING:
            return "Erro de encoding";
        case HTTPC_ERROR_STREAM_WRITE:
            return "Erro ao escrever stream";
        case HTTPC_ERROR_READ_TIMEOUT:
            return "Timeout de leitura";
        default:
            return "Erro HTTP: " + String(code);
    }
}

bool APIClient::isConnected() {
    return WiFi.isConnected() && baseURL.length() > 0;
}

String APIClient::getServerInfo() {
    JsonDocument doc;
    doc["base_url"] = baseURL;
    doc["timeout"] = timeout;
    doc["wifi_connected"] = WiFi.isConnected();
    doc["last_http_code"] = lastHTTPCode;
    
    String info;
    serializeJson(doc, info);
    return info;
}

void APIClient::printLastResponse() {
    LOG_INFO_CTX("APIClient", "Último código HTTP: %d", lastHTTPCode);
    LOG_INFO_CTX("APIClient", "URL base: %s", baseURL.c_str());
}

void APIClient::setDebug(bool enabled) {
    debugEnabled = enabled;
    LOG_INFO_CTX("APIClient", "Debug %s", enabled ? "habilitado" : "desabilitado");
}

// ============================================
// AUTO-REGISTRO E CONFIGURAÇÃO MQTT
// ============================================

bool APIClient::checkDeviceRegistration(const String& deviceUUID) {
    String response;
    String endpoint = "/api/devices/uuid/" + deviceUUID;
    
    LOG_INFO_CTX("APIClient", "Verificando registro do dispositivo: %s", deviceUUID.c_str());
    
    if (makeRequest("GET", endpoint, "", response)) {
        // Se retornou 200, o dispositivo está registrado
        return true;
    } else {
        // Se retornou 404 ou outro erro, não está registrado
        return false;
    }
}

bool APIClient::registerDevice(const String& uuid, const String& name, const String& type,
                               const String& macAddress, const String& ipAddress,
                               const String& firmwareVersion, const String& hardwareVersion) {
    
    LOG_INFO_CTX("APIClient", "Registrando dispositivo: %s", uuid.c_str());
    
    // Criar JSON com dados do dispositivo
    JsonDocument doc;
    doc["uuid"] = uuid;
    doc["name"] = name;
    doc["type"] = type;
    doc["mac_address"] = macAddress;
    doc["ip_address"] = ipAddress;
    doc["firmware_version"] = firmwareVersion;
    doc["hardware_version"] = hardwareVersion;
    
    String payload;
    serializeJson(doc, payload);
    
    String response;
    if (makeRequest("POST", "/api/devices", payload, response)) {
        LOG_INFO_CTX("APIClient", "Dispositivo registrado com sucesso");
        return true;
    } else {
        LOG_ERROR_CTX("APIClient", "Falha ao registrar dispositivo (HTTP %d)", lastHTTPCode);
        return false;
    }
}

String APIClient::getMQTTConfig() {
    String response;
    
    LOG_INFO_CTX("APIClient", "Buscando configurações MQTT do backend");
    
    if (makeRequest("GET", "/api/mqtt/config", "", response)) {
        LOG_INFO_CTX("APIClient", "Configurações MQTT obtidas com sucesso");
        return response;
    } else {
        LOG_ERROR_CTX("APIClient", "Falha ao obter configurações MQTT (HTTP %d)", lastHTTPCode);
        return "";
    }
}