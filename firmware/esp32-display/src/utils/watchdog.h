/**
 * AutoCore ESP32 Display - Watchdog
 * 
 * Sistema de watchdog para segurança e monitoramento
 * Compatível com o padrão do firmware de relé
 */

#pragma once

#include <Arduino.h>
#include <esp_task_wdt.h>
#include <map>

/**
 * Estados do watchdog
 */
enum WatchdogState {
    WDT_DISABLED = 0,
    WDT_ENABLED = 1,
    WDT_FEEDING = 2,
    WDT_WARNING = 3,
    WDT_TIMEOUT = 4
};

/**
 * Callback para reset do watchdog
 */
typedef std::function<void(String reason)> WatchdogResetCallback;

/**
 * Informações de task monitorada
 */
struct TaskInfo {
    String name;
    unsigned long lastFeed;
    unsigned long feedCount;
    unsigned long maxInterval;
    bool enabled;
    
    TaskInfo(const String& taskName, unsigned long maxInt) 
        : name(taskName), lastFeed(0), feedCount(0), maxInterval(maxInt), enabled(true) {}
};

/**
 * Sistema de watchdog para monitoramento de sistema
 * Monitora tasks críticas e sistema geral
 */
class Watchdog {
private:
    WatchdogState currentState;
    bool initialized;
    bool enabled;
    int timeoutSeconds;
    unsigned long lastFeed;
    unsigned long feedCount;
    
    // Task monitoring
    std::map<String, TaskInfo> monitoredTasks;
    unsigned long lastTaskCheck;
    static constexpr unsigned long TASK_CHECK_INTERVAL = 5000;  // 5 segundos
    
    // Callbacks
    WatchdogResetCallback resetCallback;
    
    // Configurações
    static constexpr int MIN_TIMEOUT = 5;     // 5 segundos mínimo
    static constexpr int MAX_TIMEOUT = 300;   // 5 minutos máximo
    static constexpr int DEFAULT_TIMEOUT = 30; // 30 segundos padrão
    
    // Estado interno
    bool warningIssued;
    unsigned long warningTime;
    
    // Métodos internos
    void checkTasks();
    void issueWarning(const String& reason);
    void triggerReset(const String& reason);
    
public:
    Watchdog();
    ~Watchdog();
    
    // Inicialização
    bool begin(int timeout = DEFAULT_TIMEOUT);
    bool enable();
    bool disable();
    bool isEnabled() const { return enabled; }
    bool isInitialized() const { return initialized; }
    
    // Configuração
    void setTimeout(int seconds);
    int getTimeout() const { return timeoutSeconds; }
    void setResetCallback(WatchdogResetCallback callback);
    
    // Estado
    WatchdogState getState() const { return currentState; }
    String getStateString() const;
    
    // Feeding principal
    void feed();
    unsigned long getFeedCount() const { return feedCount; }
    unsigned long getLastFeedTime() const { return lastFeed; }
    unsigned long getTimeSinceLastFeed() const { return millis() - lastFeed; }
    
    // Task monitoring
    void addTask(const String& taskName, unsigned long maxInterval = 30000);
    void removeTask(const String& taskName);
    void feedTask(const String& taskName);
    void enableTask(const String& taskName, bool enable = true);
    bool isTaskRegistered(const String& taskName);
    
    // Informações de tasks
    std::map<String, TaskInfo> getTaskInfo() const { return monitoredTasks; }
    TaskInfo* getTaskInfo(const String& taskName);
    bool isTaskHealthy(const String& taskName);
    String getUnhealthyTasks();
    
    // Verificações
    void checkTasks();
    bool checkSystemHealth();
    void update();
    
    // Reset manual
    void softReset(const String& reason = "Manual reset");
    void hardReset();
    
    // Estatísticas
    String getStats() const;
    String getTaskStats() const;
    void printStats() const;
    void printTaskStats() const;
    
    // Utilitários
    String formatInterval(unsigned long interval) const;
    static String getResetReason();
    
    // Debug
    bool debugEnabled = true;
};

// Instância global
extern Watchdog watchdog;