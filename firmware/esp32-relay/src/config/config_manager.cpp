#include "config_manager.h"
#include "../utils/logger.h"
#include <esp_system.h>
#include <esp_random.h>

// Instância global
ConfigManager configManager;

ConfigManager::ConfigManager() {
    // Construtor
}

ConfigManager::~ConfigManager() {
    if (initialized) {
        preferences.end();
    }
}

bool ConfigManager::begin() {
    LOG_INFO_F("ConfigManager: Inicializando...");
    
    if (!preferences.begin(NVS_NAMESPACE, false)) {
        LOG_ERROR_F("ConfigManager: Falha ao inicializar NVS");
        return false;
    }
    
    initialized = true;
    
    // Carregar configuração existente ou criar padrão
    if (!loadConfig()) {
        LOG_WARN_F("ConfigManager: Configuração não encontrada, criando padrão");
        setDefaults();
        saveConfig();
    }
    
    LOG_INFO_F("ConfigManager: Inicializado com sucesso");
    LOG_INFO_F("ConfigManager: UUID = %s", config.device_uuid.c_str());
    LOG_INFO_F("ConfigManager: Nome = %s", config.device_name.c_str());
    
    return true;
}

String ConfigManager::generateUUID() {
    String mac = WiFi.macAddress();
    mac.replace(":", "");
    mac.toLowerCase();
    return String("esp32-relay-") + mac.substring(6);
}

void ConfigManager::setDefaults() {
    LOG_INFO_F("ConfigManager: Configurando valores padrão");
    
    config.device_uuid = generateUUID();
    config.device_name = "ESP32 Relay " + config.device_uuid.substring(12);
    config.backend_ip = "";
    config.backend_port = 8000;
    config.mqtt_broker = "";
    config.mqtt_port = 1883;
    config.mqtt_user = "";
    config.mqtt_password = "";
    config.wifi_ssid = "";
    config.wifi_password = "";
    config.config_completed = false;
    config.total_channels = 16;
    
    // Configurar canais padrão
    for (int i = 0; i < MAX_RELAY_CHANNELS; i++) {
        config.channels[i].enabled = false;
        config.channels[i].gpio_pin = -1;
        config.channels[i].name = "Canal " + String(i + 1);
        config.channels[i].function_type = "toggle";
        config.channels[i].require_password = false;
        config.channels[i].password_hash = "";
        config.channels[i].require_confirmation = false;
        config.channels[i].dual_action_enabled = false;
        config.channels[i].dual_action_channel = -1;
        config.channels[i].max_on_time_ms = 0;
        config.channels[i].time_window_enabled = false;
        config.channels[i].time_window_start = 0;
        config.channels[i].time_window_end = 1440;
        config.channels[i].allow_in_macro = true;
        config.channels[i].inverted_logic = false;
    }
    
    // Configurar alguns canais padrão com pinos
    for (int i = 0; i < min(config.total_channels, (int)(sizeof(DEFAULT_RELAY_PINS)/sizeof(DEFAULT_RELAY_PINS[0]))); i++) {
        if (IS_VALID_GPIO(DEFAULT_RELAY_PINS[i])) {
            config.channels[i].enabled = true;
            config.channels[i].gpio_pin = DEFAULT_RELAY_PINS[i];
        }
    }
}

