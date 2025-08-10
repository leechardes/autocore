/**
 * AutoCore ESP32 Display - MQTT Handler Implementation
 */

#include "mqtt_handler.h"
#include "../config/config_manager.h"

// Instância global
MQTTHandler mqttHandler;

MQTTHandler::MQTTHandler() 
    : initialized(false),
      screenManager(nullptr),
      configManager(nullptr),
      messagesProcessed(0),
      lastMessageTime(0),
      configUpdateTime(0) {
}

MQTTHandler::~MQTTHandler() {
    // Limpar recursos se necessário
}

bool MQTTHandler::begin(ScreenManager* scrMgr) {
    LOG_INFO_CTX("MQTTHandler", "Inicializando handler de mensagens MQTT");
    
    screenManager = scrMgr;
    configManager = &::configManager;  // Referência global
    
    // Limpar caches
    relayStates.clear();
    canValues.clear();
    
    // Reset contadores
    messagesProcessed = 0;
    lastMessageTime = 0;
    
    initialized = true;
    
    LOG_INFO_CTX("MQTTHandler", "Handler MQTT inicializado");
    return true;
}

void MQTTHandler::handleMessage(const String& topic, const String& payload) {
    if (!initialized) {
        LOG_WARN_CTX("MQTTHandler", "Handler não inicializado");
        return;
    }
    
    lastMessageTime = millis();
    messagesProcessed++;
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("MQTTHandler", "Processando: %s (%d bytes)", 
                     topic.c_str(), payload.length());
    }
    
    // Validar JSON se necessário
    if (topic.indexOf("/config") >= 0 || 
        topic.indexOf("/data") >= 0 || 
        topic.indexOf("/command") >= 0) {
        
        if (!validateJSON(payload)) {
            LOG_ERROR_CTX("MQTTHandler", "JSON inválido no tópico: %s", topic.c_str());
            return;
        }
    }
    
    // Determinar tipo de mensagem e processar
    MQTTMessageType msgType = getMessageType(topic);
    
    switch (msgType) {
        case MSG_CONFIG_UPDATE:
            handleConfigUpdate(payload);
            break;
            
        case MSG_RELAY_STATE:
            handleRelayStateUpdate(topic, payload);
            break;
            
        case MSG_CAN_DATA:
            handleCANDataUpdate(payload);
            break;
            
        case MSG_SYSTEM_BROADCAST:
            handleSystemBroadcast(payload);
            break;
            
        case MSG_DISPLAY_COMMAND:
            handleDisplayCommand(payload);
            break;
            
        case MSG_THEME_UPDATE:
            handleThemeUpdate(payload);
            break;
            
        case MSG_SCREEN_UPDATE:
            handleScreenUpdate(payload);
            break;
            
        default:
            if (debugEnabled) {
                LOG_DEBUG_CTX("MQTTHandler", "Tipo de mensagem desconhecido: %s", topic.c_str());
            }
            break;
    }
}

MQTTMessageType MQTTHandler::getMessageType(const String& topic) {
    if (topic.endsWith("/config")) {
        return MSG_CONFIG_UPDATE;
    }
    if (topic.indexOf("autocore/relays/") >= 0 && topic.endsWith("/state")) {
        return MSG_RELAY_STATE;
    }
    if (topic.indexOf("autocore/can/data") >= 0) {
        return MSG_CAN_DATA;
    }
    if (topic.indexOf("autocore/system/broadcast") >= 0) {
        return MSG_SYSTEM_BROADCAST;
    }
    if (topic.indexOf("/commands") >= 0) {
        return MSG_DISPLAY_COMMAND;
    }
    if (topic.indexOf("/theme") >= 0) {
        return MSG_THEME_UPDATE;
    }
    if (topic.indexOf("/screens") >= 0) {
        return MSG_SCREEN_UPDATE;
    }
    
    return MSG_UNKNOWN;
}

void MQTTHandler::handleConfigUpdate(const String& payload) {
    LOG_INFO_CTX("MQTTHandler", "Recebida atualização de configuração");
    
    if (!configManager) {
        LOG_ERROR_CTX("MQTTHandler", "ConfigManager não disponível");
        return;
    }
    
    // Tentar parsear configuração completa
    if (configManager->updateFromJSON(payload)) {
        LOG_INFO_CTX("MQTTHandler", "Configuração atualizada via MQTT");
        
        // Salvar configuração
        configManager->save();
        
        // Atualizar timestamp
        configUpdateTime = millis();
        
        // Notificar screen manager se disponível
        if (screenManager) {
            // screenManager->reloadConfiguration();
        }
        
        // SIMULADO: Log da ação
        LOG_INFO_CTX("MQTTHandler", "SIMULADO: Configuração recarregada");
        
    } else {
        LOG_ERROR_CTX("MQTTHandler", "Falha ao processar atualização de configuração");
    }
}

