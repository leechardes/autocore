/**
 * AutoCore ESP32 Display - Watchdog Implementation
 */

#include "watchdog.h"
#include "logger.h"
#include <esp_system.h>

// Instância global
Watchdog watchdog;

Watchdog::Watchdog() 
    : currentState(WDT_DISABLED),
      initialized(false),
      enabled(false),
      timeoutSeconds(DEFAULT_TIMEOUT),
      lastFeed(0),
      feedCount(0),
      lastTaskCheck(0),
      warningIssued(false),
      warningTime(0) {
}

Watchdog::~Watchdog() {
    disable();
}

bool Watchdog::begin(int timeout) {
    LOG_INFO_CTX("Watchdog", "Inicializando sistema de watchdog");
    
    // Validar timeout
    if (timeout < MIN_TIMEOUT || timeout > MAX_TIMEOUT) {
        LOG_ERROR_CTX("Watchdog", "Timeout inválido: %d segundos (min: %d, max: %d)",
                     timeout, MIN_TIMEOUT, MAX_TIMEOUT);
        return false;
    }
    
    timeoutSeconds = timeout;
    
    // Inicializar ESP32 Task Watchdog
    esp_task_wdt_config_t config = {
        .timeout_ms = timeoutSeconds * 1000,
        .idle_core_mask = 0,  // Não monitorar idle cores
        .trigger_panic = false  // Não entrar em pânico, usar callback
    };
    
    esp_err_t result = esp_task_wdt_init(&config);
    if (result != ESP_OK) {
        LOG_ERROR_CTX("Watchdog", "Falha ao inicializar ESP Task WDT: %d", result);
        return false;
    }
    
    // Adicionar task atual ao watchdog
    result = esp_task_wdt_add(NULL);
    if (result != ESP_OK) {
        LOG_ERROR_CTX("Watchdog", "Falha ao adicionar task ao WDT: %d", result);
        return false;
    }
    
    initialized = true;
    currentState = WDT_DISABLED;
    
    // Registrar tasks básicas do sistema
    addTask("main_loop", 10000);      // Loop principal - 10s max
    addTask("wifi_check", 30000);     // Verificação WiFi - 30s max
    addTask("mqtt_loop", 15000);      // Loop MQTT - 15s max
    addTask("display_update", 5000);  // Atualização display - 5s max
    
    LOG_INFO_CTX("Watchdog", "Watchdog inicializado - Timeout: %d segundos", timeoutSeconds);
    LOG_INFO_CTX("Watchdog", "Reset reason: %s", getResetReason().c_str());
    
    return true;
}

bool Watchdog::enable() {
    if (!initialized) {
        LOG_ERROR_CTX("Watchdog", "Watchdog não inicializado");
        return false;
    }
    
    if (enabled) {
        LOG_WARN_CTX("Watchdog", "Watchdog já habilitado");
        return true;
    }
    
    enabled = true;
    currentState = WDT_ENABLED;
    lastFeed = millis();
    warningIssued = false;
    
    LOG_INFO_CTX("Watchdog", "Watchdog habilitado");
    return true;
}

bool Watchdog::disable() {
    if (!initialized) {
        return true;
    }
    
    enabled = false;
    currentState = WDT_DISABLED;
    
    LOG_WARN_CTX("Watchdog", "Watchdog desabilitado");
    return true;
}

void Watchdog::setTimeout(int seconds) {
    if (seconds < MIN_TIMEOUT || seconds > MAX_TIMEOUT) {
        LOG_ERROR_CTX("Watchdog", "Timeout inválido: %d segundos", seconds);
        return;
    }
    
    int oldTimeout = timeoutSeconds;
    timeoutSeconds = seconds;
    
    // Reconfigurar ESP Task WDT se inicializado
    if (initialized) {
        esp_task_wdt_config_t config = {
            .timeout_ms = timeoutSeconds * 1000,
            .idle_core_mask = 0,
            .trigger_panic = false
        };
        
        esp_task_wdt_reconfigure(&config);
        
        LOG_INFO_CTX("Watchdog", "Timeout alterado: %d -> %d segundos", 
                    oldTimeout, timeoutSeconds);
    }
}

void Watchdog::setResetCallback(WatchdogResetCallback callback) {
    resetCallback = callback;
    LOG_DEBUG_CTX("Watchdog", "Callback de reset configurado");
}

WatchdogState Watchdog::getState() const {
    return currentState;
}

