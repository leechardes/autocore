/**
 * AutoCore ESP32 Display - MQTT Client Implementation
 */

#include "mqtt_client.h"

// Instância global
MQTTClient mqttClient;

// Instância estática para callback
MQTTClient* MQTTClient::instance = nullptr;

MQTTClient::MQTTClient() 
    : client(wifiClient),
      currentState(MQTT_DISCONNECTED),
      port(1883),
      lastConnectionAttempt(0),
      lastKeepAlive(0),
      reconnectAttempts(0),
      autoReconnect(true),
      initialized(false) {
    
    // Definir instância estática para callback
    instance = this;
    
    // Configurar callback de mensagem
    client.setCallback(staticMessageCallback);
}

MQTTClient::~MQTTClient() {
    if (initialized) {
        disconnect();
    }
}

bool MQTTClient::begin(const String& uuid, const String& brokerHost, int brokerPort,
                       const String& user, const String& pass) {
    LOG_INFO_CTX("MQTTClient", "Inicializando cliente MQTT");
    LOG_INFO_CTX("MQTTClient", "Broker: %s:%d", brokerHost.c_str(), brokerPort);
    LOG_INFO_CTX("MQTTClient", "Device UUID: %s", uuid.c_str());
    
    deviceUUID = uuid;
    broker = brokerHost;
    port = brokerPort;
    username = user;
    password = pass;
    
    // Gerar client ID único
    clientId = generateClientId(deviceUUID);
    
    // Configurar servidor
    client.setServer(broker.c_str(), port);
    client.setKeepAlive(KEEPALIVE_INTERVAL / 1000);
    client.setBufferSize(MQTT_BUFFER_SIZE);
    
    // Construir tópicos
    buildTopics();
    
    initialized = true;
    currentState = MQTT_DISCONNECTED;
    
    LOG_INFO_CTX("MQTTClient", "Cliente MQTT inicializado - ID: %s", clientId.c_str());
    return true;
}

void MQTTClient::buildTopics() {
    topicPrefix = String(MQTT_DEVICE_TOPIC_PREFIX) + "/" + deviceUUID;
    topicConfig = topicPrefix + "/config";
    topicEvents = topicPrefix + "/events";
    topicHeartbeat = topicPrefix + "/heartbeat";
    topicTelemetry = topicPrefix + "/telemetry";
    topicCommands = topicPrefix + "/commands";
    topicStatus = topicPrefix + "/status";
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("MQTTClient", "Tópicos construídos com prefixo: %s", topicPrefix.c_str());
    }
}

void MQTTClient::changeState(MQTTState newState) {
    if (currentState != newState) {
        if (debugEnabled) {
            LOG_DEBUG_CTX("MQTTClient", "Estado: %s -> %s", 
                         getStateString().c_str(), 
                         getStateString(newState).c_str());
        }
        
        currentState = newState;
        
        // Notificar callback de conexão
        if (connectionCallback) {
            connectionCallback(newState == MQTT_CONNECTED);
        }
    }
}

String MQTTClient::getStateString() const {
    return getStateString(currentState);
}

String MQTTClient::getStateString(MQTTState state) const {
    switch (state) {
        case MQTT_DISCONNECTED: return "DESCONECTADO";
        case MQTT_CONNECTING: return "CONECTANDO";
        case MQTT_CONNECTED: return "CONECTADO";
        case MQTT_ERROR: return "ERRO";
        case MQTT_RECONNECTING: return "RECONECTANDO";
        default: return "DESCONHECIDO";
    }
}

