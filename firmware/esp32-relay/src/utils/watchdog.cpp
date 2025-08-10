#include "watchdog.h"
#include "logger.h"
#include "../relay/relay_controller.h"
#include <esp_task_wdt.h>
#include <esp_system.h>

// Instância global
Watchdog watchdog;

Watchdog::Watchdog() {
    timeout_ms = WATCHDOG_TIMEOUT_S * 1000;
    
    // Inicializar array de tasks
    for (int i = 0; i < MAX_TASKS; i++) {
        tasks[i].active = false;
    }
}

Watchdog::~Watchdog() {
    end();
}

bool Watchdog::begin(unsigned long timeoutSeconds) {
    if (initialized) {
        LOG_WARN_CTX("Watchdog", "Watchdog já inicializado");
        return true;
    }
    
    LOG_INFO_CTX("Watchdog", "Inicializando watchdog (timeout: %lu s)", timeoutSeconds);
    
    timeout_ms = timeoutSeconds * 1000;
    
    // Configurar ESP32 Task Watchdog
    esp_task_wdt_init(timeoutSeconds, true); // true = panic on timeout
    esp_task_wdt_add(NULL); // Adicionar task atual
    
    // Reset estatísticas
    feedCount = 0;
    timeoutCount = 0;
    consecutiveResets = 0;
    lastFeed = millis();
    
    // Adicionar task principal
    addTask("main_loop", 5000); // 5 segundos timeout
    addTask("mqtt_loop", 10000); // 10 segundos timeout
    addTask("relay_update", 2000); // 2 segundos timeout
    
    initialized = true;
    
    // Habilitar automaticamente
    enable();
    
    LOG_INFO_CTX("Watchdog", "Watchdog inicializado e habilitado");
    
    return true;
}

void Watchdog::end() {
    if (initialized) {
        LOG_INFO_CTX("Watchdog", "Finalizando watchdog");
        
        // Desabilitar
        disable();
        
        // Remover do ESP32 Task Watchdog
        esp_task_wdt_delete(NULL);
        esp_task_wdt_deinit();
        
        initialized = false;
        
        LOG_INFO_CTX("Watchdog", "Watchdog finalizado");
    }
}

bool Watchdog::enable() {
    if (!initialized) {
        LOG_ERROR_CTX("Watchdog", "Watchdog não inicializado");
        return false;
    }
    
    if (enabled) {
        return true;
    }
    
    enabled = true;
    lastFeed = millis();
    
    LOG_INFO_CTX("Watchdog", "Watchdog HABILITADO");
    
    // Feed inicial
    feed();
    
    return true;
}

bool Watchdog::disable() {
    if (!initialized) {
        return false;
    }
    
    if (!enabled) {
        return true;
    }
    
    enabled = false;
    
    LOG_WARN_CTX("Watchdog", "Watchdog DESABILITADO");
    
    return true;
}

void Watchdog::feed() {
    if (!initialized || !enabled) {
        return;
    }
    
    // Feed do ESP32 Task Watchdog
    esp_task_wdt_reset();
    
    lastFeed = millis();
    feedCount++;
    
    if (debugEnabled) {
        LOG_DEBUG_CTX("Watchdog", "Watchdog alimentado (feed #%lu)", feedCount);
    }
}

void Watchdog::reset() {
    LOG_WARN_CTX("Watchdog", "Watchdog reset manual solicitado");
    recordReset("manual");
    
    // Executar callback se definido
    if (resetCallback) {
        resetCallback("manual_reset");
    }
    
    delay(1000);
    esp_restart();
}

bool Watchdog::addTask(const String& taskName, unsigned long timeoutMs) {
    if (taskCount >= MAX_TASKS) {
        LOG_ERROR_CTX("Watchdog", "Máximo de tasks atingido (%d)", MAX_TASKS);
        return false;
    }
    
    // Verificar se task já existe
    int existingIndex = findTaskIndex(taskName);
    if (existingIndex >= 0) {
        // Atualizar task existente
        tasks[existingIndex].timeout = timeoutMs;
        tasks[existingIndex].lastActivity = millis();
        LOG_DEBUG_CTX("Watchdog", "Task atualizada: %s (timeout: %lu ms)", 
                      taskName.c_str(), timeoutMs);
        return true;
    }
    
    // Encontrar slot vazio
    for (int i = 0; i < MAX_TASKS; i++) {
        if (!tasks[i].active) {
            tasks[i].name = taskName;
            tasks[i].timeout = timeoutMs;
            tasks[i].lastActivity = millis();
            tasks[i].active = true;
            taskCount++;
            
            LOG_INFO_CTX("Watchdog", "Task adicionada: %s (timeout: %lu ms)", 
                         taskName.c_str(), timeoutMs);
            return true;
        }
    }
    
    LOG_ERROR_CTX("Watchdog", "Não foi possível adicionar task: %s", taskName.c_str());
    return false;
}

