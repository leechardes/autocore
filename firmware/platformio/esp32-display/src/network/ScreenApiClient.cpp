/**
 * @file ScreenApiClient.cpp
 * @brief Implementação do cliente API REST para configurações de telas
 * 
 * @author Sistema AutoCore
 * @version 2.0.0  
 * @date 2025-08-12
 */

#include "network/ScreenApiClient.h"
#include "core/Logger.h"
#include "models/DeviceModels.h"
#include "utils/DeviceUtils.h"

// Logger global declarado em main.cpp
extern Logger* logger;

ScreenApiClient::ScreenApiClient() {
    // Construir URL base das configurações
    baseUrl = String(API_PROTOCOL) + "://" + 
              String(API_SERVER) + ":" + 
              String(API_PORT) + 
              String(API_BASE_PATH);
              
    // Configurações de cache e timeout
    cacheTimeout = API_CACHE_TTL;
    cacheTimestamp = 0;
    lastHttpCode = 0;
    
    if (logger) {
        logger->info("ScreenApiClient: Initialized with base URL: " + baseUrl);
    }
}

ScreenApiClient::~ScreenApiClient() {
    // Cleanup HTTP client
    httpClient.end();
}

bool ScreenApiClient::begin() {
    // Configurar HTTPClient
    httpClient.setTimeout(API_TIMEOUT);
    httpClient.setReuse(true);
    httpClient.setUserAgent("AutoCore-HMI-v2.0.0");
    
    if (logger) {
        logger->info("ScreenApiClient: HTTP client configured");
    }
    
    // Testar conectividade inicial
    return testConnection();
}

bool ScreenApiClient::testConnection() {
    String url = buildUrl("/screens");
    
    if (logger) {
        logger->debug("ScreenApiClient: Testing connection to " + url);
    }
    
    httpClient.begin(url);
    
    // Adicionar headers de autenticação se habilitado
    if (API_USE_AUTH) {
        httpClient.addHeader("Authorization", "Bearer " + String(API_AUTH_TOKEN));
    }
    
    // Adicionar headers padrão
    httpClient.addHeader("Accept", "application/json");
    httpClient.addHeader("Content-Type", "application/json");
    
    lastHttpCode = httpClient.GET();
    httpClient.end();
    
    if (lastHttpCode == 200) {
        if (logger) {
            logger->info("ScreenApiClient: Connection test successful");
        }
        return true;
    }
    
    lastError = "Connection test failed. HTTP Code: " + String(lastHttpCode);
    if (logger) {
        logger->error("ScreenApiClient: " + lastError);
    }
    return false;
}

bool ScreenApiClient::loadConfiguration(JsonDocument& config) {
    return loadFullConfiguration(config);
}

bool ScreenApiClient::getScreens(JsonArray& screens) {
    String response;
    
    for (int attempt = 1; attempt <= API_RETRY_COUNT; attempt++) {
        if (makeHttpRequest("/screens", response)) {
            // Parse JSON response
            JsonDocument doc;
            DeserializationError error = deserializeJson(doc, response);
            
            if (error == DeserializationError::Ok) {
                // Verificar se é um array
                if (doc.is<JsonArray>()) {
                    // Copiar elementos para o array fornecido
                    for (JsonVariant v : doc.as<JsonArray>()) {
                        screens.add(v);
                    }
                    return true;
                } else {
                    lastError = "API response is not an array";
                }
            } else {
                lastError = "JSON parse error: " + String(error.c_str());
            }
        }
        
        if (logger) {
            logger->warning("ScreenApiClient: getScreens attempt " + String(attempt) + " failed: " + lastError);
        }
        
        if (attempt < API_RETRY_COUNT) {
            delay(API_RETRY_DELAY * attempt); // Exponential backoff
        }
    }
    
    return false;
}

