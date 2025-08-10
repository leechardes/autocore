#include "web_server.h"
#include "../utils/logger.h"
#include "api_client.h"
#include <WiFi.h>
#include <DNSServer.h>

// Instância global
AutoCoreWebServer webServer;

AutoCoreWebServer::AutoCoreWebServer() : server(nullptr) {
    // Construtor
}

AutoCoreWebServer::~AutoCoreWebServer() {
    stop();
}

bool AutoCoreWebServer::begin(int port) {
    LOG_INFO_CTX("WebServer", "Inicializando servidor web na porta %d", port);
    
    if (running) {
        LOG_WARN_CTX("WebServer", "Servidor já está rodando");
        return true;
    }
    
    // Montar SPIFFS se não estiver montado
    if (!spiffs_mounted) {
        mountSPIFFS();
    }
    
    // Criar servidor
    server = new AsyncWebServer(port);
    if (!server) {
        LOG_ERROR_CTX("WebServer", "Falha ao criar servidor web");
        return false;
    }
    
    // Configurar rotas
    setupCORS();
    setupRoutes();
    
    // Iniciar servidor
    server->begin();
    running = true;
    
    LOG_INFO_CTX("WebServer", "Servidor web iniciado com sucesso");
    LOG_INFO_CTX("WebServer", "Acesse: http://%s", WiFi.localIP().toString().c_str());
    
    return true;
}

void AutoCoreWebServer::stop() {
    if (server && running) {
        LOG_INFO_CTX("WebServer", "Parando servidor web");
        server->end();
        delete server;
        server = nullptr;
        running = false;
    }
}

