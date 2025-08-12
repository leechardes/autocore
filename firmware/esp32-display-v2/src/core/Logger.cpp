/**
 * @file Logger.cpp
 * @brief Implementation of logging system
 */

#include "core/Logger.h"

Logger::Logger(LogLevel level) : currentLevel(level), useSerial(true), useMQTT(false) {
    // Empty
}

void Logger::setLevel(LogLevel level) {
    currentLevel = level;
}

void Logger::enableSerial(bool enable) {
    useSerial = enable;
}

void Logger::enableMQTT(bool enable, const String& id) {
    useMQTT = enable;
    deviceId = id;
}

String Logger::levelToString(LogLevel level) {
    switch(level) {
        case LOG_DEBUG: return "DEBUG";
        case LOG_INFO: return "INFO";
        case LOG_WARNING: return "WARN";
        case LOG_ERROR: return "ERROR";
        default: return "UNKNOWN";
    }
}

String Logger::getTimestamp() {
    unsigned long ms = millis();
    unsigned long seconds = ms / 1000;
    unsigned long minutes = seconds / 60;
    unsigned long hours = minutes / 60;
    
    char timestamp[16];
    sprintf(timestamp, "%02lu:%02lu:%02lu.%03lu", 
            hours % 24, minutes % 60, seconds % 60, ms % 1000);
    
    return String(timestamp);
}

void Logger::log(LogLevel level, const String& message) {
    if (level < currentLevel) return;
    
    String logMessage = "[" + getTimestamp() + "] [" + levelToString(level) + "] " + message;
    
    if (useSerial) {
        Serial.println(logMessage);
    }
    
    if (useMQTT && deviceId.length() > 0) {
        // TODO: Send to MQTT when client is available
        // This would be implemented when MQTT client is available globally
    }
}

void Logger::debug(const String& message) {
    log(LOG_DEBUG, message);
}

void Logger::info(const String& message) {
    log(LOG_INFO, message);
}

void Logger::warning(const String& message) {
    log(LOG_WARNING, message);
}

void Logger::error(const String& message) {
    log(LOG_ERROR, message);
}