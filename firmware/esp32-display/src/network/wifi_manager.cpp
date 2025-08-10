/**
 * AutoCore ESP32 Display - WiFi Manager Implementation
 */

#include "wifi_manager.h"

// Instância global
WiFiManager wifiManager;

WiFiManager::WiFiManager() 
    : currentState(WIFI_DISCONNECTED), 
      stateChangeTime(0),
      lastConnectionAttempt(0),
      lastReconnectAttempt(0),
      connectionAttempts(0),
      dnsServer(nullptr),
      apModeActive(false),
      apIP(192, 168, 4, 1) {
}

WiFiManager::~WiFiManager() {
    if (dnsServer) {
        delete dnsServer;
    }
}

bool WiFiManager::begin() {
    LOG_INFO_CTX("WiFiManager", "Inicializando gerenciador WiFi...");
    
    // Configurar modo WiFi
    WiFi.mode(WIFI_STA);
    WiFi.setAutoConnect(false);
    WiFi.setAutoReconnect(false);
    
    // Definir callbacks WiFi
    WiFi.onEvent([this](WiFiEvent_t event, WiFiEventInfo_t info) {
        switch (event) {
            case SYSTEM_EVENT_STA_CONNECTED:
                LOG_INFO_CTX("WiFiManager", "Conectado à rede WiFi");
                break;
                
            case SYSTEM_EVENT_STA_GOT_IP:
                LOG_INFO_CTX("WiFiManager", "IP obtido: %s", WiFi.localIP().toString().c_str());
                changeState(WIFI_CONNECTED);
                if (connectedCallback) {
                    connectedCallback(WiFi.localIP());
                }
                break;
                
            case SYSTEM_EVENT_STA_DISCONNECTED:
                LOG_WARN_CTX("WiFiManager", "Desconectado da rede WiFi");
                if (currentState == WIFI_CONNECTED) {
                    changeState(WIFI_RECONNECTING);
                    if (disconnectedCallback) {
                        disconnectedCallback();
                    }
                }
                break;
                
            default:
                break;
        }
    });
    
    changeState(WIFI_DISCONNECTED);
    
    LOG_INFO_CTX("WiFiManager", "Gerenciador WiFi inicializado");
    return true;
}

void WiFiManager::changeState(WiFiState newState) {
    if (currentState != newState) {
        if (debugEnabled) {
            LOG_DEBUG_CTX("WiFiManager", "Estado: %s -> %s", 
                         getStateString().c_str(), 
                         getStateString(newState).c_str());
        }
        
        currentState = newState;
        stateChangeTime = millis();
        
        if (stateChangeCallback) {
            stateChangeCallback(newState);
        }
    }
}

String WiFiManager::getStateString() const {
    return getStateString(currentState);
}

String WiFiManager::getStateString(WiFiState state) const {
    switch (state) {
        case WIFI_DISCONNECTED: return "DESCONECTADO";
        case WIFI_CONNECTING: return "CONECTANDO";
        case WIFI_CONNECTED: return "CONECTADO";
        case WIFI_AP_MODE: return "MODO_AP";
        case WIFI_ERROR: return "ERRO";
        case WIFI_RECONNECTING: return "RECONECTANDO";
        default: return "DESCONHECIDO";
    }
}

bool WiFiManager::connect(const String& ssid, const String& password) {
    if (ssid.length() == 0) {
        LOG_ERROR_CTX("WiFiManager", "SSID não pode estar vazio");
        return false;
    }
    
    LOG_INFO_CTX("WiFiManager", "Conectando à rede: %s", ssid.c_str());
    
    // Parar modo AP se ativo
    if (apModeActive) {
        disableAPMode();
    }
    
    // Configurar modo estação
    WiFi.mode(WIFI_STA);
    
    // Iniciar conexão
    changeState(WIFI_CONNECTING);
    connectionAttempts = 0;
    lastConnectionAttempt = millis();
    
    if (password.length() > 0) {
        WiFi.begin(ssid.c_str(), password.c_str());
    } else {
        WiFi.begin(ssid.c_str());
    }
    
    return true;
}

bool WiFiManager::disconnect() {
    LOG_INFO_CTX("WiFiManager", "Desconectando WiFi");
    
    WiFi.disconnect(true);
    changeState(WIFI_DISCONNECTED);
    
    return true;
}

bool WiFiManager::reconnect() {
    LOG_INFO_CTX("WiFiManager", "Tentando reconectar...");
    
    changeState(WIFI_RECONNECTING);
    lastReconnectAttempt = millis();
    WiFi.reconnect();
    
    return true;
}

