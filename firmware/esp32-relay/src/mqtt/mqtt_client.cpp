#include "mqtt_client.h"
#include "../utils/logger.h"

// Instância global
AutoCoreMQTTClient mqttClient;

AutoCoreMQTTClient::AutoCoreMQTTClient() : mqttClient(wifiClient) {
    // Configurações padrão do PubSubClient
    mqttClient.setCallback([this](char* topic, byte* payload, unsigned int length) {
        this->handleIncomingMessage(topic, payload, length);
    });
}

AutoCoreMQTTClient::~AutoCoreMQTTClient() {
    end();
}

bool AutoCoreMQTTClient::begin(const String& uuid, const String& broker, int port, 
                              const String& user, const String& password) {
    LOG_INFO_CTX("MQTT", "Inicializando cliente MQTT");
    LOG_INFO_CTX("MQTT", "Broker: %s:%d", broker.c_str(), port);
    LOG_INFO_CTX("MQTT", "UUID: %s", uuid.c_str());
    
    if (initialized) {
        LOG_WARN_CTX("MQTT", "Cliente já inicializado");
        return true;
    }
    
    // Validar parâmetros
    if (uuid.length() == 0 || broker.length() == 0 || port <= 0) {
        LOG_ERROR_CTX("MQTT", "Parâmetros inválidos");
        return false;
    }
    
    // Armazenar configurações
    deviceUUID = uuid;
    mqttBroker = broker;
    mqttPort = port;
    mqttUser = user;
    mqttPassword = password;
    
    // Configurar cliente MQTT
    mqttClient.setServer(broker.c_str(), port);
    mqttClient.setKeepAlive(MQTT_KEEPALIVE);
    mqttClient.setSocketTimeout(MQTT_TIMEOUT / 1000);
    
    // Configurar buffer size (importante para mensagens grandes)
    mqttClient.setBufferSize(2048);
    
    // Construir tópicos
    buildTopics();
    
    // Limpar fila de mensagens
    queueHead = queueTail = queueCount = 0;
    
    initialized = true;
    
    LOG_INFO_CTX("MQTT", "Cliente MQTT inicializado com sucesso");
    printTopics();
    
    return true;
}

void AutoCoreMQTTClient::end() {
    if (initialized) {
        disconnect();
        initialized = false;
        LOG_INFO_CTX("MQTT", "Cliente MQTT finalizado");
    }
}

void AutoCoreMQTTClient::buildTopics() {
    baseTopic = String(MQTT_DEVICE_TOPIC_PREFIX) + "/" + deviceUUID;
    statusTopic = baseTopic + "/status";
    commandTopic = baseTopic + "/command";
    heartbeatTopic = baseTopic + "/heartbeat";
    telemetryTopic = baseTopic + "/telemetry";
    configTopic = baseTopic + "/config";
    relayStateTopic = baseTopic + "/relays/state";
    relayCommandTopic = baseTopic + "/relays/command";
    
    LOG_DEBUG_CTX("MQTT", "Tópicos construídos com base: %s", baseTopic.c_str());
}