void AutoCoreWebServer::setupCORS() {
    // Configurar CORS para aceitar requisições de qualquer origem
    server->onNotFound([this](AsyncWebServerRequest *request){
        if (request->method() == HTTP_OPTIONS) {
            request->send(200);
        } else {
            handleNotFound(request);
        }
    });
    
    // Headers CORS para todas as respostas
    DefaultHeaders::Instance().addHeader("Access-Control-Allow-Origin", "*");
    DefaultHeaders::Instance().addHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    DefaultHeaders::Instance().addHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

void AutoCoreWebServer::setupRoutes() {
    LOG_DEBUG_CTX("WebServer", "Configurando rotas");
    
    // Rota principal - página de configuração
    server->on("/", HTTP_GET, [this](AsyncWebServerRequest *request) {
        handleRoot(request);
    });
    
    // API de configuração
    server->on("/api/config", HTTP_GET, [this](AsyncWebServerRequest *request) {
        handleConfig(request);
    });
    
    server->on("/api/config", HTTP_POST, [this](AsyncWebServerRequest *request) {
        handleConfigPost(request);
    });
    
    // API de scan WiFi
    server->on("/api/wifi/scan", HTTP_GET, [this](AsyncWebServerRequest *request) {
        handleScanWiFi(request);
    });
    
    // API de teste de conexão
    server->on("/api/test", HTTP_POST, [this](AsyncWebServerRequest *request) {
        handleTestConnection(request);
    });
    
    // API de status
    server->on("/api/status", HTTP_GET, [this](AsyncWebServerRequest *request) {
        handleStatus(request);
    });
    
    // API de logs
    server->on("/api/logs", HTTP_GET, [this](AsyncWebServerRequest *request) {
        handleLogs(request);
    });
    
    // API de controle
    server->on("/api/restart", HTTP_POST, [this](AsyncWebServerRequest *request) {
        handleRestart(request);
    });
    
    server->on("/api/factory-reset", HTTP_POST, [this](AsyncWebServerRequest *request) {
        handleFactoryReset(request);
    });
    
    // Servir arquivos estáticos do SPIFFS
    server->serveStatic("/", SPIFFS, "/").setDefaultFile("index.html");
    
    // Captive Portal (redireciona todas as requisições não encontradas)
    server->onNotFound([this](AsyncWebServerRequest *request) {
        // Se for uma requisição para a raiz de um dominio não reconhecido, 
        // redirecionar para o portal captivo
        if (!request->url().startsWith("/api/")) {
            handleCaptivePortal();
            request->redirect("http://" + WiFi.softAPIP().toString());
        } else {
            handleNotFound(request);
        }
    });
}

void AutoCoreWebServer::handleRoot(AsyncWebServerRequest *request) {
    logRequest(request);
    
    if (spiffs_mounted && SPIFFS.exists("/index.html")) {
        request->send(SPIFFS, "/index.html", "text/html", false, [this](const String& var) {
            return templateProcessor(var);
        });
    } else {
        // HTML inline caso SPIFFS não esteja disponível
        String html = "<!DOCTYPE html><html><head>";
        html += "<title>AutoCore ESP32 Relay - Configuração</title>";
        html += "<meta name='viewport' content='width=device-width, initial-scale=1'>";
        html += "<style>body{font-family:Arial;margin:40px;background:#f5f5f5}";
        html += ".container{max-width:500px;margin:0 auto;background:white;padding:30px;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.1)}";
        html += "h1{color:#333;text-align:center;margin-bottom:30px}";
        html += ".form-group{margin-bottom:20px}";
        html += "label{display:block;margin-bottom:5px;font-weight:bold;color:#555}";
        html += "input{width:100%;padding:10px;border:1px solid #ddd;border-radius:4px;box-sizing:border-box}";
        html += "button{background:#007bff;color:white;padding:12px 30px;border:none;border-radius:4px;cursor:pointer;width:100%;font-size:16px}";
        html += "button:hover{background:#0056b3}";
        html += ".status{padding:10px;margin:10px 0;border-radius:4px}";
        html += ".success{background:#d4edda;color:#155724;border:1px solid #c3e6cb}";
        html += ".error{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}";
        html += "</style></head><body>";
        html += "<div class='container'>";
        html += "<h1>🚗 AutoCore ESP32 Relay</h1>";
        html += "<p>Configure seu dispositivo de relés para integrar com o sistema AutoCore.</p>";
        html += "<div class='status error'>⚠️ Interface de configuração básica - SPIFFS não disponível</div>";
        html += "<p><strong>UUID:</strong> " + configManager.getDeviceUUID() + "</p>";
        html += "<p><strong>Status:</strong> ";
        html += configManager.isConfigured() ? "Configurado" : "Aguardando Configuração";
        html += "</p>";
        html += "<p><a href='/api/config' target='_blank'>Ver Configuração (JSON)</a></p>";
        html += "<p><a href='/api/status' target='_blank'>Ver Status (JSON)</a></p>";
        html += "<p><a href='/api/logs' target='_blank'>Ver Logs (JSON)</a></p>";
        html += "</div></body></html>";
        
        request->send(200, "text/html", html);
    }
}

void AutoCoreWebServer::handleConfig(AsyncWebServerRequest *request) {
    logRequest(request);
    
    String config = configManager.getConfigJSON();
    request->send(200, "application/json", config);
}

void AutoCoreWebServer::handleConfigPost(AsyncWebServerRequest *request) {
    logRequest(request);
    
    // Esta função será chamada para requisições POST
    // O corpo será tratado no callback body
    if (request->hasParam("config", true)) {
        String configJson = request->getParam("config", true)->value();
        
        LOG_INFO_CTX("WebServer", "Recebida configuração: %s", configJson.c_str());
        
        // Parser do JSON de configuração
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, configJson);
        
        if (error) {
            LOG_ERROR_CTX("WebServer", "Erro ao parsear JSON: %s", error.c_str());
            request->send(400, "application/json", "{\"success\":false,\"error\":\"JSON inválido\"}");
            return;
        }
        
        bool success = true;
        String errorMsg = "";
        
        // Configurar WiFi
        if (doc["wifi_ssid"].is<String>() && doc["wifi_password"].is<String>()) {
            String ssid = doc["wifi_ssid"];
            String password = doc["wifi_password"];
            
            if (ssid.length() > 0) {
                success &= configManager.setWiFiCredentials(ssid, password);
            }
        }
        
        // Configurar Backend
        if (doc["backend_ip"].is<String>() && doc["backend_port"].is<int>()) {
            String ip = doc["backend_ip"];
            int port = doc["backend_port"];
            
            if (ip.length() > 0 && port > 0) {
                success &= configManager.setBackendInfo(ip, port);
            }
        }
        
        // Configurar MQTT (opcional)
        if (doc["mqtt_broker"].is<String>() && doc["mqtt_port"].is<int>()) {
            String broker = doc["mqtt_broker"];
            int port = doc["mqtt_port"];
            String user = doc["mqtt_user"] | "";
            String pass = doc["mqtt_password"] | "";
            
            if (broker.length() > 0 && port > 0) {
                success &= configManager.setMQTTInfo(broker, port, user, pass);
            }
        }
        
        if (success) {
            configManager.setConfigured(true);
            request->send(200, "application/json", "{\"success\":true,\"message\":\"Configuração salva com sucesso\"}");
            
            // Restart após 3 segundos para aplicar configuração
            LOG_INFO_CTX("WebServer", "Configuração salva, reiniciando em 3 segundos...");
            delay(3000);
            ESP.restart();
        } else {
            request->send(400, "application/json", "{\"success\":false,\"error\":\"Erro ao salvar configuração\"}");
        }
    } else {
        request->send(400, "application/json", "{\"success\":false,\"error\":\"Parâmetro 'config' obrigatório\"}");
    }
}