bool ConfigManager::saveConfig() {
    if (!initialized) {
        LOG_ERROR_F("ConfigManager: Não inicializado");
        return false;
    }
    
    LOG_INFO_F("ConfigManager: Salvando configuração...");
    
    // Informações básicas do dispositivo
    preferences.putString(NVS_KEY_DEVICE_UUID, config.device_uuid);
    preferences.putString(NVS_KEY_DEVICE_NAME, config.device_name);
    preferences.putString(NVS_KEY_BACKEND_IP, config.backend_ip);
    preferences.putInt(NVS_KEY_BACKEND_PORT, config.backend_port);
    
    // Configurações MQTT
    preferences.putString(NVS_KEY_MQTT_BROKER, config.mqtt_broker);
    preferences.putInt(NVS_KEY_MQTT_PORT, config.mqtt_port);
    preferences.putString(NVS_KEY_MQTT_USER, config.mqtt_user);
    preferences.putString(NVS_KEY_MQTT_PASS, config.mqtt_password);
    
    // Configurações WiFi
    preferences.putString(NVS_KEY_WIFI_SSID, config.wifi_ssid);
    preferences.putString(NVS_KEY_WIFI_PASS, config.wifi_password);
    
    // Status de configuração
    preferences.putBool(NVS_KEY_CONFIG_DONE, config.config_completed);
    preferences.putInt("total_channels", config.total_channels);
    
    // Salvar configuração dos canais como JSON para economizar espaço
    DynamicJsonDocument doc(8192);
    JsonArray channels = doc.createNestedArray("channels");
    
    for (int i = 0; i < MAX_RELAY_CHANNELS; i++) {
        JsonObject channel = channels.createNestedObject();
        channel["enabled"] = config.channels[i].enabled;
        channel["gpio_pin"] = config.channels[i].gpio_pin;
        channel["name"] = config.channels[i].name;
        channel["function_type"] = config.channels[i].function_type;
        channel["require_password"] = config.channels[i].require_password;
        channel["password_hash"] = config.channels[i].password_hash;
        channel["require_confirmation"] = config.channels[i].require_confirmation;
        channel["dual_action_enabled"] = config.channels[i].dual_action_enabled;
        channel["dual_action_channel"] = config.channels[i].dual_action_channel;
        channel["max_on_time_ms"] = config.channels[i].max_on_time_ms;
        channel["time_window_enabled"] = config.channels[i].time_window_enabled;
        channel["time_window_start"] = config.channels[i].time_window_start;
        channel["time_window_end"] = config.channels[i].time_window_end;
        channel["allow_in_macro"] = config.channels[i].allow_in_macro;
        channel["inverted_logic"] = config.channels[i].inverted_logic;
    }
    
    String channelsJson;
    serializeJson(doc, channelsJson);
    preferences.putString("channels_config", channelsJson);
    
    LOG_INFO_F("ConfigManager: Configuração salva com sucesso");
    return true;
}

bool ConfigManager::loadConfig() {
    if (!initialized) {
        LOG_ERROR_F("ConfigManager: Não inicializado");
        return false;
    }
    
    LOG_INFO_F("ConfigManager: Carregando configuração...");
    
    // Verificar se existe configuração salva
    if (!preferences.isKey(NVS_KEY_DEVICE_UUID)) {
        LOG_WARN_F("ConfigManager: Nenhuma configuração encontrada");
        return false;
    }
    
    // Carregar informações básicas
    config.device_uuid = preferences.getString(NVS_KEY_DEVICE_UUID, generateUUID());
    config.device_name = preferences.getString(NVS_KEY_DEVICE_NAME, "ESP32 Relay");
    config.backend_ip = preferences.getString(NVS_KEY_BACKEND_IP, "");
    config.backend_port = preferences.getInt(NVS_KEY_BACKEND_PORT, 8000);
    
    // Configurações MQTT
    config.mqtt_broker = preferences.getString(NVS_KEY_MQTT_BROKER, "");
    config.mqtt_port = preferences.getInt(NVS_KEY_MQTT_PORT, 1883);
    config.mqtt_user = preferences.getString(NVS_KEY_MQTT_USER, "");
    config.mqtt_password = preferences.getString(NVS_KEY_MQTT_PASS, "");
    
    // Configurações WiFi
    config.wifi_ssid = preferences.getString(NVS_KEY_WIFI_SSID, "");
    config.wifi_password = preferences.getString(NVS_KEY_WIFI_PASS, "");
    
    // Status e configurações gerais
    config.config_completed = preferences.getBool(NVS_KEY_CONFIG_DONE, false);
    config.total_channels = preferences.getInt("total_channels", 16);
    
    // Carregar configuração dos canais
    String channelsJson = preferences.getString("channels_config", "");
    if (channelsJson.length() > 0) {
        DynamicJsonDocument doc(8192);
        DeserializationError error = deserializeJson(doc, channelsJson);
        
        if (!error) {
            JsonArray channels = doc["channels"];
            for (int i = 0; i < min((int)channels.size(), MAX_RELAY_CHANNELS); i++) {
                JsonObject channel = channels[i];
                config.channels[i].enabled = channel["enabled"] | false;
                config.channels[i].gpio_pin = channel["gpio_pin"] | -1;
                config.channels[i].name = channel["name"] | ("Canal " + String(i + 1));
                config.channels[i].function_type = channel["function_type"] | "toggle";
                config.channels[i].require_password = channel["require_password"] | false;
                config.channels[i].password_hash = channel["password_hash"] | "";
                config.channels[i].require_confirmation = channel["require_confirmation"] | false;
                config.channels[i].dual_action_enabled = channel["dual_action_enabled"] | false;
                config.channels[i].dual_action_channel = channel["dual_action_channel"] | -1;
                config.channels[i].max_on_time_ms = channel["max_on_time_ms"] | 0;
                config.channels[i].time_window_enabled = channel["time_window_enabled"] | false;
                config.channels[i].time_window_start = channel["time_window_start"] | 0;
                config.channels[i].time_window_end = channel["time_window_end"] | 1440;
                config.channels[i].allow_in_macro = channel["allow_in_macro"] | true;
                config.channels[i].inverted_logic = channel["inverted_logic"] | false;
            }
        } else {
            LOG_ERROR_F("ConfigManager: Erro ao parsear configuração dos canais: %s", error.c_str());
            setDefaults();
            return false;
        }
    } else {
        // Configuração antiga ou primeira execução, usar padrões
        setDefaults();
    }
    
    LOG_INFO_F("ConfigManager: Configuração carregada com sucesso");
    return true;
}

