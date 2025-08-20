/**
 * @file ConfigReceiver.cpp
 * @brief Implementação do receptor de configuração com suporte API REST + MQTT
 * 
 * Versão 2.0 - Migração para API REST:
 * - Carregamento primário via API HTTP
 * - Fallback automático para MQTT se API falhar
 * - Hot-reload via MQTT mantido
 * - Cache e retry automáticos
 */

#include "communication/ConfigReceiver.h"
#include "core/MQTTProtocol.h"
#include "core/Logger.h"
#include <ArduinoJson.h>

extern Logger* logger;

ConfigReceiver* ConfigReceiver::instance = nullptr;

ConfigReceiver::ConfigReceiver(MQTTClient* mqtt, ConfigManager* config, ScreenApiClient* api) 
    : mqttClient(mqtt), configManager(config), apiClient(api),
      useApi(false), configReceived(false), onConfigUpdateCallback(nullptr) {
    
    instance = this;
    
    // Setup MQTT topics (apenas hot-reload)
    updateTopic = "autocore/system/config/update";  // Broadcast topic for updates
    
    // Verificar se API client está disponível
    if (apiClient) {
        useApi = true;
        if (logger) {
            logger->info("ConfigReceiver: Initialized with API support");
        }
    } else {
        if (logger) {
            logger->warning("ConfigReceiver: No API client, will use MQTT only");
        }
    }
}

ConfigReceiver::~ConfigReceiver() {
    instance = nullptr;
}

void ConfigReceiver::begin() {
    if (logger) {
        logger->info("ConfigReceiver: Starting v2.0 with API support...");
    }
    
    // Subscribe apenas ao hot-reload topic
    mqttClient->subscribe(updateTopic, 0, onConfigUpdate);
    
    if (logger) {
        logger->info("ConfigReceiver: Hot reload enabled on " + updateTopic);
        logger->info("ConfigReceiver: Using " + String(useApi ? "API" : "MQTT") + " as primary configuration source");
    }
}

void ConfigReceiver::setApiClient(ScreenApiClient* client) {
    apiClient = client;
    useApi = (client != nullptr);
    
    if (logger) {
        logger->info("ConfigReceiver: API client " + String(useApi ? "enabled" : "disabled"));
    }
}

bool ConfigReceiver::loadFromApi() {
    if (!apiClient) {
        if (logger) {
            logger->error("ConfigReceiver: API client not set");
        }
        return false;
    }
    
    if (logger) {
        logger->info("ConfigReceiver: Loading configuration from API...");
    }
    
    JsonDocument config;
    
    // Tentar carregar da API com retries automáticos
    for (int attempt = 1; attempt <= API_RETRY_COUNT; attempt++) {
        if (apiClient->loadConfiguration(config)) {
            // Converter para string para o ConfigManager
            String configStr;
            serializeJson(config, configStr);
            
            if (configManager->loadConfig(configStr)) {
                if (logger) {
                    logger->info("ConfigReceiver: Configuration loaded from API on attempt " + String(attempt));
                }
                configReceived = true;
                
                // Enviar acknowledgment via MQTT
                sendConfigAck("api", "success");
                return true;
            } else {
                if (logger) {
                    logger->error("ConfigReceiver: ConfigManager rejected API config");
                }
            }
        }
        
        if (logger) {
            logger->warning("ConfigReceiver: API attempt " + String(attempt) + " failed: " + apiClient->getLastError());
        }
        
        if (attempt < API_RETRY_COUNT) {
            delay(API_RETRY_DELAY * attempt); // Exponential backoff
        }
    }
    
    // API falhou completamente
    if (logger) {
        logger->error("ConfigReceiver: API failed after " + String(API_RETRY_COUNT) + " attempts");
    }
    
    sendConfigAck("api", "failed");
    return false;
}

