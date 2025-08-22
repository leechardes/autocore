/**
 * @file ComponentTemplate.cpp
 * @brief Implementação do template para novos componentes
 * @author AutoCore System
 * @version 1.0.0
 * @date 2025-01-18
 */

#include "ComponentTemplate.h"
#include <mbedtls/md5.h>

// Logger global externo
extern Logger* logger;

ComponentTemplate::ComponentTemplate(const String& id, const String& type, const String& version)
    : componentId(id), componentType(type), componentVersion(version) {
    logger = Logger::getInstance();
    logger->info("Creating component: " + type + " [" + id + "] v" + version);
    
    startTime = millis();
    lastActivity = startTime;
}

ComponentTemplate::~ComponentTemplate() {
    logger->info("Destroying component: " + componentType + " [" + componentId + "]");
    cleanup();
}

bool ComponentTemplate::initialize(JsonObject& config) {
    if (isInitialized) {
        logger->warning("Component already initialized: " + componentId);
        return true;
    }
    
    logger->info("Initializing component: " + componentId);
    
    try {
        // Salvar configuração
        this->config.clear();
        this->config.set(config);
        
        // Validar configuração
        if (!validateConfiguration()) {
            logger->error("Configuration validation failed: " + componentId);
            return false;
        }
        
        // Processar configuração específica
        JsonObject configObj = this->config.as<JsonObject>();
        if (!processConfiguration(configObj)) {
            logger->error("Configuration processing failed: " + componentId);
            return false;
        }
        
        // Gerar hash da configuração
        String configStr;
        serializeJson(this->config, configStr);
        configHash = createHash(configStr);
        
        // Configurar padrões
        setupDefaultConfig();
        
        // Inicializar recursos
        initializeResources();
        
        // Configurar event handlers
        setupEventHandlers();
        
        // Inicialização específica da subclasse
        if (!doInitialize()) {
            logger->error("Component-specific initialization failed: " + componentId);
            return false;
        }
        
        isInitialized = true;
        lastActivity = millis();
        
        logger->info("Component initialized successfully: " + componentId);
        return true;
        
    } catch (const std::exception& e) {
        logger->error("Exception during initialization: " + String(e.what()));
        return false;
    }
}

bool ComponentTemplate::start() {
    if (!isInitialized) {
        logger->error("Cannot start uninitialized component: " + componentId);
        return false;
    }
    
    if (isRunning) {
        logger->warning("Component already running: " + componentId);
        return true;
    }
    
    logger->info("Starting component: " + componentId);
    
    try {
        isRunning = true;
        lastActivity = millis();
        
        // Emitir evento de início
        JsonDocument eventData;
        JsonObject eventObj = eventData.to<JsonObject>();
        eventObj["component_id"] = componentId;
        eventObj["component_type"] = componentType;
        eventObj["timestamp"] = millis();
        
        emitEvent("component_started", eventObj);
        
        logger->info("Component started successfully: " + componentId);
        return true;
        
    } catch (const std::exception& e) {
        logger->error("Exception during start: " + String(e.what()));
        isRunning = false;
        return false;
    }
}

void ComponentTemplate::stop() {
    if (!isRunning) {
        logger->warning("Component not running: " + componentId);
        return;
    }
    
    logger->info("Stopping component: " + componentId);
    
    isRunning = false;
    
    // Emitir evento de parada
    JsonDocument eventData;
    JsonObject eventObj = eventData.to<JsonObject>();
    eventObj["component_id"] = componentId;
    eventObj["uptime"] = getUptime();
    eventObj["operations"] = operationCount;
    
    emitEvent("component_stopped", eventObj);
    
    logger->info("Component stopped: " + componentId);
}

bool ComponentTemplate::restart() {
    logger->info("Restarting component: " + componentId);
    
    stop();
    delay(100); // Pequena pausa
    
    return start();
}

