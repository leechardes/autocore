#ifndef WEB_SERVER_H
#define WEB_SERVER_H

#include <Arduino.h>
#include <ESPAsyncWebServer.h>
#include <AsyncTCP.h>
#include <SPIFFS.h>
#include <ArduinoJson.h>
#include "../config/config_manager.h"

class AutoCoreWebServer {
private:
    AsyncWebServer* server;
    bool running = false;
    bool spiffs_mounted = false;

    // Handlers para rotas
    void handleRoot(AsyncWebServerRequest *request);
    void handleConfig(AsyncWebServerRequest *request);
    void handleConfigPost(AsyncWebServerRequest *request);
    void handleScanWiFi(AsyncWebServerRequest *request);
    void handleTestConnection(AsyncWebServerRequest *request);
    void handleStatus(AsyncWebServerRequest *request);
    void handleLogs(AsyncWebServerRequest *request);
    void handleRestart(AsyncWebServerRequest *request);
    void handleFactoryReset(AsyncWebServerRequest *request);
    void handleNotFound(AsyncWebServerRequest *request);
    
    // Utilitários
    String getContentType(String filename);
    bool handleFileRead(AsyncWebServerRequest *request, String path);
    String scanWiFiNetworks();
    String templateProcessor(const String& var);
    bool testBackendConnection(const String& ip, int port);

public:
    AutoCoreWebServer();
    ~AutoCoreWebServer();

    // Inicialização e controle
    bool begin(int port = WEB_SERVER_PORT);
    void stop();
    bool isRunning() { return running; }
    
    // Configuração de rotas
    void setupRoutes();
    void setupCORS();
    
    // SPIFFS management
    bool mountSPIFFS();
    void unmountSPIFFS();
    bool isSPIFFSMounted() { return spiffs_mounted; }
    
    // Utilitários
    void handleCaptivePortal();
    String getClientInfo(AsyncWebServerRequest *request);
    void logRequest(AsyncWebServerRequest *request);
};

extern AutoCoreWebServer webServer;

#endif // WEB_SERVER_H