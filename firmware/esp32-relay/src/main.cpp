/**
 * AutoCore ESP32 Relay Firmware
 * Sistema completo de controle de relés via MQTT com proteções de segurança
 * 
 * Características:
 * - Servidor web para configuração inicial
 * - Cliente MQTT com sistema de heartbeat
 * - Controle de relés com proteções avançadas
 * - Sistema de watchdog para segurança
 * - Suporte a relés momentâneos e toggle
 * - Interface web moderna para configuração
 * 
 * Fase 1: SIMULAÇÃO - Não aciona hardware físico
 * 
 * Desenvolvido para o ecossistema AutoCore
 * https://github.com/leechardes/autocore
 */

#include <Arduino.h>
#include <WiFi.h>
#include <SPIFFS.h>
#include <ArduinoJson.h>

// Módulos do sistema
#include "config/config_manager.h"
#include "network/wifi_manager.h"
#include "network/web_server.h"
#include "network/api_client.h"
#include "mqtt/mqtt_client.h"
#include "mqtt/mqtt_handler.h"
#include "relay/relay_controller.h"
#include "utils/logger.h"
#include "utils/watchdog.h"

// Estados do sistema
enum SystemState {
    BOOTING,
    CONFIGURING,
    CONNECTING,
    RUNNING,
    ERROR_STATE,
    RECOVERY
};

SystemState currentState = BOOTING;
unsigned long stateChangeTime = 0;
unsigned long lastHeartbeat = 0;
unsigned long lastTelemetry = 0;

// Configurações
const unsigned long HEARTBEAT_INTERVAL = 30000;    // 30 segundos
const unsigned long TELEMETRY_INTERVAL = 5000;     // 5 segundos
const unsigned long STATE_TIMEOUT = 60000;         // 60 segundos timeout por estado

// Flags de controle
bool systemInitialized = false;
bool configurationMode = false;
bool emergencyShutdown = false;

// Protótipos das funções
void setup();
void loop();
bool initializeSystem();
void changeState(SystemState newState);
void handleSystemState();
void handleConfigurationMode();
void handleRunningMode();
void handleErrorState();
void publishSystemHeartbeat();
void publishSystemTelemetry();
void handleEmergencyShutdown();
void systemRecovery();
void printSystemInfo();
void handleWatchdogReset(String reason);

// ============================================
// SETUP - Inicialização do sistema
// ============================================

void setup() {
    // Inicializar Serial o mais cedo possível
    Serial.begin(SERIAL_BAUDRATE);
    delay(1000);
    
    // Inicializar logger
    Logger::begin(LOG_LEVEL);
    
    LOG_INFO("==============================================");
    LOG_INFO("AutoCore ESP32 Relay Firmware v%s", FIRMWARE_VERSION);
    LOG_INFO("==============================================");
    LOG_INFO("Build: %s", AUTOCORE_BUILD_DATE);
    LOG_INFO("Chip: %s (Rev %d)", ESP.getChipModel(), ESP.getChipRevision());
    LOG_INFO("CPU: %d MHz", ESP.getCpuFreqMHz());
    LOG_INFO("Flash: %d KB", ESP.getFlashChipSize() / 1024);
    LOG_INFO("Free RAM: %d KB", ESP.getFreeHeap() / 1024);
    LOG_INFO("==============================================");
    
    // Configurar watchdog com callback
    watchdog.setResetCallback(handleWatchdogReset);
    
    // Inicializar sistema
    changeState(BOOTING);
    
    if (initializeSystem()) {
        systemInitialized = true;
        LOG_INFO("Sistema inicializado com sucesso!");
        
        // Verificar se precisa entrar em modo de configuração
        if (!configManager.isConfigured()) {
            LOG_WARN("Dispositivo não configurado - entrando em modo de configuração");
            configurationMode = true;
            changeState(CONFIGURING);
        } else {
            LOG_INFO("Dispositivo configurado - iniciando operação normal");
            changeState(CONNECTING);
        }
    } else {
        LOG_ERROR("Falha na inicialização do sistema!");
        changeState(ERROR_STATE);
    }
    
    // Feed inicial do watchdog
    watchdog.feed();
    
    LOG_INFO("Setup concluído - Estado: %d", currentState);
}

// ============================================
// LOOP PRINCIPAL
// ============================================

