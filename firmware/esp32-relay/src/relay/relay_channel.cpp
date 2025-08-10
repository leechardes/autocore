#include "relay_channel.h"
#include "../utils/logger.h"
#include "../mqtt/mqtt_client.h"
#include <esp_system.h>

RelayChannel::RelayChannel(int id) : channelId(id) {
    // Inicializar estado padrão
    state.current_state = false;
    state.last_state_change = 0;
    state.last_heartbeat = 0;
    state.waiting_for_heartbeat = false;
    state.turn_on_time = 0;
    state.heartbeat_sequence = 0;
    state.safety_shutoff_triggered = false;
    
    lastUpdate = millis();
    
    LOG_DEBUG_CTX("RelayChannel", "Canal %d inicializado", channelId);
}

RelayChannel::~RelayChannel() {
    // Garantir que o relé seja desligado
    if (config.enabled && state.current_state) {
        turnOff("system_shutdown");
    }
}

bool RelayChannel::configure(const RelayChannelConfig& channelConfig) {
    if (channelConfig.enabled && !IS_VALID_GPIO(channelConfig.gpio_pin)) {
        lastError = "Pino GPIO inválido: " + String(channelConfig.gpio_pin);
        LOG_ERROR_CTX("RelayChannel", "Canal %d: %s", channelId, lastError.c_str());
        return false;
    }
    
    // Salvar configuração anterior para comparação
    bool wasEnabled = config.enabled;
    int oldPin = config.gpio_pin;
    
    config = channelConfig;
    
    // Configurar GPIO se habilitado
    if (config.enabled) {
        pinMode(config.gpio_pin, OUTPUT);
        
        // Definir estado inicial baseado na lógica
        bool initialState = config.inverted_logic ? HIGH : LOW;
        digitalWrite(config.gpio_pin, initialState);
        
        LOG_INFO_CTX("RelayChannel", "Canal %d configurado: %s (GPIO %d, %s)", 
                     channelId, config.name.c_str(), config.gpio_pin, 
                     config.function_type.c_str());
        
        if (debugEnabled) {
            LOG_DEBUG_CTX("RelayChannel", "  - Lógica invertida: %s", 
                          config.inverted_logic ? "SIM" : "NÃO");
            LOG_DEBUG_CTX("RelayChannel", "  - Requer senha: %s", 
                          config.require_password ? "SIM" : "NÃO");
            LOG_DEBUG_CTX("RelayChannel", "  - Tempo máximo: %d ms", 
                          config.max_on_time_ms);
        }
        
    } else if (wasEnabled && oldPin != -1) {
        // Desabilitar GPIO anterior
        digitalWrite(oldPin, config.inverted_logic ? HIGH : LOW);
        LOG_INFO_CTX("RelayChannel", "Canal %d desabilitado (GPIO %d)", channelId, oldPin);
    }
    
    return true;
}

bool RelayChannel::turnOn(const String& user, const String& password, bool confirmation) {
    if (!canOperate(user, password, confirmation)) {
        return false;
    }
    
    if (state.current_state) {
        LOG_DEBUG_CTX("RelayChannel", "Canal %d já está ligado", channelId);
        return true;
    }
    
    // Verificar proteções específicas para ligar
    if (!validateTimeWindow()) {
        lastError = "Fora da janela de tempo permitida";
        return false;
    }
    
    // Definir estado
    state.current_state = true;
    state.last_state_change = millis();
    state.turn_on_time = millis();
    state.safety_shutoff_triggered = false;
    
    // Aplicar estado físico
    setPhysicalState(true);
    
    logStateChange(true, "comando_" + user);
    
    LOG_INFO_CTX("RelayChannel", "Canal %d LIGADO por %s", channelId, user.c_str());
    
    // Publicar estado
    mqttClient.publishRelayState(channelId, true);
    
    return true;
}