bool WiFiManager::enableAPMode() {
    LOG_INFO_CTX("WiFiManager", "Habilitando modo Access Point");
    
    // Gerar nome do AP
    apSSID = generateAPName();
    apPassword = AP_PASSWORD;
    
    // Configurar modo AP
    WiFi.mode(WIFI_AP);
    
    if (!WiFi.softAP(apSSID.c_str(), apPassword.c_str())) {
        LOG_ERROR_CTX("WiFiManager", "Falha ao criar Access Point");
        changeState(WIFI_ERROR);
        return false;
    }
    
    // Configurar IP do AP
    WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));
    
    // Iniciar servidor DNS (para captive portal)
    if (!dnsServer) {
        dnsServer = new DNSServer();
    }
    
    dnsServer->start(53, "*", apIP);
    apModeActive = true;
    
    changeState(WIFI_AP_MODE);
    
    LOG_INFO_CTX("WiFiManager", "Access Point ativo: %s", apSSID.c_str());
    LOG_INFO_CTX("WiFiManager", "IP: %s", apIP.toString().c_str());
    LOG_INFO_CTX("WiFiManager", "Senha: %s", apPassword.c_str());
    
    return true;
}

bool WiFiManager::disableAPMode() {
    if (!apModeActive) {
        return true;
    }
    
    LOG_INFO_CTX("WiFiManager", "Desabilitando modo Access Point");
    
    // Parar servidor DNS
    if (dnsServer) {
        dnsServer->stop();
        delete dnsServer;
        dnsServer = nullptr;
    }
    
    // Desabilitar AP
    WiFi.softAPdisconnect(true);
    apModeActive = false;
    
    // Voltar para modo estação
    WiFi.mode(WIFI_STA);
    
    LOG_INFO_CTX("WiFiManager", "Access Point desabilitado");
    return true;
}

String WiFiManager::generateAPName() {
    String mac = WiFi.macAddress();
    mac.replace(":", "");
    String suffix = mac.substring(mac.length() - 4);
    return String(AP_SSID_PREFIX) + suffix;
}

void WiFiManager::update() {
    unsigned long now = millis();
    
    // Processar DNS do AP
    if (apModeActive && dnsServer) {
        dnsServer->processNextRequest();
    }
    
    // Máquina de estados
    switch (currentState) {
        case WIFI_CONNECTING:
            // Verificar se conectou
            if (WiFi.status() == WL_CONNECTED) {
                // Estado será mudado pelo callback de evento
                connectionAttempts = 0;
            }
            // Verificar timeout de conexão
            else if (now - lastConnectionAttempt > CONNECTION_TIMEOUT) {
                connectionAttempts++;
                
                if (connectionAttempts >= MAX_CONNECTION_ATTEMPTS) {
                    LOG_ERROR_CTX("WiFiManager", "Máximo de tentativas atingido");
                    changeState(WIFI_ERROR);
                } else {
                    LOG_WARN_CTX("WiFiManager", "Timeout de conexão - tentativa %d/%d", 
                                connectionAttempts, MAX_CONNECTION_ATTEMPTS);
                    lastConnectionAttempt = now;
                    WiFi.reconnect();
                }
            }
            break;
            
        case WIFI_RECONNECTING:
            // Verificar se reconectou
            if (WiFi.status() == WL_CONNECTED) {
                // Estado será mudado pelo callback de evento
            }
            // Tentar reconectar periodicamente
            else if (now - lastReconnectAttempt > RECONNECT_INTERVAL) {
                LOG_INFO_CTX("WiFiManager", "Tentando reconectar...");
                lastReconnectAttempt = now;
                WiFi.reconnect();
            }
            break;
            
        case WIFI_CONNECTED:
            // Verificar se ainda está conectado
            if (WiFi.status() != WL_CONNECTED) {
                LOG_WARN_CTX("WiFiManager", "Conexão perdida");
                changeState(WIFI_RECONNECTING);
            }
            break;
            
        case WIFI_ERROR:
            // Em caso de erro, aguardar um tempo e tentar habilitar AP
            if (now - stateChangeTime > 30000) {  // 30 segundos
                LOG_WARN_CTX("WiFiManager", "Tentando habilitar modo AP após erro");
                enableAPMode();
            }
            break;
            
        default:
            break;
    }
}

void WiFiManager::handleReconnection() {
    if (currentState == WIFI_DISCONNECTED || currentState == WIFI_ERROR) {
        if (millis() - lastReconnectAttempt > RECONNECT_INTERVAL) {
            reconnect();
        }
    }
}

String WiFiManager::getSSID() const {
    if (isConnected()) {
        return WiFi.SSID();
    }
    return "";
}