bool AutoCoreMQTTClient::connect() {
    if (!initialized) {
        LOG_ERROR_CTX("MQTT", "Cliente não inicializado");
        return false;
    }
    
    if (WiFi.status() != WL_CONNECTED) {
        LOG_ERROR_CTX("MQTT", "WiFi não conectado");
        return false;
    }
    
    if (mqttClient.connected()) {
        connected = true;
        return true;
    }
    
    LOG_INFO_CTX("MQTT", "Conectando ao broker MQTT...");
    
    String clientId = getClientId();
    bool result = false;
    
    // Preparar Last Will Testament (LWT)
    String lwt_topic = statusTopic;
    String lwt_message = "{\"status\":\"offline\",\"timestamp\":" + String(millis()) + "}";
    
    if (mqttUser.length() > 0 && mqttPassword.length() > 0) {
        // Conexão com autenticação
        result = mqttClient.connect(clientId.c_str(), 
                                  mqttUser.c_str(), 
                                  mqttPassword.c_str(),
                                  lwt_topic.c_str(), 
                                  1, 
                                  true, 
                                  lwt_message.c_str());
    } else {
        // Conexão sem autenticação
        result = mqttClient.connect(clientId.c_str(),
                                  lwt_topic.c_str(), 
                                  1, 
                                  true, 
                                  lwt_message.c_str());
    }
    
    if (result) {
        connected = true;
        LOG_INFO_CTX("MQTT", "Conectado ao broker MQTT com sucesso");
        
        // Subscrever aos tópicos necessários
        subscribeToTopics();
        
        // Publicar status online
        publishStatus("online");
        
        // Anunciar dispositivo
        publishDeviceAnnounce();
        
        // Publicar mensagens enfileiradas
        publishQueuedMessages();
        
        // Notificar callback de conexão
        if (connectionCallback) {
            connectionCallback(true);
        }
        
    } else {
        connected = false;
        int state = mqttClient.state();
        LOG_ERROR_CTX("MQTT", "Falha na conexão MQTT (state: %d)", state);
        
        // Interpretar códigos de erro
        switch (state) {
            case MQTT_CONNECTION_TIMEOUT:
                LOG_ERROR_CTX("MQTT", "Timeout de conexão");
                break;
            case MQTT_CONNECTION_LOST:
                LOG_ERROR_CTX("MQTT", "Conexão perdida");
                break;
            case MQTT_CONNECT_FAILED:
                LOG_ERROR_CTX("MQTT", "Falha na conexão");
                break;
            case MQTT_DISCONNECTED:
                LOG_ERROR_CTX("MQTT", "Desconectado");
                break;
            case MQTT_CONNECT_BAD_PROTOCOL:
                LOG_ERROR_CTX("MQTT", "Protocolo inválido");
                break;
            case MQTT_CONNECT_BAD_CLIENT_ID:
                LOG_ERROR_CTX("MQTT", "Client ID inválido");
                break;
            case MQTT_CONNECT_UNAVAILABLE:
                LOG_ERROR_CTX("MQTT", "Servidor indisponível");
                break;
            case MQTT_CONNECT_BAD_CREDENTIALS:
                LOG_ERROR_CTX("MQTT", "Credenciais inválidas");
                break;
            case MQTT_CONNECT_UNAUTHORIZED:
                LOG_ERROR_CTX("MQTT", "Não autorizado");
                break;
        }
    }
    
    return result;
}

void AutoCoreMQTTClient::disconnect() {
    if (connected) {
        LOG_INFO_CTX("MQTT", "Desconectando do broker MQTT");
        
        // Publicar status offline
        publishStatus("offline");
        
        mqttClient.disconnect();
        connected = false;
        
        // Notificar callback de conexão
        if (connectionCallback) {
            connectionCallback(false);
        }
    }
}

void AutoCoreMQTTClient::loop() {
    if (!initialized) return;
    
    // Processar mensagens MQTT
    mqttClient.loop();
    
    // Verificar reconexão automática
    if (autoReconnect && !isConnected()) {
        unsigned long now = millis();
        
        if (now - lastReconnectAttempt > reconnectInterval) {
            lastReconnectAttempt = now;
            
            LOG_INFO_CTX("MQTT", "Tentativa de reconexão...");
            if (connect()) {
                lastReconnectAttempt = 0; // Reset on successful connection
            }
        }
    }
    
    // Publicar status periodicamente
    if (isConnected()) {
        unsigned long now = millis();
        
        if (now - lastStatusPublish > statusPublishInterval) {
            lastStatusPublish = now;
            publishStatus("online");
        }
    }
}

void AutoCoreMQTTClient::subscribeToTopics() {
    LOG_INFO_CTX("MQTT", "Subscrevendo aos tópicos...");
    
    // Tópicos essenciais
    subscribe(relayCommandTopic, 1);      // Comandos de relé (QoS 1)
    subscribe(heartbeatTopic, 0);         // Heartbeats (QoS 0 - performance)
    subscribe(configTopic, 2);            // Configurações (QoS 2 - exatamente uma vez)
    subscribe(commandTopic, 1);           // Comandos gerais (QoS 1)
    
    // Broadcast topics (opcional)
    String broadcastTopic = String(MQTT_BASE_TOPIC) + "/broadcast";
    subscribe(broadcastTopic, 1);
    
    LOG_INFO_CTX("MQTT", "Subscrição aos tópicos concluída");
}

void AutoCoreMQTTClient::handleIncomingMessage(char* topic, byte* payload, unsigned int length) {
    // Converter payload para String
    String message;
    message.reserve(length + 1);
    for (unsigned int i = 0; i < length; i++) {
        message += (char)payload[i];
    }
    
    String topicStr = String(topic);
    
    LOG_DEBUG_CTX("MQTT", "Mensagem recebida - Tópico: %s", topicStr.c_str());
    LOG_DEBUG_CTX("MQTT", "Payload: %s", message.c_str());
    
    // Chamar callback se definido
    if (messageCallback) {
        messageCallback(topicStr, message);
    }
}

