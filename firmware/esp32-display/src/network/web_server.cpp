/**
 * AutoCore ESP32 Display - Web Server Implementation
 */

#include "web_server.h"

// Instância global
WebServer webServer;

WebServer::WebServer() 
    : server(nullptr), 
      initialized(false), 
      running(false), 
      port(WEB_SERVER_PORT) {
}

WebServer::~WebServer() {
    stop();
}

bool WebServer::begin(int serverPort) {
    LOG_INFO_CTX("WebServer", "Inicializando servidor web na porta %d", serverPort);
    
    port = serverPort;
    
    // Criar servidor
    server = new AsyncWebServer(port);
    
    // Configurar rotas
    setupRoutes();
    
    // Habilitar CORS por padrão
    enableCORS(true);
    
    // Iniciar servidor
    server->begin();
    
    initialized = true;
    running = true;
    
    LOG_INFO_CTX("WebServer", "Servidor web inicializado com sucesso");
    return true;
}

bool WebServer::stop() {
    if (!initialized || !server) {
        return true;
    }
    
    LOG_INFO_CTX("WebServer", "Parando servidor web");
    
    server->end();
    delete server;
    server = nullptr;
    
    initialized = false;
    running = false;
    
    return true;
}

bool WebServer::restart() {
    if (running) {
        stop();
        delay(100);
    }
    return begin(port);
}

void WebServer::setupRoutes() {
    LOG_DEBUG_CTX("WebServer", "Configurando rotas do servidor");
    
    // Página principal
    server->on("/", HTTP_GET, [this](AsyncWebServerRequest* request) {
        this->handleRoot(request);
    });
    
    // Arquivos estáticos
    server->on("/style.css", HTTP_GET, [this](AsyncWebServerRequest* request) {
        this->handleAssets(request);
    });
    
    server->on("/app.js", HTTP_GET, [this](AsyncWebServerRequest* request) {
        this->handleAssets(request);
    });
    
    // API Routes
    server->on("/api/status", HTTP_GET, [this](AsyncWebServerRequest* request) {
        this->handleGetStatus(request);
    });
    
    server->on("/api/config", HTTP_GET, [this](AsyncWebServerRequest* request) {
        this->handleGetConfig(request);
    });
    
    server->on("/api/config", HTTP_POST, [this](AsyncWebServerRequest* request) {
        this->handlePostConfig(request);
    });
    
    server->on("/api/networks", HTTP_GET, [this](AsyncWebServerRequest* request) {
        this->handleGetNetworks(request);
    });
    
    server->on("/api/test-connection", HTTP_POST, [this](AsyncWebServerRequest* request) {
        this->handleTestConnection(request);
    });
    
    server->on("/api/restart", HTTP_POST, [this](AsyncWebServerRequest* request) {
        this->handleRestart(request);
    });
    
    server->on("/api/factory-reset", HTTP_POST, [this](AsyncWebServerRequest* request) {
        this->handleFactoryReset(request);
    });
    
    // Handler para captive portal
    server->onNotFound([this](AsyncWebServerRequest* request) {
        // Redirecionar todas as requisições para a página principal
        if (wifiManager.isAPMode()) {
            request->redirect("http://" + wifiManager.getAPIP().toString());
        } else {
            request->send(404, "text/plain", "Not Found");
        }
    });
    
    LOG_DEBUG_CTX("WebServer", "Rotas configuradas");
}

