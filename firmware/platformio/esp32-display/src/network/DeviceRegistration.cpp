/**
 * @file DeviceRegistration.cpp
 * @brief Implementação do sistema de registro automático de dispositivos
 * 
 * @author Sistema AutoCore
 * @version 2.0.0
 * @date 2025-08-17
 */

#include "network/DeviceRegistration.h"
#include "utils/DeviceUtils.h"
#include "config/DeviceConfig.h"
#include "core/Logger.h"
#include <WiFi.h>
#include <esp_system.h>

// Logger global declarado em main.cpp
extern Logger* logger;

// Constantes
static const char* NVS_NAMESPACE = "device_reg";
static const char* KEY_MQTT_BROKER = "mqtt_broker";
static const char* KEY_MQTT_PORT = "mqtt_port";
static const char* KEY_MQTT_USER = "mqtt_user";
static const char* KEY_MQTT_PASS = "mqtt_pass";
static const char* KEY_MQTT_PREFIX = "mqtt_prefix";
static const char* KEY_REG_TIME = "reg_time";

// Cache de 24 horas em segundos
static const unsigned long REGISTRATION_CACHE_TTL = 24 * 60 * 60;

bool DeviceRegistration::performSmartRegistration() {
    if (logger) {
        logger->info("DeviceRegistration: Iniciando smart registration");
    }
    
    // Verificar se registro ainda é válido
    if (isRegistrationValid()) {
        if (logger) {
            logger->info("DeviceRegistration: Registro ainda válido, usando cache");
        }
        return true;
    }
    
    String deviceId = DeviceUtils::getDeviceUUID();
    if (deviceId.isEmpty()) {
        if (logger) {
            logger->error("DeviceRegistration: Falha ao obter UUID do dispositivo");
        }
        return false;
    }
    
    if (logger) {
        logger->info("DeviceRegistration: Verificando dispositivo: " + deviceId);
    }
    
    // Verificar se dispositivo existe
    bool deviceExists = checkDeviceExists(deviceId);
    
    // Se não existe, registrar
    if (!deviceExists) {
        if (logger) {
            logger->info("DeviceRegistration: Dispositivo não encontrado, registrando...");
        }
        
        if (!registerDevice(deviceId)) {
            if (logger) {
                logger->error("DeviceRegistration: Falha ao registrar dispositivo");
            }
            return false;
        }
        
        if (logger) {
            logger->info("DeviceRegistration: Dispositivo registrado com sucesso");
        }
    } else {
        if (logger) {
            logger->info("DeviceRegistration: Dispositivo já existe, atualizando informações de rede");
        }
        
        // Atualizar informações de rede se dispositivo já existe
        updateDeviceNetworkInfo(deviceId);
    }
    
    // Obter credenciais MQTT
    MQTTCredentials credentials;
    if (!fetchMQTTConfig(credentials)) {
        if (logger) {
            logger->warning("DeviceRegistration: Falha ao obter credenciais MQTT, usando configuração estática");
        }
        return false;
    }
    
    // Salvar credenciais e timestamp
    if (saveMQTTCredentials(credentials)) {
        saveRegistrationTime();
        
        if (logger) {
            logger->info("DeviceRegistration: Smart registration concluído com sucesso");
            logger->debug("DeviceRegistration: MQTT Broker: " + credentials.broker_host + ":" + String(credentials.broker_port));
        }
        
        return true;
    }
    
    if (logger) {
        logger->error("DeviceRegistration: Falha ao salvar credenciais MQTT");
    }
    return false;
}

bool DeviceRegistration::isRegistrationValid() {
    Preferences prefs;
    if (!prefs.begin(NVS_NAMESPACE, true)) {
        return false;
    }
    
    unsigned long lastRegTime = prefs.getULong(KEY_REG_TIME, 0);
    prefs.end();
    
    if (lastRegTime == 0) {
        return false;
    }
    
    unsigned long currentTime = esp_timer_get_time() / 1000000; // Converter para segundos
    unsigned long timeDiff = currentTime - lastRegTime;
    
    return timeDiff < REGISTRATION_CACHE_TTL;
}

bool DeviceRegistration::loadMQTTCredentials(MQTTCredentials& creds) {
    Preferences prefs;
    if (!prefs.begin(NVS_NAMESPACE, true)) {
        if (logger) {
            logger->error("DeviceRegistration: Falha ao abrir NVS para leitura");
        }
        return false;
    }
    
    creds.broker_host = prefs.getString(KEY_MQTT_BROKER, "");
    creds.broker_port = prefs.getUShort(KEY_MQTT_PORT, 0);
    creds.username = prefs.getString(KEY_MQTT_USER, "");
    creds.password = prefs.getString(KEY_MQTT_PASS, "");
    creds.topic_prefix = prefs.getString(KEY_MQTT_PREFIX, "");
    
    prefs.end();
    
    // Verificar se credenciais são válidas
    bool valid = !creds.broker_host.isEmpty() && creds.broker_port > 0;
    
    if (valid && logger) {
        logger->debug("DeviceRegistration: Credenciais MQTT carregadas do cache");
    }
    
    return valid;
}

