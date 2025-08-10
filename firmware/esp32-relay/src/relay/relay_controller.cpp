#include "relay_controller.h"
#include "../utils/logger.h"
#include "../mqtt/mqtt_client.h"
#include "../config/config_manager.h"

// Instância global
RelayController relayController;

RelayController::RelayController() {
    // Inicializar array de canais
    for (int i = 0; i < MAX_RELAY_CHANNELS; i++) {
        channels[i] = nullptr;
    }
    totalChannels = 0;
}

RelayController::~RelayController() {
    end();
}

bool RelayController::begin(int numChannels) {
    if (initialized) {
        LOG_WARN_CTX("RelayController", "Controlador já inicializado");
        return true;
    }
    
    if (numChannels <= 0 || numChannels > MAX_RELAY_CHANNELS) {
        LOG_ERROR_CTX("RelayController", "Número de canais inválido: %d", numChannels);
        return false;
    }
    
    LOG_INFO_CTX("RelayController", "Inicializando controlador com %d canais", numChannels);
    
    totalChannels = numChannels;
    
    // Criar objetos dos canais
    for (int i = 0; i < totalChannels; i++) {
        channels[i] = new RelayChannel(i + 1); // Canais numerados de 1 a N
        if (!channels[i]) {
            LOG_ERROR_CTX("RelayController", "Falha ao criar canal %d", i + 1);
            end(); // Limpar o que foi criado
            return false;
        }
        
        if (debugEnabled) {
            channels[i]->setDebugMode(true);
        }
    }
    
    // Carregar configuração dos canais
    loadConfigurationFromNVS();
    
    // Reset de estatísticas
    resetStatistics();
    
    // Desabilitar emergency stop
    emergencyStopActive = false;
    
    // Timestamps iniciais
    lastTelemetryPublish = millis();
    lastStatusUpdate = millis();
    
    initialized = true;
    
    LOG_INFO_CTX("RelayController", "Controlador inicializado com sucesso");
    printAllChannelsStatus();
    
    return true;
}

void RelayController::end() {
    if (initialized) {
        LOG_INFO_CTX("RelayController", "Finalizando controlador de relés");
        
        // Desligar todos os relés
        turnOffAllRelays("system_shutdown");
        
        // Deletar objetos dos canais
        for (int i = 0; i < MAX_RELAY_CHANNELS; i++) {
            if (channels[i]) {
                delete channels[i];
                channels[i] = nullptr;
            }
        }
        
        initialized = false;
        totalChannels = 0;
        
        LOG_INFO_CTX("RelayController", "Controlador finalizado");
    }
}

bool RelayController::configureChannel(int channel, const RelayChannelConfig& config) {
    if (!validateChannelNumber(channel)) {
        return false;
    }
    
    RelayChannel* ch = channels[channel - 1];
    if (!ch) {
        LOG_ERROR_CTX("RelayController", "Canal %d não existe", channel);
        return false;
    }
    
    bool success = ch->configure(config);
    if (success) {
        LOG_INFO_CTX("RelayController", "Canal %d configurado: %s", channel, config.name.c_str());
    } else {
        LOG_ERROR_CTX("RelayController", "Falha ao configurar canal %d", channel);
        incrementError();
    }
    
    return success;
}