void Watchdog::removeTask(const String& taskName) {
    int index = findTaskIndex(taskName);
    if (index >= 0) {
        tasks[index].active = false;
        tasks[index].name = "";
        taskCount--;
        
        LOG_INFO_CTX("Watchdog", "Task removida: %s", taskName.c_str());
    }
}

void Watchdog::feedTask(const String& taskName) {
    int index = findTaskIndex(taskName);
    if (index >= 0) {
        tasks[index].lastActivity = millis();
        
        if (debugEnabled) {
            LOG_DEBUG_CTX("Watchdog", "Task alimentada: %s", taskName.c_str());
        }
    }
}

void Watchdog::checkTasks() {
    if (!initialized || !enabled) {
        return;
    }
    
    unsigned long now = millis();
    
    for (int i = 0; i < MAX_TASKS; i++) {
        if (!tasks[i].active) continue;
        
        unsigned long timeSinceLastActivity = now - tasks[i].lastActivity;
        
        if (timeSinceLastActivity > tasks[i].timeout) {
            LOG_ERROR_CTX("Watchdog", "Task timeout detectado: %s (%lu ms sem atividade)", 
                          tasks[i].name.c_str(), timeSinceLastActivity);
            
            // Trigger recovery se habilitado
            if (autoRecoveryEnabled) {
                triggerRecovery("task_timeout_" + tasks[i].name);
            } else {
                // Apenas log de erro
                LOG_ERROR_CTX("Watchdog", "Auto-recovery desabilitado, continuando...");
            }
        }
    }
}

void Watchdog::triggerRecovery(const String& reason) {
    LOG_WARN_CTX("Watchdog", "Triggering recovery - Razão: %s", reason.c_str());
    
    consecutiveResets++;
    recordReset(reason);
    
    // Executar callback se definido
    if (resetCallback) {
        resetCallback(reason);
    }
    
    // Verificar se há muitos resets consecutivos
    if (consecutiveResets >= 5) {
        LOG_ERROR_CTX("Watchdog", "Muitos resets consecutivos (%d), desabilitando auto-recovery", 
                      consecutiveResets);
        autoRecoveryEnabled = false;
        
        // Apenas desligar relés, não resetar
        relayController.emergencyStop();
        return;
    }
    
    // Safe shutdown antes do reset
    safeShutdown();
    
    // Delay para permitir logs
    delay(2000);
    
    // Reset
    esp_restart();
}

void Watchdog::emergencyReset(const String& reason) {
    LOG_ERROR_CTX("Watchdog", "🚨 EMERGENCY RESET - Razão: %s", reason.c_str());
    
    recordReset("emergency_" + reason);
    
    // Executar callback
    if (resetCallback) {
        resetCallback("emergency_" + reason);
    }
    
    // Shutdown imediato
    safeShutdown();
    
    delay(1000);
    esp_restart();
}

void Watchdog::safeShutdown() {
    LOG_WARN_CTX("Watchdog", "Executando safe shutdown...");
    
    // Desligar todos os relés
    if (relayController.isInitialized()) {
        relayController.emergencyStop();
    }
    
    // Desabilitar watchdog para evitar reset durante shutdown
    disable();
    
    LOG_INFO_CTX("Watchdog", "Safe shutdown concluído");
}

void Watchdog::recordReset(const String& reason) {
    lastResetTime = millis();
    
    LOG_WARN_CTX("Watchdog", "Reset registrado - Razão: %s, Reset #%d", 
                 reason.c_str(), consecutiveResets + 1);
    
    // TODO: Salvar no NVS para persistir através de resets
}

int Watchdog::findTaskIndex(const String& taskName) {
    for (int i = 0; i < MAX_TASKS; i++) {
        if (tasks[i].active && tasks[i].name == taskName) {
            return i;
        }
    }
    return -1;
}