bool DeviceRegistration::checkDeviceExists(const String& deviceId) {
    // Endpoint: GET /api/devices/{device_identifier}
    String url = buildApiUrl("/devices/" + deviceId);
    String response;
    
    if (logger) {
        logger->debug("DeviceRegistration: Verificando existência do dispositivo: " + url);
    }
    
    if (makeHttpRequest(url, "GET", "", response)) {
        // Se retornou 200, dispositivo existe
        if (logger) {
            logger->debug("DeviceRegistration: Dispositivo encontrado na API");
        }
        return true;
    }
    
    // Se retornou erro, dispositivo não existe
    if (logger) {
        logger->debug("DeviceRegistration: Dispositivo não encontrado na API");
    }
    return false;
}

bool DeviceRegistration::registerDevice(const String& deviceId) {
    String url = buildApiUrl("/devices");
    
    // Construir payload de registro
    StaticJsonDocument<1024> doc;
    doc["uuid"] = deviceId;
    
    // Gerar nome baseado no MAC
    String macHex = DeviceUtils::getMACAddressHex(true);
    String deviceName = "ESP32-Display-" + macHex.substring(macHex.length() - 6);
    doc["name"] = deviceName;
    
    doc["type"] = "hmi_display";
    doc["mac_address"] = DeviceUtils::getMACAddress();
    doc["ip_address"] = WiFi.localIP().toString();
    doc["firmware_version"] = DEVICE_VERSION;
    doc["hardware_version"] = "ESP32-2432S028R";
    
    // Informações do display
    JsonObject displayInfo = doc["display_info"].to<JsonObject>();
    displayInfo["width"] = SCREEN_WIDTH;
    displayInfo["height"] = SCREEN_HEIGHT;
    displayInfo["touch"] = true;
    
    String payload;
    serializeJson(doc, payload);
    
    if (logger) {
        logger->debug("DeviceRegistration: Registrando dispositivo: " + url);
        logger->debug("DeviceRegistration: Payload: " + payload);
    }
    
    String response;
    return makeHttpRequest(url, "POST", payload, response);
}

bool DeviceRegistration::fetchMQTTConfig(MQTTCredentials& credentials) {
    String url = buildApiUrl("/mqtt/config");
    String response;
    
    if (logger) {
        logger->debug("DeviceRegistration: Obtendo configuração MQTT: " + url);
    }
    
    if (!makeHttpRequest(url, "GET", "", response)) {
        if (logger) {
            logger->error("DeviceRegistration: Falha na requisição de configuração MQTT");
        }
        return false;
    }
    
    // Parse da resposta JSON
    StaticJsonDocument<512> doc;
    DeserializationError error = deserializeJson(doc, response);
    
    if (error) {
        if (logger) {
            logger->error("DeviceRegistration: Falha ao parsear resposta MQTT: " + String(error.c_str()));
        }
        return false;
    }
    
    // Extrair credenciais
    credentials.broker_host = doc["broker_host"].as<String>();
    credentials.broker_port = doc["broker_port"].as<uint16_t>();
    credentials.username = doc["username"].as<String>();
    credentials.password = doc["password"].as<String>();
    credentials.topic_prefix = doc["topic_prefix"].as<String>();
    
    // Validar credenciais
    if (credentials.broker_host.isEmpty() || credentials.broker_port == 0) {
        if (logger) {
            logger->error("DeviceRegistration: Credenciais MQTT inválidas recebidas da API");
        }
        return false;
    }
    
    if (logger) {
        logger->info("DeviceRegistration: Credenciais MQTT obtidas com sucesso");
        logger->debug("DeviceRegistration: Broker: " + credentials.broker_host + ":" + String(credentials.broker_port));
    }
    
    return true;
}

bool DeviceRegistration::updateDeviceNetworkInfo(const String& deviceId) {
    // Endpoint correto: /api/devices/{device_identifier} (sem /uuid/)
    String url = buildApiUrl("/devices/" + deviceId);
    
    // Construir payload de atualização conforme documentação
    StaticJsonDocument<512> doc;
    doc["name"] = "ESP32-Display-" + deviceId.substring(deviceId.length() - 6);
    doc["type"] = DEVICE_TYPE;
    doc["ip_address"] = WiFi.localIP().toString();
    doc["mac_address"] = DeviceUtils::getMACAddress(true, ":");
    doc["is_active"] = true;
    
    // Adicionar configuration e capabilities como objetos vazios se necessário
    JsonObject configuration = doc.createNestedObject("configuration");
    configuration["firmware_version"] = DEVICE_VERSION;
    
    JsonObject capabilities = doc.createNestedObject("capabilities");
    capabilities["display"] = true;
    capabilities["touch"] = true;
    capabilities["width"] = 320;
    capabilities["height"] = 240;
    
    String payload;
    serializeJson(doc, payload);
    
    if (logger) {
        logger->debug("DeviceRegistration: Atualizando informações de rede: " + url);
        logger->debug("DeviceRegistration: Método: PATCH");
    }
    
    String response;
    return makeHttpRequest(url, "PATCH", payload, response);
}