bool RelayController::configureFromJSON(const String& configJson) {
    LOG_INFO_CTX("RelayController", "Carregando configuração de JSON");
    
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, configJson);
    
    if (error) {
        LOG_ERROR_CTX("RelayController", "Erro ao parsear JSON de configuração: %s", error.c_str());
        incrementError();
        return false;
    }
    
    if (!doc["channels"].is<JsonArray>()) {
        LOG_ERROR_CTX("RelayController", "JSON não contém configuração de canais");
        incrementError();
        return false;
    }
    
    JsonArray channelsArray = doc["channels"];
    int configuredChannels = 0;
    
    for (JsonObject channelObj : channelsArray) {
        int channelId = channelObj["id"] | 0;
        
        if (channelId < 1 || channelId > totalChannels) {
            LOG_WARN_CTX("RelayController", "ID de canal inválido ignorado: %d", channelId);
            continue;
        }
        
        RelayChannelConfig config;
        config.enabled = channelObj["enabled"] | false;
        config.gpio_pin = channelObj["gpio_pin"] | -1;
        String defaultName = "Canal " + String(channelId);
        config.name = channelObj["name"] | defaultName.c_str();
        config.function_type = channelObj["function_type"] | "toggle";
        config.require_password = channelObj["require_password"] | false;
        config.password_hash = channelObj["password_hash"] | "";
        config.require_confirmation = channelObj["require_confirmation"] | false;
        config.dual_action_enabled = channelObj["dual_action_enabled"] | false;
        config.dual_action_channel = channelObj["dual_action_channel"] | -1;
        config.max_on_time_ms = channelObj["max_on_time_ms"] | 0;
        config.time_window_enabled = channelObj["time_window_enabled"] | false;
        config.time_window_start = channelObj["time_window_start"] | 0;
        config.time_window_end = channelObj["time_window_end"] | 1440;
        config.allow_in_macro = channelObj["allow_in_macro"] | true;
        config.inverted_logic = channelObj["inverted_logic"] | false;
        
        if (configureChannel(channelId, config)) {
            configuredChannels++;
        }
    }
    
    LOG_INFO_CTX("RelayController", "Configurados %d canais a partir do JSON", configuredChannels);
    
    // Salvar configuração no NVS
    saveConfigurationToNVS();
    
    return configuredChannels > 0;
}

bool RelayController::loadConfigurationFromNVS() {
    LOG_INFO_CTX("RelayController", "Carregando configuração dos canais do NVS");
    
    // A configuração dos canais já está carregada no ConfigManager
    DeviceConfig& deviceConfig = configManager.getConfig();
    
    int configuredChannels = 0;
    
    for (int i = 0; i < totalChannels && i < MAX_RELAY_CHANNELS; i++) {
        if (deviceConfig.channels[i].enabled) {
            if (configureChannel(i + 1, deviceConfig.channels[i])) {
                configuredChannels++;
            }
        }
    }
    
    LOG_INFO_CTX("RelayController", "Carregados %d canais configurados do NVS", configuredChannels);
    return configuredChannels > 0;
}

bool RelayController::saveConfigurationToNVS() {
    LOG_INFO_CTX("RelayController", "Salvando configuração dos canais no NVS");
    
    // A configuração será salva pelo ConfigManager
    return configManager.saveConfig();
}

bool RelayController::setRelayState(int channel, bool state, const String& user, 
                                   const String& password, bool confirmation) {
    if (!validateChannelNumber(channel)) {
        incrementError();
        return false;
    }
    
    if (emergencyStopActive) {
        LOG_WARN_CTX("RelayController", "Emergency stop ativo - comando rejeitado");
        incrementError();
        return false;
    }
    
    RelayChannel* ch = channels[channel - 1];
    if (!ch || !ch->isEnabled()) {
        LOG_ERROR_CTX("RelayController", "Canal %d não está habilitado", channel);
        incrementError();
        return false;
    }
    
    bool success;
    if (state) {
        success = ch->turnOn(user, password, confirmation);
    } else {
        success = ch->turnOff(user);
    }
    
    if (success) {
        incrementOperation();
        LOG_INFO_CTX("RelayController", "Canal %d: %s por %s", 
                     channel, state ? "LIGADO" : "DESLIGADO", user.c_str());
    } else {
        incrementError();
        LOG_ERROR_CTX("RelayController", "Falha ao definir canal %d: %s", 
                      channel, ch->getLastError().c_str());
    }
    
    return success;
}

bool RelayController::toggleRelay(int channel, const String& user, 
                                 const String& password, bool confirmation) {
    if (!validateChannelNumber(channel)) {
        incrementError();
        return false;
    }
    
    RelayChannel* ch = channels[channel - 1];
    if (!ch || !ch->isEnabled()) {
        LOG_ERROR_CTX("RelayController", "Canal %d não está habilitado", channel);
        incrementError();
        return false;
    }
    
    bool success = ch->toggle(user, password, confirmation);
    
    if (success) {
        incrementOperation();
        LOG_INFO_CTX("RelayController", "Canal %d alternado por %s", channel, user.c_str());
    } else {
        incrementError();
        LOG_ERROR_CTX("RelayController", "Falha ao alternar canal %d: %s", 
                      channel, ch->getLastError().c_str());
    }
    
    return success;
}