void MQTTHandler::handleRelayStateUpdate(const String& topic, const String& payload) {
    // Extrair ID do relé do tópico
    String relayId = extractRelayIdFromTopic(topic);
    
    if (relayId.length() == 0) {
        LOG_ERROR_CTX("MQTTHandler", "Não foi possível extrair ID do relé: %s", topic.c_str());
        return;
    }
    
    // Parsear estado
    DynamicJsonDocument doc(256);
    DeserializationError error = deserializeJson(doc, payload);
    
    if (error) {
        // Tentar como valor booleano simples
        bool state = (payload == "true" || payload == "1" || payload == "ON");
        relayStates[relayId] = state;
        
        if (debugEnabled) {
            LOG_DEBUG_CTX("MQTTHandler", "Relé %s -> %s", relayId.c_str(), state ? "ON" : "OFF");
        }
    } else {
        // Parsear JSON estruturado
        if (doc.containsKey("state")) {
            bool state = doc["state"].as<bool>();
            relayStates[relayId] = state;
            
            if (debugEnabled) {
                LOG_DEBUG_CTX("MQTTHandler", "Relé %s -> %s (JSON)", 
                             relayId.c_str(), state ? "ON" : "OFF");
            }
        }
    }
    
    // Atualizar botões relacionados na UI
    updateRelayButtonStates();
}

void MQTTHandler::handleCANDataUpdate(const String& payload) {
    if (debugEnabled) {
        LOG_DEBUG_CTX("MQTTHandler", "Dados CAN recebidos");
    }
    
    DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, payload);
    
    if (error) {
        LOG_ERROR_CTX("MQTTHandler", "Erro ao parsear dados CAN");
        return;
    }
    
    // Processar sinais CAN
    if (doc.containsKey("signals")) {
        JsonObject signals = doc["signals"];
        
        for (JsonPair signal : signals) {
            String signalName = signal.key().c_str();
            float value = signal.value().as<float>();
            
            canValues[signalName] = value;
            
            if (debugEnabled) {
                LOG_DEBUG_CTX("MQTTHandler", "CAN %s = %.2f", signalName.c_str(), value);
            }
        }
        
        // Atualizar displays CAN na UI
        updateCANDisplays();
    }
}

void MQTTHandler::handleSystemBroadcast(const String& payload) {
    LOG_INFO_CTX("MQTTHandler", "Broadcast do sistema recebido");
    
    DynamicJsonDocument doc(512);
    DeserializationError error = deserializeJson(doc, payload);
    
    if (error) {
        LOG_ERROR_CTX("MQTTHandler", "Erro ao parsear broadcast do sistema");
        return;
    }
    
    // Processar diferentes tipos de broadcast
    if (doc.containsKey("type")) {
        String type = doc["type"].as<String>();
        
        if (type == "config_reload") {
            LOG_INFO_CTX("MQTTHandler", "Solicitação de reload de configuração");
            requestConfigUpdate();
        }
        else if (type == "emergency_stop") {
            LOG_WARN_CTX("MQTTHandler", "🚨 Emergency stop do sistema");
            // SIMULADO: Parar todas as ações
            LOG_WARN_CTX("MQTTHandler", "SIMULADO: Emergency stop processado");
        }
        else if (type == "system_restart") {
            LOG_WARN_CTX("MQTTHandler", "Reinicialização do sistema solicitada");
            // Agendar reinicialização
            delay(1000);
            ESP.restart();
        }
    }
}

void MQTTHandler::handleDisplayCommand(const String& payload) {
    LOG_DEBUG_CTX("MQTTHandler", "Comando de display recebido");
    
    DynamicJsonDocument doc(512);
    DeserializationError error = deserializeJson(doc, payload);
    
    if (error) {
        LOG_ERROR_CTX("MQTTHandler", "Erro ao parsear comando de display");
        return;
    }
    
    // Processar comando baseado no tipo
    if (doc.containsKey("type")) {
        String type = doc["type"].as<String>();
        
        if (type == "button") {
            processButtonCommand(doc.as<JsonObject>());
        }
        else if (type == "screen") {
            processScreenCommand(doc.as<JsonObject>());
        }
        else if (type == "system") {
            processSystemCommand(doc.as<JsonObject>());
        }
    }
}