String Watchdog::getStateString() const {
    switch (currentState) {
        case WDT_DISABLED: return "DESABILITADO";
        case WDT_ENABLED: return "HABILITADO";
        case WDT_FEEDING: return "ATIVO";
        case WDT_WARNING: return "AVISO";
        case WDT_TIMEOUT: return "TIMEOUT";
        default: return "DESCONHECIDO";
    }
}

void Watchdog::feed() {
    if (!enabled) {
        return;
    }
    
    lastFeed = millis();
    feedCount++;
    currentState = WDT_FEEDING;
    
    // Reset ESP Task WDT
    esp_task_wdt_reset();
    
    // Reset warning state
    if (warningIssued) {
        warningIssued = false;
        LOG_INFO_CTX("Watchdog", "Sistema recuperado do estado de aviso");
    }
    
    if (debugEnabled && feedCount % 100 == 0) {  // Log a cada 100 feeds
        LOG_DEBUG_CTX("Watchdog", "Watchdog fed - Count: %lu", feedCount);
    }
}

void Watchdog::addTask(const String& taskName, unsigned long maxInterval) {
    TaskInfo task(taskName, maxInterval);
    monitoredTasks[taskName] = task;
    
    LOG_DEBUG_CTX("Watchdog", "Task adicionada: %s (max: %s)", 
                 taskName.c_str(), formatInterval(maxInterval).c_str());
}

void Watchdog::removeTask(const String& taskName) {
    auto it = monitoredTasks.find(taskName);
    if (it != monitoredTasks.end()) {
        monitoredTasks.erase(it);
        LOG_DEBUG_CTX("Watchdog", "Task removida: %s", taskName.c_str());
    }
}

void Watchdog::feedTask(const String& taskName) {
    auto it = monitoredTasks.find(taskName);
    if (it != monitoredTasks.end()) {
        it->second.lastFeed = millis();
        it->second.feedCount++;
        
        if (debugEnabled && it->second.feedCount % 50 == 0) {  // Log a cada 50 feeds
            LOG_VERBOSE_CTX("Watchdog", "Task %s fed - Count: %lu", 
                           taskName.c_str(), it->second.feedCount);
        }
    } else {
        LOG_WARN_CTX("Watchdog", "Task não encontrada para feed: %s", taskName.c_str());
    }
}

void Watchdog::enableTask(const String& taskName, bool enable) {
    auto it = monitoredTasks.find(taskName);
    if (it != monitoredTasks.end()) {
        it->second.enabled = enable;
        LOG_DEBUG_CTX("Watchdog", "Task %s %s", 
                     taskName.c_str(), enable ? "habilitada" : "desabilitada");
    }
}

bool Watchdog::isTaskRegistered(const String& taskName) {
    return monitoredTasks.find(taskName) != monitoredTasks.end();
}

TaskInfo* Watchdog::getTaskInfo(const String& taskName) {
    auto it = monitoredTasks.find(taskName);
    return (it != monitoredTasks.end()) ? &it->second : nullptr;
}

bool Watchdog::isTaskHealthy(const String& taskName) {
    auto it = monitoredTasks.find(taskName);
    if (it == monitoredTasks.end() || !it->second.enabled) {
        return true;  // Task não encontrada ou desabilitada é considerada saudável
    }
    
    unsigned long timeSinceLastFeed = millis() - it->second.lastFeed;
    return timeSinceLastFeed <= it->second.maxInterval;
}

String Watchdog::getUnhealthyTasks() {
    String unhealthy = "";
    
    for (const auto& task : monitoredTasks) {
        if (task.second.enabled && !isTaskHealthy(task.first)) {
            if (unhealthy.length() > 0) unhealthy += ", ";
            unhealthy += task.first;
        }
    }
    
    return unhealthy;
}

void Watchdog::checkTasks() {
    if (!enabled) {
        return;
    }
    
    unsigned long now = millis();
    
    // Verificar apenas periodicamente
    if (now - lastTaskCheck < TASK_CHECK_INTERVAL) {
        return;
    }
    
    lastTaskCheck = now;
    
    String unhealthyTasks = getUnhealthyTasks();
    
    if (unhealthyTasks.length() > 0) {
        String warning = "Tasks não responsivas: " + unhealthyTasks;
        issueWarning(warning);
    }
}

bool Watchdog::checkSystemHealth() {
    if (!enabled) {
        return true;
    }
    
    // Verificar se o watchdog principal está sendo alimentado
    unsigned long timeSinceLastFeed = getTimeSinceLastFeed();
    
    if (timeSinceLastFeed > (timeoutSeconds * 1000 * 0.8)) {  // 80% do timeout
        issueWarning("Watchdog principal próximo do timeout");
        return false;
    }
    
    // Verificar tasks
    String unhealthyTasks = getUnhealthyTasks();
    if (unhealthyTasks.length() > 0) {
        return false;
    }
    
    return true;
}