void ComponentTemplate::loop() {
    if (!isInitialized || !isRunning || !isEnabled) {
        return;
    }
    
    try {
        // Atualizar métricas
        updateMetrics();
        
        // Operação principal da subclasse
        doOperation();
        
        // Atualizar última atividade
        lastActivity = millis();
        operationCount++;
        
    } catch (const std::exception& e) {
        handleError("Exception in loop: " + String(e.what()));
    }
}

void ComponentTemplate::cleanup() {
    logger->info("Cleaning up component: " + componentId);
    
    // Parar se estiver rodando
    if (isRunning) {
        stop();
    }
    
    // Cleanup específico da subclasse
    doCleanup();
    
    // Liberar recursos
    releaseResources();
    
    // Reset flags
    isInitialized = false;
    isRunning = false;
    
    // Limpar configuração
    config.clear();
    configHash = "";
    
    logger->debug("Component cleanup completed: " + componentId);
}

bool ComponentTemplate::updateConfiguration(JsonObject& newConfig) {
    logger->info("Updating configuration: " + componentId);
    
    // Gerar hash da nova configuração
    String newConfigStr;
    serializeJson(newConfig, newConfigStr);
    String newHash = createHash(newConfigStr);
    
    // Verificar se realmente mudou
    if (newHash == configHash) {
        logger->debug("Configuration unchanged: " + componentId);
        return true;
    }
    
    // Salvar configuração atual como backup
    JsonDocument oldConfig;
    oldConfig.set(config);
    
    try {
        // Aplicar nova configuração
        config.clear();
        config.set(newConfig);
        
        // Processar nova configuração
        JsonObject configObj = config.as<JsonObject>();
        if (!processConfiguration(configObj)) {
            logger->error("Failed to process new configuration: " + componentId);
            
            // Restaurar configuração anterior
            config.clear();
            config.set(oldConfig);
            return false;
        }
        
        // Atualizar hash
        configHash = newHash;
        
        // Reiniciar se estiver rodando
        if (isRunning) {
            restart();
        }
        
        logger->info("Configuration updated successfully: " + componentId);
        return true;
        
    } catch (const std::exception& e) {
        logger->error("Exception updating configuration: " + String(e.what()));
        
        // Restaurar configuração anterior
        config.clear();
        config.set(oldConfig);
        return false;
    }
}

JsonObject ComponentTemplate::getConfiguration() {
    return config.as<JsonObject>();
}

JsonDocument ComponentTemplate::getStatus() {
    JsonDocument status;
    JsonObject statusObj = status.to<JsonObject>();
    
    // Status básico
    statusObj["component_id"] = componentId;
    statusObj["component_type"] = componentType;
    statusObj["version"] = componentVersion;
    statusObj["initialized"] = isInitialized;
    statusObj["running"] = isRunning;
    statusObj["enabled"] = isEnabled;
    statusObj["healthy"] = isHealthy();
    
    // Métricas de tempo
    statusObj["uptime"] = getUptime();
    statusObj["last_activity"] = lastActivity;
    statusObj["uptime_formatted"] = formatUptime(getUptime());
    
    // Contadores
    statusObj["operations"] = operationCount;
    statusObj["errors"] = errorCount;
    
    // Memory info
    statusObj["free_heap"] = ESP.getFreeHeap();
    statusObj["min_free_heap"] = ESP.getMinFreeHeap();
    
    // Status específico da subclasse
    getComponentStatus(statusObj);
    
    return status;
}

JsonDocument ComponentTemplate::getMetrics() {
    JsonDocument metrics;
    JsonObject metricsObj = metrics.to<JsonObject>();
    
    metricsObj["component_id"] = componentId;
    metricsObj["operations_total"] = operationCount;
    metricsObj["errors_total"] = errorCount;
    metricsObj["uptime_seconds"] = getUptime() / 1000;
    
    // Taxa de operações (ops/sec)
    unsigned long uptimeSeconds = getUptime() / 1000;
    if (uptimeSeconds > 0) {
        metricsObj["operations_per_second"] = (float)operationCount / uptimeSeconds;
        metricsObj["error_rate"] = (float)errorCount / operationCount;
    }
    
    // Memory metrics
    metricsObj["heap_free"] = ESP.getFreeHeap();
    metricsObj["heap_size"] = ESP.getHeapSize();
    metricsObj["heap_usage_percent"] = (1.0f - (float)ESP.getFreeHeap() / ESP.getHeapSize()) * 100;
    
    return metrics;
}