void MQTTHandler::handleThemeUpdate(const String& payload) {
    LOG_INFO_CTX("MQTTHandler", "Atualização de tema recebida");
    
    if (!configManager) {
        return;
    }
    
    // Atualizar tema
    if (configManager->updateThemeFromJSON(payload)) {
        configManager->save();
        lastThemeUpdate = payload;
        
        // Notificar screen manager para aplicar novo tema
        if (screenManager) {
            // screenManager->applyTheme();
        }
        
        LOG_INFO_CTX("MQTTHandler", "SIMULADO: Tema aplicado");
    }
}

void MQTTHandler::handleScreenUpdate(const String& payload) {
    LOG_INFO_CTX("MQTTHandler", "Atualização de telas recebida");
    
    if (!configManager) {
        return;
    }
    
    // Atualizar configuração de telas
    if (configManager->updateScreensFromJSON(payload)) {
        configManager->save();
        
        // Notificar screen manager para recriar telas
        if (screenManager) {
            // screenManager->rebuildScreens();
        }
        
        LOG_INFO_CTX("MQTTHandler", "SIMULADO: Telas atualizadas");
    }
}

void MQTTHandler::processButtonCommand(const JsonObject& command) {
    if (command.containsKey("button_id") && command.containsKey("action")) {
        String buttonId = command["button_id"].as<String>();
        String action = command["action"].as<String>();
        
        LOG_DEBUG_CTX("MQTTHandler", "Comando de botão: %s -> %s", buttonId.c_str(), action.c_str());
        
        // SIMULADO: Processar comando de botão
        if (action == "press") {
            LOG_INFO_CTX("MQTTHandler", "SIMULADO: Botão %s pressionado remotamente", buttonId.c_str());
        } else if (action == "release") {
            LOG_INFO_CTX("MQTTHandler", "SIMULADO: Botão %s liberado remotamente", buttonId.c_str());
        }
    }
}

void MQTTHandler::processScreenCommand(const JsonObject& command) {
    if (command.containsKey("screen_id")) {
        String screenId = command["screen_id"].as<String>();
        
        LOG_DEBUG_CTX("MQTTHandler", "Comando de tela: %s", screenId.c_str());
        
        // SIMULADO: Navegar para tela
        if (screenManager) {
            // screenManager->showScreen(screenId);
        }
        
        LOG_INFO_CTX("MQTTHandler", "SIMULADO: Navegação para tela %s", screenId.c_str());
    }
}

void MQTTHandler::processSystemCommand(const JsonObject& command) {
    if (command.containsKey("command")) {
        String cmd = command["command"].as<String>();
        
        LOG_DEBUG_CTX("MQTTHandler", "Comando de sistema: %s", cmd.c_str());
        
        if (cmd == "brightness") {
            int brightness = command["value"].as<int>();
            LOG_INFO_CTX("MQTTHandler", "SIMULADO: Brilho ajustado para %d%%", brightness);
        }
        else if (cmd == "sleep") {
            LOG_INFO_CTX("MQTTHandler", "SIMULADO: Display entrando em sleep mode");
        }
        else if (cmd == "wake") {
            LOG_INFO_CTX("MQTTHandler", "SIMULADO: Display saindo do sleep mode");
        }
    }
}

String MQTTHandler::extractRelayIdFromTopic(const String& topic) {
    // Exemplo: autocore/relays/relay-001/state -> relay-001
    int startPos = topic.indexOf("autocore/relays/");
    if (startPos < 0) return "";
    
    startPos += 16;  // Tamanho de "autocore/relays/"
    int endPos = topic.indexOf("/", startPos);
    if (endPos < 0) return "";
    
    return topic.substring(startPos, endPos);
}

bool MQTTHandler::validateJSON(const String& payload) {
    DynamicJsonDocument doc(64);  // Buffer pequeno apenas para validação
    DeserializationError error = deserializeJson(doc, payload);
    return error == DeserializationError::Ok;
}