bool RelayController::getRelayState(int channel) {
    if (!validateChannelNumber(channel)) {
        return false;
    }
    
    RelayChannel* ch = channels[channel - 1];
    if (!ch) {
        return false;
    }
    
    return ch->getCurrentState();
}

bool RelayController::startMomentaryOperation(int channel, const String& user) {
    if (!validateChannelNumber(channel)) {
        incrementError();
        return false;
    }
    
    if (emergencyStopActive) {
        LOG_WARN_CTX("RelayController", "Emergency stop ativo - operação momentânea rejeitada");
        incrementError();
        return false;
    }
    
    RelayChannel* ch = channels[channel - 1];
    if (!ch || !ch->isEnabled()) {
        LOG_ERROR_CTX("RelayController", "Canal %d não está habilitado", channel);
        incrementError();
        return false;
    }
    
    bool success = ch->startMomentary(user);
    
    if (success) {
        incrementOperation();
        LOG_INFO_CTX("RelayController", "Operação momentânea iniciada no canal %d por %s", 
                     channel, user.c_str());
    } else {
        incrementError();
        LOG_ERROR_CTX("RelayController", "Falha ao iniciar operação momentânea no canal %d: %s", 
                      channel, ch->getLastError().c_str());
    }
    
    return success;
}

bool RelayController::stopMomentaryOperation(int channel) {
    if (!validateChannelNumber(channel)) {
        incrementError();
        return false;
    }
    
    RelayChannel* ch = channels[channel - 1];
    if (!ch || !ch->isEnabled()) {
        LOG_ERROR_CTX("RelayController", "Canal %d não está habilitado", channel);
        incrementError();
        return false;
    }
    
    bool success = ch->stopMomentary();
    
    if (success) {
        LOG_INFO_CTX("RelayController", "Operação momentânea parada no canal %d", channel);
    } else {
        incrementError();
        LOG_ERROR_CTX("RelayController", "Falha ao parar operação momentânea no canal %d: %s", 
                      channel, ch->getLastError().c_str());
    }
    
    return success;
}

bool RelayController::processHeartbeat(int channel, int sequence, unsigned long timestamp) {
    if (!validateChannelNumber(channel)) {
        return false;
    }
    
    RelayChannel* ch = channels[channel - 1];
    if (!ch || !ch->isEnabled()) {
        return false;
    }
    
    return ch->processHeartbeat(sequence, timestamp);
}

void RelayController::emergencyStop() {
    LOG_WARN_CTX("RelayController", "🚨 EMERGENCY STOP ATIVADO 🚨");
    
    emergencyStopActive = true;
    
    // Parar todos os canais imediatamente
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i] && channels[i]->isEnabled()) {
            channels[i]->emergencyStop();
        }
    }
    
    // Publicar evento de emergency stop
    JsonDocument doc;
    doc["event"] = "emergency_stop";
    doc["timestamp"] = millis();
    doc["channels_affected"] = totalChannels;
    
    String payload;
    serializeJson(doc, payload);
    mqttClient.publishSafetyEvent(payload);
    
    LOG_WARN_CTX("RelayController", "Emergency stop concluído - todos os relés desligados");
}

void RelayController::resetEmergencyStop() {
    if (emergencyStopActive) {
        LOG_INFO_CTX("RelayController", "Emergency stop RESETADO");
        emergencyStopActive = false;
        
        // Reset safety flags de todos os canais
        for (int i = 0; i < totalChannels; i++) {
            if (channels[i]) {
                channels[i]->resetSafetyFlags();
            }
        }
    }
}

void RelayController::checkAllSafetyShutoffs() {
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i] && channels[i]->isEnabled()) {
            if (channels[i]->checkSafetyShutoff()) {
                incrementSafetyShutoff();
            }
        }
    }
}