void WebServer::handleRoot(AsyncWebServerRequest* request) {
    LOG_DEBUG_CTX("WebServer", "Servindo página principal");
    
    // Tentar carregar do SPIFFS
    if (SPIFFS.exists("/index.html")) {
        request->send(SPIFFS, "/index.html", "text/html");
        return;
    }
    
    // HTML inline como fallback
    String html = R"(
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AutoCore Display - Configuração</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh; display: flex; align-items: center; justify-content: center;
        }
        .container { 
            background: white; border-radius: 12px; padding: 2rem; 
            box-shadow: 0 20px 40px rgba(0,0,0,0.1); width: 90%; max-width: 500px;
        }
        .logo { text-align: center; margin-bottom: 2rem; }
        .logo h1 { color: #333; font-size: 1.8rem; margin-bottom: 0.5rem; }
        .logo p { color: #666; font-size: 0.9rem; }
        .form-group { margin-bottom: 1.5rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; color: #333; font-weight: 500; }
        .form-group input, .form-group select { 
            width: 100%; padding: 0.75rem; border: 2px solid #e1e5e9; border-radius: 8px;
            font-size: 1rem; transition: border-color 0.3s;
        }
        .form-group input:focus, .form-group select:focus { 
            outline: none; border-color: #667eea; 
        }
        .btn { 
            width: 100%; padding: 0.875rem; background: #667eea; color: white; 
            border: none; border-radius: 8px; font-size: 1rem; cursor: pointer;
            transition: background 0.3s;
        }
        .btn:hover { background: #5a67d8; }
        .btn:disabled { background: #a0aec0; cursor: not-allowed; }
        .status { padding: 0.75rem; border-radius: 8px; margin-bottom: 1rem; }
        .status.success { background: #f0fff4; color: #22543d; border: 1px solid #9ae6b4; }
        .status.error { background: #fed7d7; color: #742a2a; border: 1px solid #fc8181; }
        .status.info { background: #ebf8ff; color: #2a4365; border: 1px solid #63b3ed; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <h1>🚗 AutoCore Display</h1>
            <p>Configuração Inicial do Sistema</p>
        </div>
        
        <div id="status"></div>
        
        <form id="configForm">
            <div class="form-group">
                <label>Nome do Dispositivo</label>
                <input type="text" id="deviceName" value="AutoCore Display" required>
            </div>
            
            <div class="form-group">
                <label>Rede WiFi</label>
                <select id="wifiNetwork" onchange="toggleCustomSSID()">
                    <option value="">Carregando...</option>
                </select>
            </div>
            
            <div class="form-group" id="customSSIDGroup" style="display:none;">
                <label>SSID Personalizado</label>
                <input type="text" id="customSSID">
            </div>
            
            <div class="form-group">
                <label>Senha WiFi</label>
                <input type="password" id="wifiPassword">
            </div>
            
            <div class="form-group">
                <label>IP do Backend</label>
                <input type="text" id="backendHost" placeholder="192.168.1.100" required>
            </div>
            
            <div class="form-group">
                <label>Porta do Backend</label>
                <input type="number" id="backendPort" value="8000" min="1" max="65535" required>
            </div>
            
            <button type="submit" class="btn" id="saveBtn">
                💾 Salvar Configuração
            </button>
        </form>
        
        <div style="margin-top: 1rem; text-align: center; font-size: 0.8rem; color: #666;">
            <p>UUID: <span id="deviceUUID">Carregando...</span></p>
            <p>Firmware: v)" + String(FIRMWARE_VERSION) + R"(</p>
        </div>
    </div>
    
    <script>
        let deviceUUID = '';
        
        // Carregar status inicial
        async function loadStatus() {
            try {
                const response = await fetch('/api/status');
                const data = await response.json();
                document.getElementById('deviceUUID').textContent = data.device_uuid || 'N/A';
                deviceUUID = data.device_uuid;
            } catch (e) {
                showStatus('Erro ao carregar status', 'error');
            }
        }
        
        // Carregar redes WiFi
        async function loadNetworks() {
            try {
                const response = await fetch('/api/networks');
                const data = await response.json();
                const select = document.getElementById('wifiNetwork');
                select.innerHTML = '<option value="">Selecione uma rede</option>';
                
                data.networks.forEach(network => {
                    const option = document.createElement('option');
                    option.value = network.ssid;
                    option.textContent = `${network.ssid} (${network.signal})`;
                    select.appendChild(option);
                });
                
                // Adicionar opção personalizada
                const customOption = document.createElement('option');
                customOption.value = 'custom';
                customOption.textContent = 'Rede personalizada...';
                select.appendChild(customOption);
            } catch (e) {
                showStatus('Erro ao carregar redes', 'error');
            }
        }
        
        // Toggle SSID personalizado
        function toggleCustomSSID() {
            const select = document.getElementById('wifiNetwork');
            const customGroup = document.getElementById('customSSIDGroup');
            customGroup.style.display = select.value === 'custom' ? 'block' : 'none';
        }
        
        // Mostrar status
        function showStatus(message, type = 'info') {
            const statusDiv = document.getElementById('status');
            statusDiv.innerHTML = `<div class="status ${type}">${message}</div>`;
        }
        
        // Enviar configuração
        document.getElementById('configForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const saveBtn = document.getElementById('saveBtn');
            saveBtn.disabled = true;
            saveBtn.textContent = '⏳ Salvando...';
            
            const formData = {
                device: {
                    name: document.getElementById('deviceName').value,
                    uuid: deviceUUID
                },
                wifi: {
                    ssid: document.getElementById('wifiNetwork').value === 'custom' 
                          ? document.getElementById('customSSID').value 
                          : document.getElementById('wifiNetwork').value,
                    password: document.getElementById('wifiPassword').value
                },
                backend: {
                    host: document.getElementById('backendHost').value,
                    port: parseInt(document.getElementById('backendPort').value)
                }
            };
            
            try {
                const response = await fetch('/api/config', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(formData)
                });
                
                const result = await response.json();
                
                if (response.ok) {
                    showStatus('✅ Configuração salva! Reiniciando dispositivo...', 'success');
                    setTimeout(() => {
                        fetch('/api/restart', { method: 'POST' });
                    }, 2000);
                } else {
                    throw new Error(result.error || 'Erro desconhecido');
                }
            } catch (e) {
                showStatus(`❌ Erro: ${e.message}`, 'error');
            } finally {
                saveBtn.disabled = false;
                saveBtn.textContent = '💾 Salvar Configuração';
            }
        });
        
        // Inicializar
        loadStatus();
        loadNetworks();
    </script>
</body>
</html>
    )";
    
    request->send(200, "text/html", html);
}

void WebServer::handleAssets(AsyncWebServerRequest* request) {
    String path = request->url();
    
    // Tentar carregar do SPIFFS
    if (handleFileRequest(request, path)) {
        return;
    }
    
    // Fallback para assets inline básicos
    if (path == "/style.css") {
        request->send(200, "text/css", "/* CSS básico já inline no HTML */");
    } else if (path == "/app.js") {
        request->send(200, "text/javascript", "/* JavaScript já inline no HTML */");
    } else {
        request->send(404, "text/plain", "Asset not found");
    }
}

void WebServer::handleGetStatus(AsyncWebServerRequest* request) {
    LOG_DEBUG_CTX("WebServer", "GET /api/status");
    
    DynamicJsonDocument doc(1024);
    
    // Status do dispositivo
    doc["device_uuid"] = configManager.getDeviceUUID();
    doc["device_name"] = configManager.getDeviceName();
    doc["firmware_version"] = FIRMWARE_VERSION;
    doc["configured"] = configManager.isConfigured();
    doc["uptime"] = millis() / 1000;
    doc["free_memory"] = ESP.getFreeHeap();
    
    // Status WiFi
    doc["wifi_state"] = wifiManager.getStateString();
    doc["wifi_connected"] = wifiManager.isConnected();
    doc["wifi_ap_mode"] = wifiManager.isAPMode();
    
    if (wifiManager.isConnected()) {
        doc["wifi_ssid"] = wifiManager.getSSID();
        doc["wifi_ip"] = wifiManager.getLocalIP().toString();
        doc["wifi_signal"] = wifiManager.getSignalStrength();
    }
    
    String response;
    serializeJson(doc, response);
    sendJSON(request, response);
}

void WebServer::handleGetConfig(AsyncWebServerRequest* request) {
    LOG_DEBUG_CTX("WebServer", "GET /api/config");
    
    DynamicJsonDocument doc(2048);
    
    const DeviceConfig& config = configManager.getConfig();
    
    // Configuração básica (sem senhas)
    doc["device"]["uuid"] = config.device_uuid;
    doc["device"]["name"] = config.device_name;
    doc["device"]["type"] = config.device_type;
    
    doc["wifi"]["ssid"] = config.wifi_ssid;
    doc["wifi"]["has_password"] = !config.wifi_password.isEmpty();
    
    doc["backend"]["host"] = config.backend_host;
    doc["backend"]["port"] = config.backend_port;
    
    doc["mqtt"]["broker"] = config.mqtt_broker;
    doc["mqtt"]["port"] = config.mqtt_port;
    doc["mqtt"]["user"] = config.mqtt_user;
    doc["mqtt"]["has_password"] = !config.mqtt_password.isEmpty();
    
    String response;
    serializeJson(doc, response);
    sendJSON(request, response);
}

void WebServer::handlePostConfig(AsyncWebServerRequest* request) {
    LOG_INFO_CTX("WebServer", "POST /api/config");
    
    // O body será processado via callback
    if (request->hasParam("body", true)) {
        String body = request->getParam("body", true)->value();
        
        if (validateConfigJSON(body)) {
            if (configManager.updateFromJSON(body)) {
                configManager.markAsConfigured();
                
                if (configManager.save()) {
                    sendSuccess(request, "Configuração salva com sucesso");
                    
                    // Agendar reinicialização
                    static AsyncWebServerRequest* restartRequest = nullptr;
                    restartRequest = request;
                    
                    return;
                } else {
                    sendError(request, "Erro ao salvar configuração");
                }
            } else {
                sendError(request, "Erro ao processar configuração");
            }
        } else {
            sendError(request, "JSON de configuração inválido");
        }
    } else {
        sendError(request, "Body da requisição vazio");
    }
}

void WebServer::handleGetNetworks(AsyncWebServerRequest* request) {
    LOG_DEBUG_CTX("WebServer", "GET /api/networks");
    
    int networkCount = wifiManager.scanNetworks();
    
    DynamicJsonDocument doc(2048);
    JsonArray networks = doc.createNestedArray("networks");
    
    for (int i = 0; i < networkCount && i < 20; i++) {  // Máximo 20 redes
        JsonObject network = networks.createNestedObject();
        network["ssid"] = wifiManager.getScannedSSID(i);
        network["rssi"] = wifiManager.getScannedRSSI(i);
        network["signal"] = wifiManager.signalStrengthToQuality(wifiManager.getScannedRSSI(i));
        network["security"] = wifiManager.getScannedSecurity(i);
    }
    
    doc["count"] = networkCount;
    
    String response;
    serializeJson(doc, response);
    sendJSON(request, response);
}

void WebServer::handleTestConnection(AsyncWebServerRequest* request) {
    LOG_DEBUG_CTX("WebServer", "POST /api/test-connection");
    
    // Implementar teste de conexão aqui
    sendSuccess(request, "Teste de conexão não implementado ainda");
}

void WebServer::handleRestart(AsyncWebServerRequest* request) {
    LOG_WARN_CTX("WebServer", "Reinicialização solicitada via API");
    
    sendSuccess(request, "Reiniciando dispositivo...");
    
    // Agendar reinicialização
    delay(1000);
    ESP.restart();
}

void WebServer::handleFactoryReset(AsyncWebServerRequest* request) {
    LOG_WARN_CTX("WebServer", "Factory reset solicitado via API");
    
    if (configManager.factoryReset()) {
        sendSuccess(request, "Factory reset executado. Reiniciando...");
        delay(1000);
        ESP.restart();
    } else {
        sendError(request, "Erro ao executar factory reset");
    }
}

bool WebServer::validateConfigJSON(const String& json) {
    DynamicJsonDocument doc(2048);
    DeserializationError error = deserializeJson(doc, json);
    return error == DeserializationError::Ok;
}

String WebServer::sanitizeInput(const String& input) {
    String sanitized = input;
    sanitized.replace("<", "&lt;");
    sanitized.replace(">", "&gt;");
    sanitized.replace("\"", "&quot;");
    sanitized.replace("'", "&#x27;");
    return sanitized;
}

void WebServer::sendJSON(AsyncWebServerRequest* request, const String& json, int code) {
    AsyncWebServerResponse* response = request->beginResponse(code, "application/json", json);
    response->addHeader("Access-Control-Allow-Origin", "*");
    request->send(response);
}

void WebServer::sendError(AsyncWebServerRequest* request, const String& message, int code) {
    DynamicJsonDocument doc(256);
    doc["success"] = false;
    doc["error"] = message;
    
    String response;
    serializeJson(doc, response);
    sendJSON(request, response, code);
}

void WebServer::sendSuccess(AsyncWebServerRequest* request, const String& message) {
    DynamicJsonDocument doc(256);
    doc["success"] = true;
    doc["message"] = message;
    
    String response;
    serializeJson(doc, response);
    sendJSON(request, response);
}

bool WebServer::handleFileRequest(AsyncWebServerRequest* request, const String& path) {
    if (SPIFFS.exists(path)) {
        request->send(SPIFFS, path, getContentType(path));
        return true;
    }
    return false;
}

String WebServer::getContentType(const String& path) {
    if (path.endsWith(".html")) return "text/html";
    if (path.endsWith(".css")) return "text/css";
    if (path.endsWith(".js")) return "text/javascript";
    if (path.endsWith(".json")) return "application/json";
    if (path.endsWith(".png")) return "image/png";
    if (path.endsWith(".jpg") || path.endsWith(".jpeg")) return "image/jpeg";
    if (path.endsWith(".gif")) return "image/gif";
    if (path.endsWith(".ico")) return "image/x-icon";
    return "text/plain";
}

void WebServer::enableCORS(bool enable) {
    if (!server) return;
    
    if (enable) {
        server->onNotFound([this](AsyncWebServerRequest* request) {
            if (request->method() == HTTP_OPTIONS) {
                AsyncWebServerResponse* response = request->beginResponse(200);
                response->addHeader("Access-Control-Allow-Origin", "*");
                response->addHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
                response->addHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
                request->send(response);
            } else {
                request->send(404, "text/plain", "Not Found");
            }
        });
    }
}

void WebServer::update() {
    // Servidor web é assíncrono, não requer update manual
}

String WebServer::getServerInfo() const {
    DynamicJsonDocument doc(256);
    doc["port"] = port;
    doc["initialized"] = initialized;
    doc["running"] = running;
    doc["free_memory"] = ESP.getFreeHeap();
    
    String info;
    serializeJson(doc, info);
    return info;
}

void WebServer::printRoutes() const {
    LOG_INFO("=== ROTAS DO SERVIDOR WEB ===");
    LOG_INFO("GET  / - Página principal");
    LOG_INFO("GET  /style.css - CSS");
    LOG_INFO("GET  /app.js - JavaScript");
    LOG_INFO("GET  /api/status - Status do sistema");
    LOG_INFO("GET  /api/config - Configuração atual");
    LOG_INFO("POST /api/config - Salvar configuração");
    LOG_INFO("GET  /api/networks - Redes WiFi");
    LOG_INFO("POST /api/test-connection - Testar conexão");
    LOG_INFO("POST /api/restart - Reiniciar dispositivo");
    LOG_INFO("POST /api/factory-reset - Reset de fábrica");
    LOG_INFO("==============================");
}