bool RelayChannel::turnOff(const String& user) {
    if (!config.enabled) {
        lastError = "Canal não habilitado";
        return false;
    }
    
    if (!state.current_state) {
        LOG_DEBUG_CTX("RelayChannel", "Canal %d já está desligado", channelId);
        return true;
    }
    
    // Definir estado
    state.current_state = false;
    state.last_state_change = millis();
    state.waiting_for_heartbeat = false;
    
    // Aplicar estado físico
    setPhysicalState(false);
    
    logStateChange(false, "comando_" + user);
    
    LOG_INFO_CTX("RelayChannel", "Canal %d DESLIGADO por %s", channelId, user.c_str());
    
    // Publicar estado
    mqttClient.publishRelayState(channelId, false);
    
    return true;
}

bool RelayChannel::toggle(const String& user, const String& password, bool confirmation) {
    if (!canOperate(user, password, confirmation)) {
        return false;
    }
    
    if (state.current_state) {
        return turnOff(user);
    } else {
        return turnOn(user, password, confirmation);
    }
}

bool RelayChannel::startMomentary(const String& user) {
    if (!canOperate(user)) {
        return false;
    }
    
    if (config.function_type != "momentary") {
        lastError = "Canal não configurado como momentâneo";
        return false;
    }
    
    // Ligar o relé
    if (!turnOn(user)) {
        return false;
    }
    
    // Marcar como esperando heartbeat
    state.waiting_for_heartbeat = true;
    state.last_heartbeat = millis();
    state.heartbeat_sequence = 0;
    
    LOG_INFO_CTX("RelayChannel", "Canal %d iniciado como momentâneo por %s", channelId, user.c_str());
    
    return true;
}

bool RelayChannel::stopMomentary() {
    if (!config.enabled) {
        lastError = "Canal não habilitado";
        return false;
    }
    
    if (config.function_type != "momentary") {
        lastError = "Canal não configurado como momentâneo";
        return false;
    }
    
    state.waiting_for_heartbeat = false;
    
    return turnOff("momentary_stop");
}

bool RelayChannel::processHeartbeat(int sequence, unsigned long timestamp) {
    if (!config.enabled || config.function_type != "momentary") {
        return false;
    }
    
    if (!state.waiting_for_heartbeat) {
        if (debugEnabled) {
            LOG_DEBUG_CTX("RelayChannel", "Canal %d não está esperando heartbeat", channelId);
        }
        return false;
    }
    
    // Atualizar heartbeat
    state.last_heartbeat = timestamp;
    state.heartbeat_sequence = sequence;
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("RelayChannel", "Canal %d heartbeat recebido: seq %d", channelId, sequence);
    }
    
    return true;
}

bool RelayChannel::checkSafetyShutoff() {
    if (!config.enabled || !state.current_state) {
        return false;
    }
    
    bool shutoffTriggered = false;
    String reason = "";
    
    // Verificar timeout de heartbeat para relés momentâneos
    if (config.function_type == "momentary" && state.waiting_for_heartbeat) {
        unsigned long now = millis();
        unsigned long timeSinceLastHeartbeat = now - state.last_heartbeat;
        
        if (timeSinceLastHeartbeat > HEARTBEAT_TIMEOUT_MS) {
            shutoffTriggered = true;
            reason = "heartbeat_timeout";
            
            LOG_WARN_CTX("RelayChannel", "Canal %d: Timeout de heartbeat (%lu ms)", 
                         channelId, timeSinceLastHeartbeat);
        }
    }
    
    // Verificar tempo máximo ligado
    if (!shutoffTriggered && config.max_on_time_ms > 0) {
        unsigned long onDuration = getOnDuration();
        if (onDuration > config.max_on_time_ms) {
            shutoffTriggered = true;
            reason = "max_on_time_exceeded";
            
            LOG_WARN_CTX("RelayChannel", "Canal %d: Tempo máximo excedido (%lu ms)", 
                         channelId, onDuration);
        }
    }
    
    // Verificar janela de tempo
    if (!shutoffTriggered && config.time_window_enabled) {
        if (!validateTimeWindow()) {
            shutoffTriggered = true;
            reason = "time_window_violation";
            
            LOG_WARN_CTX("RelayChannel", "Canal %d: Fora da janela de tempo permitida", channelId);
        }
    }
    
    // Executar safety shutoff se necessário
    if (shutoffTriggered) {
        state.safety_shutoff_triggered = true;
        
        // Desligar fisicamente
        setPhysicalState(false);
        state.current_state = false;
        state.waiting_for_heartbeat = false;
        
        // Publicar evento de segurança
        publishSafetyEvent("safety_shutoff", reason);
        
        // Publicar estado atualizado
        mqttClient.publishRelayState(channelId, false);
        
        LOG_ERROR_CTX("RelayChannel", "Canal %d: SAFETY SHUTOFF ativado - %s", channelId, reason.c_str());
        
        return true;
    }
    
    return false;
}