bool ConfigReceiver::loadFromMqtt() {
    if (logger) {
        logger->info("ConfigReceiver: Loading configuration from MQTT fallback...");
    }
    
    // Reset state
    configReceived = false;
    
    // Subscribe to legacy MQTT config topics  
    String deviceId = mqttClient->getDeviceId();
    String configTopic = "autocore/" + deviceId + "/config";
    String requestTopic = "autocore/gateway/config/request";
    String responseTopic = "autocore/gateway/config/response";
    
    // Subscribe temporariamente
    mqttClient->subscribe(configTopic, 0, onConfigReceived);
    mqttClient->subscribe(responseTopic, 0, onConfigReceived);
    
    // Enviar request
    requestConfigMqtt();
    
    // Aguardar resposta com timeout
    unsigned long startTime = millis();
    unsigned long timeout = CONFIG_REQUEST_INTERVAL;
    
    while (!configReceived && (millis() - startTime) < timeout) {
        delay(100);
        // Permitir processing de outros tasks
        yield();
    }
    
    // Cleanup subscriptions
    mqttClient->unsubscribe(configTopic);
    mqttClient->unsubscribe(responseTopic);
    
    if (configReceived) {
        if (logger) {
            logger->info("ConfigReceiver: Configuration loaded from MQTT successfully");
        }
        sendConfigAck("mqtt", "success");
        return true;
    } else {
        if (logger) {
            logger->error("ConfigReceiver: MQTT configuration timeout after " + String(timeout) + "ms");
        }
        sendConfigAck("mqtt", "timeout");
        return false;
    }
}

void ConfigReceiver::requestConfigMqtt() {
    if (logger) {
        logger->info("ConfigReceiver: Requesting configuration from MQTT gateway...");
    }
    
    // Create request message (formato esperado pelo gateway)
    JsonDocument doc;
    MQTTProtocol::addProtocolFields(doc);  // Adiciona version, uuid, timestamp
    doc["device_id"] = mqttClient->getDeviceId();
    doc["request"] = "full_config";
    doc["source"] = "api_fallback"; // Indicar que é fallback da API
    
    String payload;
    serializeJson(doc, payload);
    
    String requestTopic = "autocore/gateway/config/request";
    
    if (logger) {
        logger->debug("ConfigReceiver: MQTT request payload: " + payload);
    }
    
    if (mqttClient->publish(requestTopic, payload)) {
        if (logger) {
            logger->info("ConfigReceiver: MQTT config request sent successfully");
        }
    } else {
        if (logger) {
            logger->error("ConfigReceiver: Failed to send MQTT config request");
        }
    }
}

bool ConfigReceiver::loadConfiguration() {
    if (logger) {
        logger->info("ConfigReceiver: Starting configuration load sequence...");
    }
    
    // Tentar API primeiro se disponível
    if (useApi && apiClient) {
        if (loadFromApi()) {
            return true;
        }
        
        if (logger) {
            logger->warning("ConfigReceiver: API failed, trying MQTT fallback...");
        }
    }
    
    // Fallback para MQTT
    if (loadFromMqtt()) {
        return true;
    }
    
    // Ambos falharam
    if (logger) {
        logger->error("ConfigReceiver: Both API and MQTT failed to load configuration");
    }
    
    return false;
}

bool ConfigReceiver::testApiConnection() {
    if (!apiClient) {
        return false;
    }
    
    return apiClient->testConnection();
}

void ConfigReceiver::onConfigReceived(const String& topic, const String& payload) {
    if (!instance) return;
    
    if (logger) {
        logger->info("ConfigReceiver: MQTT message received on topic: " + topic);
        logger->debug("ConfigReceiver: Payload size: " + String(payload.length()) + " bytes");
    }
    
    instance->handleMqttConfigMessage(payload);
}

void ConfigReceiver::onConfigUpdate(const String& topic, const String& payload) {
    if (!instance) return;
    
    if (logger) {
        logger->info("ConfigReceiver: Hot reload update received via MQTT");
    }
    
    instance->handleConfigUpdate(payload);
}

