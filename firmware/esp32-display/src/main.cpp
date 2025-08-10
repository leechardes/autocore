/**
 * AutoCore ESP32 Display Firmware
 * Sistema completo de display touch com interface LVGL via MQTT
 * 
 * Características:
 * - Display touch 320x240 com LVGL
 * - Configuração via web server moderno
 * - Cliente MQTT com eventos em tempo real
 * - Renderização dinâmica baseada no backend
 * - Sistema de navegação touch e física
 * - Proteções de segurança integradas
 * 
 * Fase 1: SIMULAÇÃO - Interface completa sem hardware de display
 * 
 * Desenvolvido para o ecossistema AutoCore
 * https://github.com/leechardes/autocore
 */

#include <Arduino.h>
#include <WiFi.h>
#include <SPIFFS.h>

// Módulos do sistema
#include "config/config_manager.h"
#include "network/wifi_manager.h"
#include "network/web_server.h"
#include "network/api_client.h"
#include "mqtt/mqtt_client.h"
#include "mqtt/mqtt_handler.h"
#include "utils/logger.h"
#include "utils/watchdog.h"

// Estados do sistema (compatível com firmware de relé)
enum SystemState {
    BOOTING,
    CONFIGURING,
    CONNECTING,
    INITIALIZING_DISPLAY,
    RUNNING,
    ERROR_STATE,
    RECOVERY,
    SLEEPING
};

SystemState currentState = BOOTING;
unsigned long stateChangeTime = 0;
unsigned long lastHeartbeat = 0;
unsigned long lastTelemetry = 0;
unsigned long lastConfigSync = 0;

// Configurações de timing
const unsigned long HEARTBEAT_INTERVAL = 30000;    // 30 segundos
const unsigned long TELEMETRY_INTERVAL = 5000;     // 5 segundos  
const unsigned long CONFIG_SYNC_INTERVAL = 300000; // 5 minutos
const unsigned long STATE_TIMEOUT = 60000;         // 60 segundos timeout

// Flags de controle
bool systemInitialized = false;
bool configurationMode = false;
bool emergencyShutdown = false;
bool displayReady = false;
bool mqttConfigReceived = false;

// Contadores de desempenho
unsigned long loopCounter = 0;
unsigned long lastPerformanceLog = 0;

// Protótipos das funções
void setup();
void loop();
bool initializeSystem();
void changeState(SystemState newState);
void handleSystemState();
void handleConfigurationMode();
void handleRunningMode();
void handleErrorState();
void handleDisplayInitialization();
void publishSystemHeartbeat();
void publishSystemTelemetry();
void syncConfigurationWithBackend();
void handleEmergencyShutdown();
void systemRecovery();
void printSystemInfo();
void printPerformanceInfo();
void handleWatchdogReset(String reason);
void setupInterrupts();

// ============================================
// SETUP - Inicialização do sistema
// ============================================

void setup() {
    // Inicializar Serial e Logger o mais cedo possível
    Serial.begin(115200);
    delay(1000);
    
    // Inicializar logger
    Logger::begin(LOG_LEVEL_INFO, true);
    
    LOG_HEADER("AutoCore ESP32 Display v" + String(FIRMWARE_VERSION));
    LOG_INFO("Build: %s", __DATE__ " " __TIME__);
    LOG_INFO("Chip: %s (Rev %d)", ESP.getChipModel(), ESP.getChipRevision());
    LOG_INFO("CPU: %d MHz", ESP.getCpuFreqMHz());
    LOG_INFO("Flash: %s", Logger::formatBytes(ESP.getFlashChipSize()).c_str());
    LOG_INFO("Free RAM: %s", Logger::formatBytes(ESP.getFreeHeap()).c_str());
    if (ESP.getPsramSize() > 0) {
        LOG_INFO("PSRAM: %s", Logger::formatBytes(ESP.getPsramSize()).c_str());
    }
    LOG_SEPARATOR();
    
    // Configurar watchdog com callback
    watchdog.setResetCallback(handleWatchdogReset);
    
    // Inicializar sistema
    changeState(BOOTING);
    
    if (initializeSystem()) {
        systemInitialized = true;
        LOG_INFO("✅ Sistema inicializado com sucesso!");
        
        // Verificar se precisa entrar em modo de configuração
        if (!configManager.isConfigured()) {
            LOG_WARN("⚠️  Dispositivo não configurado - entrando em modo de configuração");
            configurationMode = true;
            changeState(CONFIGURING);
        } else {
            LOG_INFO("🔗 Dispositivo configurado - iniciando conexão");
            changeState(CONNECTING);
        }
    } else {
        LOG_ERROR("❌ Falha na inicialização do sistema!");
        changeState(ERROR_STATE);
    }
    
    // Feed inicial do watchdog
    watchdog.feed();
    
    LOG_INFO("🚀 Setup concluído - Estado: %s", getStateString().c_str());
}

