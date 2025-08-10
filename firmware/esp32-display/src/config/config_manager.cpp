/**
 * AutoCore ESP32 Display - Configuration Manager Implementation
 * 
 * Implementação do gerenciador de configurações
 */

#include "config_manager.h"
#include <WiFi.h>

// Instância global
ConfigManager configManager;

ConfigManager::ConfigManager() : initialized(false) {
    // Construtor vazio - inicialização em begin()
}

ConfigManager::~ConfigManager() {
    if (initialized) {
        prefs.end();
    }
}

bool ConfigManager::begin() {
    LOG_INFO_CTX("ConfigManager", "Inicializando gerenciador de configurações...");
    
    // Abrir namespace de preferências
    if (!prefs.begin(NVS_NAMESPACE, false)) {
        LOG_ERROR_CTX("ConfigManager", "Falha ao abrir namespace NVS");
        return false;
    }
    
    // Aplicar configurações padrão
    applyDefaults();
    
    // Tentar carregar configuração salva
    if (!loadFromNVS()) {
        LOG_WARN_CTX("ConfigManager", "Configuração não encontrada - usando padrões");
        
        // Salvar configuração padrão
        if (!saveToNVS()) {
            LOG_ERROR_CTX("ConfigManager", "Falha ao salvar configuração padrão");
            return false;
        }
    }
    
    // Validar configuração carregada
    if (!validateConfiguration()) {
        LOG_WARN_CTX("ConfigManager", "Configuração inválida - aplicando correções");
        applyDefaults();
        saveToNVS();
    }
    
    initialized = true;
    
    if (debugEnabled) {
        printConfiguration();
    }
    
    LOG_INFO_CTX("ConfigManager", "Gerenciador inicializado com sucesso");
    return true;
}

void ConfigManager::applyDefaults() {
    LOG_DEBUG_CTX("ConfigManager", "Aplicando configurações padrão");
    
    // Reset para construtor padrão
    config = DeviceConfig();
    
    // Gerar UUID se não existir
    if (config.device_uuid.length() == 0) {
        config.device_uuid = generateDeviceUUID();
        LOG_INFO_CTX("ConfigManager", "UUID gerado: %s", config.device_uuid.c_str());
    }
}

String ConfigManager::generateDeviceUUID() {
    uint64_t mac = ESP.getEfuseMac();
    String uuid = String(DEVICE_TYPE) + "-";
    uuid += String((uint32_t)(mac >> 32), HEX);
    uuid += String((uint32_t)mac, HEX);
    uuid.toUpperCase();
    return uuid;
}

bool ConfigManager::loadFromNVS() {
    LOG_DEBUG_CTX("ConfigManager", "Carregando configuração do NVS");
    
    // Verificar versão da configuração
    int version = prefs.getInt(KEY_CONFIG_VERSION, 0);
    if (version != CONFIG_VERSION) {
        LOG_WARN_CTX("ConfigManager", "Versão de configuração incompatível: %d != %d", version, CONFIG_VERSION);
        return false;
    }
    
    // Carregar configurações básicas
    config.device_uuid = prefs.getString(KEY_DEVICE_UUID, config.device_uuid);
    config.device_name = prefs.getString(KEY_DEVICE_NAME, config.device_name);
    config.wifi_ssid = prefs.getString(KEY_WIFI_SSID, "");
    config.wifi_password = prefs.getString(KEY_WIFI_PASSWORD, "");
    config.backend_host = prefs.getString(KEY_BACKEND_HOST, "");
    config.backend_port = prefs.getInt(KEY_BACKEND_PORT, config.backend_port);
    config.mqtt_broker = prefs.getString(KEY_MQTT_BROKER, "");
    config.mqtt_port = prefs.getInt(KEY_MQTT_PORT, config.mqtt_port);
    config.mqtt_user = prefs.getString(KEY_MQTT_USER, "");
    config.mqtt_password = prefs.getString(KEY_MQTT_PASSWORD, "");
    config.configured = prefs.getBool(KEY_CONFIGURED, false);
    
    // Carregar tema (JSON)
    String themeJSON = prefs.getString(KEY_THEME_JSON, "");
    if (themeJSON.length() > 0) {
        updateThemeFromJSON(themeJSON);
    }
    
    // Carregar telas (JSON)
    String screensJSON = prefs.getString(KEY_SCREENS_JSON, "");
    if (screensJSON.length() > 0) {
        updateScreensFromJSON(screensJSON);
    }
    
    LOG_INFO_CTX("ConfigManager", "Configuração carregada do NVS");
    return true;
}