void loop() {
    // Alimentar watchdog - CRÍTICO
    watchdog.feed();
    watchdog.feedTask("main_loop");
    
    // Verificar emergency shutdown
    if (emergencyShutdown) {
        handleEmergencyShutdown();
        return;
    }
    
    // Processar estado atual
    handleSystemState();
    
    // Atualizar controlador de relés sempre (independente do estado)
    relayController.update();
    watchdog.feedTask("relay_update");
    
    // Alimentar MQTT task mesmo quando não conectado
    watchdog.feedTask("mqtt_loop");
    
    // Operações contínuas quando o sistema está rodando
    if (currentState == RUNNING && systemInitialized) {
        handleRunningMode();
    }
    
    // Operações contínuas no modo configuração
    if (currentState == CONFIGURING) {
        handleConfigurationMode();
    }
    
    // Watchdog checks
    watchdog.checkTasks();
    
    // Yield para outras tasks
    yield();
    delay(10);
}

// ============================================
// INICIALIZAÇÃO DO SISTEMA
// ============================================

bool initializeSystem() {
    LOG_INFO("Inicializando componentes do sistema...");
    
    // 1. Inicializar watchdog
    if (!watchdog.begin(WATCHDOG_TIMEOUT_S)) {
        LOG_ERROR("Falha ao inicializar watchdog");
        return false;
    }
    
    // 2. Inicializar gerenciador de configuração
    if (!configManager.begin()) {
        LOG_ERROR("Falha ao inicializar gerenciador de configuração");
        return false;
    }
    
    // 3. Inicializar controlador de relés
    int totalChannels = configManager.getConfig().total_channels;
    if (!relayController.begin(totalChannels)) {
        LOG_ERROR("Falha ao inicializar controlador de relés");
        return false;
    }
    
    // 4. Inicializar handler MQTT
    if (!mqttHandler.begin(&relayController)) {
        LOG_ERROR("Falha ao inicializar handler MQTT");
        return false;
    }
    
    // 5. Configurar callback MQTT
    mqttClient.onMessage([](String topic, String payload) {
        mqttHandler.handleMessage(topic, payload);
        watchdog.feedTask("mqtt_loop");
    });
    
    mqttClient.onConnection([](bool connected) {
        if (connected) {
            LOG_INFO("MQTT conectado - publicando status inicial");
            mqttClient.publishDeviceAnnounce();
        } else {
            LOG_WARN("MQTT desconectado");
        }
    });
    
    // 6. Montar SPIFFS para servidor web
    if (!SPIFFS.begin(true)) {
        LOG_WARN("Falha ao montar SPIFFS - servidor web usará HTML inline");
    }
    
    // 7. Servidor web será inicializado após WiFi estar pronto
    // (movido para changeState)
    
    LOG_INFO("Todos os componentes inicializados com sucesso");
    return true;
}

// ============================================
// GERENCIAMENTO DE ESTADOS
// ============================================

void changeState(SystemState newState) {
    if (currentState != newState) {
        LOG_INFO("Mudança de estado: %d -> %d", currentState, newState);
        currentState = newState;
        stateChangeTime = millis();
        
        // Ações específicas por estado
        switch (newState) {
            case BOOTING:
                LOG_INFO("Estado: INICIALIZANDO");
                break;
                
            case CONFIGURING:
                {
                    LOG_INFO("Estado: MODO CONFIGURAÇÃO");
                    // Iniciar Access Point
                    WiFi.mode(WIFI_AP);
                    String apName = String(AP_SSID_PREFIX) + configManager.getDeviceUUID().substring(12);
                    WiFi.softAP(apName.c_str(), AP_PASSWORD);
                    LOG_INFO("Access Point ativo: %s", apName.c_str());
                    
                    // Aguardar o AP estar pronto
                    delay(100);
                    
                    // Aguardar um pouco mais para o AP estabilizar
                    delay(500);
                    
                    // Agora inicializar servidor web
                    if (!webServer.begin(WEB_SERVER_PORT)) {
                        LOG_ERROR("Falha ao inicializar servidor web");
                    } else {
                        LOG_INFO("Servidor web iniciado na porta %d", WEB_SERVER_PORT);
                        LOG_INFO("Teste acessando: http://192.168.4.1/test");
                    }
                    LOG_INFO("IP: %s", WiFi.softAPIP().toString().c_str());
                }
                break;
                
            case CONNECTING:
                LOG_INFO("Estado: CONECTANDO");
                // Tentar conectar WiFi
                break;
                
            case RUNNING:
                LOG_INFO("Estado: OPERANDO");
                break;
                
            case ERROR_STATE:
                LOG_ERROR("Estado: ERRO");
                break;
                
            case RECOVERY:
                LOG_WARN("Estado: RECUPERAÇÃO");
                break;
        }
    }
}