// ============================================
// LOOP PRINCIPAL
// ============================================

void loop() {
    // Alimentar watchdog - CRÍTICO
    watchdog.feed();
    watchdog.feedTask("main_loop");
    
    // Incrementar contador de loops
    loopCounter++;
    
    // Verificar emergency shutdown
    if (emergencyShutdown) {
        handleEmergencyShutdown();
        return;
    }
    
    // Processar estado atual
    handleSystemState();
    
    // Operações contínuas quando o sistema está rodando
    if (currentState == RUNNING && systemInitialized) {
        handleRunningMode();
    }
    
    // Operações contínuas no modo configuração
    if (currentState == CONFIGURING) {
        handleConfigurationMode();
    }
    
    // Atualizar componentes do sistema
    if (systemInitialized) {
        // Atualizar WiFi manager
        wifiManager.update();
        watchdog.feedTask("wifi_check");
        
        // Atualizar servidor web (assíncrono, não requer update manual)
        // webServer.update();
        
        // Loop MQTT se conectado
        if (mqttClient.isInitialized()) {
            mqttClient.loop();
            watchdog.feedTask("mqtt_loop");
        }
        
        // Atualizar handler MQTT
        mqttHandler.update();
        
        // Atualizar watchdog
        watchdog.update();
    }
    
    // Log de performance periodicamente
    if (millis() - lastPerformanceLog > 60000) {  // A cada minuto
        printPerformanceInfo();
        lastPerformanceLog = millis();
    }
    
    // Yield para outras tasks
    yield();
    delay(5);  // Pequeno delay para não sobrecarregar CPU
}

// ============================================
// INICIALIZAÇÃO DO SISTEMA
// ============================================

bool initializeSystem() {
    LOG_INFO("🔧 Inicializando componentes do sistema...");
    
    // 1. Inicializar watchdog
    if (!watchdog.begin(30)) {  // 30 segundos timeout
        LOG_ERROR("❌ Falha ao inicializar watchdog");
        return false;
    }
    watchdog.enable();
    
    // 2. Inicializar gerenciador de configuração
    if (!configManager.begin()) {
        LOG_ERROR("❌ Falha ao inicializar gerenciador de configuração");
        return false;
    }
    
    // 3. Montar SPIFFS para servidor web
    if (!SPIFFS.begin(true)) {
        LOG_WARN("⚠️  Falha ao montar SPIFFS - servidor web usará HTML inline");
    } else {
        LOG_INFO("💾 SPIFFS montado com sucesso");
    }
    
    // 4. Inicializar gerenciador WiFi
    if (!wifiManager.begin()) {
        LOG_ERROR("❌ Falha ao inicializar gerenciador WiFi");
        return false;
    }
    
    // 5. Inicializar servidor web
    if (!webServer.begin(WEB_SERVER_PORT)) {
        LOG_ERROR("❌ Falha ao inicializar servidor web");
        return false;
    }
    
    // 6. Inicializar handler MQTT
    if (!mqttHandler.begin()) {
        LOG_ERROR("❌ Falha ao inicializar handler MQTT");
        return false;
    }
    
    // 7. Configurar callback MQTT
    mqttClient.onMessage([](String topic, String payload) {
        mqttHandler.handleMessage(topic, payload);
        watchdog.feedTask("mqtt_loop");
    });
    
    mqttClient.onConnection([](bool connected) {
        if (connected) {
            LOG_INFO("🌐 MQTT conectado - publicando status inicial");
            mqttClient.publishDeviceAnnounce();
        } else {
            LOG_WARN("🔌 MQTT desconectado");
        }
    });
    
    // 8. Configurar interrupções (botões físicos, touch)
    setupInterrupts();
    
    LOG_INFO("✅ Todos os componentes inicializados com sucesso");
    return true;
}