bool MQTTHandler::updateRelayButtonStates() {
    if (!screenManager) {
        return false;
    }
    
    // SIMULADO: Atualizar estados dos botões na UI
    for (const auto& relay : relayStates) {
        if (debugEnabled) {
            LOG_DEBUG_CTX("MQTTHandler", "SIMULADO: Atualizar botão relé %s -> %s", 
                         relay.first.c_str(), relay.second ? "ON" : "OFF");
        }
    }
    
    return true;
}

bool MQTTHandler::updateCANDisplays() {
    if (!screenManager) {
        return false;
    }
    
    // SIMULADO: Atualizar displays CAN na UI
    for (const auto& signal : canValues) {
        if (debugEnabled) {
            LOG_DEBUG_CTX("MQTTHandler", "SIMULADO: Atualizar display CAN %s = %.2f", 
                         signal.first.c_str(), signal.second);
        }
    }
    
    return true;
}

bool MQTTHandler::getRelayState(const String& relayId) const {
    auto it = relayStates.find(relayId);
    return (it != relayStates.end()) ? it->second : false;
}

float MQTTHandler::getCANValue(const String& signal) const {
    auto it = canValues.find(signal);
    return (it != canValues.end()) ? it->second : 0.0f;
}

void MQTTHandler::requestConfigUpdate() {
    LOG_INFO_CTX("MQTTHandler", "Solicitando atualização de configuração");
    // Enviar solicitação via MQTT Client se necessário
}

void MQTTHandler::requestRelayStates() {
    LOG_DEBUG_CTX("MQTTHandler", "Solicitando estados dos relés");
    // Publicar solicitação de status dos relés
}

void MQTTHandler::requestCANData() {
    LOG_DEBUG_CTX("MQTTHandler", "Solicitando dados CAN");
    // Publicar solicitação de dados CAN
}

void MQTTHandler::syncAllStates() {
    LOG_INFO_CTX("MQTTHandler", "Sincronizando todos os estados");
    
    requestConfigUpdate();
    requestRelayStates();
    requestCANData();
}

void MQTTHandler::update() {
    // Handler MQTT é event-driven, não requer update contínuo
    // Pode ser usado para limpeza de cache antigo, etc.
    
    static unsigned long lastCleanup = 0;
    if (millis() - lastCleanup > 300000) {  // 5 minutos
        // Limpeza periódica se necessário
        lastCleanup = millis();
    }
}

void MQTTHandler::setScreenManager(ScreenManager* manager) {
    screenManager = manager;
    LOG_DEBUG_CTX("MQTTHandler", "Screen Manager configurado");
}

void MQTTHandler::setConfigManager(ConfigManager* manager) {
    configManager = manager;
    LOG_DEBUG_CTX("MQTTHandler", "Config Manager configurado");
}

void MQTTHandler::printStats() const {
    LOG_INFO("=== STATS MQTT HANDLER ===");
    LOG_INFO("Mensagens processadas: %lu", messagesProcessed);
    LOG_INFO("Última mensagem: %lu ms atrás", millis() - lastMessageTime);
    LOG_INFO("Relés em cache: %d", relayStates.size());
    LOG_INFO("Sinais CAN em cache: %d", canValues.size());
    LOG_INFO("Última config update: %lu ms atrás", millis() - configUpdateTime);
    LOG_INFO("==========================");
}

void MQTTHandler::printCachedStates() const {
    LOG_INFO("=== ESTADOS EM CACHE ===");
    
    LOG_INFO("Relés:");
    for (const auto& relay : relayStates) {
        LOG_INFO("  %s: %s", relay.first.c_str(), relay.second ? "ON" : "OFF");
    }
    
    LOG_INFO("Sinais CAN:");
    for (const auto& signal : canValues) {
        LOG_INFO("  %s: %.2f", signal.first.c_str(), signal.second);
    }
    
    LOG_INFO("========================");
}

void MQTTHandler::clearCache() {
    LOG_WARN_CTX("MQTTHandler", "Limpando cache de estados");
    
    relayStates.clear();
    canValues.clear();
    lastThemeUpdate = "";
}

String MQTTHandler::getStatsJSON() const {
    DynamicJsonDocument doc(512);
    
    doc["messages_processed"] = messagesProcessed;
    doc["last_message_time"] = lastMessageTime;
    doc["cached_relays"] = relayStates.size();
    doc["cached_can_signals"] = canValues.size();
    doc["config_update_time"] = configUpdateTime;
    doc["uptime"] = millis();
    
    String stats;
    serializeJson(doc, stats);
    return stats;
}