void handleSystemState() {
    unsigned long stateTime = millis() - stateChangeTime;
    
    switch (currentState) {
        case BOOTING:
            // Estado transitório - já deve ter mudado no setup
            if (stateTime > 10000) {
                LOG_ERROR("Timeout no boot - indo para estado de erro");
                changeState(ERROR_STATE);
            }
            break;
            
        case CONFIGURING:
            // Verificar se foi configurado
            if (configManager.isConfigured()) {
                LOG_INFO("Configuração concluída - tentando conectar");
                changeState(CONNECTING);
            }
            break;
            
        case CONNECTING:
            // Tentar conectar WiFi
            if (WiFi.status() != WL_CONNECTED) {
                DeviceConfig& config = configManager.getConfig();
                
                if (config.wifi_ssid.length() > 0) {
                    LOG_INFO("Conectando WiFi: %s", config.wifi_ssid.c_str());
                    WiFi.mode(WIFI_STA);
                    WiFi.begin(config.wifi_ssid.c_str(), config.wifi_password.c_str());
                    
                    // Aguardar conexão
                    int attempts = 0;
                    while (WiFi.status() != WL_CONNECTED && attempts < 20) {
                        delay(500);
                        attempts++;
                        watchdog.feed();
                    }
                    
                    if (WiFi.status() == WL_CONNECTED) {
                        LOG_INFO("WiFi conectado: %s", WiFi.localIP().toString().c_str());
                        
                        // Inicializar servidor web agora que WiFi está pronto
                        if (!webServer.begin(WEB_SERVER_PORT)) {
                            LOG_ERROR("Falha ao inicializar servidor web");
                        } else {
                            LOG_INFO("Servidor web iniciado na porta %d", WEB_SERVER_PORT);
                        }
                        
                        // Auto-registro e busca de config MQTT do backend
                        if (config.backend_ip.length() > 0) {
                            LOG_INFO("Verificando registro no backend...");
                            
                            // 1. Verificar se está registrado
                            if (apiClient.checkDeviceRegistration(config.device_uuid)) {
                                LOG_INFO("Dispositivo já registrado no backend");
                            } else {
                                LOG_INFO("Dispositivo não registrado - fazendo auto-registro...");
                                
                                // Preparar dados para registro
                                String deviceName = "ESP32_Relay_" + config.device_uuid.substring(12);
                                String macAddress = WiFi.macAddress();
                                String ipAddress = WiFi.localIP().toString();
                                String firmwareVersion = "1.0.0";
                                String hardwareVersion = "ESP32-D0WD-V3";
                                
                                if (apiClient.registerDevice(config.device_uuid, deviceName, "relay", 
                                                            macAddress, ipAddress, firmwareVersion, hardwareVersion)) {
                                    LOG_INFO("Auto-registro concluído com sucesso!");
                                } else {
                                    LOG_ERROR("Falha no auto-registro");
                                }
                            }
                            
                            // 2. Buscar configurações MQTT do backend
                            LOG_INFO("Buscando configurações MQTT do backend...");
                            String mqttConfig = apiClient.getMQTTConfig();
                            
                            if (mqttConfig.length() > 0) {
                                // Parsear configurações MQTT
                                JsonDocument doc;
                                DeserializationError error = deserializeJson(doc, mqttConfig);
                                
                                if (!error) {
                                    // Aplicar configurações MQTT (broker será o mesmo IP do backend)
                                    config.mqtt_broker = config.backend_ip;  // Usar IP do backend
                                    config.mqtt_port = doc["port"] | 1883;
                                    config.mqtt_user = doc["username"] | "";
                                    config.mqtt_password = doc["password"] | "";
                                    
                                    // Salvar configurações atualizadas
                                    configManager.updateMQTTSettings(config.mqtt_broker, config.mqtt_port, 
                                                                    config.mqtt_user, config.mqtt_password);
                                    
                                    LOG_INFO("Configurações MQTT obtidas do backend:");
                                    LOG_INFO("  Broker: %s", config.mqtt_broker.c_str());
                                    LOG_INFO("  Porta: %d", config.mqtt_port);
                                    LOG_INFO("  Usuário: %s", config.mqtt_user.length() > 0 ? "***" : "nenhum");
                                    
                                    // Conectar MQTT com as novas configurações
                                    if (!mqttClient.begin(config.device_uuid, config.mqtt_broker, 
                                                        config.mqtt_port, config.mqtt_user, config.mqtt_password)) {
                                        LOG_ERROR("Falha ao inicializar cliente MQTT");
                                    } else {
                                        LOG_INFO("Cliente MQTT inicializado com configurações do backend");
                                    }
                                } else {
                                    LOG_ERROR("Erro ao parsear configurações MQTT: %s", error.c_str());
                                }
                            } else {
                                LOG_WARN("Não foi possível obter configurações MQTT do backend");
                            }
                        } else {
                            LOG_WARN("Backend não configurado - pulando auto-registro e config MQTT");
                        }
                        
                        changeState(RUNNING);
                    } else {
                        LOG_ERROR("Falha na conexão WiFi");
                        changeState(ERROR_STATE);
                    }
                } else {
                    LOG_ERROR("Credenciais WiFi não configuradas");
                    changeState(CONFIGURING);
                }
            }
            
            // Timeout de conexão
            if (stateTime > STATE_TIMEOUT) {
                LOG_ERROR("Timeout na conexão - voltando para configuração");
                changeState(CONFIGURING);
            }
            break;
            
        case RUNNING:
            // Verificar conectividade
            if (WiFi.status() != WL_CONNECTED) {
                LOG_WARN("WiFi desconectado - tentando reconectar");
                changeState(CONNECTING);
            }
            break;
            
        case ERROR_STATE:
            handleErrorState();
            break;
            
        case RECOVERY:
            systemRecovery();
            break;
    }
}