bool ScreenApiClient::getScreenItems(int screenId, JsonArray& items) {
    String endpoint = "/screens/" + String(screenId) + "/items";
    String response;
    
    if (logger) {
        logger->debug("ScreenApiClient: Fetching items from endpoint: " + endpoint);
    }
    
    if (makeHttpRequest(endpoint, response)) {
        if (logger) {
            logger->debug("ScreenApiClient: Response received (" + String(response.length()) + " bytes)");
            // Log first 200 chars for debugging
            String preview = response.substring(0, 200);
            if (response.length() > 200) preview += "...";
            logger->debug("ScreenApiClient: Response preview: " + preview);
        }
        
        // Parse JSON response
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, response);
        
        if (error == DeserializationError::Ok) {
            // Verificar se é um array
            if (doc.is<JsonArray>()) {
                int itemCount = 0;
                // Copiar elementos para o array fornecido
                for (JsonVariant v : doc.as<JsonArray>()) {
                    items.add(v);
                    itemCount++;
                    
                    // Log primeiro item para debug
                    if (itemCount == 1 && logger) {
                        JsonObject firstItem = v.as<JsonObject>();
                        logger->debug("ScreenApiClient: First item - type: " + firstItem["item_type"].as<String>() + ", name: " + firstItem["name"].as<String>());
                    }
                }
                
                if (logger) {
                    logger->info("ScreenApiClient: Successfully parsed " + String(itemCount) + " items for screen " + String(screenId));
                }
                return true;
            } else {
                lastError = "Screen items response is not an array";
                if (logger) {
                    logger->error("ScreenApiClient: Response is not an array, got: " + String(doc.as<String>()));
                }
            }
        } else {
            lastError = "JSON parse error for screen items: " + String(error.c_str());
            if (logger) {
                logger->error("ScreenApiClient: JSON parse error: " + lastError);
            }
        }
    }
    
    if (logger) {
        logger->error("ScreenApiClient: Failed to load items for screen " + String(screenId) + ": " + lastError);
    }
    return false;
}

bool ScreenApiClient::makeHttpRequest(const String& endpoint, String& response) {
    String url = buildUrl(endpoint);
    
    if (logger) {
        logger->debug("ScreenApiClient: Making request to " + url);
    }
    
    httpClient.begin(url);
    
    // Headers de autenticação se habilitado
    if (API_USE_AUTH) {
        httpClient.addHeader("Authorization", "Bearer " + String(API_AUTH_TOKEN));
    }
    
    // Headers padrão
    httpClient.addHeader("Accept", "application/json");
    httpClient.addHeader("Content-Type", "application/json");
    httpClient.addHeader("User-Agent", "AutoCore-HMI-v2.0.0");
    
    lastHttpCode = httpClient.GET();
    
    if (lastHttpCode == 200) {
        response = httpClient.getString();
        httpClient.end();
        
        if (logger) {
            logger->debug("ScreenApiClient: Request successful, response size: " + String(response.length()) + " bytes");
        }
        return true;
    } else {
        httpClient.end();
        lastError = "HTTP error: " + String(lastHttpCode);
        
        // Logs mais detalhados para diferentes códigos de erro
        switch (lastHttpCode) {
            case -1:
                lastError += " (Connection failed)";
                break;
            case 404:
                lastError += " (Not Found)";
                break;
            case 500:
                lastError += " (Internal Server Error)";
                break;
            case 503:
                lastError += " (Service Unavailable)";
                break;
        }
        
        if (logger) {
            logger->debug("ScreenApiClient: Request failed: " + lastError);
        }
    }
    
    return false;
}

bool ScreenApiClient::isCacheValid() {
    if (cacheTimestamp == 0) return false;
    return (millis() - cacheTimestamp) < cacheTimeout;
}

void ScreenApiClient::clearCache() {
    cachedConfig.clear();
    cacheTimestamp = 0;
    if (logger) {
        logger->debug("ScreenApiClient: Cache cleared");
    }
}

String ScreenApiClient::buildUrl(const String& endpoint) {
    return baseUrl + endpoint;
}

void ScreenApiClient::setTimeout(unsigned long timeout) {
    httpClient.setTimeout(timeout);
    if (logger) {
        logger->debug("ScreenApiClient: Timeout set to " + String(timeout) + "ms");
    }
}

void ScreenApiClient::setCacheTTL(unsigned long ttl) {
    cacheTimeout = ttl;
    if (logger) {
        logger->debug("ScreenApiClient: Cache TTL set to " + String(ttl) + "ms");
    }
}

