#include "mqtt_handler.h"
#include "../relay/relay_controller.h"
#include "../utils/logger.h"
#include "mqtt_client.h"

// Instância global
MQTTHandler mqttHandler;

MQTTHandler::MQTTHandler() : relayController(nullptr) {
    // Construtor
}

MQTTHandler::~MQTTHandler() {
    // Destructor
}

bool MQTTHandler::begin(RelayController* controller) {
    if (!controller) {
        LOG_ERROR_CTX("MQTTHandler", "Controlador de relés não fornecido");
        return false;
    }
    
    relayController = controller;
    
    LOG_INFO_CTX("MQTTHandler", "Handler MQTT inicializado");
    return true;
}

void MQTTHandler::handleMessage(const String& topic, const String& payload) {
    messagesReceived++;
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("MQTTHandler", "Processando mensagem - Tópico: %s", topic.c_str());
        LOG_DEBUG_CTX("MQTTHandler", "Payload: %s", payload.c_str());
    }
    
    // Determinar qual handler usar baseado no tópico
    if (topic.endsWith("/relays/command")) {
        handleRelayCommand(payload);
    }
    else if (topic.endsWith("/heartbeat")) {
        handleHeartbeat(payload);
    }
    else if (topic.endsWith("/config")) {
        handleConfiguration(payload);
    }
    else if (topic.endsWith("/command")) {
        handleGeneralCommand(payload);
    }
    else if (topic.contains("/broadcast")) {
        handleBroadcast(payload);
    }
    else {
        LOG_WARN_CTX("MQTTHandler", "Tópico não reconhecido: %s", topic.c_str());
        errorsCount++;
    }
}

void MQTTHandler::handleRelayCommand(const String& payload) {
    LOG_INFO_CTX("MQTTHandler", "Processando comando de relé");
    
    if (!relayController) {
        LOG_ERROR_CTX("MQTTHandler", "Controlador de relés não disponível");
        errorsCount++;
        return;
    }
    
    DynamicJsonDocument doc(512);
    if (!parseJsonPayload(payload, doc)) {
        errorsCount++;
        return;
    }
    
    JsonObject cmd = doc.as<JsonObject>();
    if (!validateRelayCommand(cmd)) {
        errorsCount++;
        return;
    }
    
    // Extrair parâmetros do comando
    int channel = cmd["channel"];
    bool state = cmd["state"];
    String functionType = cmd["function_type"] | "toggle";
    String user = cmd["user"] | "unknown";
    bool momentary = cmd["momentary"] | false;
    String password = cmd["password"] | "";
    bool confirmation = cmd["confirmation"] | false;
    
    LOG_INFO_CTX("MQTTHandler", "Comando: Canal %d -> %s (%s) por %s", 
                 channel, state ? "ON" : "OFF", functionType.c_str(), user.c_str());
    
    // Executar comando
    bool success = false;
    String error = "";
    
    if (momentary && state) {
        // Para relés momentâneos, iniciar operação
        success = relayController->startMomentaryOperation(channel, user);
        if (!success) {
            error = "Falha ao iniciar operação momentânea";
        }
    } else if (momentary && !state) {
        // Para relés momentâneos, parar operação
        success = relayController->stopMomentaryOperation(channel);
        if (!success) {
            error = "Falha ao parar operação momentânea";
        }
    } else {
        // Comando toggle normal
        success = relayController->setRelayState(channel, state, user, password, confirmation);
        if (!success) {
            error = "Falha ao executar comando de relé";
        }
    }
    
    if (success) {
        commandsExecuted++;
        LOG_INFO_CTX("MQTTHandler", "Comando executado com sucesso");
    } else {
        errorsCount++;
        LOG_ERROR_CTX("MQTTHandler", "Falha na execução do comando: %s", error.c_str());
    }
    
    // Enviar resposta
    sendCommandResponse("relay", success, error);
}

void MQTTHandler::handleHeartbeat(const String& payload) {
    if (debugEnabled) {
        LOG_DEBUG_CTX("MQTTHandler", "Processando heartbeat");
    }
    
    if (!relayController) {
        LOG_ERROR_CTX("MQTTHandler", "Controlador de relés não disponível");
        errorsCount++;
        return;
    }
    
    DynamicJsonDocument doc(256);
    if (!parseJsonPayload(payload, doc)) {
        errorsCount++;
        return;
    }
    
    JsonObject hb = doc.as<JsonObject>();
    if (!validateHeartbeat(hb)) {
        errorsCount++;
        return;
    }
    
    // Extrair parâmetros do heartbeat
    int channel = hb["channel"];
    int sequence = hb["sequence"] | 0;
    unsigned long timestamp = hb["timestamp"] | millis();
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("MQTTHandler", "Heartbeat: Canal %d, Seq %d", channel, sequence);
    }
    
    // Processar heartbeat
    bool success = relayController->processHeartbeat(channel, sequence, timestamp);
    
    if (success) {
        heartbeatsReceived++;
        
        // Enviar ACK do heartbeat
        sendHeartbeatAck(channel, sequence);
    } else {
        errorsCount++;
        LOG_WARN_CTX("MQTTHandler", "Heartbeat rejeitado para canal %d", channel);
    }
}

void MQTTHandler::handleConfiguration(const String& payload) {
    LOG_INFO_CTX("MQTTHandler", "Processando configuração");
    
    DynamicJsonDocument doc(2048);
    if (!parseJsonPayload(payload, doc)) {
        errorsCount++;
        return;
    }
    
    // TODO: Implementar processamento de configuração
    // Por enquanto, apenas log
    LOG_INFO_CTX("MQTTHandler", "Configuração recebida (processamento não implementado)");
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("MQTTHandler", "Config payload: %s", payload.c_str());
    }
}

