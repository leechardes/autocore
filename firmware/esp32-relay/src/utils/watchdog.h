#ifndef WATCHDOG_H
#define WATCHDOG_H

#include <Arduino.h>
#include "../config/device_config.h"

class Watchdog {
private:
    bool initialized = false;
    bool enabled = false;
    unsigned long timeout_ms;
    unsigned long lastFeed = 0;
    unsigned long feedCount = 0;
    unsigned long timeoutCount = 0;
    
    // Task watchdog para monitorar tasks específicas
    struct TaskWatch {
        String name;
        unsigned long lastActivity;
        unsigned long timeout;
        bool active;
    };
    
    static const int MAX_TASKS = 10;
    TaskWatch tasks[MAX_TASKS];
    int taskCount = 0;
    
    // Sistema de recovery
    bool autoRecoveryEnabled = true;
    int consecutiveResets = 0;
    unsigned long lastResetTime = 0;
    
public:
    Watchdog();
    ~Watchdog();
    
    // Inicialização
    bool begin(unsigned long timeoutSeconds = WATCHDOG_TIMEOUT_S);
    void end();
    bool isInitialized() { return initialized; }
    bool isEnabled() { return enabled; }
    
    // Controle do watchdog
    bool enable();
    bool disable(); 
    void feed();
    void reset();
    
    // Task monitoring
    bool addTask(const String& taskName, unsigned long timeoutMs = TASK_WATCHDOG_TIMEOUT_S * 1000);
    void removeTask(const String& taskName);
    void feedTask(const String& taskName);
    void checkTasks();
    
    // Sistema de recovery
    void setAutoRecovery(bool enabled) { autoRecoveryEnabled = enabled; }
    bool isAutoRecoveryEnabled() { return autoRecoveryEnabled; }
    void triggerRecovery(const String& reason);
    
    // Estatísticas
    unsigned long getFeedCount() { return feedCount; }
    unsigned long getTimeoutCount() { return timeoutCount; }
    int getConsecutiveResets() { return consecutiveResets; }
    unsigned long getLastResetTime() { return lastResetTime; }
    unsigned long getTimeSinceLastFeed() { return millis() - lastFeed; }
    
    // Status
    String getStatusJSON();
    String getTasksStatusJSON();
    void printStatus();
    
    // Configuração
    void setTimeout(unsigned long timeoutSeconds);
    unsigned long getTimeout() { return timeout_ms; }
    
    // Callbacks para eventos críticos
    void setResetCallback(std::function<void(String reason)> callback);
    std::function<void(String reason)> resetCallback;
    
    // Sistema de emergency
    void emergencyReset(const String& reason = "emergency");
    void safeShutdown();
    
    // Debug
    void setDebugMode(bool enabled) { debugEnabled = enabled; }
    bool debugEnabled = false;
    
private:
    // Métodos privados
    void handleTimeout();
    void recordReset(const String& reason);
    int findTaskIndex(const String& taskName);
    void cleanupExpiredTasks();
};

extern Watchdog watchdog;

#endif // WATCHDOG_H