void ConfigReceiver::handleMqttConfigMessage(const String& payload) {
    if (logger) {
        logger->info("ConfigReceiver: Processing MQTT configuration message");
    }
    
    // Parse response to extract config
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, payload);
    
    if (error) {
        if (logger) {
            logger->error("ConfigReceiver: Failed to parse MQTT config: " + String(error.c_str()));
        }
        return;
    }
    
    // Gateway sends config inside a "config" field
    String configStr;
    if (doc["config"].is<JsonObject>()) {
        if (logger) {
            logger->debug("ConfigReceiver: Found config object in MQTT message");
        }
        serializeJson(doc["config"], configStr);
    } else {
        if (logger) {
            logger->debug("ConfigReceiver: Using entire MQTT payload as config");
        }
        configStr = payload;
    }
    
    // Try to load configuration
    if (configManager->loadConfig(configStr)) {
        if (logger) {
            logger->info("ConfigReceiver: MQTT configuration loaded successfully!");
        }
        configReceived = true;
    } else {
        if (logger) {
            logger->error("ConfigReceiver: Failed to load MQTT configuration");
        }
    }
}

void ConfigReceiver::enableHotReload(std::function<void()> callback) {
    onConfigUpdateCallback = callback;
    if (logger) {
        logger->info("ConfigReceiver: Hot reload callback registered");
    }
}

void ConfigReceiver::handleConfigUpdate(const String& payload) {
    // Parse update message
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, payload);
    
    if (error) {
        if (logger) {
            logger->error("ConfigReceiver: Failed to parse update message: " + String(error.c_str()));
        }
        return;
    }
    
    // Check if update is for this device or all devices
    if (doc["target"].is<JsonVariant>()) {
        String target = doc["target"].as<String>();
        if (target != "all" && target != mqttClient->getDeviceId()) {
            if (logger) {
                logger->debug("ConfigReceiver: Update not for this device, ignoring");
            }
            return;
        }
    }
    
    // Handle different types of updates
    if (doc["command"].is<JsonVariant>()) {
        String command = doc["command"].as<String>();
        
        if (command == "reload") {
            if (logger) {
                logger->info("ConfigReceiver: Reload command received, reloading from primary source...");
            }
            
            // Use the combined method to try API first, then MQTT
            if (loadConfiguration() && onConfigUpdateCallback) {
                onConfigUpdateCallback();
            }
            
        } else if (command == "clear_cache" && apiClient) {
            if (logger) {
                logger->info("ConfigReceiver: Clear cache command received");
            }
            apiClient->clearCache();
            
        } else if (command == "switch_to_mqtt") {
            if (logger) {
                logger->info("ConfigReceiver: Switch to MQTT command received");
            }
            useApi = false;
            
        } else if (command == "switch_to_api" && apiClient) {
            if (logger) {
                logger->info("ConfigReceiver: Switch to API command received");
            }
            useApi = true;
        }
    }
    
    // Handle direct config updates
    else if (doc["config"].is<JsonVariant>()) {
        // Full configuration update via MQTT
        String configStr;
        serializeJson(doc["config"], configStr);
        
        if (logger) {
            logger->info("ConfigReceiver: Applying direct configuration update via MQTT...");
        }
        
        if (configManager->loadConfig(configStr)) {
            if (logger) {
                logger->info("ConfigReceiver: Configuration updated successfully via hot reload!");
            }
            
            configReceived = true;
            
            // Call the update callback if registered
            if (onConfigUpdateCallback) {
                onConfigUpdateCallback();
            }
            
            sendConfigAck("mqtt_hotreload", "success");
        } else {
            if (logger) {
                logger->error("ConfigReceiver: Failed to apply hot reload configuration");
            }
            sendConfigAck("mqtt_hotreload", "failed");
        }
    }
}

void ConfigReceiver::sendConfigAck(const String& source, const String& status) {
    // Send acknowledgment via MQTT
    JsonDocument ack;
    MQTTProtocol::addProtocolFields(ack);  // Adiciona version, uuid, timestamp
    ack["device_id"] = mqttClient->getDeviceId();
    ack["type"] = "config_ack";
    ack["source"] = source;
    ack["status"] = status;
    ack["version"] = configManager->getVersion();
    ack["using_api"] = useApi;
    
    String ackPayload;
    serializeJson(ack, ackPayload);
    
    String ackTopic = "autocore/system/config/ack";
    mqttClient->publish(ackTopic, ackPayload);
    
    if (logger) {
        logger->debug("ConfigReceiver: Sent config ACK - source: " + source + ", status: " + status);
    }
}