JsonDocument ComponentTemplate::runDiagnostics() {
    JsonDocument diagnostics;
    JsonObject diagObj = diagnostics.to<JsonObject>();
    
    diagObj["component_id"] = componentId;
    diagObj["timestamp"] = millis();
    
    // Verificações básicas
    diagObj["initialized"] = isInitialized;
    diagObj["running"] = isRunning;
    diagObj["enabled"] = isEnabled;
    
    // Verificação de memória
    uint32_t freeHeap = ESP.getFreeHeap();
    diagObj["memory_ok"] = (freeHeap > 10000); // Pelo menos 10KB livre
    diagObj["memory_free"] = freeHeap;
    
    // Verificação de atividade
    unsigned long timeSinceActivity = millis() - lastActivity;
    diagObj["activity_ok"] = (timeSinceActivity < 60000); // Ativo nos últimos 60s
    diagObj["time_since_activity"] = timeSinceActivity;
    
    // Taxa de erro
    float errorRate = (operationCount > 0) ? (float)errorCount / operationCount : 0;
    diagObj["error_rate_ok"] = (errorRate < 0.05); // Menos de 5% de erro
    diagObj["error_rate"] = errorRate;
    
    // Status geral
    bool allOk = diagObj["memory_ok"].as<bool>() && 
                 diagObj["activity_ok"].as<bool>() && 
                 diagObj["error_rate_ok"].as<bool>() &&
                 isInitialized && isRunning;
    
    diagObj["overall_status"] = allOk ? "healthy" : "unhealthy";
    
    return diagnostics;
}

bool ComponentTemplate::isHealthy() {
    if (!isInitialized || !isRunning) {
        return false;
    }
    
    // Verificar memória
    if (ESP.getFreeHeap() < 10000) {
        return false;
    }
    
    // Verificar atividade recente
    if (millis() - lastActivity > 60000) {
        return false;
    }
    
    // Verificar taxa de erro
    if (operationCount > 0) {
        float errorRate = (float)errorCount / operationCount;
        if (errorRate > 0.05) { // Mais de 5% de erro
            return false;
        }
    }
    
    return true;
}

bool ComponentTemplate::processCommand(JsonObject& command) {
    String cmdType = command["type"];
    
    if (cmdType == "start") {
        return start();
    } else if (cmdType == "stop") {
        stop();
        return true;
    } else if (cmdType == "restart") {
        return restart();
    } else if (cmdType == "enable") {
        setEnabled(true);
        return true;
    } else if (cmdType == "disable") {
        setEnabled(false);
        return true;
    } else if (cmdType == "get_status") {
        JsonDocument status = getStatus();
        if (dataCallback) {
            JsonObject statusObj = status.as<JsonObject>();
            dataCallback(statusObj);
        }
        return true;
    } else if (cmdType == "update_config") {
        if (command.containsKey("config")) {
            JsonObject newConfig = command["config"];
            return updateConfiguration(newConfig);
        }
    }
    
    logger->warning("Unknown command type: " + cmdType + " for component: " + componentId);
    return false;
}

// Métodos privados

bool ComponentTemplate::validateConfiguration() {
    JsonObject configObj = config.as<JsonObject>();
    
    // Validações básicas
    if (!configObj.containsKey("enabled")) {
        configObj["enabled"] = true;
    }
    
    if (!configObj.containsKey("log_level")) {
        configObj["log_level"] = "info";
    }
    
    // Validar formato JSON
    String configStr;
    serializeJson(config, configStr);
    if (!isValidJson(configStr)) {
        logger->error("Invalid JSON configuration: " + componentId);
        return false;
    }
    
    return true;
}

