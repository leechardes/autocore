#ifndef LOGGER_H
#define LOGGER_H

#include <Arduino.h>
#include "../config/device_config.h"

// Classe para logging com níveis e formatação
class Logger {
private:
    static log_level_t current_level;
    static bool initialized;
    static unsigned long start_time;

    // Buffer circular para logs (opcional - para web interface)
    static const int LOG_BUFFER_SIZE = 100;
    static String log_buffer[LOG_BUFFER_SIZE];
    static int log_buffer_index;
    static int log_buffer_count;

public:
    // Inicialização
    static bool begin(log_level_t level = LOG_LEVEL);
    static void setLevel(log_level_t level);
    static log_level_t getLevel();
    
    // Logging principal
    static void print(log_level_t level, const char* file, int line, const char* format, ...);
    static void println(log_level_t level, const char* message);
    
    // Métodos específicos por nível
    static void error(const char* format, ...);
    static void warn(const char* format, ...);
    static void info(const char* format, ...);
    static void debug(const char* format, ...);
    
    // Logging com contexto
    static void errorWithContext(const char* context, const char* format, ...);
    static void warnWithContext(const char* context, const char* format, ...);
    static void infoWithContext(const char* context, const char* format, ...);
    static void debugWithContext(const char* context, const char* format, ...);
    
    // Buffer management (para web interface)
    static void addToBuffer(const String& message);
    static String getBufferAsJSON();
    static void clearBuffer();
    
    // Utilitários
    static String levelToString(log_level_t level);
    static String getCurrentTimestamp();
    static void printSystemInfo();
    static void printMemoryInfo();
    
    // Debug helpers
    static void hexDump(const char* title, const uint8_t* data, size_t length);
    static void printStackTrace();
};

// Macros globais para logging (implementa automaticamente file/line)
#define logPrint(level, file, line, format, ...) Logger::print(level, file, line, format, ##__VA_ARGS__)

// Macros mais simples para uso geral
#define LOG_ERROR(format, ...)   Logger::error(format, ##__VA_ARGS__)
#define LOG_WARN(format, ...)    Logger::warn(format, ##__VA_ARGS__)
#define LOG_INFO(format, ...)    Logger::info(format, ##__VA_ARGS__)
#define LOG_DEBUG(format, ...)   Logger::debug(format, ##__VA_ARGS__)

// Macros com contexto
#define LOG_ERROR_CTX(ctx, format, ...)   Logger::errorWithContext(ctx, format, ##__VA_ARGS__)
#define LOG_WARN_CTX(ctx, format, ...)    Logger::warnWithContext(ctx, format, ##__VA_ARGS__)
#define LOG_INFO_CTX(ctx, format, ...)    Logger::infoWithContext(ctx, format, ##__VA_ARGS__)
#define LOG_DEBUG_CTX(ctx, format, ...)   Logger::debugWithContext(ctx, format, ##__VA_ARGS__)

// Macros para debug de memória
#define LOG_MEMORY() Logger::printMemoryInfo()
#define LOG_SYSTEM() Logger::printSystemInfo()

// Macro para hex dump
#define LOG_HEX_DUMP(title, data, length) Logger::hexDump(title, data, length)

#endif // LOGGER_H