// ============================================
// MODOS DE OPERAÇÃO
// ============================================

void handleConfigurationMode() {
    // No modo configuração, apenas manter servidor web ativo
    // O processamento é feito via handlers HTTP
    
    static unsigned long lastConfigStatus = 0;
    
    if (millis() - lastConfigStatus > 10000) {  // A cada 10 segundos
        LOG_INFO("Modo configuração ativo - aguardando configuração via web");
        LOG_INFO("Acesse: http://192.168.4.1");
        lastConfigStatus = millis();
    }
}

void handleRunningMode() {
    // Loop MQTT
    if (mqttClient.isInitialized()) {
        mqttClient.loop();
        
        // Tentar conectar se não estiver conectado
        if (!mqttClient.isConnected()) {
            mqttClient.connect();
        }
    }
    
    // Publicar heartbeat periodicamente
    if (millis() - lastHeartbeat > HEARTBEAT_INTERVAL) {
        publishSystemHeartbeat();
        lastHeartbeat = millis();
    }
    
    // Publicar telemetria periodicamente
    if (millis() - lastTelemetry > TELEMETRY_INTERVAL) {
        publishSystemTelemetry();
        lastTelemetry = millis();
    }
    
    // Verificar botão de emergency stop físico (GPIO 0)
    if (digitalRead(EMERGENCY_SHUTOFF_PIN) == LOW) {
        LOG_WARN("Botão de emergency stop pressionado!");
        emergencyShutdown = true;
    }
}

void handleErrorState() {
    static unsigned long lastErrorLog = 0;
    
    if (millis() - lastErrorLog > 30000) {  // A cada 30 segundos
        LOG_ERROR("Sistema em estado de erro - tentando recuperação");
        LOG_MEMORY();
        LOG_SYSTEM();
        lastErrorLog = millis();
        
        // Tentar recovery após um tempo
        if (millis() - stateChangeTime > 60000) {  // 1 minuto em erro
            changeState(RECOVERY);
        }
    }
    
    // Manter relés desligados por segurança
    if (relayController.isInitialized()) {
        relayController.emergencyStop();
    }
}

// ============================================
// TELEMETRIA E HEARTBEAT
// ============================================