void MQTTHandler::handleGeneralCommand(const String& payload) {
    LOG_INFO_CTX("MQTTHandler", "Processando comando geral");
    
    DynamicJsonDocument doc(512);
    if (!parseJsonPayload(payload, doc)) {
        errorsCount++;
        return;
    }
    
    JsonObject cmd = doc.as<JsonObject>();
    String command = cmd["command"] | "";
    
    if (command == "restart") {
        LOG_WARN_CTX("MQTTHandler", "Comando de reinicialização recebido");
        sendCommandResponse("restart", true, "Reiniciando em 3 segundos");
        delay(3000);
        ESP.restart();
    }
    else if (command == "status") {
        LOG_INFO_CTX("MQTTHandler", "Comando de status recebido");
        // Publicar status
        mqttClient.publishStatus("online");
        sendCommandResponse("status", true, "Status publicado");
    }
    else if (command == "ping") {
        LOG_DEBUG_CTX("MQTTHandler", "Comando ping recebido");
        sendCommandResponse("ping", true, "pong");
    }
    else {
        LOG_WARN_CTX("MQTTHandler", "Comando não reconhecido: %s", command.c_str());
        sendCommandResponse(command, false, "Comando não reconhecido");
        errorsCount++;
    }
}

void MQTTHandler::handleBroadcast(const String& payload) {
    LOG_INFO_CTX("MQTTHandler", "Processando broadcast");
    
    DynamicJsonDocument doc(512);
    if (!parseJsonPayload(payload, doc)) {
        errorsCount++;
        return;
    }
    
    JsonObject broadcast = doc.as<JsonObject>();
    String type = broadcast["type"] | "";
    
    if (type == "emergency_stop") {
        LOG_WARN_CTX("MQTTHandler", "EMERGENCY STOP recebido via broadcast");
        if (relayController) {
            relayController->emergencyStop();
        }
    }
    else if (type == "system_update") {
        LOG_INFO_CTX("MQTTHandler", "Aviso de atualização do sistema recebido");
        // TODO: Implementar lógica de atualização
    }
    else {
        LOG_DEBUG_CTX("MQTTHandler", "Broadcast tipo: %s", type.c_str());
    }
}

bool MQTTHandler::validateRelayCommand(const JsonObject& cmd) {
    // Verificar campos obrigatórios
    if (!cmd.containsKey("channel") || !cmd.containsKey("state")) {
        LOG_ERROR_CTX("MQTTHandler", "Comando de relé inválido: campos obrigatórios ausentes");
        return false;
    }
    
    int channel = cmd["channel"];
    if (channel < 1 || channel > MAX_RELAY_CHANNELS) {
        LOG_ERROR_CTX("MQTTHandler", "Canal de relé inválido: %d", channel);
        return false;
    }
    
    return true;
}

bool MQTTHandler::validateHeartbeat(const JsonObject& hb) {
    // Verificar campo obrigatório
    if (!hb.containsKey("channel")) {
        LOG_ERROR_CTX("MQTTHandler", "Heartbeat inválido: canal não especificado");
        return false;
    }
    
    int channel = hb["channel"];
    if (channel < 1 || channel > MAX_RELAY_CHANNELS) {
        LOG_ERROR_CTX("MQTTHandler", "Canal de heartbeat inválido: %d", channel);
        return false;
    }
    
    return true;
}

bool MQTTHandler::parseJsonPayload(const String& payload, DynamicJsonDocument& doc) {
    DeserializationError error = deserializeJson(doc, payload);
    
    if (error) {
        LOG_ERROR_CTX("MQTTHandler", "Erro ao parsear JSON: %s", error.c_str());
        LOG_ERROR_CTX("MQTTHandler", "Payload: %s", payload.c_str());
        return false;
    }
    
    return true;
}

void MQTTHandler::sendCommandResponse(const String& command, bool success, const String& error) {
    DynamicJsonDocument doc(256);
    doc["command"] = command;
    doc["success"] = success;
    doc["timestamp"] = millis();
    
    if (!success && error.length() > 0) {
        doc["error"] = error;
    }
    
    String response;
    serializeJson(doc, response);
    
    // Publicar resposta
    String responseTopic = mqttClient.getBaseTopic() + "/response";
    mqttClient.publish(responseTopic, response);
}

void MQTTHandler::sendHeartbeatAck(int channel, int sequence) {
    mqttClient.publishHeartbeatAck(channel, sequence);
}

String MQTTHandler::getTopicSuffix(const String& topic, const String& baseTopic) {
    if (topic.startsWith(baseTopic)) {
        return topic.substring(baseTopic.length());
    }
    return topic;
}

bool MQTTHandler::isTopicMatch(const String& topic, const String& pattern) {
    // Implementação simples - pode ser expandida para suportar wildcards
    return topic.endsWith(pattern);
}

String MQTTHandler::getStatisticsJSON() {
    DynamicJsonDocument doc(512);
    doc["messages_received"] = messagesReceived;
    doc["commands_executed"] = commandsExecuted;
    doc["heartbeats_received"] = heartbeatsReceived;
    doc["errors_count"] = errorsCount;
    doc["uptime"] = millis() / 1000;
    
    String stats;
    serializeJson(doc, stats);
    return stats;
}

void MQTTHandler::resetStatistics() {
    messagesReceived = 0;
    commandsExecuted = 0;
    heartbeatsReceived = 0;
    errorsCount = 0;
    
    LOG_INFO_CTX("MQTTHandler", "Estatísticas resetadas");
}

void MQTTHandler::setDebugMode(bool enabled) {
    debugEnabled = enabled;
    LOG_INFO_CTX("MQTTHandler", "Debug mode %s", enabled ? "habilitado" : "desabilitado");
}