void setupInterrupts() {
    // SIMULADO: Configurar interrupções para botões físicos
    LOG_INFO_CTX("Interrupts", "SIMULADO: Configurando interrupções de botões");
    
    // pinMode(BTN_PREV, INPUT_PULLUP);
    // pinMode(BTN_SELECT, INPUT_PULLUP);  
    // pinMode(BTN_NEXT, INPUT_PULLUP);
    // pinMode(EMERGENCY_SHUTOFF_PIN, INPUT_PULLUP);
    
    // attachInterrupt(digitalPinToInterrupt(EMERGENCY_SHUTOFF_PIN), []() {
    //     emergencyShutdown = true;
    // }, FALLING);
}

// ============================================
// GERENCIAMENTO DE ESTADOS
// ============================================

void changeState(SystemState newState) {
    if (currentState != newState) {
        String oldState = getStateString();
        currentState = newState;
        stateChangeTime = millis();
        
        LOG_INFO("🔄 Estado: %s -> %s", oldState.c_str(), getStateString().c_str());
        
        // Ações específicas por estado
        switch (newState) {
            case BOOTING:
                LOG_INFO("🚀 Estado: INICIALIZANDO");
                break;
                
            case CONFIGURING:
                LOG_INFO("⚙️  Estado: MODO CONFIGURAÇÃO");
                // Iniciar Access Point
                wifiManager.enableAPMode();
                break;
                
            case CONNECTING:
                LOG_INFO("🔗 Estado: CONECTANDO");
                break;
                
            case INITIALIZING_DISPLAY:
                LOG_INFO("📺 Estado: INICIALIZANDO DISPLAY");
                break;
                
            case RUNNING:
                LOG_INFO("🟢 Estado: OPERANDO");
                break;
                
            case ERROR_STATE:
                LOG_ERROR("🔴 Estado: ERRO");
                break;
                
            case RECOVERY:
                LOG_WARN("🔄 Estado: RECUPERAÇÃO");
                break;
                
            case SLEEPING:
                LOG_INFO("😴 Estado: DORMINDO");
                break;
        }
    }
}

String getStateString() {
    switch (currentState) {
        case BOOTING: return "BOOTING";
        case CONFIGURING: return "CONFIGURING";
        case CONNECTING: return "CONNECTING";
        case INITIALIZING_DISPLAY: return "INITIALIZING_DISPLAY";
        case RUNNING: return "RUNNING";
        case ERROR_STATE: return "ERROR";
        case RECOVERY: return "RECOVERY";
        case SLEEPING: return "SLEEPING";
        default: return "UNKNOWN";
    }
}

void handleSystemState() {
    unsigned long stateTime = millis() - stateChangeTime;
    
    switch (currentState) {
        case BOOTING:
            // Estado transitório - já deve ter mudado no setup
            if (stateTime > 10000) {
                LOG_ERROR("⏰ Timeout no boot - indo para estado de erro");
                changeState(ERROR_STATE);
            }
            break;
            
        case CONFIGURING:
            // Verificar se foi configurado
            if (configManager.isConfigured()) {
                LOG_INFO("✅ Configuração concluída - tentando conectar");
                changeState(CONNECTING);
            }
            break;
            
        case CONNECTING:
            handleConnecting();
            break;
            
        case INITIALIZING_DISPLAY:
            handleDisplayInitialization();
            break;
            
        case RUNNING:
            // Verificar conectividade
            if (!wifiManager.isConnected()) {
                LOG_WARN("📡 WiFi desconectado - tentando reconectar");
                changeState(CONNECTING);
            }
            break;
            
        case ERROR_STATE:
            handleErrorState();
            break;
            
        case RECOVERY:
            systemRecovery();
            break;
            
        case SLEEPING:
            // Estado de baixo consumo
            delay(100);
            break;
    }
}

