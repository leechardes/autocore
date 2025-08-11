#ifndef API_CLIENT_H
#define API_CLIENT_H

#include <Arduino.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "../config/device_config.h"

class APIClient {
private:
    HTTPClient http;
    String baseURL;
    int timeout;
    int lastHTTPCode = 0;
    
    // Métodos privados
    bool makeRequest(const String& method, const String& endpoint, const String& payload, String& response);
    String buildURL(const String& endpoint);
    void setRequestHeaders();

public:
    APIClient();
    ~APIClient();

    // Configuração
    bool begin(const String& serverIP, int serverPort, int timeoutMs = HTTP_REQUEST_TIMEOUT);
    void setBaseURL(const String& ip, int port);
    void setTimeout(int timeoutMs);
    
    // Testes de conectividade
    bool testConnection(const String& ip, int port);
    bool ping();
    
    // Endpoints do AutoCore Config App
    bool announceDevice(const String& deviceUUID, const String& deviceType);
    bool fetchConfig(const String& deviceUUID, String& configJson);
    bool updateStatus(const String& deviceUUID, const String& statusJson);
    bool reportTelemetry(const String& deviceUUID, const String& telemetryJson);
    
    // Auto-registro e configuração MQTT
    bool checkDeviceRegistration(const String& deviceUUID);
    bool registerDevice(const String& uuid, const String& name, const String& type,
                       const String& macAddress, const String& ipAddress,
                       const String& firmwareVersion, const String& hardwareVersion);
    String getMQTTConfig();
    
    // Descoberta e configuração
    bool discoverBackend(String& discoveredIP, int& discoveredPort);
    bool validateBackendAPI(const String& ip, int port);
    
    // Gerenciamento de erros
    int getLastHTTPCode() { return lastHTTPCode; }
    String getLastError();
    
    // Utilitários
    bool isConnected();
    String getServerInfo();
    void printLastResponse();
    
    // Debug
    void setDebug(bool enabled);
    bool debugEnabled = false;
};

extern APIClient apiClient;

#endif // API_CLIENT_H