void RelayChannel::emergencyStop() {
    if (!config.enabled) return;
    
    LOG_WARN_CTX("RelayChannel", "Canal %d: EMERGENCY STOP", channelId);
    
    // Parar tudo imediatamente
    setPhysicalState(false);
    state.current_state = false;
    state.waiting_for_heartbeat = false;
    state.safety_shutoff_triggered = true;
    
    // Publicar evento
    publishSafetyEvent("emergency_stop", "manual_trigger");
    
    // Publicar estado
    mqttClient.publishRelayState(channelId, false);
}

void RelayChannel::resetSafetyFlags() {
    state.safety_shutoff_triggered = false;
    LOG_INFO_CTX("RelayChannel", "Canal %d: Flags de segurança resetadas", channelId);
}

bool RelayChannel::canOperate(const String& user, const String& password, bool confirmation) {
    if (!config.enabled) {
        lastError = "Canal não habilitado";
        return false;
    }
    
    // Verificar senha se necessária
    if (config.require_password && !validatePassword(password)) {
        lastError = "Senha incorreta ou não fornecida";
        return false;
    }
    
    // Verificar confirmação se necessária
    if (config.require_confirmation && !confirmation) {
        lastError = "Confirmação necessária";
        return false;
    }
    
    // Verificar ação dupla se configurada
    if (config.dual_action_enabled && !validateDualAction()) {
        lastError = "Ação dupla não validada";
        return false;
    }
    
    return true;
}

void RelayChannel::update() {
    if (!config.enabled) return;
    
    unsigned long now = millis();
    
    // Verificar a cada 100ms para heartbeat
    if (now - lastUpdate >= HEARTBEAT_CHECK_INTERVAL) {
        lastUpdate = now;
        
        // Verificar safety shutoff
        checkSafetyShutoff();
    }
}

bool RelayChannel::validateTimeWindow() {
    if (!config.time_window_enabled) {
        return true;
    }
    
    return isInTimeWindow();
}

bool RelayChannel::validateMaxOnTime() {
    if (config.max_on_time_ms == 0) {
        return true; // Sem limite
    }
    
    unsigned long onDuration = getOnDuration();
    return onDuration <= config.max_on_time_ms;
}

bool RelayChannel::validatePassword(const String& password) {
    if (!config.require_password) {
        return true;
    }
    
    if (config.password_hash.length() == 0) {
        return false; // Senha configurada mas hash vazio
    }
    
    // TODO: Implementar hash da senha fornecida e comparar
    // Por enquanto, comparação simples (INSEGURO para produção)
    return password == config.password_hash;
}

bool RelayChannel::validateDualAction() {
    // TODO: Implementar lógica de ação dupla
    // Por enquanto, sempre true
    return true;
}

void RelayChannel::setPhysicalState(bool state) {
    if (!config.enabled || config.gpio_pin == -1) {
        return;
    }
    
    // FASE 1: SIMULAÇÃO - NÃO ACIONAR HARDWARE
    /*
    // Aplicar lógica invertida se configurada
    bool physicalState = config.inverted_logic ? !state : state;
    digitalWrite(config.gpio_pin, physicalState ? HIGH : LOW);
    */
    
    // SIMULAÇÃO: Apenas log
    String physicalStateStr = config.inverted_logic ? 
                             (state ? "LOW" : "HIGH") : 
                             (state ? "HIGH" : "LOW");
    
    LOG_INFO_CTX("RelayChannel", "SIMULADO: Canal %d GPIO %d -> %s (%s)", 
                 channelId, config.gpio_pin, 
                 state ? "ON" : "OFF", 
                 physicalStateStr.c_str());
}

