/**
 * AutoCore ESP32 Display - Logger
 * 
 * Sistema de logging contextualizado
 * Compatível com o padrão do firmware de relé
 */

#pragma once

#include <Arduino.h>
#include <vector>

/**
 * Níveis de log
 */
enum LogLevel {
    LOG_LEVEL_NONE = 0,
    LOG_LEVEL_ERROR = 1,
    LOG_LEVEL_WARN = 2,
    LOG_LEVEL_INFO = 3,
    LOG_LEVEL_DEBUG = 4,
    LOG_LEVEL_VERBOSE = 5
};

/**
 * Estrutura de entrada de log
 */
struct LogEntry {
    unsigned long timestamp;
    LogLevel level;
    String context;
    String message;
    
    LogEntry(LogLevel lvl, const String& ctx, const String& msg) 
        : timestamp(millis()), level(lvl), context(ctx), message(msg) {}
};

/**
 * Sistema de logging para o display
 * Suporta múltiplas saídas e buffer circular
 */
class Logger {
private:
    static LogLevel currentLevel;
    static bool initialized;
    static bool serialEnabled;
    static bool bufferEnabled;
    static std::vector<LogEntry> logBuffer;
    static size_t maxBufferSize;
    static size_t bufferIndex;
    
    // Formatação
    static String formatTimestamp(unsigned long timestamp);
    static String formatLevel(LogLevel level);
    static String formatEntry(const LogEntry& entry);
    
    // Buffer circular
    static void addToBuffer(LogLevel level, const String& context, const String& message);
    
public:
    // Inicialização
    static bool begin(LogLevel level = LOG_LEVEL_INFO, bool enableSerial = true);
    static void end();
    static bool isInitialized() { return initialized; }
    
    // Configuração
    static void setLevel(LogLevel level);
    static LogLevel getLevel() { return currentLevel; }
    static void enableSerial(bool enable);
    static void enableBuffer(bool enable, size_t maxSize = 100);
    
    // Logging principal
    static void log(LogLevel level, const char* format, ...);
    static void logWithContext(LogLevel level, const String& context, const char* format, ...);
    
    // Métodos de conveniência
    static void error(const char* format, ...);
    static void warn(const char* format, ...);
    static void info(const char* format, ...);
    static void debug(const char* format, ...);
    static void verbose(const char* format, ...);
    
    // Logging contextualizado
    static void errorCtx(const String& context, const char* format, ...);
    static void warnCtx(const String& context, const char* format, ...);
    static void infoCtx(const String& context, const char* format, ...);
    static void debugCtx(const String& context, const char* format, ...);
    static void verboseCtx(const String& context, const char* format, ...);
    
    // Sistema e memória
    static void logMemory();
    static void logSystem();
    static void logNetwork();
    
    // Buffer de logs
    static std::vector<LogEntry> getLogBuffer();
    static String getLogBufferAsString();
    static void clearBuffer();
    static size_t getBufferSize() { return logBuffer.size(); }
    
    // Utilitários
    static String levelToString(LogLevel level);
    static LogLevel stringToLevel(const String& levelStr);
    static void hexDump(const uint8_t* data, size_t length, const String& context = "");
    
    // Formatação específica
    static String formatBytes(size_t bytes);
    static String formatUptime(unsigned long milliseconds);
    
    // Debug helpers
    static void separator(const String& title = "");
    static void header(const String& title);
};

// Macros globais de logging (compatibilidade com firmware de relé)
#define LOG_ERROR(format, ...) Logger::error(format, ##__VA_ARGS__)
#define LOG_WARN(format, ...)  Logger::warn(format, ##__VA_ARGS__)
#define LOG_INFO(format, ...)  Logger::info(format, ##__VA_ARGS__)
#define LOG_DEBUG(format, ...) Logger::debug(format, ##__VA_ARGS__)
#define LOG_VERBOSE(format, ...) Logger::verbose(format, ##__VA_ARGS__)

// Macros contextualizadas
#define LOG_ERROR_CTX(ctx, format, ...) Logger::errorCtx(ctx, format, ##__VA_ARGS__)
#define LOG_WARN_CTX(ctx, format, ...)  Logger::warnCtx(ctx, format, ##__VA_ARGS__)
#define LOG_INFO_CTX(ctx, format, ...)  Logger::infoCtx(ctx, format, ##__VA_ARGS__)
#define LOG_DEBUG_CTX(ctx, format, ...) Logger::debugCtx(ctx, format, ##__VA_ARGS__)
#define LOG_VERBOSE_CTX(ctx, format, ...) Logger::verboseCtx(ctx, format, ##__VA_ARGS__)

// Macros de sistema
#define LOG_MEMORY() Logger::logMemory()
#define LOG_SYSTEM() Logger::logSystem()
#define LOG_NETWORK() Logger::logNetwork()

// Macros de debug
#define LOG_SEPARATOR(title) Logger::separator(title)
#define LOG_HEADER(title) Logger::header(title)