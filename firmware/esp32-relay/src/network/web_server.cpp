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
    
    // Verificar se WiFi está pronto
    if (WiFi.getMode() == WIFI_MODE_NULL) {
        LOG_ERROR_CTX("WebServer", "WiFi não inicializado - não pode iniciar servidor web");
        return false;
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
    
    // Configurar rotas ANTES do CORS (importante!)
    setupRoutes();
    setupCORS();
    
    // Iniciar servidor
    server->begin();
    running = true;
    
    LOG_INFO_CTX("WebServer", "Servidor web iniciado com sucesso");
    
    // Mostrar IP correto baseado no modo WiFi
    if (WiFi.getMode() == WIFI_AP || WiFi.getMode() == WIFI_AP_STA) {
        LOG_INFO_CTX("WebServer", "Acesse via AP: http://%s", WiFi.softAPIP().toString().c_str());
    }
    if ((WiFi.getMode() == WIFI_STA || WiFi.getMode() == WIFI_AP_STA) && WiFi.status() == WL_CONNECTED) {
        LOG_INFO_CTX("WebServer", "Acesse via WiFi: http://%s", WiFi.localIP().toString().c_str());
    }
    
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
    
    // Rota de teste super simples
    server->on("/test", HTTP_GET, [](AsyncWebServerRequest *request) {
        LOG_INFO_CTX("WebServer", "Requisição GET /test recebida");
        request->send(200, "text/plain", "ESP32 Relay OK");
    });
    
    // Rota principal - página de configuração
    server->on("/", HTTP_GET, [this](AsyncWebServerRequest *request) {
        LOG_INFO_CTX("WebServer", "Requisição GET / recebida");
        handleRoot(request);
    });
    
    // API de configuração
    server->on("/api/config", HTTP_GET, [this](AsyncWebServerRequest *request) {
        handleConfig(request);
    });
    
    // Endpoint de teste simples
    server->on("/api/test-post", HTTP_POST, [this](AsyncWebServerRequest *request) {
        LOG_INFO_CTX("WebServer", "Test POST recebido!");
        request->send(200, "application/json", "{\"success\":true,\"message\":\"POST funcionando\"}");
    });
    
    // Handler com body para JSON
    server->on("/api/config", HTTP_POST, 
        [this](AsyncWebServerRequest *request) {
            // Chamado quando a requisição termina
            // Resposta será enviada pelo handler do body
        },
        nullptr,  // upload handler
        [this](AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
            // Body handler
            handleConfigPostWithBody(request, data, len, index, total);
        }
    );
    
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
        html += "<meta charset='UTF-8'>";
        html += "<title>AutoCore ESP32 Relay - Configuracao</title>";
        html += "<meta name='viewport' content='width=device-width, initial-scale=1'>";
        html += "<style>body{font-family:Arial;margin:20px;background:#f5f5f5}";
        html += ".container{max-width:500px;margin:0 auto;background:white;padding:20px;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.1)}";
        html += "h1{color:#333;text-align:center;margin-bottom:20px;font-size:24px}";
        html += ".form-group{margin-bottom:15px}";
        html += "label{display:block;margin-bottom:5px;font-weight:bold;color:#555}";
        html += "input,select{width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;box-sizing:border-box}";
        html += "button{background:#007bff;color:white;padding:10px 20px;border:none;border-radius:4px;cursor:pointer;width:100%;font-size:16px;margin-top:10px}";
        html += "button:hover{background:#0056b3}";
        html += ".status{padding:10px;margin:10px 0;border-radius:4px}";
        html += ".info{background:#d1ecf1;color:#0c5460;border:1px solid #bee5eb}";
        html += ".success{background:#d4edda;color:#155724;border:1px solid #c3e6cb}";
        html += ".error{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}";
        html += ".scan-btn{background:#28a745;margin-bottom:10px}";
        html += ".scan-btn:hover{background:#218838}";
        html += "</style></head><body>";
        html += "<div class='container'>";
        html += "<h1>AutoCore ESP32 Relay</h1>";
        html += "<div class='status info'>UUID: " + configManager.getDeviceUUID() + "</div>";
        
        // Formulário de configuração SIMPLIFICADO
        html += "<form id='configForm'>";
        html += "<h3>Configuracao WiFi</h3>";
        
        html += "<div class='form-group'>";
        html += "<button type='button' class='scan-btn' onclick='scanWifi()'>Buscar Redes WiFi</button>";
        html += "<label>Rede WiFi (SSID):</label>";
        html += "<select name='wifi_ssid' id='wifiSelect'>";
        html += "<option value=''>Selecione ou digite...</option>";
        html += "</select>";
        html += "<input type='text' name='wifi_ssid_manual' placeholder='Ou digite o SSID manualmente' style='margin-top:5px'>";
        html += "</div>";
        
        html += "<div class='form-group'>";
        html += "<label>Senha WiFi:</label>";
        html += "<input type='password' name='wifi_password' placeholder='Deixe em branco para rede aberta'>";
        html += "</div>";
        
        html += "<h3>Configuracao Backend AutoCore</h3>";
        html += "<div class='form-group'>";
        html += "<label>IP do Backend:</label>";
        html += "<input type='text' name='backend_ip' placeholder='Ex: 192.168.1.100' required>";
        html += "</div>";
        
        html += "<div class='form-group'>";
        html += "<label>Porta do Backend:</label>";
        html += "<input type='number' name='backend_port' value='8081' required>";
        html += "</div>";
        
        html += "<div class='status info' style='margin-top:20px'>";
        html += "<strong>Nota:</strong> As configuracoes MQTT serao obtidas automaticamente do backend apos a conexao.";
        html += "</div>";
        
        html += "<button type='submit'>Salvar e Conectar</button>";
        html += "</form>";
        
        html += "<div id='message'></div>";
        
        // JavaScript para interação
        html += "<script>";
        html += "function scanWifi(){";
        html += "  document.getElementById('message').innerHTML='<div class=\"status info\">Buscando redes...</div>';";
        html += "  fetch('/api/wifi/scan').then(r=>r.json()).then(data=>{";
        html += "    var select=document.getElementById('wifiSelect');";
        html += "    select.innerHTML='<option value=\"\">Selecione...</option>';";
        html += "    data.networks.forEach(net=>{";
        html += "      select.innerHTML+='<option value=\"'+net.ssid+'\">'+net.ssid+' ('+net.rssi+'dBm)</option>';";
        html += "    });";
        html += "    document.getElementById('message').innerHTML='<div class=\"status success\">'+data.networks.length+' redes encontradas</div>';";
        html += "  }).catch(e=>{";
        html += "    document.getElementById('message').innerHTML='<div class=\"status error\">Erro ao buscar redes</div>';";
        html += "  });";
        html += "}";
        
        html += "document.getElementById('configForm').onsubmit=function(e){";
        html += "  e.preventDefault();";
        html += "  var formData=new FormData(e.target);";
        html += "  var data={};";
        html += "  formData.forEach((v,k)=>data[k]=v);";
        html += "  if(data.wifi_ssid_manual)data.wifi_ssid=data.wifi_ssid_manual;";
        html += "  delete data.wifi_ssid_manual;";
        html += "  data.device_name='ESP32_Relay_" + configManager.getDeviceUUID().substring(12) + "';";  // Nome automático
        html += "  console.log('Enviando dados:', data);";
        html += "  document.getElementById('message').innerHTML='<div class=\"status info\">Salvando configuracao...</div>';";
        html += "  const controller = new AbortController();";
        html += "  const timeoutId = setTimeout(() => controller.abort(), 10000);";  // Timeout de 10 segundos
        html += "  fetch('/api/config',{";
        html += "    method:'POST',";
        html += "    headers:{'Content-Type':'application/json'},";
        html += "    body:JSON.stringify({config:data}),";
        html += "    signal: controller.signal";
        html += "  })";
        html += "  .then(r=>{";
        html += "    clearTimeout(timeoutId);";
        html += "    console.log('Resposta recebida:', r.status);";
        html += "    if(!r.ok) throw new Error('Status: '+r.status);";
        html += "    return r.json();";
        html += "  })";
        html += "  .then(resp=>{";
        html += "    console.log('JSON parseado:', resp);";
        html += "    if(resp.success){";
        html += "      document.getElementById('message').innerHTML='<div class=\"status success\">Configuracao salva! O dispositivo ira reiniciar em 3 segundos...</div>';";
        html += "      setTimeout(()=>window.location.reload(),3000);";
        html += "    }else{";
        html += "      document.getElementById('message').innerHTML='<div class=\"status error\">Erro: '+(resp.error||'Desconhecido')+'</div>';";
        html += "    }";
        html += "  }).catch(e=>{";
        html += "    console.error('Erro:', e);";
        html += "    if(e.name === 'AbortError'){";
        html += "      document.getElementById('message').innerHTML='<div class=\"status error\">Timeout - servidor nao respondeu</div>';";
        html += "    }else{";
        html += "      document.getElementById('message').innerHTML='<div class=\"status error\">Erro: '+e.message+'</div>';";
        html += "    }";
        html += "  });";
        html += "  return false;";
        html += "};";
        html += "</script>";
        
        html += "</div></body></html>";
        
        request->send(200, "text/html; charset=UTF-8", html);
    }
}