void RelayChannel::logStateChange(bool newState, const String& reason) {
    LOG_INFO_CTX("RelayChannel", "Canal %d: %s -> %s (%s)", 
                 channelId, 
                 state.current_state ? "ON" : "OFF",
                 newState ? "ON" : "OFF",
                 reason.c_str());
}

void RelayChannel::publishSafetyEvent(const String& event, const String& reason) {
    DynamicJsonDocument doc(256);
    doc["channel"] = channelId;
    doc["event"] = event;
    doc["reason"] = reason;
    doc["timestamp"] = millis();
    
    String payload;
    serializeJson(doc, payload);
    
    mqttClient.publishSafetyEvent(payload);
}

bool RelayChannel::isInTimeWindow() {
    // TODO: Implementar verificação de janela de tempo baseada na hora atual
    // Por enquanto, sempre dentro da janela
    return true;
}

unsigned long RelayChannel::getOnDuration() {
    if (!state.current_state || state.turn_on_time == 0) {
        return 0;
    }
    
    return millis() - state.turn_on_time;
}

String RelayChannel::getStatusJSON() {
    DynamicJsonDocument doc(512);
    
    doc["channel"] = channelId;
    doc["enabled"] = config.enabled;
    doc["name"] = config.name;
    doc["current_state"] = state.current_state;
    doc["function_type"] = config.function_type;
    doc["gpio_pin"] = config.gpio_pin;
    doc["last_state_change"] = state.last_state_change;
    doc["waiting_for_heartbeat"] = state.waiting_for_heartbeat;
    doc["safety_shutoff_triggered"] = state.safety_shutoff_triggered;
    
    if (state.current_state) {
        doc["on_duration"] = getOnDuration();
    }
    
    if (state.waiting_for_heartbeat) {
        doc["last_heartbeat"] = state.last_heartbeat;
        doc["heartbeat_sequence"] = state.heartbeat_sequence;
        doc["heartbeat_timeout"] = HEARTBEAT_TIMEOUT_MS;
    }
    
    String status;
    serializeJson(doc, status);
    return status;
}

String RelayChannel::getTelemetryJSON() {
    DynamicJsonDocument doc(256);
    
    doc["channel"] = channelId;
    doc["state"] = state.current_state;
    doc["timestamp"] = millis();
    
    if (state.current_state) {
        doc["on_duration"] = getOnDuration();
        
        if (config.max_on_time_ms > 0) {
            doc["remaining_time"] = config.max_on_time_ms - getOnDuration();
        }
    }
    
    if (state.waiting_for_heartbeat) {
        unsigned long timeSinceHeartbeat = millis() - state.last_heartbeat;
        doc["heartbeat_age"] = timeSinceHeartbeat;
        doc["heartbeat_timeout_remaining"] = HEARTBEAT_TIMEOUT_MS - timeSinceHeartbeat;
    }
    
    String telemetry;
    serializeJson(doc, telemetry);
    return telemetry;
}

void RelayChannel::printStatus() {
    LOG_INFO_CTX("RelayChannel", "=== STATUS CANAL %d ===", channelId);
    LOG_INFO_CTX("RelayChannel", "Nome: %s", config.name.c_str());
    LOG_INFO_CTX("RelayChannel", "Habilitado: %s", config.enabled ? "SIM" : "NÃO");
    if (config.enabled) {
        LOG_INFO_CTX("RelayChannel", "GPIO: %d", config.gpio_pin);
        LOG_INFO_CTX("RelayChannel", "Tipo: %s", config.function_type.c_str());
        LOG_INFO_CTX("RelayChannel", "Estado: %s", state.current_state ? "ON" : "OFF");
        
        if (state.current_state) {
            LOG_INFO_CTX("RelayChannel", "Ligado há: %lu ms", getOnDuration());
        }
        
        if (state.waiting_for_heartbeat) {
            unsigned long heartbeatAge = millis() - state.last_heartbeat;
            LOG_INFO_CTX("RelayChannel", "Aguardando heartbeat (último: %lu ms atrás)", heartbeatAge);
        }
        
        if (state.safety_shutoff_triggered) {
            LOG_INFO_CTX("RelayChannel", "⚠️  SAFETY SHUTOFF ATIVO");
        }
    }
    LOG_INFO_CTX("RelayChannel", "========================");
}