bool ConfigManager::saveToNVS() {
    LOG_DEBUG_CTX("ConfigManager", "Salvando configuração no NVS");
    
    // Salvar versão
    prefs.putInt(KEY_CONFIG_VERSION, CONFIG_VERSION);
    
    // Salvar configurações básicas
    prefs.putString(KEY_DEVICE_UUID, config.device_uuid);
    prefs.putString(KEY_DEVICE_NAME, config.device_name);
    prefs.putString(KEY_WIFI_SSID, config.wifi_ssid);
    prefs.putString(KEY_WIFI_PASSWORD, config.wifi_password);
    prefs.putString(KEY_BACKEND_HOST, config.backend_host);
    prefs.putInt(KEY_BACKEND_PORT, config.backend_port);
    prefs.putString(KEY_MQTT_BROKER, config.mqtt_broker);
    prefs.putInt(KEY_MQTT_PORT, config.mqtt_port);
    prefs.putString(KEY_MQTT_USER, config.mqtt_user);
    prefs.putString(KEY_MQTT_PASSWORD, config.mqtt_password);
    prefs.putBool(KEY_CONFIGURED, config.configured);
    
    // Salvar tema como JSON
    String themeJSON = getThemeAsJSON();
    prefs.putString(KEY_THEME_JSON, themeJSON);
    
    // Salvar telas como JSON
    String screensJSON = getScreensAsJSON();
    prefs.putString(KEY_SCREENS_JSON, screensJSON);
    
    // Atualizar timestamp
    config.last_config_update = millis();
    
    LOG_INFO_CTX("ConfigManager", "Configuração salva no NVS");
    return true;
}

bool ConfigManager::validateConfiguration() {
    bool valid = true;
    
    // Validar UUID
    if (config.device_uuid.length() < 10) {
        LOG_ERROR_CTX("ConfigManager", "UUID inválido: %s", config.device_uuid.c_str());
        valid = false;
    }
    
    // Se configurado, validar campos obrigatórios
    if (config.configured) {
        if (config.wifi_ssid.length() == 0) {
            LOG_ERROR_CTX("ConfigManager", "SSID WiFi obrigatório quando configurado");
            valid = false;
        }
        
        if (config.backend_host.length() == 0) {
            LOG_ERROR_CTX("ConfigManager", "Host do backend obrigatório quando configurado");
            valid = false;
        }
        
        if (config.backend_port <= 0 || config.backend_port > 65535) {
            LOG_ERROR_CTX("ConfigManager", "Porta do backend inválida: %d", config.backend_port);
            valid = false;
        }
    }
    
    return valid;
}

void ConfigManager::setDeviceName(const String& name) {
    config.device_name = name;
    LOG_INFO_CTX("ConfigManager", "Nome do dispositivo alterado: %s", name.c_str());
}

void ConfigManager::setWiFiCredentials(const String& ssid, const String& password) {
    config.wifi_ssid = ssid;
    config.wifi_password = password;
    LOG_INFO_CTX("ConfigManager", "Credenciais WiFi atualizadas: %s", ssid.c_str());
}

void ConfigManager::setBackendConfig(const String& host, int port) {
    config.backend_host = host;
    config.backend_port = port;
    LOG_INFO_CTX("ConfigManager", "Backend configurado: %s:%d", host.c_str(), port);
}

void ConfigManager::setMQTTConfig(const String& broker, int port, const String& user, const String& password) {
    config.mqtt_broker = broker;
    config.mqtt_port = port;
    config.mqtt_user = user;
    config.mqtt_password = password;
    LOG_INFO_CTX("ConfigManager", "MQTT configurado: %s:%d", broker.c_str(), port);
}

bool ConfigManager::updateFromJSON(const String& jsonString) {
    LOG_INFO_CTX("ConfigManager", "Atualizando configuração via JSON (%d bytes)", jsonString.length());
    
    DynamicJsonDocument doc(4096);
    DeserializationError error = deserializeJson(doc, jsonString);
    
    if (error) {
        LOG_ERROR_CTX("ConfigManager", "Erro ao parsear JSON: %s", error.c_str());
        return false;
    }
    
    // Atualizar dispositivo
    if (doc.containsKey("device")) {
        JsonObject device = doc["device"];
        if (device.containsKey("name")) config.device_name = device["name"].as<String>();
    }
    
    // Atualizar WiFi
    if (doc.containsKey("wifi")) {
        JsonObject wifi = doc["wifi"];
        if (wifi.containsKey("ssid")) config.wifi_ssid = wifi["ssid"].as<String>();
        if (wifi.containsKey("password")) config.wifi_password = wifi["password"].as<String>();
    }
    
    // Atualizar backend
    if (doc.containsKey("backend")) {
        JsonObject backend = doc["backend"];
        if (backend.containsKey("host")) config.backend_host = backend["host"].as<String>();
        if (backend.containsKey("port")) config.backend_port = backend["port"].as<int>();
    }
    
    // Atualizar MQTT
    if (doc.containsKey("mqtt")) {
        JsonObject mqtt = doc["mqtt"];
        if (mqtt.containsKey("broker")) config.mqtt_broker = mqtt["broker"].as<String>();
        if (mqtt.containsKey("port")) config.mqtt_port = mqtt["port"].as<int>();
        if (mqtt.containsKey("user")) config.mqtt_user = mqtt["user"].as<String>();
        if (mqtt.containsKey("password")) config.mqtt_password = mqtt["password"].as<String>();
    }
    
    // Atualizar tema
    if (doc.containsKey("theme")) {
        String themeJSON;
        serializeJson(doc["theme"], themeJSON);
        updateThemeFromJSON(themeJSON);
    }
    
    // Atualizar telas
    if (doc.containsKey("screens")) {
        String screensJSON;
        serializeJson(doc["screens"], screensJSON);
        updateScreensFromJSON(screensJSON);
    }
    
    return true;
}

