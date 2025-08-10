/**
 * AutoCore ESP32 Display - Web Server
 * 
 * Servidor web para configuração inicial via interface moderna
 * Compatível com o padrão do firmware de relé
 */

#pragma once

#include <Arduino.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <SPIFFS.h>
#include "../config/config_manager.h"
#include "wifi_manager.h"

/**
 * Servidor web para configuração do dispositivo
 * Interface moderna inspirada no shadcn/ui
 */
class WebServer {
private:
    AsyncWebServer* server;
    bool initialized;
    bool running;
    int port;
    
    // Rotas e handlers
    void setupRoutes();
    void handleRoot(AsyncWebServerRequest* request);
    void handleAssets(AsyncWebServerRequest* request);
    void handleAPI(AsyncWebServerRequest* request);
    
    // API Endpoints
    void handleGetStatus(AsyncWebServerRequest* request);
    void handleGetConfig(AsyncWebServerRequest* request);
    void handlePostConfig(AsyncWebServerRequest* request);
    void handleGetNetworks(AsyncWebServerRequest* request);
    void handleTestConnection(AsyncWebServerRequest* request);
    void handleRestart(AsyncWebServerRequest* request);
    void handleFactoryReset(AsyncWebServerRequest* request);
    
    // Validação
    bool validateConfigJSON(const String& json);
    String sanitizeInput(const String& input);
    
    // Respostas HTTP
    void sendJSON(AsyncWebServerRequest* request, const String& json, int code = 200);
    void sendError(AsyncWebServerRequest* request, const String& message, int code = 400);
    void sendSuccess(AsyncWebServerRequest* request, const String& message);
    
    // Arquivos estáticos
    String getContentType(const String& path);
    bool handleFileRequest(AsyncWebServerRequest* request, const String& path);
    
public:
    WebServer();
    ~WebServer();
    
    // Inicialização
    bool begin(int serverPort = WEB_SERVER_PORT);
    bool stop();
    bool restart();
    
    // Estado
    bool isInitialized() const { return initialized; }
    bool isRunning() const { return running; }
    int getPort() const { return port; }
    
    // Configuração
    void enableCORS(bool enable = true);
    void setMaxClients(int maxClients);
    
    // Utilitários
    void update();
    String getServerInfo() const;
    void printRoutes() const;
    
    // Debug
    bool debugEnabled = true;
};

// Instância global
extern WebServer webServer;