void AutoCoreWebServer::handleScanWiFi(AsyncWebServerRequest *request) {
    logRequest(request);
    
    LOG_INFO_CTX("WebServer", "Executando scan de WiFi...");
    String networks = scanWiFiNetworks();
    request->send(200, "application/json", networks);
}

void AutoCoreWebServer::handleTestConnection(AsyncWebServerRequest *request) {
    logRequest(request);
    
    if (!request->hasParam("ip", true) || !request->hasParam("port", true)) {
        request->send(400, "application/json", "{\"success\":false,\"error\":\"IP e porta obrigatórios\"}");
        return;
    }
    
    String ip = request->getParam("ip", true)->value();
    int port = request->getParam("port", true)->value().toInt();
    
    LOG_INFO_CTX("WebServer", "Testando conexão com %s:%d", ip.c_str(), port);
    
    bool success = testBackendConnection(ip, port);
    
    JsonDocument doc;
    doc["success"] = success;
    doc["ip"] = ip;
    doc["port"] = port;
    doc["message"] = success ? "Conexão bem-sucedida" : "Falha na conexão";
    
    String response;
    serializeJson(doc, response);
    request->send(200, "application/json", response);
}

void AutoCoreWebServer::handleStatus(AsyncWebServerRequest *request) {
    logRequest(request);
    
    String status = configManager.getStatusJSON();
    request->send(200, "application/json", status);
}

void AutoCoreWebServer::handleLogs(AsyncWebServerRequest *request) {
    logRequest(request);
    
    String logs = Logger::getBufferAsJSON();
    request->send(200, "application/json", logs);
}

void AutoCoreWebServer::handleRestart(AsyncWebServerRequest *request) {
    logRequest(request);
    
    LOG_WARN_CTX("WebServer", "Reinicialização solicitada via API");
    request->send(200, "application/json", "{\"success\":true,\"message\":\"Reiniciando em 3 segundos...\"}");
    
    delay(3000);
    ESP.restart();
}

void AutoCoreWebServer::handleFactoryReset(AsyncWebServerRequest *request) {
    logRequest(request);
    
    LOG_WARN_CTX("WebServer", "Factory reset solicitado via API");
    configManager.factoryReset();
    
    request->send(200, "application/json", "{\"success\":true,\"message\":\"Factory reset concluído, reiniciando...\"}");
    
    delay(3000);
    ESP.restart();
}