void AutoCoreWebServer::handleConfig(AsyncWebServerRequest *request) {
    logRequest(request);
    
    String config = configManager.getConfigJSON();
    request->send(200, "application/json", config);
}

void AutoCoreWebServer::handleConfigPost(AsyncWebServerRequest *request) {
    logRequest(request);
    
    // Para requisições JSON, precisamos de um handler diferente
    // Esta função será chamada sem o body
    LOG_ERROR_CTX("WebServer", "handleConfigPost chamado sem body - use handler com body");
    request->send(400, "application/json", "{\"success\":false,\"error\":\"Método incorreto\"}");
}

void AutoCoreWebServer::handleConfigPostWithBody(AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
    // Log imediato para debug
    if(index == 0) {
        LOG_INFO_CTX("WebServer", "=== INICIO POST /api/config ===");
        logRequest(request);
    }
    
    LOG_INFO_CTX("WebServer", "Recebendo body - index: %d, len: %d, total: %d", index, len, total);
    
    // Acumular o body completo
    static String bodyContent = "";
    
    if (index == 0) {
        bodyContent = ""; // Reset no início
    }
    
    // Adicionar chunk atual
    for (size_t i = 0; i < len; i++) {
        bodyContent += (char)data[i];
    }
    
    // Se recebemos tudo, processar
    if (index + len == total) {
        LOG_INFO_CTX("WebServer", "Body completo recebido: %s", bodyContent.c_str());
        
        // Parser do JSON
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, bodyContent);
        
        if (error) {
            LOG_ERROR_CTX("WebServer", "Erro ao parsear JSON: %s", error.c_str());
            request->send(400, "application/json", "{\"success\":false,\"error\":\"JSON inválido\"}");
            return;
        }
        
        // Verificar se tem o campo config
        if (!doc.containsKey("config")) {
            LOG_ERROR_CTX("WebServer", "Campo 'config' não encontrado no JSON");
            request->send(400, "application/json", "{\"success\":false,\"error\":\"Parâmetro 'config' obrigatório\"}");
            return;
        }
        
        JsonObject configObj = doc["config"];
        LOG_INFO_CTX("WebServer", "Processando configuração...");
        
        bool success = true;
        String errorMsg = "";
        
        // Configurar WiFi
        if (configObj["wifi_ssid"].is<String>() && configObj["wifi_password"].is<String>()) {
            String ssid = configObj["wifi_ssid"];
            String password = configObj["wifi_password"];
            LOG_INFO_CTX("WebServer", "Configurando WiFi: %s", ssid.c_str());
            
            if (ssid.length() > 0) {
                success &= configManager.setWiFiCredentials(ssid, password);
            }
        }
        
        // Configurar Backend
        if (configObj["backend_ip"].is<String>() && configObj["backend_port"]) {
            String ip = configObj["backend_ip"];
            int port = configObj["backend_port"].as<int>();
            LOG_INFO_CTX("WebServer", "Configurando Backend: %s:%d", ip.c_str(), port);
            
            if (ip.length() > 0 && port > 0) {
                success &= configManager.setBackendInfo(ip, port);
            }
        }
        
        // Configurar MQTT (opcional)
        if (configObj["mqtt_broker"].is<String>() && configObj["mqtt_port"]) {
            String broker = configObj["mqtt_broker"];
            int port = configObj["mqtt_port"].as<int>();
            String user = configObj["mqtt_user"] | "";
            String pass = configObj["mqtt_password"] | "";
            LOG_INFO_CTX("WebServer", "Configurando MQTT: %s:%d", broker.c_str(), port);
            
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
    // Mudar para INFO para aparecer sempre nos logs
    LOG_INFO_CTX("WebServer", "REQ: %s %s - IP: %s", 
                  request->methodToString(), 
                  request->url().c_str(),
                  request->client()->remoteIP().toString().c_str());
    
    // Logs adicionais para POST
    if(request->method() == HTTP_POST) {
        if(request->hasHeader("Content-Type")) {
            LOG_INFO_CTX("WebServer", "Content-Type: %s", request->getHeader("Content-Type")->value().c_str());
        }
        if(request->hasHeader("Content-Length")) {
            LOG_INFO_CTX("WebServer", "Content-Length: %s", request->getHeader("Content-Length")->value().c_str());
        }
    }
}