bool AutoCoreMQTTClient::publish(const String& topic, const String& payload, bool retain) {
    if (!isConnected()) {
        LOG_WARN_CTX("MQTT", "Não conectado, enfileirando mensagem: %s", topic.c_str());
        return enqueueMessage(topic, payload, retain);
    }
    
    bool result = mqttClient.publish(topic.c_str(), payload.c_str(), retain);
    
    if (result) {
        LOG_DEBUG_CTX("MQTT", "Mensagem publicada - Tópico: %s", topic.c_str());
    } else {
        LOG_ERROR_CTX("MQTT", "Falha ao publicar mensagem: %s", topic.c_str());
        // Enfileirar para tentar novamente
        enqueueMessage(topic, payload, retain);
    }
    
    return result;
}

bool AutoCoreMQTTClient::publishToDevice(const String& subtopic, const String& payload, bool retain) {
    String fullTopic = baseTopic + "/" + subtopic;
    return publish(fullTopic, payload, retain);
}

bool AutoCoreMQTTClient::publishStatus(const String& status) {
    DynamicJsonDocument doc(512);
    doc["status"] = status;
    doc["timestamp"] = millis();
    doc["uptime"] = millis() / 1000;
    doc["free_memory"] = ESP.getFreeHeap();
    doc["wifi_signal"] = WiFi.RSSI();
    doc["firmware_version"] = FIRMWARE_VERSION;
    
    String payload;
    serializeJson(doc, payload);
    
    return publish(statusTopic, payload, true); // Retain status messages
}

bool AutoCoreMQTTClient::publishTelemetry(const String& telemetryJson) {
    return publish(telemetryTopic, telemetryJson, false);
}

bool AutoCoreMQTTClient::publishRelayState(int channel, bool state) {
    DynamicJsonDocument doc(256);
    doc["channel"] = channel;
    doc["state"] = state;
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    return publish(relayStateTopic, payload, true); // Retain relay states
}

bool AutoCoreMQTTClient::publishHeartbeatAck(int channel, int sequence) {
    DynamicJsonDocument doc(128);
    doc["channel"] = channel;
    doc["sequence"] = sequence;
    doc["timestamp"] = millis();
    doc["ack"] = true;
    
    String payload;
    serializeJson(doc, payload);
    
    return publish(heartbeatTopic + "/ack", payload, false);
}

bool AutoCoreMQTTClient::publishSafetyEvent(const String& eventJson) {
    String safetyTopic = baseTopic + "/safety";
    return publish(safetyTopic, eventJson, false);
}

bool AutoCoreMQTTClient::publishDeviceAnnounce() {
    DynamicJsonDocument doc(512);
    doc["uuid"] = deviceUUID;
    doc["type"] = DEVICE_TYPE;
    doc["firmware_version"] = FIRMWARE_VERSION;
    doc["hardware_version"] = HARDWARE_VERSION;
    doc["ip_address"] = WiFi.localIP().toString();
    doc["mac_address"] = WiFi.macAddress();
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    String announceTopic = String(MQTT_BASE_TOPIC) + "/discovery/announce";
    return publish(announceTopic, payload, false);
}

bool AutoCoreMQTTClient::subscribe(const String& topic, int qos) {
    if (!isConnected()) {
        LOG_WARN_CTX("MQTT", "Não conectado, não é possível subscrever: %s", topic.c_str());
        return false;
    }
    
    bool result = mqttClient.subscribe(topic.c_str(), qos);
    
    if (result) {
        LOG_INFO_CTX("MQTT", "Subscrito ao tópico: %s (QoS %d)", topic.c_str(), qos);
    } else {
        LOG_ERROR_CTX("MQTT", "Falha ao subscrever: %s", topic.c_str());
    }
    
    return result;
}

bool AutoCoreMQTTClient::subscribeToDevice(const String& subtopic, int qos) {
    String fullTopic = baseTopic + "/" + subtopic;
    return subscribe(fullTopic, qos);
}

void AutoCoreMQTTClient::unsubscribe(const String& topic) {
    if (isConnected()) {
        mqttClient.unsubscribe(topic.c_str());
        LOG_INFO_CTX("MQTT", "Desinscrito do tópico: %s", topic.c_str());
    }
}

bool AutoCoreMQTTClient::enqueueMessage(const String& topic, const String& payload, bool retain) {
    if (queueCount >= MESSAGE_QUEUE_SIZE) {
        LOG_WARN_CTX("MQTT", "Fila de mensagens cheia, descartando mensagem mais antiga");
        // Remove oldest message
        queueHead = (queueHead + 1) % MESSAGE_QUEUE_SIZE;
        queueCount--;
    }
    
    // Add new message
    QueuedMessage& msg = messageQueue[queueTail];
    msg.topic = topic;
    msg.payload = payload;
    msg.retain = retain;
    msg.timestamp = millis();
    
    queueTail = (queueTail + 1) % MESSAGE_QUEUE_SIZE;
    queueCount++;
    
    LOG_DEBUG_CTX("MQTT", "Mensagem enfileirada (%d/%d): %s", queueCount, MESSAGE_QUEUE_SIZE, topic.c_str());
    return true;
}