void ComponentTemplate::setupDefaultConfig() {
    JsonObject configObj = config.as<JsonObject>();
    
    // Configurações padrão
    if (!configObj.containsKey("update_interval")) {
        configObj["update_interval"] = 1000; // 1 segundo
    }
    
    if (!configObj.containsKey("retry_count")) {
        configObj["retry_count"] = 3;
    }
    
    if (!configObj.containsKey("timeout")) {
        configObj["timeout"] = 5000; // 5 segundos
    }
}

void ComponentTemplate::initializeResources() {
    // Inicializar recursos básicos se necessário
    logger->debug("Initializing resources for: " + componentId);
}

void ComponentTemplate::setupEventHandlers() {
    // Configurar handlers básicos se necessário
    logger->debug("Setting up event handlers for: " + componentId);
}

void ComponentTemplate::updateMetrics() {
    // Atualizar métricas básicas
    // Implementação específica pode ser adicionada pela subclasse
}

void ComponentTemplate::handleError(const String& error) {
    errorCount++;
    logger->error("Component error [" + componentId + "]: " + error);
    
    if (errorCallback) {
        errorCallback(error);
    }
    
    // Emitir evento de erro
    JsonDocument errorData;
    JsonObject errorObj = errorData.to<JsonObject>();
    errorObj["component_id"] = componentId;
    errorObj["error"] = error;
    errorObj["error_count"] = errorCount;
    errorObj["timestamp"] = millis();
    
    emitEvent("component_error", errorObj);
}

void ComponentTemplate::emitEvent(const String& eventType, JsonObject& data) {
    if (eventCallback) {
        eventCallback(eventType, data);
    }
    
    logger->debug("Event emitted [" + componentId + "]: " + eventType);
}

void ComponentTemplate::releaseResources() {
    // Liberar recursos específicos
    logger->debug("Releasing resources for: " + componentId);
}

// Callbacks

void ComponentTemplate::setErrorCallback(std::function<void(const String&)> callback) {
    errorCallback = callback;
}

void ComponentTemplate::setEventCallback(std::function<void(const String&, JsonObject&)> callback) {
    eventCallback = callback;
}

void ComponentTemplate::setDataCallback(std::function<void(JsonObject&)> callback) {
    dataCallback = callback;
}

// Métodos estáticos utilitários

String ComponentTemplate::createHash(const String& data) {
    mbedtls_md5_context ctx;
    unsigned char output[16];
    
    mbedtls_md5_init(&ctx);
    mbedtls_md5_starts(&ctx);
    mbedtls_md5_update(&ctx, (const unsigned char*)data.c_str(), data.length());
    mbedtls_md5_finish(&ctx, output);
    mbedtls_md5_free(&ctx);
    
    String hash = "";
    for (int i = 0; i < 16; i++) {
        if (output[i] < 16) hash += "0";
        hash += String(output[i], HEX);
    }
    
    return hash;
}

bool ComponentTemplate::isValidJson(const String& jsonString) {
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, jsonString);
    return (error == DeserializationError::Ok);
}

JsonDocument ComponentTemplate::mergeJsonObjects(JsonObject& base, JsonObject& overlay) {
    JsonDocument merged;
    JsonObject mergedObj = merged.to<JsonObject>();
    
    // Copiar base
    for (JsonPair kv : base) {
        mergedObj[kv.key()] = kv.value();
    }
    
    // Sobrepor com overlay
    for (JsonPair kv : overlay) {
        mergedObj[kv.key()] = kv.value();
    }
    
    return merged;
}

String ComponentTemplate::formatUptime(unsigned long milliseconds) {
    unsigned long seconds = milliseconds / 1000;
    unsigned long minutes = seconds / 60;
    unsigned long hours = minutes / 60;
    unsigned long days = hours / 24;
    
    String result = "";
    
    if (days > 0) {
        result += String(days) + "d ";
    }
    if (hours % 24 > 0) {
        result += String(hours % 24) + "h ";
    }
    if (minutes % 60 > 0) {
        result += String(minutes % 60) + "m ";
    }
    if (result.isEmpty() || seconds % 60 > 0) {
        result += String(seconds % 60) + "s";
    }
    
    return result.trim();
}