void RelayController::resetAllSafetyFlags() {
    LOG_INFO_CTX("RelayController", "Resetando todas as flags de segurança");
    
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i]) {
            channels[i]->resetSafetyFlags();
        }
    }
}

RelayChannel* RelayController::getChannel(int channel) {
    if (!validateChannelNumber(channel)) {
        return nullptr;
    }
    
    return channels[channel - 1];
}

RelayChannelConfig RelayController::getChannelConfig(int channel) {
    RelayChannel* ch = getChannel(channel);
    if (ch) {
        return ch->getConfig();
    }
    return RelayChannelConfig(); // Retorna config vazia se inválido
}

RelayChannelState RelayController::getChannelState(int channel) {
    RelayChannel* ch = getChannel(channel);
    if (ch) {
        return ch->getState();
    }
    return RelayChannelState(); // Retorna state vazio se inválido
}

bool RelayController::setMultipleRelays(const std::vector<int>& channels, bool state, const String& user) {
    bool allSuccess = true;
    
    LOG_INFO_CTX("RelayController", "Definindo %d canais para %s por %s", 
                 channels.size(), state ? "ON" : "OFF", user.c_str());
    
    for (int channel : channels) {
        if (!setRelayState(channel, state, user)) {
            allSuccess = false;
        }
    }
    
    return allSuccess;
}

bool RelayController::turnOffAllRelays(const String& reason) {
    LOG_INFO_CTX("RelayController", "Desligando todos os relés - Razão: %s", reason.c_str());
    
    bool allSuccess = true;
    int turnedOff = 0;
    
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i] && channels[i]->isEnabled() && channels[i]->getCurrentState()) {
            if (channels[i]->turnOff(reason)) {
                turnedOff++;
            } else {
                allSuccess = false;
            }
        }
    }
    
    LOG_INFO_CTX("RelayController", "Desligados %d relés", turnedOff);
    return allSuccess;
}

int RelayController::getActiveRelaysCount() {
    int count = 0;
    
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i] && channels[i]->isEnabled() && channels[i]->getCurrentState()) {
            count++;
        }
    }
    
    return count;
}

std::vector<int> RelayController::getActiveRelays() {
    std::vector<int> activeChannels;
    
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i] && channels[i]->isEnabled() && channels[i]->getCurrentState()) {
            activeChannels.push_back(i + 1);
        }
    }
    
    return activeChannels;
}

void RelayController::update() {
    if (!initialized) return;
    
    unsigned long now = millis();
    
    // Atualizar todos os canais
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i] && channels[i]->isEnabled()) {
            channels[i]->update();
        }
    }
    
    // Verificar safety shutoffs
    checkAllSafetyShutoffs();
    
    // Publicar telemetria periodicamente
    if (now - lastTelemetryPublish >= telemetryInterval) {
        publishTelemetry();
        lastTelemetryPublish = now;
    }
    
    // Publicar status periodicamente
    if (now - lastStatusUpdate >= statusInterval) {
        publishStatus();
        lastStatusUpdate = now;
    }
}

void RelayController::publishTelemetry() {
    if (!mqttClient.isConnected()) {
        return;
    }
    
    String telemetry = getAllChannelsTelemetryJSON();
    mqttClient.publishTelemetry(telemetry);
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("RelayController", "Telemetria publicada");
    }
}

void RelayController::publishStatus() {
    if (!mqttClient.isConnected()) {
        return;
    }
    
    String status = getSystemStatusJSON();
    String statusTopic = mqttClient.getBaseTopic() + "/system_status";
    mqttClient.publish(statusTopic, status);
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("RelayController", "Status do sistema publicado");
    }
}

String RelayController::getStatisticsJSON() {
    JsonDocument doc;
    
    doc["total_operations"] = totalOperations;
    doc["total_errors"] = totalErrors;
    doc["safety_shutoffs"] = safetyShutoffs;
    doc["active_relays"] = getActiveRelaysCount();
    doc["total_channels"] = totalChannels;
    doc["emergency_stop_active"] = emergencyStopActive;
    doc["uptime"] = millis() / 1000;
    
    String stats;
    serializeJson(doc, stats);
    return stats;
}