bool ScreenApiClient::getDevices(JsonArray& devices) {
    String url = buildUrl("/devices");
    Serial.printf("[API] Fetching devices from: %s\n", url.c_str());
    
    for (int attempt = 1; attempt <= API_RETRY_COUNT; attempt++) {
        httpClient.begin(url);
        
        if (API_USE_AUTH) {
            httpClient.addHeader("Authorization", "Bearer " + String(API_AUTH_TOKEN));
        }
        
        lastHttpCode = httpClient.GET();
        
        if (lastHttpCode == 200) {
            String response = httpClient.getString();
            httpClient.end();
            
            JsonDocument doc;
            DeserializationError error = deserializeJson(doc, response);
            
            if (error == DeserializationError::Ok) {
                JsonArray responseArray = doc.as<JsonArray>();
                Serial.printf("[API] Loaded %d devices\n", responseArray.size());
                
                for (JsonVariant v : responseArray) {
                    devices.add(v);
                }
                return true;
            }
            
            lastError = "JSON parse error: " + String(error.c_str());
        } else {
            httpClient.end();
            lastError = "HTTP error: " + String(lastHttpCode);
        }
        
        if (attempt < API_RETRY_COUNT) {
            delay(API_RETRY_DELAY * attempt);
        }
    }
    
    return false;
}

bool ScreenApiClient::getRelayBoards(JsonArray& boards) {
    String url = buildUrl("/relays/boards");
    Serial.printf("[API] Fetching relay boards from: %s\n", url.c_str());
    
    httpClient.begin(url);
    
    if (API_USE_AUTH) {
        httpClient.addHeader("Authorization", "Bearer " + String(API_AUTH_TOKEN));
    }
    
    lastHttpCode = httpClient.GET();
    
    if (lastHttpCode == 200) {
        String response = httpClient.getString();
        httpClient.end();
        
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, response);
        
        if (error == DeserializationError::Ok) {
            JsonArray responseArray = doc.as<JsonArray>();
            Serial.printf("[API] Loaded %d relay boards\n", responseArray.size());
            
            for (JsonVariant v : responseArray) {
                boards.add(v);
            }
            return true;
        }
        
        lastError = "JSON parse error: " + String(error.c_str());
    } else {
        httpClient.end();
        lastError = "HTTP error: " + String(lastHttpCode);
    }
    
    return false;
}

bool ScreenApiClient::loadFullConfiguration(JsonDocument& config) {
    // Check cache first
    if (isCacheValid() && !cachedConfig.isEmpty()) {
        DeserializationError error = deserializeJson(config, cachedConfig);
        if (error == DeserializationError::Ok) {
            if (logger) {
                logger->info("ScreenApiClient: Using cached full configuration");
            }
            return true;
        }
    }
    
    // Clear device registry before loading new data
    DeviceRegistry::getInstance()->clear();
    
    // Use unified endpoint /api/config/full/{device_uuid} for single request
    String deviceUUID = DeviceUtils::getDeviceUUID();
    String endpoint = "/config/full/" + deviceUUID;
    String response;
    
    if (logger) {
        logger->info("ScreenApiClient: Loading full configuration from unified endpoint: " + endpoint);
    }
    
    for (int attempt = 1; attempt <= API_RETRY_COUNT; attempt++) {
        if (makeHttpRequest(endpoint, response)) {
            if (logger) {
                logger->debug("ScreenApiClient: Received full config response (" + String(response.length()) + " bytes)");
            }
            
            // Parse unified response
            JsonDocument fullResponse;
            DeserializationError error = deserializeJson(fullResponse, response);
            
            if (error == DeserializationError::Ok) {
                // Process unified response structure
                if (processUnifiedResponse(fullResponse, config)) {
                    // Cache the result
                    cachedConfig.clear();
                    serializeJson(config, cachedConfig);
                    cacheTimestamp = millis();
                    
                    if (logger) {
                        logger->info("ScreenApiClient: Full configuration loaded successfully from unified endpoint");
                        logger->info("ScreenApiClient: Performance improvement - Single request vs multiple requests");
                    }
                    return true;
                }
            } else {
                lastError = "JSON parse error in unified response: " + String(error.c_str());
                if (logger) {
                    logger->error("ScreenApiClient: " + lastError);
                }
            }
        }
        
        if (logger) {
            logger->warning("ScreenApiClient: Unified endpoint attempt " + String(attempt) + " failed: " + lastError);
        }
        
        if (attempt < API_RETRY_COUNT) {
            delay(API_RETRY_DELAY * attempt); // Exponential backoff
        }
    }
    
    // Fallback to legacy multiple requests if unified endpoint fails
    // COMENTADO: Por enquanto, não usar fallback para múltiplas requisições
    // if (logger) {
    //     logger->warning("ScreenApiClient: Unified endpoint failed, falling back to legacy multiple requests");
    // }
    // 
    // return loadLegacyConfiguration(config);
    
    // Retornar falha se o endpoint unificado falhar
    if (logger) {
        logger->error("ScreenApiClient: Failed to load configuration from unified endpoint");
    }
    return false;
}