void handleConnecting() {
    const DeviceConfig& config = configManager.getConfig();
    
    // Tentar conectar WiFi
    if (!wifiManager.isConnected()) {
        if (config.wifi_ssid.length() > 0) {
            if (!wifiManager.connect(config.wifi_ssid, config.wifi_password)) {
                // Conexão já está sendo tentada, aguardar
                unsigned long stateTime = millis() - stateChangeTime;
                if (stateTime > STATE_TIMEOUT) {
                    LOG_ERROR("⏰ Timeout na conexão WiFi - voltando para configuração");
                    changeState(CONFIGURING);
                }
                return;
            }
        } else {
            LOG_ERROR("❌ Credenciais WiFi não configuradas");
            changeState(CONFIGURING);
            return;
        }
    }
    
    // WiFi conectado, configurar serviços
    if (wifiManager.isConnected()) {
        LOG_INFO("📶 WiFi conectado: %s", wifiManager.getLocalIP().toString().c_str());
        
        // Inicializar cliente API se configurado
        if (config.backend_host.length() > 0) {
            if (!apiClient.begin(config.backend_host, config.backend_port, config.backend_api_key)) {
                LOG_ERROR("❌ Falha ao inicializar cliente API");
            } else {
                LOG_INFO("🌐 Cliente API inicializado");
            }
        }
        
        // Tentar conectar MQTT se configurado
        if (config.mqtt_broker.length() > 0) {
            if (!mqttClient.begin(config.device_uuid, config.mqtt_broker, 
                                config.mqtt_port, config.mqtt_user, config.mqtt_password)) {
                LOG_ERROR("❌ Falha ao inicializar cliente MQTT");
            } else {
                LOG_INFO("📡 Cliente MQTT inicializado");
                mqttClient.connect();
            }
        }
        
        // Sincronizar configuração com backend
        syncConfigurationWithBackend();
        
        // Avançar para inicialização do display
        changeState(INITIALIZING_DISPLAY);
    }
}

void handleDisplayInitialization() {
    LOG_INFO("🖥️  SIMULADO: Inicializando display LVGL");
    
    // SIMULADO: Inicialização do display touch
    LOG_INFO("📱 SIMULADO: Display 320x240 inicializado");
    LOG_INFO("👆 SIMULADO: Touch controller configurado");
    LOG_INFO("🎨 SIMULADO: LVGL inicializado");
    LOG_INFO("📋 SIMULADO: Screen manager configurado");
    LOG_INFO("🔘 SIMULADO: Navigation bar criada");
    LOG_INFO("📊 SIMULADO: Status bar criada");
    
    // Simular tempo de inicialização
    static unsigned long displayInitStart = 0;
    if (displayInitStart == 0) {
        displayInitStart = millis();
    }
    
    if (millis() - displayInitStart > 2000) {  // 2 segundos para "inicializar"
        displayReady = true;
        LOG_INFO("✅ Display inicializado com sucesso");
        changeState(RUNNING);
    }
}

// ============================================
// MODOS DE OPERAÇÃO
// ============================================

void handleConfigurationMode() {
    // No modo configuração, apenas manter servidor web ativo
    static unsigned long lastConfigStatus = 0;
    
    if (millis() - lastConfigStatus > 30000) {  // A cada 30 segundos
        LOG_INFO("⚙️  Modo configuração ativo - aguardando configuração via web");
        LOG_INFO("🌐 Acesse: http://%s", wifiManager.getAPIP().toString().c_str());
        LOG_INFO("📱 SSID: %s | Senha: %s", wifiManager.getAPName().c_str(), AP_PASSWORD);
        lastConfigStatus = millis();
    }
}

