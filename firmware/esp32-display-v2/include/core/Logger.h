/**
 * @file Logger.h
 * @brief Sistema de logging para debug e monitoramento
 */

#ifndef LOGGER_H
#define LOGGER_H

#include <Arduino.h>

enum LogLevel {
    LOG_DEBUG = 0,
    LOG_INFO = 1,
    LOG_WARNING = 2,
    LOG_ERROR = 3
};

class Logger {
private:
    LogLevel currentLevel;
    bool useSerial;
    bool useMQTT;
    String deviceId;
    
    String levelToString(LogLevel level);
    String getTimestamp();
    
public:
    Logger(LogLevel level = LOG_INFO);
    
    void setLevel(LogLevel level);
    void enableSerial(bool enable);
    void enableMQTT(bool enable, const String& id);
    
    void debug(const String& message);
    void info(const String& message);
    void warning(const String& message);
    void error(const String& message);
    
    void log(LogLevel level, const String& message);
};

#endif // LOGGER_H