bool ScreenApiClient::processUnifiedResponse(const JsonDocument& response, JsonDocument& config) {
    if (logger) {
        logger->debug("ScreenApiClient: Processing unified API response");
    }
    
    // Validate response structure
    if (!response["version"].is<String>() || !response["protocol_version"].is<String>()) {
        lastError = "Invalid unified response structure - missing version fields";
        return false;
    }
    
    // Simply copy the response elements to config for now
    config["version"] = response["version"];
    config["protocol_version"] = response["protocol_version"];
    
    if (response["devices"]) {
        config["devices"] = response["devices"];
    }
    
    if (response["relay_boards"]) {
        config["relay_boards"] = response["relay_boards"];
    }
    
    if (response["screens"]) {
        config["screens"] = response["screens"];
    }
    
    if (response["theme"]) {
        config["theme"] = response["theme"];
    }
    
    if (response["system"]) {
        config["system"] = response["system"];
    }
    
    if (response["icons"]) {
        config["icons"] = response["icons"];
    }
    
    config["source"] = "api_unified";
    config["timestamp"] = millis();
    
    if (logger) {
        logger->info("ScreenApiClient: Successfully processed unified response");
    }
    
    return true;
}

bool ScreenApiClient::loadLegacyConfiguration(JsonDocument& config) {
    if (logger) {
        logger->info("ScreenApiClient: Loading configuration using legacy multiple requests");
    }
    
    // 1. Load devices
    JsonDocument devicesDoc;
    JsonArray devicesArray = devicesDoc.to<JsonArray>();
    if (getDevices(devicesArray)) {
        // Populate device registry
        for (JsonObject device : devicesArray) {
            DeviceInfo info(
                device["id"].as<uint8_t>(),
                device["uuid"].as<String>(),
                device["type"].as<String>(),
                device["name"].as<String>()
            );
            DeviceRegistry::getInstance()->addDevice(info);
        }
        if (logger) {
            logger->debug("ScreenApiClient: Legacy - Registered " + String(DeviceRegistry::getInstance()->getDeviceCount()) + " devices");
        }
    }
    
    // 2. Load relay boards
    JsonDocument boardsDoc;
    JsonArray boardsArray = boardsDoc.to<JsonArray>();
    if (getRelayBoards(boardsArray)) {
        // Populate relay board registry
        for (JsonObject board : boardsArray) {
            RelayBoardInfo info(
                board["id"].as<uint8_t>(),
                board["device_id"].as<uint8_t>(),
                board["name"].as<String>(),
                board["total_channels"].as<uint8_t>()
            );
            DeviceRegistry::getInstance()->addRelayBoard(info);
        }
        if (logger) {
            logger->debug("ScreenApiClient: Legacy - Registered " + String(DeviceRegistry::getInstance()->getRelayBoardCount()) + " relay boards");
        }
    }
    
    // 3. Load screens
    JsonDocument screensDoc;
    JsonArray screensArray = screensDoc["screens"].to<JsonArray>();
    
    if (!getScreens(screensArray)) {
        return false;
    }
    
    // For each screen, load its items
    for (JsonObject screen : screensArray) {
        int screenId = screen["id"];
        // Try new API format first (items), fallback to legacy (screen_items)
        JsonArray items;
        if (screen["items"].is<JsonArray>()) {
            items = screen["items"].to<JsonArray>();
        } else if (screen["screen_items"].is<JsonArray>()) {
            items = screen["screen_items"].to<JsonArray>();
            if (logger) {
                logger->warning("ScreenApiClient: Using deprecated 'screen_items' field for screen " + String(screenId));
            }
        }
        
        if (!getScreenItems(screenId, items)) {
            if (logger) {
                logger->warning("ScreenApiClient: Legacy - Failed to load items for screen " + String(screenId));
            }
        }
    }
    
    // Build final configuration
    config["version"] = "2.0.0";
    config["screens"] = screensArray;
    config["devices"] = devicesArray;
    config["relay_boards"] = boardsArray;
    config["source"] = "api_legacy";
    config["timestamp"] = millis();
    
    // Cache the result
    cachedConfig.clear();
    serializeJson(config, cachedConfig);
    cacheTimestamp = millis();
    
    if (logger) {
        logger->info("ScreenApiClient: Legacy configuration loaded successfully");
        logger->warning("ScreenApiClient: Consider upgrading backend to support unified endpoint for better performance");
    }
    
    return true;
}