void AutoCoreMQTTClient::publishQueuedMessages() {
    if (queueCount == 0) return;
    
    LOG_INFO_CTX("MQTT", "Publicando %d mensagens enfileiradas", queueCount);
    
    int published = 0;
    int failed = 0;
    
    while (queueCount > 0 && isConnected()) {
        QueuedMessage& msg = messageQueue[queueHead];
        
        // Check if message is too old (optional timeout)
        unsigned long age = millis() - msg.timestamp;
        if (age > 60000) { // 1 minute timeout
            LOG_WARN_CTX("MQTT", "Descartando mensagem antiga: %s", msg.topic.c_str());
            queueHead = (queueHead + 1) % MESSAGE_QUEUE_SIZE;
            queueCount--;
            failed++;
            continue;
        }
        
        if (mqttClient.publish(msg.topic.c_str(), msg.payload.c_str(), msg.retain)) {
            LOG_DEBUG_CTX("MQTT", "Mensagem da fila publicada: %s", msg.topic.c_str());
            queueHead = (queueHead + 1) % MESSAGE_QUEUE_SIZE;
            queueCount--;
            published++;
        } else {
            LOG_WARN_CTX("MQTT", "Falha ao publicar mensagem da fila: %s", msg.topic.c_str());
            break; // Stop trying if publish fails
        }
    }
    
    if (published > 0) {
        LOG_INFO_CTX("MQTT", "Publicadas %d mensagens da fila", published);
    }
    if (failed > 0) {
        LOG_WARN_CTX("MQTT", "Falharam %d mensagens da fila", failed);
    }
}

String AutoCoreMQTTClient::getClientId() {
    return String("autocore-") + deviceUUID;
}

void AutoCoreMQTTClient::onMessage(std::function<void(String topic, String payload)> callback) {
    messageCallback = callback;
}

void AutoCoreMQTTClient::onConnection(std::function<void(bool connected)> callback) {
    connectionCallback = callback;
}

String AutoCoreMQTTClient::getConnectionStatus() {
    DynamicJsonDocument doc(512);
    doc["initialized"] = initialized;
    doc["connected"] = isConnected();
    doc["mqtt_state"] = mqttClient.state();
    doc["broker"] = mqttBroker;
    doc["port"] = mqttPort;
    doc["device_uuid"] = deviceUUID;
    doc["queued_messages"] = queueCount;
    doc["last_reconnect_attempt"] = lastReconnectAttempt;
    
    String status;
    serializeJson(doc, status);
    return status;
}

void AutoCoreMQTTClient::printTopics() {
    LOG_INFO_CTX("MQTT", "=== TÓPICOS MQTT ===");
    LOG_INFO_CTX("MQTT", "Base: %s", baseTopic.c_str());
    LOG_INFO_CTX("MQTT", "Status: %s", statusTopic.c_str());
    LOG_INFO_CTX("MQTT", "Command: %s", commandTopic.c_str());
    LOG_INFO_CTX("MQTT", "Heartbeat: %s", heartbeatTopic.c_str());
    LOG_INFO_CTX("MQTT", "Telemetry: %s", telemetryTopic.c_str());
    LOG_INFO_CTX("MQTT", "Relay State: %s", relayStateTopic.c_str());
    LOG_INFO_CTX("MQTT", "Relay Command: %s", relayCommandTopic.c_str());
    LOG_INFO_CTX("MQTT", "Config: %s", configTopic.c_str());
    LOG_INFO_CTX("MQTT", "==================");
}

void AutoCoreMQTTClient::printQueueStatus() {
    LOG_DEBUG_CTX("MQTT", "Fila de mensagens: %d/%d", queueCount, MESSAGE_QUEUE_SIZE);
}

void AutoCoreMQTTClient::setKeepAlive(int seconds) {
    mqttClient.setKeepAlive(seconds);
}

void AutoCoreMQTTClient::setBufferSize(int size) {
    mqttClient.setBufferSize(size);
}

void AutoCoreMQTTClient::enableAutoReconnect(bool enable) {
    autoReconnect = enable;
    LOG_INFO_CTX("MQTT", "Auto-reconexão %s", enable ? "habilitada" : "desabilitada");
}

void AutoCoreMQTTClient::setReconnectInterval(unsigned long intervalMs) {
    reconnectInterval = intervalMs;
}

void AutoCoreMQTTClient::setStatusPublishInterval(unsigned long intervalMs) {
    statusPublishInterval = intervalMs;
}

void AutoCoreMQTTClient::setTelemetryPublishInterval(unsigned long intervalMs) {
    telemetryPublishInterval = intervalMs;
}