bool ConfigManager::setWiFiCredentials(const String& ssid, const String& password) {
    if (ssid.length() == 0) {
        LOG_ERROR_F("ConfigManager: SSID não pode estar vazio");
        return false;
    }
    
    config.wifi_ssid = ssid;
    config.wifi_password = password;
    
    LOG_INFO_F("ConfigManager: Credenciais WiFi atualizadas: %s", ssid.c_str());
    return saveConfig();
}

bool ConfigManager::setBackendInfo(const String& ip, int port) {
    if (ip.length() == 0 || port <= 0 || port > 65535) {
        LOG_ERROR_F("ConfigManager: IP ou porta inválidos");
        return false;
    }
    
    config.backend_ip = ip;
    config.backend_port = port;
    
    LOG_INFO_F("ConfigManager: Backend configurado: %s:%d", ip.c_str(), port);
    return saveConfig();
}

bool ConfigManager::setMQTTInfo(const String& broker, int port, const String& user, const String& pass) {
    if (broker.length() == 0 || port <= 0 || port > 65535) {
        LOG_ERROR_F("ConfigManager: Broker MQTT ou porta inválidos");
        return false;
    }
    
    config.mqtt_broker = broker;
    config.mqtt_port = port;
    config.mqtt_user = user;
    config.mqtt_password = pass;
    
    LOG_INFO_F("ConfigManager: MQTT configurado: %s:%d", broker.c_str(), port);
    return saveConfig();
}

bool ConfigManager::setRelayChannel(int channel, const RelayChannelConfig& channelConfig) {
    if (channel < 0 || channel >= MAX_RELAY_CHANNELS) {
        LOG_ERROR_F("ConfigManager: Canal inválido: %d", channel);
        return false;
    }
    
    if (channelConfig.enabled && !IS_VALID_GPIO(channelConfig.gpio_pin)) {
        LOG_ERROR_F("ConfigManager: Pino GPIO inválido: %d", channelConfig.gpio_pin);
        return false;
    }
    
    config.channels[channel] = channelConfig;
    
    LOG_INFO_F("ConfigManager: Canal %d configurado: %s (GPIO %d)", 
               channel + 1, channelConfig.name.c_str(), channelConfig.gpio_pin);
    
    return saveConfig();
}

RelayChannelConfig ConfigManager::getRelayChannel(int channel) {
    if (channel < 0 || channel >= MAX_RELAY_CHANNELS) {
        LOG_ERROR_F("ConfigManager: Canal inválido: %d", channel);
        return RelayChannelConfig(); // Retorna configuração vazia
    }
    
    return config.channels[channel];
}

bool ConfigManager::isConfigured() {
    return config.config_completed && 
           isWiFiConfigured() && 
           isBackendConfigured();
}

bool ConfigManager::isWiFiConfigured() {
    return config.wifi_ssid.length() > 0;
}

bool ConfigManager::isMQTTConfigured() {
    return config.mqtt_broker.length() > 0 && config.mqtt_port > 0;
}