bool MQTTClient::connect() {
    if (!initialized) {
        LOG_ERROR_CTX("MQTTClient", "Cliente não inicializado");
        return false;
    }
    
    if (!WiFi.isConnected()) {
        LOG_ERROR_CTX("MQTTClient", "WiFi não conectado");
        changeState(MQTT_ERROR);
        return false;
    }
    
    if (isConnected()) {
        LOG_DEBUG_CTX("MQTTClient", "Já conectado");
        return true;
    }
    
    LOG_INFO_CTX("MQTTClient", "Conectando ao broker MQTT...");
    changeState(MQTT_CONNECTING);
    lastConnectionAttempt = millis();
    
    bool connected = false;
    
    // Tentar conectar com ou sem credenciais
    if (username.length() > 0 && password.length() > 0) {
        connected = client.connect(clientId.c_str(), username.c_str(), password.c_str());
    } else {
        connected = client.connect(clientId.c_str());
    }
    
    if (connected) {
        LOG_INFO_CTX("MQTTClient", "Conectado ao broker MQTT");
        changeState(MQTT_CONNECTED);
        reconnectAttempts = 0;
        
        // Subscrever aos tópicos do dispositivo
        subscribeToDeviceTopics();
        
        // Publicar anúncio do dispositivo
        publishDeviceAnnounce();
        
        return true;
    } else {
        int error = client.state();
        LOG_ERROR_CTX("MQTTClient", "Falha na conexão MQTT: %d", error);
        changeState(MQTT_ERROR);
        reconnectAttempts++;
        
        return false;
    }
}

bool MQTTClient::disconnect() {
    if (isConnected()) {
        LOG_INFO_CTX("MQTTClient", "Desconectando do broker MQTT");
        client.disconnect();
    }
    
    changeState(MQTT_DISCONNECTED);
    return true;
}

bool MQTTClient::reconnect() {
    LOG_INFO_CTX("MQTTClient", "Tentando reconectar (tentativa %d/%d)", 
                reconnectAttempts + 1, MAX_RECONNECT_ATTEMPTS);
    
    changeState(MQTT_RECONNECTING);
    return connect();
}

void MQTTClient::loop() {
    if (!initialized) {
        return;
    }
    
    unsigned long now = millis();
    
    // Processar mensagens se conectado
    if (isConnected()) {
        if (!client.loop()) {
            LOG_WARN_CTX("MQTTClient", "Conexão MQTT perdida");
            changeState(MQTT_DISCONNECTED);
        }
        
        // Enviar keep alive periodicamente
        if (now - lastKeepAlive > KEEPALIVE_INTERVAL) {
            publishHeartbeat();
            lastKeepAlive = now;
        }
    }
    
    // Auto-reconnect se habilitado
    if (autoReconnect && !isConnected() && WiFi.isConnected()) {
        if (now - lastConnectionAttempt > RECONNECT_INTERVAL) {
            if (reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
                reconnect();
            } else {
                LOG_ERROR_CTX("MQTTClient", "Máximo de tentativas de reconexão atingido");
                changeState(MQTT_ERROR);
                reconnectAttempts = 0;  // Reset após erro
            }
        }
    }
}

void MQTTClient::subscribeToDeviceTopics() {
    LOG_DEBUG_CTX("MQTTClient", "Subscrevendo aos tópicos do dispositivo");
    
    // Tópicos básicos do dispositivo
    subscribe(topicConfig);
    subscribe(topicCommands);
    
    // Tópicos globais do sistema
    subscribe("autocore/system/broadcast");
    subscribe("autocore/relays/+/state");  // Estados dos relés
    subscribe("autocore/can/data");        // Dados CAN
    
    LOG_INFO_CTX("MQTTClient", "Subscrito aos tópicos do dispositivo");
}

bool MQTTClient::subscribe(const String& topic, int qos) {
    if (!isConnected()) {
        LOG_WARN_CTX("MQTTClient", "Não conectado - não é possível subscrever: %s", topic.c_str());
        return false;
    }
    
    if (client.subscribe(topic.c_str(), qos)) {
        subscriptions.push_back(topic);
        if (debugEnabled) {
            LOG_DEBUG_CTX("MQTTClient", "Subscrito: %s (QoS %d)", topic.c_str(), qos);
        }
        return true;
    } else {
        LOG_ERROR_CTX("MQTTClient", "Falha ao subscrever: %s", topic.c_str());
        return false;
    }
}

bool MQTTClient::unsubscribe(const String& topic) {
    if (!isConnected()) {
        return false;
    }
    
    if (client.unsubscribe(topic.c_str())) {
        // Remover da lista de subscrições
        for (auto it = subscriptions.begin(); it != subscriptions.end(); ++it) {
            if (*it == topic) {
                subscriptions.erase(it);
                break;
            }
        }
        
        LOG_DEBUG_CTX("MQTTClient", "Dessubscrito: %s", topic.c_str());
        return true;
    }
    
    return false;
}