void DeviceRegistration::saveRegistrationTime() {
    Preferences prefs;
    if (!prefs.begin(NVS_NAMESPACE, false)) {
        if (logger) {
            logger->error("DeviceRegistration: Falha ao abrir NVS para escrita do timestamp");
        }
        return;
    }
    
    unsigned long currentTime = esp_timer_get_time() / 1000000; // Converter para segundos
    prefs.putULong(KEY_REG_TIME, currentTime);
    prefs.end();
    
    if (logger) {
        logger->debug("DeviceRegistration: Timestamp de registro salvo: " + String(currentTime));
    }
}

bool DeviceRegistration::saveMQTTCredentials(const MQTTCredentials& creds) {
    Preferences prefs;
    if (!prefs.begin(NVS_NAMESPACE, false)) {
        if (logger) {
            logger->error("DeviceRegistration: Falha ao abrir NVS para escrita das credenciais");
        }
        return false;
    }
    
    bool success = true;
    success &= prefs.putString(KEY_MQTT_BROKER, creds.broker_host);
    success &= prefs.putUShort(KEY_MQTT_PORT, creds.broker_port);
    success &= prefs.putString(KEY_MQTT_USER, creds.username);
    success &= prefs.putString(KEY_MQTT_PASS, creds.password);
    success &= prefs.putString(KEY_MQTT_PREFIX, creds.topic_prefix);
    
    prefs.end();
    
    if (success && logger) {
        logger->debug("DeviceRegistration: Credenciais MQTT salvas no NVS");
    } else if (logger) {
        logger->error("DeviceRegistration: Falha ao salvar credenciais MQTT no NVS");
    }
    
    return success;
}

String DeviceRegistration::buildApiUrl(const String& endpoint) {
    String url = String(API_PROTOCOL) + "://" + String(API_SERVER) + ":" + String(API_PORT) + String(API_BASE_PATH) + endpoint;
    return url;
}

bool DeviceRegistration::makeHttpRequest(const String& url, const String& method, const String& payload, String& response) {
    HTTPClient http;
    http.setTimeout(API_TIMEOUT);
    
    for (int attempt = 1; attempt <= API_RETRY_COUNT; attempt++) {
        if (logger) {
            logger->debug("DeviceRegistration: Tentativa " + String(attempt) + "/" + String(API_RETRY_COUNT) + " - " + method + " " + url);
        }
        
        http.begin(url);
        http.addHeader("Content-Type", "application/json");
        
        #if API_USE_AUTH
        if (strlen(API_AUTH_TOKEN) > 0) {
            http.addHeader("Authorization", "Bearer " + String(API_AUTH_TOKEN));
        }
        #endif
        
        int httpCode = -1;
        
        if (method == "GET") {
            httpCode = http.GET();
        } else if (method == "POST") {
            httpCode = http.POST(payload);
        } else if (method == "PUT") {
            httpCode = http.PUT(payload);
        }
        
        if (httpCode > 0) {
            response = http.getString();
            
            if (logger) {
                logger->debug("DeviceRegistration: Resposta HTTP " + String(httpCode));
                if (response.length() > 0) {
                    logger->debug("DeviceRegistration: Resposta: " + response.substring(0, 200) + (response.length() > 200 ? "..." : ""));
                }
            }
            
            if (httpCode >= 200 && httpCode < 300) {
                http.end();
                return true;
            } else if (httpCode == 404 && method == "GET") {
                // 404 em GET é esperado quando dispositivo não existe
                http.end();
                return false;
            }
        } else {
            if (logger) {
                logger->error("DeviceRegistration: Erro HTTP: " + String(httpCode));
            }
        }
        
        http.end();
        
        // Se não é a última tentativa, aguardar antes de retry
        if (attempt < API_RETRY_COUNT) {
            if (logger) {
                logger->warning("DeviceRegistration: Falha na tentativa " + String(attempt) + ", aguardando " + String(API_RETRY_DELAY) + "ms");
            }
            delay(API_RETRY_DELAY);
        }
    }
    
    if (logger) {
        logger->error("DeviceRegistration: Todas as tentativas falharam para " + method + " " + url);
    }
    return false;
}