void Watchdog::cleanupExpiredTasks() {
    // TODO: Implementar limpeza de tasks expiradas se necessário
}

void Watchdog::setTimeout(unsigned long timeoutSeconds) {
    timeout_ms = timeoutSeconds * 1000;
    
    if (initialized) {
        // Reconfigurar ESP32 Task Watchdog
        esp_task_wdt_deinit();
        esp_task_wdt_init(timeoutSeconds, true);
        esp_task_wdt_add(NULL);
    }
    
    LOG_INFO_CTX("Watchdog", "Timeout alterado para %lu segundos", timeoutSeconds);
}

String Watchdog::getStatusJSON() {
    JsonDocument doc;
    
    doc["initialized"] = initialized;
    doc["enabled"] = enabled;
    doc["timeout_ms"] = timeout_ms;
    doc["feed_count"] = feedCount;
    doc["timeout_count"] = timeoutCount;
    doc["consecutive_resets"] = consecutiveResets;
    doc["last_reset_time"] = lastResetTime;
    doc["time_since_last_feed"] = getTimeSinceLastFeed();
    doc["auto_recovery_enabled"] = autoRecoveryEnabled;
    doc["active_tasks"] = taskCount;
    
    String status;
    serializeJson(doc, status);
    return status;
}

String Watchdog::getTasksStatusJSON() {
    JsonDocument doc;
    
    JsonArray tasksArray = doc["tasks"].to<JsonArray>();
    
    unsigned long now = millis();
    
    for (int i = 0; i < MAX_TASKS; i++) {
        if (!tasks[i].active) continue;
        
        JsonObject task = tasksArray.add<JsonObject>();
        task["name"] = tasks[i].name;
        task["timeout_ms"] = tasks[i].timeout;
        task["last_activity"] = tasks[i].lastActivity;
        task["time_since_activity"] = now - tasks[i].lastActivity;
        task["healthy"] = (now - tasks[i].lastActivity) <= tasks[i].timeout;
    }
    
    doc["total_tasks"] = taskCount;
    doc["timestamp"] = now;
    
    String tasksStatus;
    serializeJson(doc, tasksStatus);
    return tasksStatus;
}

void Watchdog::printStatus() {
    LOG_INFO_CTX("Watchdog", "=== STATUS DO WATCHDOG ===");
    LOG_INFO_CTX("Watchdog", "Inicializado: %s", initialized ? "SIM" : "NÃO");
    LOG_INFO_CTX("Watchdog", "Habilitado: %s", enabled ? "SIM" : "NÃO");
    LOG_INFO_CTX("Watchdog", "Timeout: %lu ms", timeout_ms);
    LOG_INFO_CTX("Watchdog", "Feeds: %lu", feedCount);
    LOG_INFO_CTX("Watchdog", "Timeouts: %lu", timeoutCount);
    LOG_INFO_CTX("Watchdog", "Resets consecutivos: %d", consecutiveResets);
    LOG_INFO_CTX("Watchdog", "Tempo desde último feed: %lu ms", getTimeSinceLastFeed());
    LOG_INFO_CTX("Watchdog", "Auto-recovery: %s", autoRecoveryEnabled ? "SIM" : "NÃO");
    LOG_INFO_CTX("Watchdog", "Tasks ativas: %d/%d", taskCount, MAX_TASKS);
    
    if (taskCount > 0) {
        LOG_INFO_CTX("Watchdog", "--- Tasks Monitoradas ---");
        unsigned long now = millis();
        
        for (int i = 0; i < MAX_TASKS; i++) {
            if (!tasks[i].active) continue;
            
            unsigned long timeSinceActivity = now - tasks[i].lastActivity;
            bool healthy = timeSinceActivity <= tasks[i].timeout;
            
            LOG_INFO_CTX("Watchdog", "  %s: %s (%lu ms ago, timeout: %lu ms)", 
                         tasks[i].name.c_str(),
                         healthy ? "OK" : "⚠️  TIMEOUT",
                         timeSinceActivity,
                         tasks[i].timeout);
        }
    }
    
    LOG_INFO_CTX("Watchdog", "==========================");
}

void Watchdog::setResetCallback(std::function<void(String reason)> callback) {
    resetCallback = callback;
    LOG_INFO_CTX("Watchdog", "Callback de reset configurado");
}