void AutoCoreWebServer::handleNotFound(AsyncWebServerRequest *request) {
    logRequest(request);
    
    JsonDocument doc;
    doc["error"] = "Endpoint não encontrado";
    doc["method"] = request->methodToString();
    doc["url"] = request->url();
    
    String response;
    serializeJson(doc, response);
    request->send(404, "application/json", response);
}

String AutoCoreWebServer::scanWiFiNetworks() {
    JsonDocument doc;
    JsonArray networks = doc["networks"].to<JsonArray>();
    
    int n = WiFi.scanNetworks();
    
    if (n == 0) {
        LOG_WARN_CTX("WebServer", "Nenhuma rede WiFi encontrada");
    } else {
        LOG_INFO_CTX("WebServer", "Encontradas %d redes WiFi", n);
        
        for (int i = 0; i < n; ++i) {
            JsonObject network = networks.add<JsonObject>();
            network["ssid"] = WiFi.SSID(i);
            network["rssi"] = WiFi.RSSI(i);
            network["security"] = (WiFi.encryptionType(i) == WIFI_AUTH_OPEN) ? "open" : "secure";
            network["channel"] = WiFi.channel(i);
        }
    }
    
    doc["count"] = n;
    doc["timestamp"] = millis();
    
    String result;
    serializeJson(doc, result);
    return result;
}

bool AutoCoreWebServer::testBackendConnection(const String& ip, int port) {
    // Usar o APIClient para testar conexão
    APIClient apiClient;
    return apiClient.testConnection(ip, port);
}

String AutoCoreWebServer::templateProcessor(const String& var) {
    // Substituir variáveis no template HTML
    if (var == "DEVICE_UUID") {
        return configManager.getDeviceUUID();
    }
    if (var == "DEVICE_NAME") {
        return configManager.getDeviceName();
    }
    if (var == "FIRMWARE_VERSION") {
        return FIRMWARE_VERSION;
    }
    if (var == "WIFI_STATUS") {
        return WiFi.isConnected() ? "Conectado" : "Desconectado";
    }
    if (var == "CONFIG_STATUS") {
        return configManager.isConfigured() ? "Configurado" : "Pendente";
    }
    
    return String();
}

bool AutoCoreWebServer::mountSPIFFS() {
    if (spiffs_mounted) {
        return true;
    }
    
    LOG_INFO_CTX("WebServer", "Montando SPIFFS...");
    
    if (!SPIFFS.begin(true)) {
        LOG_ERROR_CTX("WebServer", "Falha ao montar SPIFFS");
        return false;
    }
    
    spiffs_mounted = true;
    
    // Listar arquivos
    File root = SPIFFS.open("/");
    File file = root.openNextFile();
    
    LOG_DEBUG_CTX("WebServer", "Arquivos SPIFFS:");
    while (file) {
        LOG_DEBUG_CTX("WebServer", "  %s (%d bytes)", file.name(), file.size());
        file = root.openNextFile();
    }
    
    LOG_INFO_CTX("WebServer", "SPIFFS montado com sucesso");
    return true;
}

void AutoCoreWebServer::unmountSPIFFS() {
    if (spiffs_mounted) {
        SPIFFS.end();
        spiffs_mounted = false;
        LOG_INFO_CTX("WebServer", "SPIFFS desmontado");
    }
}

void AutoCoreWebServer::handleCaptivePortal() {
    LOG_DEBUG_CTX("WebServer", "Redirecionamento para captive portal");
}

String AutoCoreWebServer::getClientInfo(AsyncWebServerRequest *request) {
    String info = "Client: ";
    info += request->client()->remoteIP().toString();
    info += " - User-Agent: ";
    if (request->hasHeader("User-Agent")) {
        info += request->getHeader("User-Agent")->value();
    }
    return info;
}

void AutoCoreWebServer::logRequest(AsyncWebServerRequest *request) {
    LOG_DEBUG_CTX("WebServer", "%s %s - %s", 
                  request->methodToString(), 
                  request->url().c_str(),
                  request->client()->remoteIP().toString().c_str());
}