bool ConfigManager::updateThemeFromJSON(const String& themeJSON) {
    LOG_DEBUG_CTX("ConfigManager", "Atualizando tema via JSON");
    
    DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, themeJSON);
    
    if (error) {
        LOG_ERROR_CTX("ConfigManager", "Erro ao parsear tema JSON: %s", error.c_str());
        return false;
    }
    
    if (doc.containsKey("colors")) {
        JsonObject colors = doc["colors"];
        if (colors.containsKey("primary")) {
            String hex = colors["primary"].as<String>();
            config.theme.primary_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
        if (colors.containsKey("secondary")) {
            String hex = colors["secondary"].as<String>();
            config.theme.secondary_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
        if (colors.containsKey("warning")) {
            String hex = colors["warning"].as<String>();
            config.theme.warning_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
        if (colors.containsKey("danger")) {
            String hex = colors["danger"].as<String>();
            config.theme.danger_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
        if (colors.containsKey("background")) {
            String hex = colors["background"].as<String>();
            config.theme.background_color = strtol(hex.substring(1).c_str(), NULL, 16);
        }
    }
    
    if (doc.containsKey("fonts")) {
        JsonObject fonts = doc["fonts"];
        if (fonts.containsKey("size_normal")) {
            config.theme.font_size_base = fonts["size_normal"].as<int>();
        }
    }
    
    return true;
}

bool ConfigManager::updateScreensFromJSON(const String& screensJSON) {
    LOG_DEBUG_CTX("ConfigManager", "Atualizando telas via JSON");
    
    DynamicJsonDocument doc(8192);
    DeserializationError error = deserializeJson(doc, screensJSON);
    
    if (error) {
        LOG_ERROR_CTX("ConfigManager", "Erro ao parsear telas JSON: %s", error.c_str());
        return false;
    }
    
    config.screens.clear();
    
    if (doc.is<JsonArray>()) {
        JsonArray screens = doc.as<JsonArray>();
        
        for (JsonObject screenObj : screens) {
            ScreenConfig screen;
            screen.id = screenObj["id"].as<String>();
            screen.title = screenObj["title"].as<String>();
            
            if (screenObj.containsKey("layout")) {
                JsonObject layout = screenObj["layout"];
                screen.layout_type = layout["type"].as<String>();
                if (layout.containsKey("cols")) screen.layout_cols = layout["cols"];
                if (layout.containsKey("rows")) screen.layout_rows = layout["rows"];
                if (layout.containsKey("spacing")) screen.layout_spacing = layout["spacing"];
            }
            
            if (screenObj.containsKey("buttons")) {
                JsonArray buttons = screenObj["buttons"];
                
                for (JsonObject buttonObj : buttons) {
                    ButtonConfig button;
                    button.id = buttonObj["id"].as<String>();
                    button.label = buttonObj["label"].as<String>();
                    button.icon = buttonObj["icon"].as<String>();
                    button.type = buttonObj["type"].as<String>();
                    
                    if (buttonObj.containsKey("position")) {
                        JsonObject pos = buttonObj["position"];
                        button.col = pos["col"];
                        button.row = pos["row"];
                    }
                    
                    if (buttonObj.containsKey("action")) {
                        JsonObject action = buttonObj["action"];
                        button.action_type = action["type"].as<String>();
                        if (action.containsKey("channel")) button.action_channel = action["channel"];
                    }
                    
                    screen.buttons.push_back(button);
                }
            }
            
            config.screens.push_back(screen);
        }
    }
    
    LOG_INFO_CTX("ConfigManager", "Carregadas %d telas", config.screens.size());
    return true;
}

String ConfigManager::getThemeAsJSON() const {
    DynamicJsonDocument doc(1024);
    
    doc["name"] = config.theme.name;
    
    JsonObject colors = doc.createNestedObject("colors");
    colors["primary"] = "#" + String(config.theme.primary_color, HEX);
    colors["secondary"] = "#" + String(config.theme.secondary_color, HEX);
    colors["warning"] = "#" + String(config.theme.warning_color, HEX);
    colors["danger"] = "#" + String(config.theme.danger_color, HEX);
    colors["background"] = "#" + String(config.theme.background_color, HEX);
    colors["surface"] = "#" + String(config.theme.surface_color, HEX);
    colors["text_primary"] = "#" + String(config.theme.text_primary_color, HEX);
    colors["text_secondary"] = "#" + String(config.theme.text_secondary_color, HEX);
    
    JsonObject style = doc.createNestedObject("style");
    style["border_radius"] = config.theme.border_radius;
    style["shadow_enabled"] = config.theme.shadow_enabled;
    style["animation_speed"] = config.theme.animation_speed;
    style["font_size_base"] = config.theme.font_size_base;
    
    String result;
    serializeJson(doc, result);
    return result;
}

String ConfigManager::getScreensAsJSON() const {
    DynamicJsonDocument doc(8192);
    JsonArray screens = doc.to<JsonArray>();
    
    for (const ScreenConfig& screen : config.screens) {
        JsonObject screenObj = screens.createNestedObject();
        screenObj["id"] = screen.id;
        screenObj["title"] = screen.title;
        
        JsonObject layout = screenObj.createNestedObject("layout");
        layout["type"] = screen.layout_type;
        layout["cols"] = screen.layout_cols;
        layout["rows"] = screen.layout_rows;
        layout["spacing"] = screen.layout_spacing;
        
        JsonArray buttons = screenObj.createNestedArray("buttons");
        for (const ButtonConfig& button : screen.buttons) {
            JsonObject buttonObj = buttons.createNestedObject();
            buttonObj["id"] = button.id;
            buttonObj["label"] = button.label;
            buttonObj["icon"] = button.icon;
            buttonObj["type"] = button.type;
            
            JsonObject pos = buttonObj.createNestedObject("position");
            pos["col"] = button.col;
            pos["row"] = button.row;
            
            JsonObject action = buttonObj.createNestedObject("action");
            action["type"] = button.action_type;
            action["channel"] = button.action_channel;
        }
    }
    
    String result;
    serializeJson(doc, result);
    return result;
}

void ConfigManager::markAsConfigured() {
    config.configured = true;
    config.last_config_update = millis();
    LOG_INFO_CTX("ConfigManager", "Dispositivo marcado como configurado");
}

void ConfigManager::markAsUnconfigured() {
    config.configured = false;
    LOG_WARN_CTX("ConfigManager", "Dispositivo marcado como não configurado");
}

bool ConfigManager::save() {
    if (!initialized) {
        LOG_ERROR_CTX("ConfigManager", "Tentativa de salvar sem inicialização");
        return false;
    }
    
    return saveToNVS();
}

bool ConfigManager::load() {
    if (!initialized) {
        LOG_ERROR_CTX("ConfigManager", "Tentativa de carregar sem inicialização");
        return false;
    }
    
    return loadFromNVS();
}

bool ConfigManager::factoryReset() {
    LOG_WARN_CTX("ConfigManager", "Executando factory reset...");
    
    // Limpar todas as preferências
    prefs.clear();
    
    // Aplicar configurações padrão
    applyDefaults();
    
    // Salvar configuração padrão
    bool success = saveToNVS();
    
    if (success) {
        LOG_INFO_CTX("ConfigManager", "Factory reset concluído com sucesso");
    } else {
        LOG_ERROR_CTX("ConfigManager", "Falha no factory reset");
    }
    
    return success;
}

void ConfigManager::printConfiguration() const {
    LOG_INFO("=== CONFIGURAÇÃO DO DISPLAY ===");
    LOG_INFO("UUID: %s", config.device_uuid.c_str());
    LOG_INFO("Nome: %s", config.device_name.c_str());
    LOG_INFO("Configurado: %s", config.configured ? "SIM" : "NÃO");
    LOG_INFO("WiFi: %s", config.wifi_ssid.length() > 0 ? config.wifi_ssid.c_str() : "Não configurado");
    LOG_INFO("Backend: %s:%d", config.backend_host.c_str(), config.backend_port);
    LOG_INFO("MQTT: %s:%d", config.mqtt_broker.c_str(), config.mqtt_port);
    LOG_INFO("Tema: %s", config.theme.name.c_str());
    LOG_INFO("Telas: %d configuradas", config.screens.size());
    LOG_INFO("==============================");
}

void ConfigManager::printStorageInfo() const {
    size_t total = prefs.freeEntries();
    LOG_DEBUG_CTX("ConfigManager", "NVS entries livres: %d", total);
}