// ComponentFactory implementation

static std::map<String, std::function<std::unique_ptr<ComponentTemplate>(const String&, JsonObject&)>> componentFactories;

std::unique_ptr<ComponentTemplate> ComponentFactory::createComponent(const String& type, const String& id, JsonObject& config) {
    auto it = componentFactories.find(type);
    if (it != componentFactories.end()) {
        return it->second(id, config);
    }
    
    logger->error("Unknown component type: " + type);
    return nullptr;
}

void ComponentFactory::registerComponentType(const String& type, std::function<std::unique_ptr<ComponentTemplate>(const String&, JsonObject&)> factory) {
    componentFactories[type] = factory;
    logger->info("Registered component type: " + type);
}

std::vector<String> ComponentFactory::getRegisteredTypes() {
    std::vector<String> types;
    for (const auto& pair : componentFactories) {
        types.push_back(pair.first);
    }
    return types;
}

// ComponentManager implementation

ComponentManager::ComponentManager() {
    logger = Logger::getInstance();
    logger->info("ComponentManager created");
}

ComponentManager::~ComponentManager() {
    cleanupAll();
    logger->info("ComponentManager destroyed");
}

void ComponentManager::addComponent(std::unique_ptr<ComponentTemplate> component) {
    if (component) {
        logger->info("Adding component to manager: " + component->getId());
        components.push_back(std::move(component));
    }
}

void ComponentManager::removeComponent(const String& componentId) {
    auto it = std::remove_if(components.begin(), components.end(),
        [&componentId](const std::unique_ptr<ComponentTemplate>& comp) {
            return comp->getId() == componentId;
        });
    
    if (it != components.end()) {
        logger->info("Removing component from manager: " + componentId);
        components.erase(it, components.end());
    }
}

ComponentTemplate* ComponentManager::getComponent(const String& componentId) {
    for (auto& component : components) {
        if (component->getId() == componentId) {
            return component.get();
        }
    }
    return nullptr;
}

bool ComponentManager::initializeAll() {
    logger->info("Initializing all components...");
    
    bool allSuccess = true;
    for (auto& component : components) {
        JsonObject emptyConfig;
        if (!component->initialize(emptyConfig)) {
            logger->error("Failed to initialize component: " + component->getId());
            allSuccess = false;
        }
    }
    
    logger->info("Component initialization completed. Success: " + String(allSuccess ? "true" : "false"));
    return allSuccess;
}

bool ComponentManager::startAll() {
    logger->info("Starting all components...");
    
    bool allSuccess = true;
    for (auto& component : components) {
        if (!component->start()) {
            logger->error("Failed to start component: " + component->getId());
            allSuccess = false;
        }
    }
    
    logger->info("Component startup completed. Success: " + String(allSuccess ? "true" : "false"));
    return allSuccess;
}

void ComponentManager::stopAll() {
    logger->info("Stopping all components...");
    
    for (auto& component : components) {
        component->stop();
    }
    
    logger->info("All components stopped");
}

void ComponentManager::loopAll() {
    for (auto& component : components) {
        component->loop();
    }
}

void ComponentManager::cleanupAll() {
    logger->info("Cleaning up all components...");
    
    for (auto& component : components) {
        component->cleanup();
    }
    
    components.clear();
    logger->info("All components cleaned up");
}

JsonDocument ComponentManager::getAllStatus() {
    JsonDocument status;
    JsonObject statusObj = status.to<JsonObject>();
    
    statusObj["component_count"] = components.size();
    statusObj["timestamp"] = millis();
    
    JsonArray componentsArray = statusObj.createNestedArray("components");
    
    for (auto& component : components) {
        JsonDocument compStatus = component->getStatus();
        componentsArray.add(compStatus);
    }
    
    return status;
}