void RelayController::resetStatistics() {
    totalOperations = 0;
    totalErrors = 0;
    safetyShutoffs = 0;
    
    LOG_INFO_CTX("RelayController", "Estatísticas resetadas");
}

String RelayController::getAllChannelsStatusJSON() {
    JsonDocument doc;
    
    JsonArray channelsArray = doc["channels"].to<JsonArray>();
    
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i]) {
            JsonDocument channelDoc;
            deserializeJson(channelDoc, channels[i]->getStatusJSON());
            channelsArray.add(channelDoc);
        }
    }
    
    doc["timestamp"] = millis();
    doc["total_channels"] = totalChannels;
    doc["active_channels"] = getActiveRelaysCount();
    
    String status;
    serializeJson(doc, status);
    return status;
}

String RelayController::getAllChannelsTelemetryJSON() {
    JsonDocument doc;
    
    JsonArray channelsArray = doc["channels"].to<JsonArray>();
    
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i] && channels[i]->isEnabled()) {
            JsonDocument channelDoc;
            deserializeJson(channelDoc, channels[i]->getTelemetryJSON());
            channelsArray.add(channelDoc);
        }
    }
    
    doc["timestamp"] = millis();
    doc["device_uuid"] = configManager.getDeviceUUID();
    doc["free_memory"] = ESP.getFreeHeap();
    
    String telemetry;
    serializeJson(doc, telemetry);
    return telemetry;
}

String RelayController::getSystemStatusJSON() {
    JsonDocument doc;
    
    doc["device_uuid"] = configManager.getDeviceUUID();
    doc["timestamp"] = millis();
    doc["uptime"] = millis() / 1000;
    doc["total_channels"] = totalChannels;
    doc["active_channels"] = getActiveRelaysCount();
    doc["emergency_stop_active"] = emergencyStopActive;
    doc["free_memory"] = ESP.getFreeHeap();
    doc["total_operations"] = totalOperations;
    doc["total_errors"] = totalErrors;
    doc["safety_shutoffs"] = safetyShutoffs;
    
    // Lista dos canais ativos
    std::vector<int> activeChannels = getActiveRelays();
    JsonArray activeArray = doc["active_relay_channels"].to<JsonArray>();
    for (int channel : activeChannels) {
        activeArray.add(channel);
    }
    
    String status;
    serializeJson(doc, status);
    return status;
}

bool RelayController::isValidChannel(int channel) {
    return validateChannelNumber(channel);
}

bool RelayController::isChannelEnabled(int channel) {
    RelayChannel* ch = getChannel(channel);
    return ch && ch->isEnabled();
}

bool RelayController::isChannelMomentary(int channel) {
    RelayChannel* ch = getChannel(channel);
    if (ch) {
        RelayChannelConfig config = ch->getConfig();
        return config.function_type == "momentary";
    }
    return false;
}

void RelayController::printAllChannelsStatus() {
    LOG_INFO_CTX("RelayController", "=== STATUS DE TODOS OS CANAIS ===");
    
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i]) {
            channels[i]->printStatus();
        }
    }
    
    LOG_INFO_CTX("RelayController", "Canais ativos: %d/%d", getActiveRelaysCount(), totalChannels);
    LOG_INFO_CTX("RelayController", "Emergency stop: %s", emergencyStopActive ? "ATIVO" : "Inativo");
    LOG_INFO_CTX("RelayController", "================================");
}

void RelayController::setDebugMode(bool enabled) {
    debugEnabled = enabled;
    
    // Aplicar a todos os canais
    for (int i = 0; i < totalChannels; i++) {
        if (channels[i]) {
            channels[i]->setDebugMode(enabled);
        }
    }
    
    LOG_INFO_CTX("RelayController", "Debug mode %s", enabled ? "habilitado" : "desabilitado");
}

bool RelayController::validateChannelNumber(int channel) {
    if (channel < 1 || channel > totalChannels) {
        LOG_ERROR_CTX("RelayController", "Número de canal inválido: %d (1-%d)", channel, totalChannels);
        return false;
    }
    return true;
}