bool ConfigManager::isBackendConfigured() {
    return config.backend_ip.length() > 0 && config.backend_port > 0;
}

void ConfigManager::setConfigured(bool configured) {
    config.config_completed = configured;
    saveConfig();
}

String ConfigManager::getDeviceUUID() {
    return config.device_uuid;
}

String ConfigManager::getDeviceName() {
    return config.device_name;
}

String ConfigManager::getStatusJSON() {
    DynamicJsonDocument doc(1024);
    
    doc["uuid"] = config.device_uuid;
    doc["name"] = config.device_name;
    doc["type"] = DEVICE_TYPE;
    doc["firmware_version"] = FIRMWARE_VERSION;
    doc["hardware_version"] = HARDWARE_VERSION;
    doc["uptime"] = millis() / 1000;
    doc["free_memory"] = ESP.getFreeHeap();
    doc["wifi_connected"] = WiFi.isConnected();
    if (WiFi.isConnected()) {
        doc["ip_address"] = WiFi.localIP().toString();
        doc["wifi_signal"] = WiFi.RSSI();
    }
    doc["configured"] = isConfigured();
    doc["total_channels"] = config.total_channels;
    
    String json;
    serializeJson(doc, json);
    return json;
}

String ConfigManager::getConfigJSON() {
    DynamicJsonDocument doc(4096);
    
    // Informações básicas (sem senhas)
    doc["device_uuid"] = config.device_uuid;
    doc["device_name"] = config.device_name;
    doc["backend_ip"] = config.backend_ip;
    doc["backend_port"] = config.backend_port;
    doc["mqtt_broker"] = config.mqtt_broker;
    doc["mqtt_port"] = config.mqtt_port;
    doc["mqtt_user"] = config.mqtt_user;
    doc["wifi_ssid"] = config.wifi_ssid;
    doc["total_channels"] = config.total_channels;
    doc["configured"] = config.config_completed;
    
    // Canais habilitados
    JsonArray channels = doc.createNestedArray("channels");
    for (int i = 0; i < config.total_channels; i++) {
        if (config.channels[i].enabled) {
            JsonObject channel = channels.createNestedObject();
            channel["id"] = i + 1;
            channel["name"] = config.channels[i].name;
            channel["gpio_pin"] = config.channels[i].gpio_pin;
            channel["function_type"] = config.channels[i].function_type;
            channel["require_password"] = config.channels[i].require_password;
            channel["require_confirmation"] = config.channels[i].require_confirmation;
        }
    }
    
    String json;
    serializeJson(doc, json);
    return json;
}

void ConfigManager::printConfig() {
    LOG_INFO_F("=== CONFIGURAÇÃO DO DISPOSITIVO ===");
    LOG_INFO_F("UUID: %s", config.device_uuid.c_str());
    LOG_INFO_F("Nome: %s", config.device_name.c_str());
    LOG_INFO_F("Backend: %s:%d", config.backend_ip.c_str(), config.backend_port);
    LOG_INFO_F("MQTT: %s:%d", config.mqtt_broker.c_str(), config.mqtt_port);
    LOG_INFO_F("WiFi: %s", config.wifi_ssid.c_str());
    LOG_INFO_F("Configurado: %s", isConfigured() ? "SIM" : "NÃO");
    LOG_INFO_F("Canais ativos: %d", config.total_channels);
    
    for (int i = 0; i < config.total_channels; i++) {
        if (config.channels[i].enabled) {
            LOG_INFO_F("  Canal %d: %s (GPIO %d, %s)", 
                       i + 1, 
                       config.channels[i].name.c_str(), 
                       config.channels[i].gpio_pin,
                       config.channels[i].function_type.c_str());
        }
    }
    LOG_INFO_F("===================================");
}

void ConfigManager::factoryReset() {
    LOG_WARN_F("ConfigManager: Executando factory reset...");
    preferences.clear();
    setDefaults();
    saveConfig();
    LOG_INFO_F("ConfigManager: Factory reset concluído");
}

size_t ConfigManager::getUsedNVSSpace() {
    return preferences.getBytesLength(NVS_NAMESPACE);
}

size_t ConfigManager::getFreeNVSSpace() {
    return preferences.freeEntries() * 32; // Estimativa aproximada
}