bool MQTTClient::publish(const String& topic, const String& payload, bool retained) {
    if (!isConnected()) {
        if (debugEnabled) {
            LOG_WARN_CTX("MQTTClient", "Não conectado - não é possível publicar");
        }
        return false;
    }
    
    bool success = client.publish(topic.c_str(), payload.c_str(), retained);
    
    if (success) {
        if (debugEnabled) {
            LOG_DEBUG_CTX("MQTTClient", "Publicado: %s (%d bytes)", topic.c_str(), payload.length());
        }
    } else {
        LOG_ERROR_CTX("MQTTClient", "Falha ao publicar: %s", topic.c_str());
    }
    
    return success;
}

bool MQTTClient::publishJSON(const String& topic, const JsonDocument& doc, bool retained) {
    String payload;
    serializeJson(doc, payload);
    return publish(topic, payload, retained);
}

bool MQTTClient::publishEvent(const String& event, const String& data) {
    DynamicJsonDocument doc(512);
    doc["event"] = event;
    doc["timestamp"] = millis();
    doc["device_uuid"] = deviceUUID;
    
    if (data.length() > 0) {
        doc["data"] = data;
    }
    
    return publishJSON(topicEvents, doc);
}

bool MQTTClient::publishHeartbeat() {
    DynamicJsonDocument doc(512);
    doc["device_uuid"] = deviceUUID;
    doc["timestamp"] = millis();
    doc["uptime"] = millis() / 1000;
    doc["state"] = "running";
    doc["free_memory"] = ESP.getFreeHeap();
    doc["wifi_signal"] = WiFi.RSSI();
    
    return publishJSON(topicHeartbeat, doc);
}

bool MQTTClient::publishTelemetry(const String& telemetryData) {
    return publish(topicTelemetry, telemetryData);
}

bool MQTTClient::publishStatus(const String& status) {
    DynamicJsonDocument doc(256);
    doc["device_uuid"] = deviceUUID;
    doc["timestamp"] = millis();
    doc["status"] = status;
    
    return publishJSON(topicStatus, doc);
}

bool MQTTClient::publishDeviceAnnounce() {
    DynamicJsonDocument doc(512);
    doc["device_uuid"] = deviceUUID;
    doc["device_type"] = DEVICE_TYPE;
    doc["device_name"] = "AutoCore Display";  // Buscar do config
    doc["firmware_version"] = FIRMWARE_VERSION;
    doc["timestamp"] = millis();
    doc["ip_address"] = WiFi.localIP().toString();
    doc["mac_address"] = WiFi.macAddress();
    
    String announceTopic = "autocore/system/device/announce";
    return publishJSON(announceTopic, doc);
}

// Eventos específicos do display
bool MQTTClient::sendButtonPress(const String& buttonId, const String& screenId) {
    DynamicJsonDocument doc(256);
    doc["type"] = "button_press";
    doc["button_id"] = buttonId;
    if (screenId.length() > 0) {
        doc["screen_id"] = screenId;
    }
    
    String data;
    serializeJson(doc, data);
    return publishEvent("button_interaction", data);
}

bool MQTTClient::sendButtonRelease(const String& buttonId, const String& screenId) {
    DynamicJsonDocument doc(256);
    doc["type"] = "button_release";
    doc["button_id"] = buttonId;
    if (screenId.length() > 0) {
        doc["screen_id"] = screenId;
    }
    
    String data;
    serializeJson(doc, data);
    return publishEvent("button_interaction", data);
}

bool MQTTClient::sendScreenChange(const String& fromScreen, const String& toScreen) {
    DynamicJsonDocument doc(256);
    doc["from_screen"] = fromScreen;
    doc["to_screen"] = toScreen;
    
    String data;
    serializeJson(doc, data);
    return publishEvent("screen_change", data);
}

bool MQTTClient::sendUserInteraction(const String& action, const String& data) {
    return publishEvent("user_interaction", action + ":" + data);
}

bool MQTTClient::sendSystemAlert(const String& level, const String& message) {
    DynamicJsonDocument doc(256);
    doc["level"] = level;
    doc["message"] = message;
    
    String data;
    serializeJson(doc, data);
    return publishEvent("system_alert", data);
}