void publishSystemHeartbeat() {
    if (!mqttClient.isConnected()) {
        return;
    }
    
    JsonDocument doc;
    doc["device_uuid"] = configManager.getDeviceUUID();
    doc["timestamp"] = millis();
    doc["uptime"] = millis() / 1000;
    doc["state"] = currentState;
    doc["wifi_signal"] = WiFi.RSSI();
    doc["free_memory"] = ESP.getFreeHeap();
    doc["active_relays"] = relayController.getActiveRelaysCount();
    doc["watchdog_feeds"] = watchdog.getFeedCount();
    
    String payload;
    serializeJson(doc, payload);
    
    String heartbeatTopic = String(MQTT_DEVICE_TOPIC_PREFIX) + "/" + 
                           configManager.getDeviceUUID() + "/heartbeat";
    mqttClient.publish(heartbeatTopic, payload);
    
    if (watchdog.debugEnabled) {
        LOG_DEBUG("Heartbeat publicado");
    }
}

void publishSystemTelemetry() {
    if (!mqttClient.isConnected()) {
        return;
    }
    
    // Usar telemetria do controlador de relés
    String telemetry = relayController.getAllChannelsTelemetryJSON();
    mqttClient.publishTelemetry(telemetry);
    
    if (relayController.debugEnabled) {
        LOG_DEBUG("Telemetria publicada");
    }
}

// ============================================
// RECOVERY E EMERGENCY
// ============================================

void handleEmergencyShutdown() {
    LOG_ERROR("🚨 EMERGENCY SHUTDOWN EM PROGRESSO 🚨");
    
    // Parar todos os relés
    if (relayController.isInitialized()) {
        relayController.emergencyStop();
    }
    
    // Publicar evento de emergency
    if (mqttClient.isConnected()) {
        JsonDocument doc;
        doc["event"] = "emergency_shutdown";
        doc["timestamp"] = millis();
        doc["reason"] = "manual_trigger";
        
        String payload;
        serializeJson(doc, payload);
        mqttClient.publishSafetyEvent(payload);
    }
    
    // Aguardar confirmação manual para sair do estado
    if (digitalRead(EMERGENCY_SHUTOFF_PIN) == HIGH) {
        LOG_INFO("Emergency stop liberado - sistema pode ser reiniciado");
        emergencyShutdown = false;
        
        // Reset emergency stop do controlador
        relayController.resetEmergencyStop();
    }
    
    delay(100);
}

void systemRecovery() {
    LOG_WARN("Iniciando recuperação do sistema...");
    
    // Resetar componentes
    relayController.resetAllSafetyFlags();
    mqttClient.enableAutoReconnect(true);
    
    // Tentar reconectar WiFi
    if (WiFi.status() != WL_CONNECTED) {
        DeviceConfig& config = configManager.getConfig();
        WiFi.begin(config.wifi_ssid.c_str(), config.wifi_password.c_str());
    }
    
    // Aguardar um pouco e tentar voltar ao normal
    delay(5000);
    
    if (WiFi.status() == WL_CONNECTED) {
        LOG_INFO("Recovery bem-sucedido - voltando ao modo normal");
        changeState(RUNNING);
    } else {
        LOG_ERROR("Recovery falhou - voltando ao estado de erro");
        changeState(ERROR_STATE);
    }
}

void handleWatchdogReset(String reason) {
    LOG_ERROR("🚨 WATCHDOG RESET TRIGGERED: %s", reason.c_str());
    
    // Safe shutdown antes do reset
    if (relayController.isInitialized()) {
        relayController.emergencyStop();
    }
    
    // Log final
    LOG_ERROR("Sistema será resetado em 3 segundos...");
    delay(3000);
}

// ============================================
// UTILITÁRIOS
// ============================================

void printSystemInfo() {
    LOG_INFO("=== INFORMAÇÕES DO SISTEMA ===");
    LOG_INFO("UUID: %s", configManager.getDeviceUUID().c_str());
    LOG_INFO("Nome: %s", configManager.getDeviceName().c_str());
    LOG_INFO("Estado: %d", currentState);
    LOG_INFO("Uptime: %lu segundos", millis() / 1000);
    LOG_INFO("WiFi: %s (%s)", WiFi.isConnected() ? "Conectado" : "Desconectado",
             WiFi.isConnected() ? WiFi.localIP().toString().c_str() : "N/A");
    LOG_INFO("MQTT: %s", mqttClient.isConnected() ? "Conectado" : "Desconectado");
    LOG_INFO("Relés ativos: %d/%d", relayController.getActiveRelaysCount(), 
             relayController.getTotalChannels());
    LOG_INFO("Memória livre: %d bytes", ESP.getFreeHeap());
    LOG_INFO("Watchdog feeds: %lu", watchdog.getFeedCount());
    LOG_INFO("==============================");
}