void handleRunningMode() {
    // SIMULADO: Atualizar display e UI
    watchdog.feedTask("display_update");
    
    // Loop MQTT
    if (mqttClient.isInitialized() && !mqttClient.isConnected()) {
        mqttClient.connect();
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
    
    // Sincronizar configuração periodicamente
    if (millis() - lastConfigSync > CONFIG_SYNC_INTERVAL) {
        syncConfigurationWithBackend();
        lastConfigSync = millis();
    }
    
    // SIMULADO: Verificar botão de emergency stop
    // if (digitalRead(EMERGENCY_SHUTOFF_PIN) == LOW) {
    //     LOG_WARN("🚨 Botão de emergency stop pressionado!");
    //     emergencyShutdown = true;
    // }
}

void handleErrorState() {
    static unsigned long lastErrorLog = 0;
    
    if (millis() - lastErrorLog > 30000) {  // A cada 30 segundos
        LOG_ERROR("🔴 Sistema em estado de erro - tentando recuperação");
        LOG_MEMORY();
        LOG_SYSTEM();
        lastErrorLog = millis();
        
        // Tentar recovery após um tempo
        unsigned long stateTime = millis() - stateChangeTime;
        if (stateTime > 60000) {  // 1 minuto em erro
            changeState(RECOVERY);
        }
    }
    
    // SIMULADO: Manter display em estado de erro
    LOG_DEBUG("🖥️  SIMULADO: Display mostrando tela de erro");
}

// ============================================
// TELEMETRIA E HEARTBEAT
// ============================================

void publishSystemHeartbeat() {
    if (!mqttClient.isConnected()) {
        return;
    }
    
    // Usar método específico do cliente MQTT
    if (mqttClient.publishHeartbeat()) {
        LOG_DEBUG("💓 Heartbeat publicado");
    }
}

void publishSystemTelemetry() {
    if (!mqttClient.isConnected()) {
        return;
    }
    
    DynamicJsonDocument doc(1024);
    doc["device_uuid"] = configManager.getDeviceUUID();
    doc["timestamp"] = millis();
    doc["uptime"] = millis() / 1000;
    doc["state"] = getStateString();
    doc["free_memory"] = ESP.getFreeHeap();
    doc["wifi_signal"] = WiFi.RSSI();
    doc["loop_counter"] = loopCounter;
    doc["display_ready"] = displayReady;
    doc["configuration_mode"] = configurationMode;
    
    // Status dos componentes
    doc["components"]["wifi"] = wifiManager.getStateString();
    doc["components"]["mqtt"] = mqttClient.getStateString();
    doc["components"]["api"] = apiClient.getStateString();
    doc["components"]["watchdog"] = watchdog.getStateString();
    
    String telemetry;
    serializeJson(doc, telemetry);
    
    if (mqttClient.publishTelemetry(telemetry)) {
        LOG_DEBUG("📊 Telemetria publicada");
    }
}

void syncConfigurationWithBackend() {
    if (!apiClient.isInitialized()) {
        return;
    }
    
    LOG_INFO("🔄 Sincronizando configuração com backend");
    
    // Buscar configuração completa do display
    APIResponse response = apiClient.getDisplayConfig(configManager.getDeviceUUID());
    
    if (response.success) {
        LOG_INFO("✅ Configuração recebida do backend (%d bytes)", response.data.length());
        
        // Parsear e aplicar configuração
        if (apiClient.parseDisplayConfig(response.data, configManager.getConfig())) {
            configManager.save();
            mqttConfigReceived = true;
            
            // SIMULADO: Recarregar interface
            LOG_INFO("🎨 SIMULADO: Interface recarregada com nova configuração");
        } else {
            LOG_ERROR("❌ Falha ao parsear configuração do backend");
        }
    } else {
        LOG_WARN("⚠️  Falha ao sincronizar configuração: %s", response.error.c_str());
    }
}

// ============================================
// RECOVERY E EMERGENCY
// ============================================

void handleEmergencyShutdown() {
    LOG_ERROR("🚨 EMERGENCY SHUTDOWN EM PROGRESSO 🚨");
    
    // SIMULADO: Parar todas as ações do display
    LOG_INFO("🖥️  SIMULADO: Display entrando em modo de emergência");
    LOG_INFO("🔴 SIMULADO: Todas as interações bloqueadas");
    
    // Publicar evento de emergency
    if (mqttClient.isConnected()) {
        mqttClient.sendSystemAlert("emergency", "Display em modo de emergência");
    }
    
    // SIMULADO: Aguardar liberação do emergency stop
    // if (digitalRead(EMERGENCY_SHUTOFF_PIN) == HIGH) {
    //     LOG_INFO("✅ Emergency stop liberado - sistema pode ser reiniciado");
    //     emergencyShutdown = false;
    // }
    
    // Para simulação, sair do emergency após 10 segundos
    static unsigned long emergencyStart = 0;
    if (emergencyStart == 0) emergencyStart = millis();
    if (millis() - emergencyStart > 10000) {
        LOG_INFO("✅ SIMULADO: Emergency stop liberado");
        emergencyShutdown = false;
        emergencyStart = 0;
    }
    
    delay(100);
}

void systemRecovery() {
    LOG_WARN("🔧 Iniciando recuperação do sistema...");
    
    // Reset componentes
    watchdog.enable();  // Reabilitar watchdog
    mqttClient.enableAutoReconnect(true);
    
    // Tentar reconectar WiFi
    if (!wifiManager.isConnected()) {
        const DeviceConfig& config = configManager.getConfig();
        wifiManager.connect(config.wifi_ssid, config.wifi_password);
    }
    
    // Aguardar um pouco e tentar voltar ao normal
    delay(5000);
    
    if (wifiManager.isConnected()) {
        LOG_INFO("✅ Recovery bem-sucedido - voltando ao modo normal");
        changeState(RUNNING);
    } else {
        LOG_ERROR("❌ Recovery falhou - voltando ao estado de erro");
        changeState(ERROR_STATE);
    }
}

void handleWatchdogReset(String reason) {
    LOG_ERROR("🚨 WATCHDOG RESET TRIGGERED: %s", reason.c_str());
    
    // SIMULADO: Safe shutdown do display
    LOG_INFO("🖥️  SIMULADO: Display entrando em modo seguro");
    
    // Log final
    LOG_ERROR("🔄 Sistema será resetado em 3 segundos...");
    delay(3000);
}

// ============================================
// UTILITÁRIOS E DEBUG
// ============================================

void printSystemInfo() {
    LOG_SEPARATOR("INFORMAÇÕES DO SISTEMA");
    LOG_INFO("UUID: %s", configManager.getDeviceUUID().c_str());
    LOG_INFO("Nome: %s", configManager.getDeviceName().c_str());
    LOG_INFO("Estado: %s", getStateString().c_str());
    LOG_INFO("Uptime: %s", Logger::formatUptime(millis()).c_str());
    LOG_INFO("WiFi: %s (%s)", 
             wifiManager.isConnected() ? "Conectado" : "Desconectado",
             wifiManager.isConnected() ? wifiManager.getLocalIP().toString().c_str() : "N/A");
    LOG_INFO("MQTT: %s", mqttClient.isConnected() ? "Conectado" : "Desconectado");
    LOG_INFO("Display: %s", displayReady ? "Pronto" : "Não inicializado");
    LOG_INFO("Memória livre: %s", Logger::formatBytes(ESP.getFreeHeap()).c_str());
    LOG_INFO("Loops executados: %lu", loopCounter);
    LOG_SEPARATOR();
}

void printPerformanceInfo() {
    static unsigned long lastLoopCount = 0;
    unsigned long loopsPerMinute = loopCounter - lastLoopCount;
    lastLoopCount = loopCounter;
    
    LOG_DEBUG("⚡ Performance: %lu loops/min | Mem: %s | Estado: %s", 
             loopsPerMinute, 
             Logger::formatBytes(ESP.getFreeHeap()).c_str(),
             getStateString().c_str());
}