void MQTTClient::handleMQTTMessage(char* topic, byte* payload, unsigned int length) {
    // Converter payload para string
    String message = "";
    for (unsigned int i = 0; i < length; i++) {
        message += (char)payload[i];
    }
    
    String topicStr = String(topic);
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("MQTTClient", "Mensagem recebida: %s (%d bytes)", 
                     topicStr.c_str(), length);
    }
    
    // Chamar callback personalizado se definido
    if (messageCallback) {
        messageCallback(topicStr, message);
    }
}

void MQTTClient::staticMessageCallback(char* topic, byte* payload, unsigned int length) {
    if (instance) {
        instance->handleMQTTMessage(topic, payload, length);
    }
}

String MQTTClient::generateClientId(const String& deviceUUID) {
    String clientId = "autocore-display-" + deviceUUID;
    clientId.replace("-", "");  // Remover hífens
    if (clientId.length() > 23) {  // Limite do MQTT
        clientId = clientId.substring(0, 23);
    }
    return clientId;
}

void MQTTClient::setCredentials(const String& user, const String& pass) {
    username = user;
    password = pass;
    LOG_DEBUG_CTX("MQTTClient", "Credenciais MQTT atualizadas");
}

void MQTTClient::setClientId(const String& id) {
    clientId = id;
    LOG_DEBUG_CTX("MQTTClient", "Client ID atualizado: %s", id.c_str());
}

void MQTTClient::enableAutoReconnect(bool enable) {
    autoReconnect = enable;
    LOG_DEBUG_CTX("MQTTClient", "Auto-reconnect %s", enable ? "habilitado" : "desabilitado");
}

String MQTTClient::getBrokerInfo() const {
    return broker + ":" + String(port);
}

String MQTTClient::getTopicsInfo() const {
    String info = "Tópicos:\n";
    info += "  Config: " + topicConfig + "\n";
    info += "  Events: " + topicEvents + "\n";
    info += "  Heartbeat: " + topicHeartbeat + "\n";
    info += "  Telemetry: " + topicTelemetry + "\n";
    info += "  Commands: " + topicCommands + "\n";
    info += "  Status: " + topicStatus + "\n";
    info += "Subscrições: " + String(subscriptions.size());
    return info;
}

void MQTTClient::printStatus() const {
    LOG_INFO("=== STATUS MQTT ===");
    LOG_INFO("Broker: %s", getBrokerInfo().c_str());
    LOG_INFO("Client ID: %s", clientId.c_str());
    LOG_INFO("Estado: %s", getStateString().c_str());
    LOG_INFO("Auto-reconnect: %s", autoReconnect ? "SIM" : "NÃO");
    LOG_INFO("Tentativas reconexão: %d/%d", reconnectAttempts, MAX_RECONNECT_ATTEMPTS);
    LOG_INFO("Subscrições: %d", subscriptions.size());
    LOG_INFO("==================");
}

void MQTTClient::printTopics() const {
    LOG_INFO("=== TÓPICOS MQTT ===");
    LOG_INFO("Prefixo: %s", topicPrefix.c_str());
    LOG_INFO("Config: %s", topicConfig.c_str());
    LOG_INFO("Events: %s", topicEvents.c_str());
    LOG_INFO("Heartbeat: %s", topicHeartbeat.c_str());
    LOG_INFO("Telemetry: %s", topicTelemetry.c_str());
    LOG_INFO("Commands: %s", topicCommands.c_str());
    LOG_INFO("Status: %s", topicStatus.c_str());
    LOG_INFO("===================");
}

String MQTTClient::getStatusJSON() const {
    DynamicJsonDocument doc(512);
    
    doc["broker"] = getBrokerInfo();
    doc["client_id"] = clientId;
    doc["state"] = getStateString();
    doc["connected"] = isConnected();
    doc["auto_reconnect"] = autoReconnect;
    doc["reconnect_attempts"] = reconnectAttempts;
    doc["subscriptions"] = subscriptions.size();
    doc["topic_prefix"] = topicPrefix;
    
    String status;
    serializeJson(doc, status);
    return status;
}