void Watchdog::update() {
    if (!enabled) {
        return;
    }
    
    checkTasks();
    
    // Verificar timeout geral do sistema
    unsigned long timeSinceLastFeed = getTimeSinceLastFeed();
    unsigned long warningThreshold = (timeoutSeconds * 1000 * 0.9);  // 90% do timeout
    
    if (timeSinceLastFeed > warningThreshold && !warningIssued) {
        issueWarning("Sistema próximo do timeout do watchdog");
    }
}

void Watchdog::issueWarning(const String& reason) {
    if (warningIssued) {
        return;  // Evitar spam de warnings
    }
    
    warningIssued = true;
    warningTime = millis();
    currentState = WDT_WARNING;
    
    LOG_WARN_CTX("Watchdog", "⚠️  AVISO: %s", reason.c_str());
    
    // Dar uma última chance alimentando o watchdog
    feed();
}

void Watchdog::triggerReset(const String& reason) {
    currentState = WDT_TIMEOUT;
    
    LOG_ERROR_CTX("Watchdog", "🚨 WATCHDOG RESET: %s", reason.c_str());
    
    // Chamar callback se definido
    if (resetCallback) {
        resetCallback(reason);
    }
    
    // Forçar reset após um breve delay
    delay(1000);
    ESP.restart();
}

void Watchdog::softReset(const String& reason) {
    LOG_WARN_CTX("Watchdog", "Soft reset solicitado: %s", reason.c_str());
    triggerReset(reason);
}

void Watchdog::hardReset() {
    LOG_ERROR_CTX("Watchdog", "Hard reset solicitado");
    esp_restart();
}

String Watchdog::getStats() const {
    char buffer[512];
    snprintf(buffer, sizeof(buffer),
        "Estado: %s | Timeout: %ds | Feeds: %lu | Último feed: %s atrás | Tasks: %d",
        getStateString().c_str(),
        timeoutSeconds,
        feedCount,
        formatInterval(getTimeSinceLastFeed()).c_str(),
        monitoredTasks.size()
    );
    
    return String(buffer);
}

String Watchdog::getTaskStats() const {
    String stats = "Tasks monitoradas:\n";
    
    for (const auto& task : monitoredTasks) {
        const TaskInfo& info = task.second;
        unsigned long timeSinceLastFeed = millis() - info.lastFeed;
        bool healthy = info.enabled && timeSinceLastFeed <= info.maxInterval;
        
        stats += "  " + info.name + ": ";
        stats += healthy ? "✓" : "✗";
        stats += " (último: " + formatInterval(timeSinceLastFeed) + ")";
        if (!info.enabled) stats += " [DESABILITADA]";
        stats += "\n";
    }
    
    return stats;
}

void Watchdog::printStats() const {
    LOG_INFO("=== WATCHDOG STATS ===");
    LOG_INFO("%s", getStats().c_str());
    LOG_INFO("=====================");
}

void Watchdog::printTaskStats() const {
    LOG_INFO("=== TASK STATS ===");
    String stats = getTaskStats();
    
    // Imprimir linha por linha
    int startPos = 0;
    int endPos;
    while ((endPos = stats.indexOf('\n', startPos)) != -1) {
        String line = stats.substring(startPos, endPos);
        LOG_INFO("%s", line.c_str());
        startPos = endPos + 1;
    }
    
    LOG_INFO("==================");
}

String Watchdog::formatInterval(unsigned long interval) const {
    if (interval < 1000) {
        return String(interval) + "ms";
    } else if (interval < 60000) {
        return String(interval / 1000.0, 1) + "s";
    } else {
        return String(interval / 60000.0, 1) + "min";
    }
}

String Watchdog::getResetReason() {
    esp_reset_reason_t reason = esp_reset_reason();
    
    switch (reason) {
        case ESP_RST_POWERON: return "Power-on reset";
        case ESP_RST_EXT: return "External reset";
        case ESP_RST_SW: return "Software reset";
        case ESP_RST_PANIC: return "Panic reset";
        case ESP_RST_INT_WDT: return "Interrupt watchdog";
        case ESP_RST_TASK_WDT: return "Task watchdog";
        case ESP_RST_WDT: return "Other watchdog";
        case ESP_RST_DEEPSLEEP: return "Deep sleep reset";
        case ESP_RST_BROWNOUT: return "Brownout reset";
        case ESP_RST_SDIO: return "SDIO reset";
        default: return "Unknown reset";
    }
}