bool ScreenApiClient::getIcons(JsonDocument& icons) {
    String endpoint = "/icons?platform=esp32";
    String response;
    
    if (logger) {
        logger->debug("ScreenApiClient: Fetching icons from endpoint: " + endpoint);
    }
    
    if (makeHttpRequest(endpoint, response)) {
        DeserializationError error = deserializeJson(icons, response);
        
        if (error == DeserializationError::Ok) {
            if (logger) {
                logger->info("ScreenApiClient: Successfully loaded icon mappings for ESP32 platform");
            }
            return true;
        } else {
            lastError = "JSON parse error for icons: " + String(error.c_str());
            if (logger) {
                logger->error("ScreenApiClient: " + lastError);
            }
        }
    }
    
    return false;
}

bool ScreenApiClient::getThemes(JsonDocument& themes) {
    String response;
    
    if (makeHttpRequest("/themes", response)) {
        DeserializationError error = deserializeJson(themes, response);
        
        if (error == DeserializationError::Ok) {
            if (logger) {
                logger->debug("ScreenApiClient: Successfully loaded themes");
            }
            return true;
        } else {
            lastError = "JSON parse error for themes: " + String(error.c_str());
            if (logger) {
                logger->error("ScreenApiClient: " + lastError);
            }
        }
    }
    
    return false;
}

bool ScreenApiClient::parseScreensResponse(const String& response, JsonDocument& doc) {
    DeserializationError error = deserializeJson(doc, response);
    
    if (error != DeserializationError::Ok) {
        lastError = "JSON parse error in screens response: " + String(error.c_str());
        if (logger) {
            logger->error("ScreenApiClient: " + lastError);
        }
        return false;
    }
    
    if (!doc.is<JsonArray>()) {
        lastError = "Screens response is not an array";
        if (logger) {
            logger->error("ScreenApiClient: " + lastError);
        }
        return false;
    }
    
    if (logger) {
        logger->debug("ScreenApiClient: Successfully parsed screens response with " + 
                     String(doc.as<JsonArray>().size()) + " screens");
    }
    
    return true;
}

bool ScreenApiClient::parseItemsResponse(const String& response, JsonArray& items) {
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, response);
    
    if (error != DeserializationError::Ok) {
        lastError = "JSON parse error in items response: " + String(error.c_str());
        if (logger) {
            logger->error("ScreenApiClient: " + lastError);
        }
        return false;
    }
    
    if (!doc.is<JsonArray>()) {
        lastError = "Items response is not an array";
        if (logger) {
            logger->error("ScreenApiClient: " + lastError);
        }
        return false;
    }
    
    // Copiar elementos para o array fornecido
    JsonArray responseArray = doc.as<JsonArray>();
    for (JsonVariant v : responseArray) {
        items.add(v);
    }
    
    if (logger) {
        logger->debug("ScreenApiClient: Successfully parsed items response with " + 
                     String(items.size()) + " items");
    }
    
    return true;
}