IPAddress WiFiManager::getLocalIP() const {
    if (isConnected()) {
        return WiFi.localIP();
    }
    return IPAddress(0, 0, 0, 0);
}

int WiFiManager::getSignalStrength() const {
    if (isConnected()) {
        return WiFi.RSSI();
    }
    return -100;  // Sinal muito fraco
}

String WiFiManager::getSignalQuality() const {
    return signalStrengthToQuality(getSignalStrength());
}

String WiFiManager::getMacAddress() const {
    return WiFi.macAddress();
}

int WiFiManager::scanNetworks() {
    LOG_INFO_CTX("WiFiManager", "Escaneando redes WiFi...");
    
    WiFi.scanDelete();  // Limpar scan anterior
    int networks = WiFi.scanNetworks(false, true);  // Async = false, show_hidden = true
    
    LOG_INFO_CTX("WiFiManager", "Encontradas %d redes", networks);
    return networks;
}

String WiFiManager::getScannedSSID(int index) {
    return WiFi.SSID(index);
}

int WiFiManager::getScannedRSSI(int index) {
    return WiFi.RSSI(index);
}

String WiFiManager::getScannedSecurity(int index) {
    return encryptionTypeToString(WiFi.encryptionType(index));
}

void WiFiManager::printStatus() const {
    LOG_INFO("=== STATUS WiFi ===");
    LOG_INFO("Estado: %s", getStateString().c_str());
    LOG_INFO("MAC: %s", getMacAddress().c_str());
    
    if (isConnected()) {
        LOG_INFO("SSID: %s", getSSID().c_str());
        LOG_INFO("IP: %s", getLocalIP().toString().c_str());
        LOG_INFO("Gateway: %s", WiFi.gatewayIP().toString().c_str());
        LOG_INFO("DNS: %s", WiFi.dnsIP().toString().c_str());
        LOG_INFO("Sinal: %d dBm (%s)", getSignalStrength(), getSignalQuality().c_str());
    }
    
    if (isAPMode()) {
        LOG_INFO("AP SSID: %s", apSSID.c_str());
        LOG_INFO("AP IP: %s", apIP.toString().c_str());
        LOG_INFO("Clientes: %d", WiFi.softAPgetStationNum());
    }
    
    LOG_INFO("==================");
}

void WiFiManager::printNetworkInfo() const {
    LOG_INFO("=== INFORMAÇÕES DE REDE ===");
    LOG_INFO("Hostname: %s", WiFi.getHostname());
    LOG_INFO("Sleep Mode: %d", WiFi.getSleep());
    LOG_INFO("TX Power: %.1f dBm", WiFi.getTxPower() * 0.25);
    LOG_INFO("============================");
}

String WiFiManager::getStatusJSON() const {
    DynamicJsonDocument doc(512);
    
    doc["state"] = getStateString();
    doc["connected"] = isConnected();
    doc["ap_mode"] = isAPMode();
    doc["mac"] = getMacAddress();
    
    if (isConnected()) {
        doc["ssid"] = getSSID();
        doc["ip"] = getLocalIP().toString();
        doc["gateway"] = WiFi.gatewayIP().toString();
        doc["rssi"] = getSignalStrength();
        doc["quality"] = getSignalQuality();
    }
    
    if (isAPMode()) {
        doc["ap_ssid"] = apSSID;
        doc["ap_ip"] = apIP.toString();
        doc["ap_clients"] = WiFi.softAPgetStationNum();
    }
    
    String result;
    serializeJson(doc, result);
    return result;
}

String WiFiManager::signalStrengthToQuality(int rssi) {
    if (rssi >= -50) return "Excelente";
    if (rssi >= -60) return "Boa";
    if (rssi >= -70) return "Regular";
    if (rssi >= -80) return "Fraca";
    return "Muito Fraca";
}

String WiFiManager::encryptionTypeToString(wifi_auth_mode_t type) {
    switch (type) {
        case WIFI_AUTH_OPEN: return "Aberta";
        case WIFI_AUTH_WEP: return "WEP";
        case WIFI_AUTH_WPA_PSK: return "WPA";
        case WIFI_AUTH_WPA2_PSK: return "WPA2";
        case WIFI_AUTH_WPA_WPA2_PSK: return "WPA/WPA2";
        case WIFI_AUTH_WPA2_ENTERPRISE: return "WPA2 Enterprise";
        case WIFI_AUTH_WPA3_PSK: return "WPA3";
        case WIFI_AUTH_WPA2_WPA3_PSK: return "WPA2/WPA3";
        default: return "Desconhecida";
    }
}